//
//  HWTextAlertView.m
//  HuaWo
//
//  Created by hwawo on 16/5/5.
//  Copyright © 2016年 circlely. All rights reserved.
//

#import "HWTextAlertView.h"
#import <TextView/TextView.h>
@interface HWTextAlertView ()
@property (weak, nonatomic) IBOutlet UIView *textAlertView;
@property (weak, nonatomic) UILabel *placeholderLabel;
@end
@implementation HWTextAlertView

+ (instancetype)textAlertView{

    return [[[NSBundle mainBundle] loadNibNamed:@"HWTextAlertView" owner:self options:nil] lastObject];
}

- (void)awakeFromNib{
    
    self.frame = [[UIScreen mainScreen] bounds];
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.0];
    
    self.textAlertView.alpha = 0.0;
    self.textAlertView.layer.borderColor = [UIColor grayColor].CGColor;
    self.textAlertView.layer.borderWidth = 0.3f;
    self.textAlertView.layer.cornerRadius = 10;
    self.textAlertView.layer.masksToBounds = YES;
    
    // 添加textView
    [self setupTextView];
}

- (void)setupTextView{

    TextView *textview = [[TextView alloc] init];
    textview.font = [UIFont systemFontOfSize:15];
    textview.frame = self.commentTextField.bounds;
    textview.placeholder = @"说点新鲜事...";
    [self.commentTextField addSubview:textview];
    self.textview = textview;

    
}

- (void)showTextAlertView{

    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:self];
    self.textAlertView.transform = CGAffineTransformScale(self.textAlertView.transform, 1.1, 1.1);
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        self.textAlertView.transform = CGAffineTransformIdentity;
        self.textAlertView.alpha = 1.0;
        
    } completion:nil];
}

- (void)closeTextAlertView{

    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.textAlertView.transform = CGAffineTransformScale(self.textAlertView.transform, 0.9, 0.9);
        self.textAlertView.alpha = 0.0;
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.0];
    } completion:^(BOOL finished) {
        
        if (finished) {
            [self removeFromSuperview];
        }
    }];
}

- (IBAction)cancelEdit:(UIButton *)sender {
    self.getDetermine((int)sender.tag);
    [self closeTextAlertView];
}
@end
