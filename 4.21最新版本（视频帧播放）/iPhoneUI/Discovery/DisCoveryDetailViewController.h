//
//  DisCoveryDetailViewController.h
//  HuaWo
//
//  Created by circlely on 2/29/16.
//  Copyright © 2016 circlely. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoModel.h"
@class MBProgressHUD;
@interface DisCoveryDetailViewController : UIViewController
@property (strong, nonatomic) VideoModel *model;
/**
 用了自定义的手势返回，则系统的手势返回屏蔽
 不用自定义的手势返回，则系统的手势返回启用
 */
@property (nonatomic, assign) BOOL enablePanGesture;//是否支持自定义拖动pop手势，默认yes,支持手势
@property (nonatomic,retain) MBProgressHUD* hud;
@property (nonatomic, copy) NSString *flag;
@property (assign, nonatomic, getter=isStatusBarHidden) BOOL statusBarHidden;

+ (instancetype)disCoveryDetailViewController;
- (void)share:(VideoModel *)urlStr;


- (void)addHud;
- (void)addHudWithMessage:(NSString*)message;
- (void)removeHud;
@end
