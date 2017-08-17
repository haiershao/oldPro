//
//  CameraViewController.h
//  HuaWo
//
//  Created by circlely on 1/20/16.
//  Copyright © 2016 circlely. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CameraViewController;
@protocol CameraViewControllerDelegate <NSObject>
- (void)cameraViewController:(CameraViewController *)cameraViewController;

@end
@interface CameraViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIView *headerView;

@property (weak, nonatomic) id<CameraViewControllerDelegate>delegate;
+ (instancetype)cameraViewController;
@end
