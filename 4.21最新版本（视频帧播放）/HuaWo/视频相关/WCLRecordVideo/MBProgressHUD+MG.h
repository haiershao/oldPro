//
//  MBProgressHUD+MG.h
//  test
//
//  Created by dasen on 16/7/15.
//  Copyright © 2016年 dasen. All rights reserved.
//

#import "MBProgressHUD.h"

@interface MBProgressHUD (MG)
+ (void)showSuccess:(NSString *)success;
+ (void)showSuccess:(NSString *)success toView:(UIView *)view;

+ (void)showError:(NSString *)error;
+ (void)showError:(NSString *)error toView:(UIView *)view;

+ (MBProgressHUD *)showMessage:(NSString *)message;
+ (MBProgressHUD *)showMessage:(NSString *)message toView:(UIView *)view;
+ (MBProgressHUD *)showMessageDim:(NSString *)message dim:(BOOL)dim;

+ (MBProgressHUD *)showMessageEnabled:(NSString *)message;
+ (void)hideHUD;
+ (void)hideHUDForView:(UIView *)view;

@end
