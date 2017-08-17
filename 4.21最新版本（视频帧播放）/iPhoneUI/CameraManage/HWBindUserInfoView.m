//
//  HWBindUserInfoView.m
//  HuaWo
//
//  Created by hwawo on 16/6/13.
//  Copyright © 2016年 HW. All rights reserved.
//

#import "HWBindUserInfoView.h"
@interface HWBindUserInfoView ()
@property (weak, nonatomic) IBOutlet UILabel *zhifubaoLabel;
@property (weak, nonatomic) IBOutlet UITextField *zhifubaoTextView;

@end
@implementation HWBindUserInfoView
+ (instancetype)bindUserInfoView{

    
    
    return [[[NSBundle mainBundle] loadNibNamed:@"HWBindUserInfoView" owner:self options:nil] lastObject];
}

- (IBAction)quitBtn:(UIButton *)sender {
    [self endEditing:YES];
}

- (IBAction)cancelBtnClick:(UIButton *)sender {
    [self removeFromSuperview];
}

- (IBAction)confirmBtnClick:(UIButton *)sender {

    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title", nil) message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    
//    if (!(self.identityCardTextField.text.length == 18)) {
//        alertView.message = @"请输入合法的身份证号";
//        [alertView show];
//        return;
//    }else if (!(self.plateNumberTextField.text.length == 7)){
//        alertView.message = @"请输入正确的车牌号";
//        [alertView show];
//        return;
//    }
    
    [self removeFromSuperview];
    if ([self.delegate respondsToSelector:@selector(bindUserInfoView:IDCardText:realNameText:phoneNumText:plateNumText:emailText:zhifuAccountText:)]) {
        [self.delegate bindUserInfoView:self IDCardText:self.identityCardTextField.text realNameText:self.userRealNameTextField.text phoneNumText:self.phoneNumTextField.text plateNumText:self.plateNumberTextField.text emailText:self.emailAddressTextField.text zhifuAccountText:self.zhifubaoAccount.text];
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
