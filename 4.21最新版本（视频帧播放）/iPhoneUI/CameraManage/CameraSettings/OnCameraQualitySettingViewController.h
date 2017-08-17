//
//  OnCameraQualitySettingViewController.h
//  HuaWo
//
//  Created by circlely on 1/29/16.
//  Copyright © 2016 circlely. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol cameraQualitySetDelegate <NSObject>

- (void)cameraSettingSuccessed;

@end


@interface OnCameraQualitySettingViewController : UIViewController
@property (assign, nonatomic) id<cameraQualitySetDelegate> delegate;
@property (strong, nonatomic) NSString *cidNumber;
@end
