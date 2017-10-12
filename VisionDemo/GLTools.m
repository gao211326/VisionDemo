//
//  GLTools.m
//  VisionDemo
//
//  Created by 高磊 on 2017/9/30.
//  Copyright © 2017年 高磊. All rights reserved.
//

#import "GLTools.h"
#import "GLDiscernPointModel.h"

#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>

#import <objc/runtime.h>

#import <Vision/Vision.h>

@implementation GLTools

SYNTHESIZE_SINGLETON_FOR_CLASS(GLTools)

- (void)glDiscernWithImageType:(GLDiscernType)type image:(UIImage *)image complete:(discernResultBlock)complete
{
    __block NSError *error;
    // 创建处理requestHandler
    VNImageRequestHandler *handler = [[VNImageRequestHandler alloc] initWithCIImage:[[CIImage alloc] initWithImage:image] options:@{}];
    
    VNRequestCompletionHandler completionHandler = ^(VNRequest *request, NSError * _Nullable error){
        NSArray *observations = request.results;
        GLDiscernPointModel *pointModel = [self glHandlerImageWithType:type image:image observations:observations];
        complete(pointModel);
    };
    
    VNImageBasedRequest *requset = [[VNImageBasedRequest alloc] init];
    
    switch (type) {
        case GLDiscernFaceRectType:
        {
            requset = [[VNDetectFaceRectanglesRequest alloc] initWithCompletionHandler:completionHandler];
        }
            break;
        case GLDiscernFaceLandmarkType:
        {
            requset = [[VNDetectFaceLandmarksRequest alloc] initWithCompletionHandler:completionHandler];
        }
            break;
        default:
            break;
    }
    
    requset.preferBackgroundProcessing = YES;
    // 发送识别请求 在后台执行 在更新UI的时候记得切换到主线程
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [handler performRequests:@[requset] error:&error];
    });
    
    if (error) {
        NSLog(@"%@",error.localizedDescription);
    }
}

- (GLDiscernPointModel *)glHandlerImageWithType:(GLDiscernType)type image:(UIImage *)image observations:(NSArray *)observations
{
    GLDiscernPointModel *pointModel = nil;
    switch (type) {
        case GLDiscernFaceRectType:
        {
            pointModel = [self handlerFaceRect:observations image:image];
        }
            break;
        case GLDiscernFaceLandmarkType:
        {
            pointModel = [self handlerFaceLandMark:observations image:image];
        }
            break;
        default:
            break;
    }
    
    return pointModel;
}

- (GLDiscernPointModel *)handlerFaceRect:(NSArray *)observations image:(UIImage *)image
{
    GLDiscernPointModel *pointModel = [[GLDiscernPointModel alloc] init];
    NSMutableArray *rects = @[].mutableCopy;
    for (VNFaceObservation *faceObservation in observations) {
        //boundingBox
        CGRect transFrame = [self convertRect:faceObservation.boundingBox imageSize:image.size];
        [rects addObject:[NSValue valueWithCGRect:transFrame]];
    }
    pointModel.faceRectPoints = rects;
    return pointModel;
}

- (GLDiscernPointModel *)handlerFaceLandMark:(NSArray *)observations image:(UIImage *)image
{
    GLDiscernPointModel *pointModel = [[GLDiscernPointModel alloc] init];
    NSMutableArray *rects = @[].mutableCopy;

    for (VNFaceObservation *faceObservation in observations) {
        
        VNFaceLandmarks2D *faceLandMarks2D = faceObservation.landmarks;
        
        [self getKeysWithClass:[VNFaceLandmarks2D class] block:^(NSString *key) {
            if ([key isEqualToString:@"allPoints"]) {
                return ;
            }
            VNFaceLandmarkRegion2D *faceLandMarkRegion2D = [faceLandMarks2D valueForKey:key];
            
            NSMutableArray *sPoints = [[NSMutableArray alloc] initWithCapacity:faceLandMarkRegion2D.pointCount];
            
            for (int i = 0; i < faceLandMarkRegion2D.pointCount; i ++) {
                CGPoint point = faceLandMarkRegion2D.normalizedPoints[i];
                
                CGFloat rectWidth = image.size.width * faceObservation.boundingBox.size.width;
                CGFloat rectHeight = image.size.height * faceObservation.boundingBox.size.height;
                CGPoint p = CGPointMake(point.x * rectWidth + faceObservation.boundingBox.origin.x * image.size.width, faceObservation.boundingBox.origin.y * image.size.height + point.y * rectHeight);
                [sPoints addObject:[NSValue valueWithCGPoint:p]];
            }
            
            [rects addObject:sPoints];
        }];
    }
    
    pointModel.faceLandMarkPoints = rects;
    return pointModel;
}

#pragma mark camera utility
- (BOOL)isCamer
{
    BOOL camer = NO;
    
    __block BOOL blockCamer = camer;
    
    if(([[[UIDevice currentDevice] systemVersion] floatValue]>=7.0)){
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if(authStatus == AVAuthorizationStatusAuthorized){
            camer=YES;
        }else if(authStatus==AVAuthorizationStatusNotDetermined){
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted)
             {
                 blockCamer = granted;
                 
             }];
        }else{
            camer = NO;
        }
    }
    else{
        camer = YES;
    }
    return camer;
}

- (BOOL)isCameraAvailable{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL)isRearCameraAvailable{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

- (BOOL)isFrontCameraAvailable {
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

- (BOOL)doesCameraSupportTakingPhotos {
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeImage
                          sourceType:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL)isPhotoLibraryAvailable{
    return [UIImagePickerController isSourceTypeAvailable:
            UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL)canUserPickVideosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeMovie
            sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL)canUserPickPhotosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeImage
            sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (BOOL)cameraSupportsMedia:(NSString *)paramMediaType
                  sourceType:(UIImagePickerControllerSourceType)paramSourceType{
    __block BOOL result = NO;
    if ([paramMediaType length] == 0) {
        return NO;
    }
    NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:paramSourceType];
    [availableMediaTypes enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *mediaType = (NSString *)obj;
        if ([mediaType isEqualToString:paramMediaType]){
            result = YES;
            *stop= YES;
        }
    }];
    return result;
}

// 转换Rect
- (CGRect)convertRect:(CGRect)boundingBox imageSize:(CGSize)imageSize{
    CGFloat w = boundingBox.size.width * imageSize.width;
    CGFloat h = boundingBox.size.height * imageSize.height;
    CGFloat x = boundingBox.origin.x * imageSize.width;
    CGFloat y = imageSize.height * (1 - boundingBox.origin.y - boundingBox.size.height);//- (boundingBox.origin.y * imageSize.height) - h;
    return CGRectMake(x, y, w, h);
}

- (NSArray *)getKeysWithClass:(Class)class block:(void(^)(NSString *key))block
{
    NSMutableArray *keys = @[].mutableCopy;
    unsigned int outCount = 0;
    
    Ivar *vars = NULL;
    objc_property_t *propertys = NULL;
    const char *name;
    
    propertys = class_copyPropertyList(class, &outCount);
    
    for (int i = 0; i < outCount; i ++) {
        objc_property_t property = propertys[i];
        name = property_getName(property);
        
        NSString *key = [NSString stringWithUTF8String:name];
        [keys addObject:key];
        block(key);
    }
    free(vars);
    return keys.copy;
}

@end
