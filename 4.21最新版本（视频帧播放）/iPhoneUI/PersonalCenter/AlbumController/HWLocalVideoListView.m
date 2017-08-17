//
//  HWLocalVideoListView.m
//  HuaWo
//
//  Created by hwawo on 16/9/23.
//  Copyright © 2016年 HW. All rights reserved.
//

#import "HWLocalVideoListView.h"

@implementation HWLocalVideoListView
+ (instancetype)LocalVideoListView{

    return [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:self options:nil].firstObject;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
