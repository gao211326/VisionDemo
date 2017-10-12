//
//  GLDiscernPointModel.m
//  VisionDemo
//
//  Created by 高磊 on 2017/10/11.
//  Copyright © 2017年 高磊. All rights reserved.
//

#import "GLDiscernPointModel.h"

@implementation GLDiscernPointModel
- (NSMutableArray *)faceRectPoints
{
    if (nil == _faceRectPoints)
    {
        _faceRectPoints = [[NSMutableArray alloc] init];
    }
    return _faceRectPoints;
}

- (NSMutableArray *)faceLandMarkPoints
{
    if (nil == _faceLandMarkPoints)
    {
        _faceLandMarkPoints = [[NSMutableArray alloc] init];
    }
    return _faceLandMarkPoints;
}

- (NSMutableArray *)faceContourPoints
{
    if (nil == _faceContourPoints)
    {
        _faceContourPoints = [[NSMutableArray alloc] init];
    }
    return _faceContourPoints;
}

- (NSMutableArray *)leftEyePoints
{
    if (nil == _leftEyePoints)
    {
        _leftEyePoints = [[NSMutableArray alloc] init];
    }
    return _leftEyePoints;
}

- (NSMutableArray *)rightEyePoints
{
    if (nil == _rightEyePoints)
    {
        _rightEyePoints = [[NSMutableArray alloc] init];
    }
    return _rightEyePoints;
}

- (NSMutableArray *)leftEyebrowPoints
{
    if (nil == _leftEyebrowPoints)
    {
        _leftEyebrowPoints = [[NSMutableArray alloc] init];
    }
    return _leftEyebrowPoints;
}

- (NSMutableArray *)rightEyebrowPoints
{
    if (nil == _rightEyebrowPoints)
    {
        _rightEyebrowPoints = [[NSMutableArray alloc] init];
    }
    return _rightEyebrowPoints;
}

- (NSMutableArray *)nosePoints
{
    if (nil == _nosePoints)
    {
        _nosePoints = [[NSMutableArray alloc] init];
    }
    return _nosePoints;
}

- (NSMutableArray *)noseCrestPoints
{
    if (nil == _noseCrestPoints)
    {
        _noseCrestPoints = [[NSMutableArray alloc] init];
    }
    return _noseCrestPoints;
}

- (NSMutableArray *)medianLinePoints
{
    if (nil == _medianLinePoints)
    {
        _medianLinePoints = [[NSMutableArray alloc] init];
    }
    return _medianLinePoints;
}

- (NSMutableArray *)outerLipsPoints
{
    if (nil == _outerLipsPoints)
    {
        _outerLipsPoints = [[NSMutableArray alloc] init];
    }
    return _outerLipsPoints;
}

- (NSMutableArray *)innerLipsPoints
{
    if (nil == _innerLipsPoints)
    {
        _innerLipsPoints = [[NSMutableArray alloc] init];
    }
    return _innerLipsPoints;
}

- (NSMutableArray *)leftPupilPoints
{
    if (nil == _leftPupilPoints)
    {
        _leftPupilPoints = [[NSMutableArray alloc] init];
    }
    return _leftPupilPoints;
}

- (NSMutableArray *)rightPupilPoints
{
    if (nil == _rightPupilPoints)
    {
        _rightPupilPoints = [[NSMutableArray alloc] init];
    }
    return _rightPupilPoints;
}
@end
