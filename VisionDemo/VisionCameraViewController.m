//
//  VisionCameraViewController.m
//  VisionDemo
//
//  Created by 高磊 on 2017/9/29.
//  Copyright © 2017年 高磊. All rights reserved.
//

#import "VisionCameraViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <Vision/Vision.h>
#import "GLDiscernPointModel.h"

@interface VisionCameraViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic,strong) AVCaptureDevice *avDevice;
@property (nonatomic,strong) AVCaptureDeviceInput *avInput;
@property (nonatomic,strong) AVCaptureVideoDataOutput *avOutput;
@property (nonatomic,strong) AVCaptureSession *avSession;
@property (nonatomic,strong) AVCaptureVideoPreviewLayer *avPreviewLayer;

@property (nonatomic,strong) UIButton *changeCameraButton;
@property (nonatomic,strong) UIButton *turnCameraButton;

//矩形框数组
@property (nonatomic,strong) NSMutableArray *rectLayers;

@property (nonatomic,strong) UIImageView *glassesImageView;

@property (nonatomic,assign) GLDiscernType discernType;

@end

@implementation VisionCameraViewController

- (void)dealloc{
    
}


- (id)initWithDiscernType:(GLDiscernType)type
{
    self = [super init];
    if (self) {
        self.discernType = type;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self checkAuthority];

    [self addControls];
    
//    UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 100, 200, 300)];
//    imageview.tag = 100;
//    [self.view addSubview:imageview];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
    [self.avSession stopRunning];
}

#pragma mark == private method
- (void)addControls
{
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(20, 30, 30, 30);
    [backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setImage:[UIImage imageNamed:@"返回"] forState:UIControlStateNormal];
    [self.view addSubview:backButton];
    
    self.turnCameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.turnCameraButton.frame = CGRectMake(self.view.frame.size.width - 50, 30, 30, 30);
    [self.turnCameraButton setImage:[UIImage imageNamed:@"turn"] forState:UIControlStateNormal];
    [self.turnCameraButton addTarget:self action:@selector(turnCamera:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.turnCameraButton];
    
    self.glassesImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.glassesImageView];
    self.glassesImageView.image = [UIImage imageNamed:@"eyes"];
}

- (void)addCapture
{
    self.avDevice = [self cameraWithPosition:AVCaptureDevicePositionBack];
    
    //添加输入
    self.avInput = [[AVCaptureDeviceInput alloc] initWithDevice:self.avDevice error:nil];
    if ([self.avSession canAddInput:self.avInput]) {
        [self.avSession addInput:self.avInput];
    }
    //添加输出
    
    self.avOutput = [[AVCaptureVideoDataOutput alloc] init];
    [self.avOutput setSampleBufferDelegate:(id)self queue:dispatch_queue_create("CameraCaptureSampleBufferDelegateQueue", NULL)];
    
    if ([self.avSession canAddOutput:self.avOutput]) {
        [self.avSession addOutput:self.avOutput];
        AVCaptureConnection *captureConnection = [self.avOutput connectionWithMediaType:AVMediaTypeVideo];
        
        if ([captureConnection isVideoOrientationSupported]) {
            [captureConnection setVideoOrientation:AVCaptureVideoOrientationPortrait];
        }
        // 视频稳定设置
        if ([captureConnection isVideoStabilizationSupported]) {
            captureConnection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
        }
        // 设置输出图片方向
        captureConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
    }
    
    //创建预览视图
    // 通过会话 (AVCaptureSession) 创建预览层
    self.avPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.avSession];
    self.avPreviewLayer.frame = self.view.bounds;
    
    //有时候需要拍摄完整屏幕大小的时候可以修改这个
    self.avPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.avPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
    
    
    // 显示在视图表面的图层
    CALayer *layer = self.view.layer;
    layer.masksToBounds = YES;
    [self.view layoutIfNeeded];
    [layer addSublayer:self.avPreviewLayer];
    
    [self.avSession commitConfiguration];
    [self.avSession startRunning];
}

//摄像头选择
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for ( AVCaptureDevice *device in devices )
        if (device.position == position ){
            return device;
        }
    return nil;
}


