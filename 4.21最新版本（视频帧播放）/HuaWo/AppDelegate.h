//
//  AppDelegate.h
//  HuaWo
//
//  Created by circlely on 1/18/16.
//  Copyright © 2016 circlely. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property(nonatomic,assign)BOOL allowRotation;
- (UIViewController *)setupViewControllers;
@end

