//
//  OpenCameraOrPhoto.h
//  BaishitongClient
//
//  Created by 高磊 on 15/10/28.
//  Copyright © 2015年 高磊. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLTools.h"

typedef void(^OpenCameraOrPhotoBlock)(UIImage *image);

@interface OpenCameraOrPhoto : NSObject

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(OpenCameraOrPhoto);

+ (void)showOpenCameraOrPhotoWithView:(UIView *)view withBlock:(OpenCameraOrPhotoBlock)openCameraOrPhotoBlock;

@property (nonatomic,copy) OpenCameraOrPhotoBlock openCameraOrPhotoBlock;

@end
