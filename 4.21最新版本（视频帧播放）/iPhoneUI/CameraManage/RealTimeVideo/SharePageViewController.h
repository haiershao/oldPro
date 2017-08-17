//
//  SharePageViewController.h
//  HuaWo
//
//  Created by Sun on 16/4/14.
//  Copyright © 2016年 circlely. All rights reserved.
//
#import <UIKit/UIKit.h>
@interface SharePageViewController : UIViewController
@property (copy, nonatomic) NSString * videoPath;
@property (copy, nonatomic) NSString * imagePath;
@property (nonatomic, copy) NSString * cidNum;

+ (instancetype)sharePageViewController;
@end
