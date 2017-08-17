//
//  HWImmediatelyShareController.h
//  HuaWo
//
//  Created by hwawo on 16/5/24.
//  Copyright © 2016年 HW. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HWImmediatelyShareController : UIViewController
@property (copy, nonatomic) NSString *videoPath;
@property (copy, nonatomic) NSString *imageIconPath;
@property (nonatomic, copy) NSString * cidNum;
+ (instancetype)immediatelyShareController;

@end
