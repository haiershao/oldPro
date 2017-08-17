//
//  HWLocalVideoListViewController.h
//  HuaWo
//
//  Created by hwawo on 16/9/23.
//  Copyright © 2016年 HW. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HWLocalVideoListViewController : UIViewController
@property (strong, nonatomic) UINavigationController *navigationController;
@property (nonatomic,strong) NSMutableArray *loopImages;
@property (nonatomic,strong) NSMutableArray *videoPaths;
+ (instancetype)localVideoListViewController;

@end
