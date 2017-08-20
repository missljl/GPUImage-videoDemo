//
//  LJLGPUImageStillCamera.h
//  Video+GPUImage
//
//  Created by 1111 on 2017/8/20.
//  Copyright © 2017年 ljl. All rights reserved.
//现场拍摄图片 ，要加入水影

#import <UIKit/UIKit.h>
#import "LJLGPUImageStillCamera.h"
#import "GPUImage.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "FilterChooseView.h"
#define FilterViewHeight 95

@protocol LJLGPUImagestillCameraDelegate <NSObject>


-(void)SavePictureCallback:(NSData *)image;


@end


@interface LJLGPUImageStillCamera : GPUImageView




@property(nonatomic,weak)id<LJLGPUImagestillCameraDelegate>delegate;
//初始化
-(instancetype)initWithFrame:(CGRect)frame cameraPosition:(AVCaptureDevicePosition )positon;
//开始捕捉
-(void)startCameraCapture;
//停止捕捉
-(void)stopCameraCapture;
//切换摄像头
-(void)rotateCamera;


-(void)ClickOnShutter;


@end
