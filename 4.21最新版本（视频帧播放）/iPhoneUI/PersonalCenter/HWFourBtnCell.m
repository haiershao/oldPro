//
//  HWFourBtnCell.m
//  HuaWo
//
//  Created by hwawo on 16/12/13.
//  Copyright © 2016年 HW. All rights reserved.
//

#import "HWFourBtnCell.h"

@implementation HWFourBtnCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)shareBtnClick:(UIButton *)sender {
    sender.tag = 1;
    if ([self.delegate respondsToSelector:@selector(HWFourBtnCell:fourBtn:)]) {
        [self.delegate HWFourBtnCell:self fourBtn:sender];
    }
}
- (IBAction)xingcheConBtn:(UIButton *)sender {
    sender.tag = 2;
    if ([self.delegate respondsToSelector:@selector(HWFourBtnCell:fourBtn:)]) {
        [self.delegate HWFourBtnCell:self fourBtn:sender];
    }
    
}
- (IBAction)guanzhuBtnClick:(UIButton *)sender {
    sender.tag = 3;
    if ([self.delegate respondsToSelector:@selector(HWFourBtnCell:fourBtn:)]) {
        [self.delegate HWFourBtnCell:self fourBtn:sender];
    }
    
}
- (IBAction)fansBtnClick:(UIButton *)sender {
    sender.tag = 4;
    if ([self.delegate respondsToSelector:@selector(HWFourBtnCell:fourBtn:)]) {
        [self.delegate HWFourBtnCell:self fourBtn:sender];
    }
    
}

@end
