//
//  VisionTableViewController.m
//  VisionDemo
//
//  Created by 高磊 on 2017/9/27.
//  Copyright © 2017年 高磊. All rights reserved.
//

#import "VisionTableViewController.h"
#import "VisionFaceViewController.h"
#import "VisionCameraViewController.h"

#import "OpenCameraOrPhoto.h"
#import "UIImage+GLProcessing.h"

@interface VisionTableViewController ()

@property (nonatomic,strong) NSArray *titles;

@end

@implementation VisionTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titles = @[@"人脸识别",@"人脸面部检测",@"动态人脸添加场景",@"动态人脸识别"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.titles.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"visionCell" forIndexPath:indexPath];
    
    cell.textLabel.text = self.titles[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    
    switch (indexPath.row) {
        case 0:
        {
            __weak typeof(self)weakSelf = self;

            [OpenCameraOrPhoto showOpenCameraOrPhotoWithView:self.view withBlock:^(UIImage *image) {
                
                //图片进行旋转
                UIImage *upImage = [UIImage fixOrientationImage:image];;
                VisionFaceViewController *visionFaceVc = [[VisionFaceViewController alloc] initWithImage:upImage discernType:GLDiscernFaceRectType];
                [weakSelf.navigationController pushViewController:visionFaceVc animated:YES];
            }];

        }
            break;
        case 1:
        {
            __weak typeof(self)weakSelf = self;

            [OpenCameraOrPhoto showOpenCameraOrPhotoWithView:self.view withBlock:^(UIImage *image) {
                
                //图片进行旋转
                UIImage *upImage = [UIImage fixOrientationImage:image];;
                VisionFaceViewController *visionFaceVc = [[VisionFaceViewController alloc] initWithImage:upImage discernType:GLDiscernFaceLandmarkType];
                [weakSelf.navigationController pushViewController:visionFaceVc animated:YES];

            }];
        }
            break;
        case 2:
        {
            VisionCameraViewController *visionCameraVc = [[VisionCameraViewController alloc] initWithDiscernType:GLDiscernFaceDynamicSceneType];
            [self.navigationController pushViewController:visionCameraVc animated:YES];
        }
            break;
        case 3:
        {
            VisionCameraViewController *visionCameraVc = [[VisionCameraViewController alloc] initWithDiscernType:GLDiscernFaceRectDynamicType];
            [self.navigationController pushViewController:visionCameraVc animated:YES];
        }
            break;
        default:
            break;
    }
}




@end
