//
//  LJLRecordEngine.h
//  Video+GPUImage
//
//  Created by 1111 on 2017/8/18.
//  Copyright © 2017年 ljl. All rights reserved.
//
//视频录制相关类
//对外接口
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol LJLRecordEngineDelegate <NSObject>

- (void)recordProgress:(CGFloat)progress;

@end
@interface LJLRecordEngine : NSObject
//是否正在录制
@property(nonatomic,assign,readonly) BOOL isCapturing;
//是否展厅
@property(nonatomic,assign,readonly)BOOL isPaused;

//当前录制时间
@property(nonatomic,assign,readonly) CGFloat currentRecordTime;
//最长录制时间
@property(nonatomic,assign) CGFloat maxRecordTime;
//视频路径
@property(nonatomic,copy)NSString *videPath;

@property(nonatomic,weak)id<LJLRecordEngineDelegate>delegate;
//将捕捉到的视频呈现到layer就是录制视频打开，由于它不能直接显示所以要添加到vc的view上
-(AVCaptureVideoPreviewLayer *)previewLayer;

//启动录制(还没录制，只是将视频录制呈现)
-(void)stratUp;

//开始录制
-(void)stratCapTure;
//展厅录制
-(void)pauseCapTure;


//继续录制
- (void)resumeCapture;


//停止录制
-(void)stopCapTureHandler:(void (^)(UIImage *movieImage))handler;
//关闭录制
-(void)shutdown;


/////
/**
 开启闪光灯
 */
- (void)openFlashLight;

/**
 关闭闪光灯
 */
- (void)closeFlashLight;


/**
 切换前后置摄像头
 */
- (void)changeCameraInputDeviceisFront:(BOOL)isFront;
/**
 将mov的视频转成mp4
 */
- (void)changeMovToMp4:(NSURL *)mediaURL dataBlock:(void (^)(UIImage *movieImage))handler;

@end
