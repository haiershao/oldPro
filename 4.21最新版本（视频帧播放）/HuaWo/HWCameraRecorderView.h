//
//  HWCameraRecorderView.h
//  HuaWo
//
//  Created by hwawo on 16/11/21.
//  Copyright © 2016年 HW. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HWCameraRecorderView;
@protocol HWCameraRecorderViewDelegate <NSObject>

- (void)cameraRecorderView:(HWCameraRecorderView *)cameraRecorderView;
@end
@interface HWCameraRecorderView : UIView
+ (instancetype)cameraRecorderView;
@property (weak, nonatomic) id<HWCameraRecorderViewDelegate>delegate;

@end
