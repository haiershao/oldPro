//
//  HWIntegralConvertView.h
//  HuaWo
//
//  Created by hwawo on 16/7/19.
//  Copyright © 2016年 HW. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HWIntegralConvertView;
@protocol HWIntegralConvertViewDelegate <NSObject>

- (void)integralConvertViewView:(HWIntegralConvertView *)integralConvertViewView IDCardText:(NSString *)IDCardText  zhifuAccountText:(NSString *)zhifuAccountText integral:(NSString *)integralText;
@end
@interface HWIntegralConvertView : UIView
@property (weak, nonatomic) IBOutlet UIView *popConvertView;
@property (weak, nonatomic) id<HWIntegralConvertViewDelegate>delegate;
+ (instancetype)integralConvertView;
@end
