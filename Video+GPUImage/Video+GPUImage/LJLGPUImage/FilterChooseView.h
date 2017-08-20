//
//  FilterChooseView.h
//  GPU-Video-Edit
//
//  Created by ljl on 16/4/13.
//  Copyright © 2017年 ljl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GPUImage.h"

typedef void(^callBackFilter)(GPUImageOutput<GPUImageInput> * filter);

@interface FilterChooseView : UIView

@property(nonatomic,copy) callBackFilter backback;


@end




@interface FilterChooseCell : UICollectionViewCell
@property(nonatomic,strong)UIImageView * iconImg;
@property(nonatomic,strong)UILabel * nameLab;
@end
