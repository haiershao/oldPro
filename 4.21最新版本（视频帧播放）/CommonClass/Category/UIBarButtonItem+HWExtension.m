//
//  UIBarButtonItem+HWExtension.m
//  HuaWo
//
//  Created by hwawo on 16/6/15.
//  Copyright © 2016年 HW. All rights reserved.
//

#import "UIBarButtonItem+HWExtension.h"

@implementation UIBarButtonItem (HWExtension)
+ (instancetype)itemWithImage:(NSString *)image highImage:(NSString *)highImage target:(id)target action:(SEL)action{

    UIButton *buttion = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttion setBackgroundImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
    [buttion setBackgroundImage:[UIImage imageNamed:highImage] forState:UIControlStateHighlighted];
    buttion.size = buttion.currentBackgroundImage.size;
    [buttion addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return [[self alloc] initWithCustomView:buttion];
}
@end
