//
//  ViewController.m
//  Video+GPUImage
//
//  Created by 1111 on 2017/8/18.
//  Copyright © 2017年 ljl. All rights reserved.
//
//目的：视频录制，为视频增加滤镜
//目的2:音屏录制，音频播放
//为图片增加滤镜
/*
 ios  录制视频有3种方式
 第一种，pickercontroller
 第二种avfoundation框架下的AVCaptureSession
 
 
 第三种AVCaptureDataOutput 和 AVAssetWriter
 
 
 */
#import "ViewController.h"
#import "PickerViewController.h"
#import "AVCaptureSessionViewController.h"
#import "GPUImageViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
  //视频录制
    [self Video];
    //音频分类
//    [self Audio];
    // Do any additional setup after loading the view, typically from a nib.
}
-(void)Video{

    UILabel *videolable = [[UILabel alloc]initWithFrame:CGRectMake(0, 80, self.view.frame.size.width, 30)];
//    videolable.textAlignment = NSTextAlignmentCenter;
    videolable.text  = @"视频录制方式:";
    videolable.textColor = [UIColor redColor];
    [self.view addSubview:videolable];
    
    NSArray *ar = @[@"PickerController",@"AVCaptureSession",@"GPUImage"];
    
    for (int i=0; i<ar.count; i++) {
        
        UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 110+(i*40), self.view.frame.size.width, 30)];
        
        btn.tag = 100+i;
        
        [btn setTitle:ar[i] forState:UIControlStateNormal];
        btn.layer.borderColor  =[UIColor lightGrayColor].CGColor;
        btn.layer.borderWidth = 2.0;
        
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(btns:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:btn];
        
    }



}
//音频处理分类
-(void)Audio{
    
    UILabel *audiolable = [[UILabel alloc]initWithFrame:CGRectMake(0, 80, 100, 30)];
    audiolable.text  = @"音频";
    [self.view addSubview:audiolable];
    
    NSArray *ar = @[@"PickerController",@"AVCaptureSession",@"AVAssetWriter"];
    
    for (int i=0; i<ar.count; i++) {
        
        UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 100+(i*40), self.view.frame.size.width, 30)];
        
        btn.tag = 100+i;
        
        [btn setTitle:ar[i] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(btns:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:btn];
        
    }
    
    
    
}


-(void)btns:(UIButton *)send{


    switch (send.tag) {
        case 100:{
            PickerViewController *pickVC = [[PickerViewController alloc]init];
            [self presentViewController:pickVC animated:YES completion:nil];
//            [self.navigationController pushViewController:pickVC animated:YES];
            
        }
            break;
        case 101:{
            AVCaptureSessionViewController *avVC =[[AVCaptureSessionViewController alloc]init];
            [self presentViewController:avVC animated:YES completion:nil];
            
            
        }break;
        case 102:{
           
            GPUImageViewController *avVC =[[GPUImageViewController alloc]init];
            [self presentViewController:avVC animated:YES completion:nil];
  
            
        } break;
        default:
            break;
    }



}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
