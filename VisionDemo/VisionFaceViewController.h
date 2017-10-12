//
//  VisionCheckViewController.h
//  VisionDemo
//
//  Created by 高磊 on 2017/9/27.
//  Copyright © 2017年 高磊. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Vision/Vision.h>
#import "GLTools.h"

@interface VisionFaceViewController : UIViewController

- (id)initWithImage:(UIImage *)image discernType:(GLDiscernType)type;

@end
