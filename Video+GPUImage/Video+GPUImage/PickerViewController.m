//
//  PickerViewController.m
//  Video+GPUImage
//
//  Created by 1111 on 2017/8/18.
//  Copyright © 2017年 ljl. All rights reserved.
//

/*
 相关属性
sourceType;有3种类型（枚举）
 UIImagePickerControllerSourceTypePhotoLibrary,（相册）
 UIImagePickerControllerSourceTypeCamera,（相机）
 UIImagePickerControllerSourceTypeSavedPhotosAlbum（照片流）
 *mediaTypes（相机支持的功能，拍照或者视频）kUTTypeMovie,kUTTypeImage
 showsCameraControls用于指定拍照时下方的工具栏是否显示
allowImageEditing在iOS3.1就已废弃，取而代之的是allowEditing,表示拍完照片或者从相册选完照片后，是否跳转到编辑模式对图片裁剪，只有在showsCameraControls为YES时才有效果。
 
 cameraCaptureMode捕捉模式指定的是相机是拍摄照片还是视频（枚举）
 UIImagePickerControllerCameraCaptureModePhoto,//photo
 UIImagePickerControllerCameraCaptureModeVideo//video
 
 
 UIImagePickerControllerCameraDevice（枚举，表示摄像头的位置）
 UIImagePickerControllerCameraDeviceRear,
 UIImagePickerControllerCameraDeviceFront
 
 
 cameraFlashMode用于指定闪光灯模式，它的枚举类型如下:
 UIImagePickerControllerCameraFlashModeOff  = -1,
 UIImagePickerControllerCameraFlashModeAuto = 0,
 UIImagePickerControllerCameraFlashModeOn   = 1
 
videoMaximumDuration用于设置视频拍摄模式下最大拍摄时长，默认值是10分钟。 
 
 
 
videoQuality表示拍摄的视频质量设置，默认是Medium即表示中等质量。 videoQuality支持的枚举类型如下:
 UIImagePickerControllerQualityTypeHigh = 0,       // 高清模式
 UIImagePickerControllerQualityTypeMedium = 1,     //中等质量，适于WIFI传播
 UIImagePickerControllerQualityTypeLow = 2,         //低等质量，适于蜂窝网络传输
 UIImagePickerControllerQualityType640x480 NS_ENUM_AVAILABLE_IOS(4_0) = 3,    // VGA 质量
 UIImagePickerControllerQualityTypeIFrame1280x720 NS_ENUM_AVAILABLE_IOS(5_0) = 4,//1280*720的分辨率
 UIImagePickerControllerQualityTypeIFrame960x540 NS_ENUM_AVAILABLE_IOS(5_0) = 5,//960*540分辨率
 
类方法
 isSourceTypeAvailable用于判断当前设备是否支持指定的sourceType，可以是照片库/相册/相机.
 isCameraDeviceAvailable判断当前设备是否支持前置摄像头或者后置摄像头
 isFlashAvailableForCameraDevice是否支持前置摄像头闪光灯或者后置摄像头闪光灯
 availableMediaTypesForSourceType方法返回所特定的媒体如相册/图片库/相机所支持的媒体类型数组,元素值可以是kUTTypeImage类型或者kUTTypeMovie类型的静态字符串，所以是NSString类型的数组
 availableCaptureModesForCameraDevice返回特定的摄像头(前置摄像头/后置摄像头)所支持的拍摄模式数值数组，元素值可以是UIImagePickerControllerCameraCaptureMode枚举里面的video或者photo,所以是NSNumber类型的数组
对象方法
 - (void)takePicture NS_AVAILABLE_IOS(3_1);
 - (BOOL)startVideoCapture NS_AVAILABLE_IOS(4_0);
 - (void)stopVideoCapture  NS_AVAILABLE_IOS(4_0);
 takePicture可以用来实现照片的连续拍摄，需要自己自定义拍摄的背景视图来赋值给cameraOverlayView ，结合自定义overlayView实现多张照片的采集，在收到代理的didFinishPickingMediaWithInfo方法之后可以启动额外的捕捉。
 startVideoCapture用来判断当前是否可以开始录制视频，当视频正在拍摄中，设备不支持视频拍摄，磁盘空间不足等情况，该方法会返回NO.该方法结合自定义overlayView可以拍摄多部视频
 stopVideoCapture当你调用此方法停止视频拍摄时，它会调用代理的imagePickerController：didFinishPickingMediaWithInfo：方法
 
 
 
 */