- (void)checkAuthority
{
    if ([[GLTools sharedInstance] isCamer])
    {
        [self addCapture];
    }
    else
    {
        UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"提示" message:@"您尚未为该APP打开”相机服务“，开启方法为“手机设置-隐私-相机服务”进行[开启]" preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            [self.navigationController popViewControllerAnimated:YES];
        }];
        [actionSheet addAction:action];
        [self presentViewController:actionSheet animated:YES completion:nil];
    }
}

#pragma mark == event response
- (void)back:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)turnCamera:(UIButton *)sender
{
    [self.rectLayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    
    NSUInteger cameraCount = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
    if (cameraCount > 1) {
        NSError *error;
        //给摄像头的切换添加翻转动画
        CATransition *animation = [CATransition animation];
        animation.duration = .5f;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        animation.type = @"oglFlip";
        
        AVCaptureDevice *newCamera = nil;
        AVCaptureDeviceInput *newInput = nil;
        //拿到另外一个摄像头位置
        AVCaptureDevicePosition position = [[self.avInput device] position];
        if (position == AVCaptureDevicePositionFront){
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
            animation.subtype = kCATransitionFromLeft;//动画翻转方向
        }
        else {
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
            animation.subtype = kCATransitionFromRight;//动画翻转方向
        }
        
        self.avDevice = newCamera;
        //生成新的输入
        newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:nil];
        [self.avPreviewLayer addAnimation:animation forKey:nil];
        if (newInput != nil) {
            [self.avSession beginConfiguration];
            [self.avSession removeInput:self.avInput];

            if ([self.avSession canAddInput:newInput]) {
                [self.avSession addInput:newInput];
                self.avInput = newInput;
            } else {
                [self.avSession addInput:self.avInput];
            }
            
            //需要重新进行配置输出 特别是下面的输出方向
            AVCaptureConnection *captureConnection = [self.avOutput connectionWithMediaType:AVMediaTypeVideo];
            if ([captureConnection isVideoOrientationSupported]) {
                [captureConnection setVideoOrientation:AVCaptureVideoOrientationPortrait];
            }
            // 视频稳定设置
            if ([captureConnection isVideoStabilizationSupported]) {
                captureConnection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
            }
            // 设置输出图片方向
            captureConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
            
            
            [self.avSession commitConfiguration];
            
        } else if (error) {
            NSLog(@"toggle carema failed, error = %@", error);
        }
    }
}


