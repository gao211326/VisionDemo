//
//  GLDiscernPointModel.h
//  VisionDemo
//
//  Created by 高磊 on 2017/10/11.
//  Copyright © 2017年 高磊. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GLDiscernPointModel : NSObject

//面部识别坐标
@property (nonatomic,strong) NSMutableArray *faceRectPoints;

//面部所有特征坐标
@property (nonatomic,strong) NSMutableArray *faceLandMarkPoints;
//面部轮廓
@property (nonatomic,strong) NSMutableArray *faceContourPoints;
//左眼
@property (nonatomic,strong) NSMutableArray *leftEyePoints;
//右眼
@property (nonatomic,strong) NSMutableArray *rightEyePoints;
//左眉毛
@property (nonatomic,strong) NSMutableArray *leftEyebrowPoints;
//右眉毛
@property (nonatomic,strong) NSMutableArray *rightEyebrowPoints;
//鼻子
@property (nonatomic,strong) NSMutableArray *nosePoints;
//鼻子顶
@property (nonatomic,strong) NSMutableArray *noseCrestPoints;
//鼻子中线
@property (nonatomic,strong) NSMutableArray *medianLinePoints;
//外唇
@property (nonatomic,strong) NSMutableArray *outerLipsPoints;
//内唇
@property (nonatomic,strong) NSMutableArray *innerLipsPoints;
//左瞳
@property (nonatomic,strong) NSMutableArray *leftPupilPoints;
//右瞳
@property (nonatomic,strong) NSMutableArray *rightPupilPoints;


@end
