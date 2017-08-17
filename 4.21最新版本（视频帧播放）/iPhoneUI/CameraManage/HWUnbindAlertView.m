//
//  HWUnbindAlertView.m
//  HuaWo
//
//  Created by hwawo on 16/6/30.
//  Copyright © 2016年 HW. All rights reserved.
//

#import "HWUnbindAlertView.h"
@interface HWUnbindAlertView ()
@property (weak, nonatomic) IBOutlet UITextField *idCardText;

@end

@implementation HWUnbindAlertView
+ (instancetype)unbindAlertView{

    return [[[NSBundle mainBundle] loadNibNamed:@"HWUnbindAlertView" owner:self options:nil] lastObject];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{

    [self endEditing:YES];
}
- (IBAction)cancelButtonClick:(UIButton *)sender {
    [self removeFromSuperview];
}

- (IBAction)confirmButtonClick:(UIButton *)sender {
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title", nil) message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//    
//    if (!(self.idCardText.text.length == 18)) {
//        alertView.message = @"请输入合法的身份证号";
//        [alertView show];
//        return;
//    }
//    
    [self removeFromSuperview];
    if ([self.delegate respondsToSelector:@selector(unbindAlertView:idCardNum:)]) {
        [self.delegate unbindAlertView:self idCardNum:self.idCardText.text];
    }
    
}

@end
