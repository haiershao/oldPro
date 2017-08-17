//
//  HWUnbindAlertView.h
//  HuaWo
//
//  Created by hwawo on 16/6/30.
//  Copyright © 2016年 HW. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HWUnbindAlertView;
@protocol HWUnbindAlertViewDelegate <NSObject>
- (void)unbindAlertView:(HWUnbindAlertView *)bindAlertView idCardNum:(NSString *)idCardNum;

@end
@interface HWUnbindAlertView : UIView
@property (weak, nonatomic) IBOutlet UIView *popUnbindView;
+ (instancetype)unbindAlertView;
@property (weak, nonatomic) id<HWUnbindAlertViewDelegate>delegate;
@end
