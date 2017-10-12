//
//  GLTools.h
//  VisionDemo
//
//  Created by 高磊 on 2017/9/30.
//  Copyright © 2017年 高磊. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define KNavagationHeight  (CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(375, 812))?83:64)

//定义单例的宏
#define SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER( __CLASSNAME__)    \
\
    + ( __CLASSNAME__*) sharedInstance;    \


#define SYNTHESIZE_SINGLETON_FOR_CLASS(__CLASSNAME__)    \
\
    static __CLASSNAME__ *instance = nil;   \
\
    + (__CLASSNAME__ *)sharedInstance{ \
        static dispatch_once_t onceToken;   \
        dispatch_once(&onceToken, ^{    \
        if (nil == instance){   \
            instance = [[__CLASSNAME__ alloc] init];    \
        }   \
    }); \
\
    return instance;   \
}   \

typedef NS_ENUM(NSInteger,GLDiscernType) {
    GLDiscernFaceRectType,//人脸矩形检测
    GLDiscernFaceLandmarkType,//人脸特征识别
    GLDiscernFaceRectDynamicType,//人脸矩形动态检测
    GLDiscernFaceDynamicSceneType,//人脸动态添加场景
};


@class GLDiscernPointModel;
/**
 识别返回结果

 @param pointModel 返回结果坐标
 */
typedef void(^discernResultBlock)(GLDiscernPointModel * _Nonnull pointModel);

@interface GLTools : NSObject

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(GLTools);



/**
 识别图片

 @param type 识别类型
 @param image 图片
 @param complete 识别结果block
 */
- (void)glDiscernWithImageType:(GLDiscernType)type image:(UIImage *_Nullable)image complete:(discernResultBlock _Nullable)complete;

/**
 相机权限是否打开

 @return 返回
 */
- (BOOL)isCamer;


/**
 后置摄像头是否可用

 @return 返回
 */
- (BOOL) isRearCameraAvailable;


/**
 前置摄像头是否可用

 @return 返回
 */
- (BOOL) isFrontCameraAvailable;


/**
 设备是否支持相机

 @return 返回
 */
- (BOOL) isCameraAvailable;
/**
 设备是否支持相册

 @return 返回
 */
- (BOOL) isPhotoLibraryAvailable;


/**
 是否支持拍照

 @return 返回
 */
- (BOOL) doesCameraSupportTakingPhotos;


/**
 坐标转换

 @param boundingBox 矩形坐标
 @param imageSize 图片大小
 @return 返回
 */
- (CGRect)convertRect:(CGRect)boundingBox imageSize:(CGSize)imageSize;
@end
