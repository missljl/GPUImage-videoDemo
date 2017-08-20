//
//  LJLGPUImageStillCamera.m
//  Video+GPUImage
//
//  Created by 1111 on 2017/8/20.
//  Copyright © 2017年 ljl. All rights reserved.
//
//
#import "LJLGPUImageStillCamera.h"
#import <Photos/Photos.h>


@interface LJLGPUImageStillCamera()

@property(strong,nonatomic)GPUImageStillCamera *myCamera;
//@property(strong,nonatomic)GPUImageView *myGPUImageView;
@property (nonatomic,retain) GPUImageOutput<GPUImageInput> *filter;
@property(assign,nonatomic)AVCaptureDevicePosition position;
@end

@implementation LJLGPUImageStillCamera
-(instancetype)initWithFrame:(CGRect)frame cameraPosition:(AVCaptureDevicePosition )positon{

    
    if (self=[super initWithFrame:frame]) {
        _position=positon;
        [self config];
        
    }


    return self;


}
-(void)config{

    //初始化相机，第一个参数表示相册的尺寸，第二个参数表示前后摄像头
    self.myCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1280x720 cameraPosition:AVCaptureDevicePositionFront];
    self.myCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    self.myCamera.horizontallyMirrorFrontFacingCamera = NO;
    self.myCamera.horizontallyMirrorRearFacingCamera = NO;

    //竖屏方向
//    self.myCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    
    //哈哈镜效果
    _filter = [[GPUImageFilter alloc] init];


    [self.myCamera addTarget:_filter];
    [_filter addTarget:self];
    

    
    
    FilterChooseView * chooseView = [[FilterChooseView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-FilterViewHeight-60, self.frame.size.width, FilterViewHeight)];
    chooseView.backback = ^(GPUImageOutput<GPUImageInput> * filter){
        [self choose_callBack:filter];
    };
    [self addSubview:chooseView];

    
     [self.myCamera startCameraCapture];
    
}
#pragma mark 选择滤镜
-(void)choose_callBack:(GPUImageOutput<GPUImageInput> *)filter
{

    
    self.filter = filter;
    [self.myCamera removeAllTargets];
    [self.myCamera addTarget:_filter];
    [_filter addTarget:self];
}

//开始捕捉
-(void)startCameraCapture{

    [self.myCamera startCameraCapture];

}
//停止捕捉
-(void)stopCameraCapture{

    [self.myCamera stopCameraCapture];
}
//切换摄像头
-(void)rotateCamera{


    [self.myCamera rotateCamera];

}

-(void)ClickOnShutter{


    [self.myCamera capturePhotoAsImageProcessedUpToFilter:_filter withCompletionHandler:^(UIImage *processedImage, NSError *error) {
        
        NSMutableArray *imageIds = [NSMutableArray array];
        
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
           
            //写入图片到相册
            PHAssetChangeRequest *req = [PHAssetChangeRequest creationRequestForAssetFromImage:processedImage];
            //记录本地标识，等待完成后取到相册中的图片对象
            [imageIds addObject:req.placeholderForCreatedAsset.localIdentifier];
     
            
            
            
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
           
            if (success) {
                
                
                //成功后取相册中的图片对象
                __block PHAsset *imageAsset = nil;
                PHFetchResult *result = [PHAsset fetchAssetsWithLocalIdentifiers:imageIds options:nil];
                [result enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    
                    imageAsset = obj;
                    *stop = YES;
                    
                }];
            
                if (imageAsset)
                {
                    //加载图片数据
                    [[PHImageManager defaultManager] requestImageDataForAsset:imageAsset
                                                                      options:nil
                                                                resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                                                                    
                                                                    [self.delegate SavePictureCallback:imageData];                                                              NSLog(@"imageData = %@ ,%@,%@,%@", imageData,info,imageAsset,dataUTI);
                                                                    
                                                                }];
                 
            
                
                
                
                
            }
            
            }
            
        }];
        
        
    }];
     
         
         
}

        // Save to assets library
//        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
////
////     
////        
//        [library writeImageToSavedPhotosAlbum:processedImage.CGImage metadata:nil completionBlock:^(NSURL *assetURL, NSError *error2)
//         {
//             if (error2) {
//                 NSLog(@"ERROR: the image failed to be written");
//             }
//             else {
//                 NSLog(@"PHOTO SAVED - assetURL: %@", assetURL);
//             }
//             
//             runOnMainQueueWithoutDeadlocking(^{
////                 [photoCaptureButton setEnabled:YES];
//             });
//         }];
 


      






@end
