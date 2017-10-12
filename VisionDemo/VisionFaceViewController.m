//
//  VisionCheckViewController.m
//  VisionDemo
//
//  Created by 高磊 on 2017/9/27.
//  Copyright © 2017年 高磊. All rights reserved.
//

#import "VisionFaceViewController.h"

#import "GLTools.h"
#import "GLDiscernPointModel.h"
#import "UIImage+GLProcessing.h"

@interface VisionFaceViewController ()

@property (strong, nonatomic) UIImageView *visionImageView;

@property (nonatomic,strong) UIImage *visonImage;

@property (nonatomic,assign) GLDiscernType discernType;
@end

@implementation VisionFaceViewController

- (id)initWithImage:(UIImage *)image discernType:(GLDiscernType)type{
    self = [super init];
    if (self) {
        self.visonImage = image;
        
        self.discernType = type;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.visionImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, KNavagationHeight + 40, self.view.frame.size.width, self.view.frame.size.width)];
    self.visionImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.visionImageView];
    
    self.visionImageView.image = self.visonImage;

    [self checkImage:self.visonImage];
}

- (void)checkImage:(UIImage *)image
{
    [[GLTools sharedInstance] glDiscernWithImageType:self.discernType image:image complete:^(GLDiscernPointModel * _Nonnull pointModel) {
        switch (self.discernType) {
            case GLDiscernFaceRectType:
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.visionImageView.image = [UIImage gl_drawImage:image withRects:pointModel.faceRectPoints];
                });
            }
                break;
            case GLDiscernFaceLandmarkType:
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.visionImageView.image = [UIImage gl_drawImage:image faceLandMarkPoints:pointModel.faceLandMarkPoints];
                });
            }
                break;
            default:
                break;
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



@end
