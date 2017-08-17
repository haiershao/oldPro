//
//  HWIntegralConvertView.m
//  HuaWo
//
//  Created by hwawo on 16/7/19.
//  Copyright © 2016年 HW. All rights reserved.
//

#import "HWIntegralConvertView.h"
@interface HWIntegralConvertView ()

@property (weak, nonatomic) IBOutlet UITextField *idCardTextField;

@property (weak, nonatomic) IBOutlet UITextField *zhifubaoTextField;

@property (weak, nonatomic) IBOutlet UITextField *integralTextField;
@end
@implementation HWIntegralConvertView

+ (instancetype)integralConvertView{

    return [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil].firstObject;
}

- (IBAction)cancel:(UIButton *)sender {
    [self removeFromSuperview];
}

- (IBAction)confirm:(UIButton *)sender {
    [self removeFromSuperview];
    if ([self.delegate respondsToSelector:@selector(integralConvertViewView:IDCardText:zhifuAccountText:integral:)]) {
        [self.delegate integralConvertViewView:self IDCardText:self.idCardTextField.text zhifuAccountText:self.zhifubaoTextField.text integral:self.integralTextField.text];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{

    [self endEditing:YES];
}
@end
