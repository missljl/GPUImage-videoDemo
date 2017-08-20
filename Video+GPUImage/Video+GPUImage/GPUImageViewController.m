//
//  GPUImageViewController.m
//  Video+GPUImage
//
//  Created by 1111 on 2017/8/18.
//  Copyright © 2017年 ljl. All rights reserved.
//
//美颜效果等下继续探索，还有添加水印，视频合并，和混音等
//视频添加滤镜，美颜滤镜，视频录制完成，播放已经完成，

//添加水印
//水印其实就是一张图片，给视频加上水印，其实就是给这个视频的每一帧叠加上一张图片，而且图片的位置和大小都是固定的，这样思路就很清晰了。
/*
 因为是叠加，所以需要用到blendFilter(blendFilter有很多种，我这里就直接用了GPUImageAlphaBlendFilter，主要用来做半透明的混合的，简直是水印专用！)
 
 因为某些水印是带有动画效果的，也就是随着视频的播放，水印的位置和大小虽然不变，但是水印的图片(image)可能会改变，这是做动画效果的一种方法；另外的方法当然就是改变位置和大小了。这样的效果可以通过使用GPUImageTransformFilter来制作，通过setAffineTransform:可以改变从GPUImageTransformFilter中流出的图像数据，具体请参考coreAnimation。
 */

//视频合并
/*
 摄像头采集的数据通过GPUImageVideoCamera进入响应链，视频文件的数据通过GPUImageMovie进入响应链，在GPUImageDissolveBlenderFilter进行合并，最后把数据传给响应链的终点GPUImageView以显示到UI和GPUImageMovieWriter以写入临时文件，最后临时文件通过ALAssetsLibrary写入系统库。
 */


#import "GPUImageViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "FilterChooseView.h"

#import <AVFoundation/AVFoundation.h>
#import "GPUImageBeautifyFilter.h"
#define FilterViewHeight 95


#import "LJLGPUImageStillCamera.h"


@interface GPUImageViewController ()<LJLGPUImagestillCameraDelegate>
{
    NSString *pathToMovie;
    LJLGPUImageStillCamera *ljl;
    UIImageView *backview;



}//美白滤镜按钮
@property (nonatomic, strong) UIButton *beautifyButton;
@property(nonatomic,strong)AVPlayer *avplayer;
@property (nonatomic,retain) UIButton *movieButton;
@property(nonatomic,strong)UIImageView *imageview;

@property (nonatomic,retain) GPUImageVideoCamera *camera;
@property(nonatomic,strong)GPUImageView * filterView;
//视频写入
@property (nonatomic,retain) GPUImageMovieWriter *writer;
@property (nonatomic,retain) GPUImageOutput<GPUImageInput> *filter;

//视频添加水印
@property(nonatomic,strong) GPUImageUIElement *uienlement;
@property(nonatomic,strong)GPUImageBrightnessFilter *brightfilter;
@property(nonatomic,strong) GPUImageAlphaBlendFilter *blendfliter;
@end

@implementation GPUImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    NSArray *ar = @[@"拍照",@"图库",@"摄像"];
    for (int i=0; i<ar.count; i++) {
        
        UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0+(110*i), self.view.frame.size.height-100, 100, 30)];
        [btn setTitle:ar[i] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        btn.tag = 1000+i;
        
        [btn addTarget:self action:@selector(phtobtn:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:btn];
        
    }
    [self.view addSubview:self.imageview];
    
    
}
-(UIImageView*)imageview{
    
    if (!_imageview) {
        
        _imageview = [[UIImageView alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64-100)];
        _imageview.backgroundColor = [UIColor blueColor];
        
    }
    
    return _imageview;
    
}
-(void)phtobtn:(UIButton *)btn{
    
    switch (btn.tag) {
        case 1000:{

            NSLog(@"拍照");
           ljl = [[LJLGPUImageStillCamera alloc]initWithFrame:self.view.bounds cameraPosition:AVCaptureDevicePositionFront];
            
            
            ljl.delegate = self;
//            [self.view addSubview:ljl];
            UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0+(110), self.view.frame.size.height-100, 100, 30)];
            [btn setTitle:@"快门"forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
//            btn.tag = 1000+i;
            
            [btn addTarget:self action:@selector(phtobtn1) forControlEvents:UIControlEventTouchUpInside];
            
            
            backview = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 150, 100)];
            backview.backgroundColor = [UIColor redColor];
//            NSLog(@"dddddddddddddd");
            [ljl addSubview:backview];

            
            
            [ljl addSubview:btn];
            [ljl addSubview:backview];
            [self.view addSubview:ljl];

        }
            break;
        case 1001:{
            NSLog(@"图库");

        }
            break;
        case 1002:{
            NSLog(@"摄像");
            [self reconding];

            
        }
            break;
            
        default:
            break;
    }
    
    
    
    
}
-(void)phtobtn1{


    [ljl ClickOnShutter];

}
-(void)SavePictureCallback:(NSData *)image{
    

    
    backview.image=[UIImage imageWithData:image];

    
}

