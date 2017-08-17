//
//  HWCameraRecorderViewController.h
//  HuaWo
//
//  Created by hwawo on 17/2/20.
//  Copyright © 2017年 HW. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HWCameraRecorderViewController;
@protocol HWCameraRecorderViewControllerDelegate <NSObject>

- (void)cameraRecorderViewController:(HWCameraRecorderViewController *)cameraRecorderViewController;
@end

@interface HWCameraRecorderViewController : UIViewController

+ (instancetype)cameraRecorderViewController;
@property (weak, nonatomic) id<HWCameraRecorderViewControllerDelegate>delegate;
@end
