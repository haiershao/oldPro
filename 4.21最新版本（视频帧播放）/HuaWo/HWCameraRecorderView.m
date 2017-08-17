//
//  HWCameraRecorderView.m
//  HuaWo
//
//  Created by hwawo on 16/11/21.
//  Copyright © 2016年 HW. All rights reserved.
//

#import "HWCameraRecorderView.h"
@interface HWCameraRecorderView()

@end
@implementation HWCameraRecorderView
+ (instancetype)cameraRecorderView{

    return [[NSBundle mainBundle] loadNibNamed:@"HWCameraRecorderView" owner:self options:nil].firstObject;
}

- (IBAction)shequBtnClick:(UIButton *)sender {
    
    if ([self.delegate respondsToSelector:@selector(cameraRecorderView:)]) {
        [self.delegate cameraRecorderView:self];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