#pragma mark == AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    CVPixelBufferRef cvpixeBufferRef = CMSampleBufferGetImageBuffer(sampleBuffer);
//屏蔽掉218-229的代码 可以发现 当切换摄像头的时候  输出的图片方向变了
//    UIImage *image = [UIImage imageWithCIImage:[CIImage imageWithCVPixelBuffer:cvpixeBufferRef]];
//
//    dispatch_async(dispatch_get_main_queue(), ^{
//        UIImageView *imageview = [self.view viewWithTag:100];
//        imageview.image = image;
//    });
    
    VNImageRequestHandler *handler = [[VNImageRequestHandler alloc] initWithCVPixelBuffer:cvpixeBufferRef options:@{}];
    VNImageBasedRequest *request = [[VNImageBasedRequest alloc] init];
    switch (self.discernType) {
        case GLDiscernFaceRectDynamicType:
        {
            request = [[VNDetectFaceRectanglesRequest alloc] initWithCompletionHandler:^(VNRequest * _Nonnull request, NSError * _Nullable error) {
                
                NSLog(@" 打印信息:%lu",request.results.count);
                NSArray *vnobservations = request.results;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    //先移除之前的矩形框
                    [self.rectLayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];

                    AVCaptureDevicePosition position = [[self.avInput device] position];

                    
                    
                    for (VNFaceObservation *faceObservation in vnobservations) {
                        //boundingBox
                        CGRect transFrame = [[GLTools sharedInstance] convertRect:faceObservation.boundingBox imageSize:self.view.frame.size];
                        //前置摄像头的时候 记得转换
                        if (position == AVCaptureDevicePositionFront){
                            transFrame.origin.x = self.view.frame.size.width - transFrame.origin.x - transFrame.size.width;
                        }
                        
                        CALayer *rectLayer = [CALayer layer];
                        rectLayer.frame = transFrame;
                        rectLayer.borderColor = [UIColor purpleColor].CGColor;
                        rectLayer.borderWidth = 2;
                        [self.view.layer addSublayer:rectLayer];
                        
                        [self.rectLayers addObject:rectLayer];
                    }
                });
            }];
        }
            break;
        case GLDiscernFaceDynamicSceneType:
        {
            request = [[VNDetectFaceLandmarksRequest alloc] initWithCompletionHandler:^(VNRequest * _Nonnull request, NSError * _Nullable error) {
                NSArray *vnobservations = request.results;
                
                
                for (VNFaceObservation *faceObservation in vnobservations) {
                    
                    
                    VNFaceLandmarks2D *faceLandMarks2D = faceObservation.landmarks;
                    
                    VNFaceLandmarkRegion2D *leftEyefaceLandMarkRegion2D = faceLandMarks2D.leftEye;
                    VNFaceLandmarkRegion2D *rightEyefaceLandMarkRegion2D = faceLandMarks2D.rightEye;
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
//                        //先移除之前的矩形框
//                        [self.rectLayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
//
//                        AVCaptureDevicePosition position = [[self.avInput device] position];
//
//                        CGRect transFrame = [[GLTools sharedInstance] convertRect:faceObservation.boundingBox imageSize:self.view.frame.size];
//                        //前置摄像头的时候 记得转换
//                        if (position == AVCaptureDevicePositionFront){
//                            transFrame.origin.x = self.view.frame.size.width - transFrame.origin.x - transFrame.size.width;
//                        }
//
//                        CALayer *rectLayer = [CALayer layer];
//                        rectLayer.frame = transFrame;
//                        rectLayer.borderColor = [UIColor purpleColor].CGColor;
//                        rectLayer.borderWidth = 2;
//                        [self.view.layer addSublayer:rectLayer];
//
//                        [self.rectLayers addObject:rectLayer];
                        
                        AVCaptureDevicePosition position = [[self.avInput device] position];

                        
                        CGPoint sPoints[leftEyefaceLandMarkRegion2D.pointCount + rightEyefaceLandMarkRegion2D.pointCount];
                        
                        NSMutableArray *pointXs = [[NSMutableArray alloc] init];
                        NSMutableArray *pointYs = [[NSMutableArray alloc] init];
                        
                        for (int i = 0; i < leftEyefaceLandMarkRegion2D.pointCount; i ++) {
                            CGPoint point = leftEyefaceLandMarkRegion2D.normalizedPoints[i];
                            
                            CGFloat rectWidth = self.view.bounds.size.width * faceObservation.boundingBox.size.width;
                            CGFloat rectHeight = self.view.bounds.size.height * faceObservation.boundingBox.size.height;
                            
                            CGFloat boundingBoxY = self.view.bounds.size.height * (1 - faceObservation.boundingBox.origin.y - faceObservation.boundingBox.size.height);
                            
                            CGPoint p = CGPointZero;
                            if (position == AVCaptureDevicePositionFront){
                                
                                CGFloat boundingX = self.view.frame.size.width - faceObservation.boundingBox.origin.x * self.view.bounds.size.width - rectWidth;
                                
                                p = CGPointMake(point.x * rectWidth + boundingX, boundingBoxY + (1-point.y) * rectHeight);

                            }else{
                              p = CGPointMake(point.x * rectWidth + faceObservation.boundingBox.origin.x * self.view.bounds.size.width, boundingBoxY + (1-point.y) * rectHeight);
                            }

                            sPoints[i] = p;
                            
                            [pointXs addObject:[NSNumber numberWithFloat:p.x]];
                            [pointYs addObject:[NSNumber numberWithFloat:p.y]];
                        }
                        
                        for (int j = 0; j < rightEyefaceLandMarkRegion2D.pointCount; j ++) {
                            CGPoint point = rightEyefaceLandMarkRegion2D.normalizedPoints[j];

                            CGFloat rectWidth = self.view.bounds.size.width * faceObservation.boundingBox.size.width;
                            CGFloat rectHeight = self.view.bounds.size.height * faceObservation.boundingBox.size.height;

                            CGFloat boundingBoxY = self.view.bounds.size.height * (1 - faceObservation.boundingBox.origin.y - faceObservation.boundingBox.size.height);

                            CGPoint p = CGPointZero;
                            if (position == AVCaptureDevicePositionFront){
                                
                                CGFloat boundingX = self.view.frame.size.width - faceObservation.boundingBox.origin.x * self.view.bounds.size.width - rectWidth;
                                
                                p = CGPointMake(point.x * rectWidth + boundingX, boundingBoxY + (1-point.y) * rectHeight);
                                
                            }else{
                                p = CGPointMake(point.x * rectWidth + faceObservation.boundingBox.origin.x * self.view.bounds.size.width, boundingBoxY + (1-point.y) * rectHeight);
                            }
                            
                            sPoints[leftEyefaceLandMarkRegion2D.pointCount + j] = p;
                            
                            [pointXs addObject:[NSNumber numberWithFloat:p.x]];
                            [pointYs addObject:[NSNumber numberWithFloat:p.y]];
                        }
                        
//                        for (UIView *view in self.view.subviews) {
//                            if ([view isKindOfClass:[UIImageView class]]) {
//                                [view removeFromSuperview];
//                            }
//                        }
//
//                        for (int i = 0; i < rightEyefaceLandMarkRegion2D.pointCount + leftEyefaceLandMarkRegion2D.pointCount; i++) {
//                            CGFloat x = sPoints[i].x;
//                            CGFloat y = sPoints[i].y;
//                            UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, 2, 2)];
//                            view.backgroundColor = [UIColor redColor];
//                            [self.view addSubview:view];
//                        }
                        
                        //排序 得到最小的x和最大的x
                        NSArray *sortPointXs = [pointXs sortedArrayWithOptions:NSSortStable usingComparator:
                                                ^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                                                    int value1 = [obj1 floatValue];
                                                    int value2 = [obj2 floatValue];
                                                    if (value1 > value2) {
                                                        return NSOrderedDescending;
                                                    }else if (value1 == value2){
                                                        return NSOrderedSame;
                                                    }else{
                                                        return NSOrderedAscending;
                                                    }
                                                }];

                        NSArray *sortPointYs = [pointYs sortedArrayWithOptions:NSSortStable usingComparator:
                                                ^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                                                    int value1 = [obj1 floatValue];
                                                    int value2 = [obj2 floatValue];
                                                    if (value1 > value2) {
                                                        return NSOrderedDescending;
                                                    }else if (value1 == value2){
                                                        return NSOrderedSame;
                                                    }else{
                                                        return NSOrderedAscending;
                                                    }
                                                }];
                        
                        UIImage *image =[UIImage imageNamed:@"eyes"];
                        CGFloat imageWidth = [sortPointXs.lastObject floatValue] - [sortPointXs.firstObject floatValue] + 40;
                        CGFloat imageHeight = (imageWidth * image.size.height)/image.size.width;
                        
                        self.glassesImageView.frame = CGRectMake([sortPointXs.firstObject floatValue]-20, [sortPointYs.firstObject floatValue]-5, imageWidth, imageHeight);
                    });
                }
            }];
        }
            break;
        default:
            break;
    }
    [handler performRequests:@[request] error:NULL];
}

#pragma mark == 懒加载
- (AVCaptureSession *)avSession
{
    if (nil == _avSession) {
        _avSession = [[AVCaptureSession alloc] init];
        if ([_avSession canSetSessionPreset:AVCaptureSessionPresetHigh]) {
            [_avSession setSessionPreset:AVCaptureSessionPresetHigh];
        }
        [_avSession beginConfiguration];
    }
    return _avSession;
}

- (NSMutableArray *)rectLayers
{
    if (nil == _rectLayers) {
        _rectLayers = [[NSMutableArray alloc] init];
    }
    return _rectLayers;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