#import "PickerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface PickerViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property(nonatomic,strong)UIImageView *imageview;
@property(nonatomic,strong)AVPlayer *avplayer;
@end

@implementation PickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    // 这段代码会自动判断当前设备是否有摄像机功能，如果没有，会弹窗提示
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
//        UIAlertController *myAlertView = [[UIAlertController alertControllerWithTitle:@"提示" message:@"摄像头没打开" preferredStyle:UIAlertControllerStyleActionSheet];
//        
//        [myAlertView show];
        
    }
    
    
    
    
    
    
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
    
    
    
    // Do any additional setup after loading the view.
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
            [self takePhoto];
            NSLog(@"拍照");}
            break;
        case 1001:{
            NSLog(@"图库");
            [self Photos];}
            break;
        case 1002:{
            NSLog(@"摄像");
            [self Recording];
            //            [self Photos];
        
        }
            break;

        default:
            break;
    }




}
//拍照
-(void)takePhoto{

    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    
    picker.delegate = self;
    
    picker.allowsEditing = YES;
    
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
//    picker.mediaTypes =
//    picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
    [self presentViewController:picker animated:YES completion:nil];


}
//图库
-(void)Photos{
    // 创建UIImagePickerController控制器对象
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:nil];




}
//摄像
-(void)Recording{


    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
   picker.delegate = self;
  picker.allowsEditing = YES;
    //来源为摄像头
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    //设置使用的摄像头：后知
    picker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    picker.mediaTypes = @[(NSString *)kUTTypeMovie];
    //设置视频质量
    picker.videoQuality = UIImagePickerControllerQualityTypeHigh;
    //设置摄像头为录制视频
    picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
    
    [self presentViewController:picker animated:YES completion:nil];

    
    
    

}




#pragma 代理方法
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    if ([type isEqualToString:(NSString *) kUTTypeMovie]) {
        NSURL *url = [info objectForKey:UIImagePickerControllerMediaURL];
        NSString *urlPath = [url path];
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(urlPath)) {
            UISaveVideoAtPathToSavedPhotosAlbum(urlPath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
        }
       NSLog(@"保存视频");
        
    }else{
    
    UIImage* chosenImage = info[UIImagePickerControllerEditedImage];
    self.imageview.image = chosenImage;
    //当image从相机中获取的时候存入相册中
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        UIImageWriteToSavedPhotosAlbum(chosenImage,self,@selector(image:didFinishSavingWithError:contextInfo:),NULL);
    }
    }
      [picker dismissViewControllerAnimated:YES completion:nil];
}

//}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}
//这个地方只做一个提示的功能
- (void)image:(UIImage*)image didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo
{
    if (error) {
        NSLog(@"保存失败");
    }else{
        
        NSLog(@"保存成功");
    }
}
//视频保存后的回调
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if (error) {
        NSLog(@"保存视频过程中发生错误，错误信息:%@",error.localizedDescription);
    }else{
        NSLog(@"视频保存成功.");
        //录制完之后自动播放
        NSURL *url=[NSURL fileURLWithPath:videoPath];
        _avplayer=[AVPlayer playerWithURL:url];
        AVPlayerLayer *playerLayer=[AVPlayerLayer playerLayerWithPlayer:_avplayer];
        playerLayer.frame = CGRectMake(0, 0, self.imageview.frame.size.width, 320);
    
        [self.imageview.layer addSublayer:playerLayer];
        [_avplayer play];
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