-(void)reconding{

    //相机
    self.camera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1280x720 cameraPosition:AVCaptureDevicePositionFront];
    //输出图像旋转
    self.camera.outputImageOrientation = UIInterfaceOrientationPortrait;
    self.camera.horizontallyMirrorFrontFacingCamera = NO;
    self.camera.horizontallyMirrorRearFacingCamera = NO;
     _filterView = [[GPUImageView alloc] initWithFrame:self.view.bounds];
    //该句可防治允许声音通过的情况下，避免录制第一帧黑屏和闪屏
    [_camera addAudioInputsAndOutputs];
    
         _filter = [[GPUImageFilter alloc]init];
        //滤镜二
//        GPUImageLuminanceRangeFilter *filter1 = [[GPUImageLuminanceRangeFilter alloc]init];
//    显示view
    
//    组合
        [self.camera addTarget:_filter];
//        [_filter addTarget:filter1];
        [_filter addTarget:_filterView];
    [self.view addSubview:_filterView];
    //相机开始运行
    [self.camera startCameraCapture];
    FilterChooseView * chooseView = [[FilterChooseView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-FilterViewHeight-60, self.view.frame.size.width, FilterViewHeight)];
    chooseView.backback = ^(GPUImageOutput<GPUImageInput> * filter){
        [self choose_callBack:filter];
    };
    [_filterView addSubview:chooseView];
    
    
    
    self.movieButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.movieButton setFrame:CGRectMake(0, 0, self.view.frame.size.width/3, 40)];
    self.movieButton.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height-30);
    self.movieButton.layer.borderWidth  = 2;
    self.movieButton.layer.borderColor = [UIColor whiteColor].CGColor;
    [self.movieButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.movieButton setTitle:@"录制" forState:UIControlStateNormal];
    [self.movieButton setTitle:@"完成" forState:UIControlStateSelected];
    [self.movieButton addTarget:self action:@selector(start_stop) forControlEvents:UIControlEventTouchUpInside];
    [_filterView addSubview:self.movieButton];
    
    self.beautifyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.beautifyButton.frame = CGRectMake(0, self.movieButton.frame.origin.y, 100, 40);
    self.beautifyButton.backgroundColor = [UIColor whiteColor];
    [self.beautifyButton setTitle:@"开启美颜" forState:UIControlStateNormal];
    [self.beautifyButton setTitle:@"关闭美颜" forState:UIControlStateSelected];
    [self.beautifyButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.beautifyButton addTarget:self action:@selector(beautify) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.beautifyButton];


    
    UIButton *Lvbtn = [[UIButton alloc]initWithFrame:CGRectMake(self.filterView.frame.size.width-100, self.movieButton.frame.origin.y, 100, 40)];
    [Lvbtn setTitle:@"添加水印" forState:UIControlStateNormal];
    [Lvbtn setTitle:@"关闭水印" forState:UIControlStateSelected];
    Lvbtn.layer.borderWidth  = 2;
    Lvbtn.layer.borderColor = [UIColor whiteColor].CGColor;
    [Lvbtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [Lvbtn addTarget:self action:@selector(lvbtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:Lvbtn];
    
    
    

}
#pragma mark 选择滤镜
-(void)choose_callBack:(GPUImageOutput<GPUImageInput> *)filter
{
    BOOL isSelected = self.movieButton.isSelected;
    if (isSelected) {
        return;
    }
    
//    GPUImageBeautifyFilter *beautifyFilter = [[GPUImageBeautifyFilter alloc] init];
//    [self.camera removeAllTargets];
//    
//    self.filter = beautifyFilter;
//    [self.camera addTarget:_filter];
//    [_filter addTarget:_filterView];
    
    
    
    self.filter = filter;
    [self.camera removeAllTargets];
    [self.camera addTarget:_filter];
    [_filter addTarget:_filterView];
}

- (void)start_stop
{
    BOOL isSelected = self.movieButton.isSelected;
    [self.movieButton setSelected:!isSelected];
    if (isSelected) {
        //结束录制
        [self.filter removeTarget:self.writer];
        self.camera.audioEncodingTarget = nil;
        //完成写入
        [self.writer finishRecording];
        NSLog(@"1保存");
        UIAlertView * alertview = [[UIAlertView alloc] initWithTitle:@"是否保存到相册" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"保存", nil];
        [alertview show];
    }else{
        NSLog(@"2录制");
        NSString *fileName = [@"Documents/" stringByAppendingFormat:@"Movie%d.m4v",(int)[[NSDate date] timeIntervalSince1970]];
        pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:fileName];
        
        NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
        //录制视频文件初始化
        self.writer = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(480.0, 640.0)];
        [self.filter addTarget:self.writer];
        self.camera.audioEncodingTarget = self.writer;
        //开始录制
        [self.writer startRecording];
        
    }
}
-(void)lvbtn:(UIButton *)btn{

    if (btn.selected ==YES) {
        
        btn.selected = NO;
        NSLog(@"dd去除水印逻辑");
    }else{
        btn.selected = YES;
        self.filter = [[GPUImageDissolveBlendFilter alloc] init];
        [(GPUImageDissolveBlendFilter *) _filter setMix:0.5];;
  
//        //滤镜
//         = [[GPUImageDissolveBlendFilter alloc] init];
//        [(GPUImageDissolveBlendFilter *) _filter setMix:0.5];
        
#pragma 第二种添加水印方法（视频实时录制添加水印）
        
        
        GPUImageFilter *file1 = [[GPUImageFilter alloc]init];
        
//        _filterView = [[GPUImageView alloc] initWithFrame:self.view.bounds];
        
        UIView *wiv = [[UIView alloc]initWithFrame:_filterView.frame];
        wiv.backgroundColor = [UIColor clearColor];
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 22, 100, 30)];
        
        label.text = @"我是水印";
        label.font  = [UIFont systemFontOfSize:15];
        label.backgroundColor = [UIColor whiteColor];
        label.textColor = [UIColor redColor];
        label.hidden = NO;
        [wiv addSubview:label];
        
        
        _uienlement = [[GPUImageUIElement alloc]initWithView:wiv];
        
        
        __weak typeof (self) weakSelf = self;
        [file1 setFrameProcessingCompletionBlock:^(GPUImageOutput *output,CMTime time){
            
            
            label.layer.transform = CATransform3DRotate(label.layer.transform, M_PI/100, 0, 0 , 1);
            [weakSelf.uienlement updateWithTimestamp:time];
        }];
        
        [self.camera removeAllTargets];

        
        [self.camera addTarget:file1];
        [file1 addTarget:_filter];
        [_uienlement addTarget:_filter];
        [_filter addTarget:_filterView];
