//
//  AVCaptureSessionViewController.m
//  Video+GPUImage
//
//  Created by 1111 on 2017/8/18.
//  Copyright © 2017年 ljl. All rights reserved.
//

/*
 1.AVCaptureSession：媒体（音、视频）捕获会话，负责把捕获的音视频数据输出到输出设备中。
 AVCaptureDevice：输入设备，包括麦克风、摄像头，通过该对象可以设置物理设备的一些属性（例如相机聚焦、白平衡等）。
 AVCaptureDeviceInput：设备输入数据管理对象，可以根据AVCaptureDevice创建对应的AVCaptureDeviceInput对象，该对象将会被添加到AVCaptureSession中管理。
 AVCaptureOutput：输出数据管理对象，用于接收各类输出数据，通常使用对应的子类AVCaptureAudioDataOutput、AVCaptureStillImageOutput、AVCaptureVideoDataOutput、AVCaptureFileOutput，该对象将会被添加到AVCaptureSession中管理。注意：前面几个对象的输出数据都是NSData类型，而AVCaptureFileOutput代表数据以文件形式输出，类似的，AVCcaptureFileOutput也不会直接创建使用，通常会使用其子类：AVCaptureAudioFileOutput、AVCaptureMovieFileOutput。当把一个输入或者输出添加到AVCaptureSession之后AVCaptureSession就会在所有相符的输入、输出设备之间建立连接（AVCaptionConnection）：
 AVCaptureVideoPreviewLayer：相机拍摄预览图层，是CALayer的子类，使用该对象可以实时查看拍照或视频录制效果，创建该对象需要指定对应的AVCaptureSession对象。
 
 使用AVFoundation拍照和录制视频的一般步骤如下：
 
 创建AVCaptureSession对象。
 使用AVCaptureDevice的静态方法获得需要使用的设备，例如拍照和录像就需要获得摄像头设备，录音就要获得麦克风设备。
 利用输入设备AVCaptureDevice初始化AVCaptureDeviceInput对象。
 初始化输出数据管理对象，如果要拍照就初始化AVCaptureStillImageOutput对象；如果拍摄视频就初始化AVCaptureMovieFileOutput对象。
 将数据输入对象AVCaptureDeviceInput、数据输出对象AVCaptureOutput添加到媒体会话管理对象AVCaptureSession中。
 创建视频预览图层AVCaptureVideoPreviewLayer并指定媒体会话，添加图层到显示容器中，调用AVCaptureSession的startRuning方法开始捕获。
 将捕获的音频或视频数据输出到指定文件。
 
 */



//功能，拍照，录视频，录音
#import "AVCaptureSessionViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "LJLRecordEngine.h"
@interface AVCaptureSessionViewController ()<LJLRecordEngineDelegate>


@property (nonatomic, strong) LJLRecordEngine *recordEngine;
@property (nonatomic, strong) UIButton *recordButton;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UIButton *okBtn;
@property (nonatomic, strong) UIView *playerView;


@end

@implementation AVCaptureSessionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    NSArray *ar = @[@"拍照",@"摄像"];
    for (int i=0; i<ar.count; i++) {
        
        UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0+(110*i), self.view.frame.size.height-100, 100, 30)];
        [btn setTitle:ar[i] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        btn.tag = 1000+i;
        
        [btn addTarget:self action:@selector(phtobtn:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:btn];
        
    }
    
    // Do any additional setup after loading the view.
}
//懒加载录制视频类
- (LJLRecordEngine *)recordEngine {
    if (!_recordEngine) {
        _recordEngine = [[LJLRecordEngine alloc] init];
        _recordEngine.delegate = self;
    }
    return _recordEngine;
}
-(void)phtobtn:(UIButton *)btn{
    
    switch (btn.tag) {
        case 1000:{
//            [self takePhoto];
            NSLog(@"拍照");}
            break;
        case 1001:{
            NSLog(@"录象");
            [self Recording];
        }
//            [self Photos];}
            break;
        default:
            break;
    }
    
    
    
    
}
-(void)Recording{

[self configRecordEngine];

}
//呈现录制视频界面
- (void)configRecordEngine {
    if (!_recordEngine) {
        [self.recordEngine previewLayer].frame = self.view.bounds;
        [self.view.layer insertSublayer:[self.recordEngine previewLayer] atIndex:0];
    }
    //启动视频录制功能
    [self.recordEngine stratUp];
}
-(void)recordProgress:(CGFloat)progress{

    NSLog(@"%f",progress);

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
