//
//  HWCommentView.m
//  HuaWo
//
//  Created by hwawo on 16/7/19.
//  Copyright © 2016年 HW. All rights reserved.
//

#import "HWCommentView.h"
@interface HWCommentView ()


@end
@implementation HWCommentView

+ (instancetype)commentView{

    return [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil].firstObject;
}

- (IBAction)cancel:(UIButton *)sender {
    [self removeFromSuperview];
}

- (IBAction)confirm:(UIButton *)sender {
    [self.commentTextField resignFirstResponder]; 
    [self removeFromSuperview];
    
    if ([self.delegate respondsToSelector:@selector(commentView:commentText:)]) {
        [self.delegate commentView:self commentText:self.commentTextField];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{

    [self endEditing:YES];
}
@end