//        [self.view addSubview:self.filterView];
        
        
#pragma 这下面方法是不添加水印是用
        
        //  //    _filter = [[GPUImageMultiplyBlendFilter alloc]init];
        //    //滤镜二
        //    GPUImageLuminanceRangeFilter *filter1 = [[GPUImageLuminanceRangeFilter alloc]init];
        //显示view
        
        //组合
        //    [self.camera addTarget:_filter];
        //    [_filter addTarget:filter1];
        //    [_filter addTarget:_filterView];
        
#pragma 这方法是图片水印，由于是全图的适合图片
        /*
         增加水印
         有好多种方法
         这是第一种
         第二种
         GPUImageUIElement
         */
        //这种适合给图片添加水印，因为是全屏的不适合视频
        //    _puict = [[GPUImagePicture alloc]initWithImage:[UIImage imageNamed:@"IMG_0875.JPG"]];
        //    [self.camera addTarget:_filter];
        //    [_puict addTarget:_filter];
        //    [_filter addTarget:_filterView];
        //    [_puict processImage];
        

        
        NSLog(@"pp添加水印逻辑");
    
    
    
    }






}




//美颜点击事件
- (void)beautify {
    if (self.beautifyButton.selected) {
        [self.camera removeAllTargets];
        [self.camera addTarget:_filter];
        [_filter addTarget:_filterView];
        self.beautifyButton.selected = NO;
//        [self.camera removeAllTargets];
//        [self.camera addTarget:self.filterView];
    }
    else {
     
        self.beautifyButton.selected = YES;
          GPUImageBeautifyFilter *beautifyFilter = [[GPUImageBeautifyFilter alloc] init];
        [self.camera removeAllTargets];
   
        self.filter = beautifyFilter;
        [self.camera addTarget:_filter];
        [_filter addTarget:_filterView];

    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        NSLog(@"3保存成功");
        [self save_to_photosAlbum:pathToMovie];
    }
}
-(void)save_to_photosAlbum:(NSString *)path
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(path)) {
            
            UISaveVideoAtPathToSavedPhotosAlbum(path, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
        }
    });
}
// 视频保存回调
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo: (void *)contextInfo {
    if (error) {
        NSLog(@"保存视频过程中发生错误，错误信息:%@",error.localizedDescription);
    }else{
        
        //录制完之后自动播放
        NSURL *url=[NSURL fileURLWithPath:videoPath];
        _avplayer=[AVPlayer playerWithURL:url];
        AVPlayerLayer *playerLayer=[AVPlayerLayer playerLayerWithPlayer:_avplayer];
        playerLayer.frame = CGRectMake(self.view.frame.size.width-150,22, 150,100);
        playerLayer.videoGravity = AVLayerVideoGravityResize;
        [self.filterView.layer addSublayer:playerLayer];
        [_avplayer play];

        NSLog(@"视频保存成功%@",videoPath);
//        [MBProgressHUD showSuccess:@"视频保存成功"];
        
    }
    
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
