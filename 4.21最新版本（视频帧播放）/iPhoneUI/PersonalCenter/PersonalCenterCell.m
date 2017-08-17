//
//  PersonalCenterCell.m
//  HuaWo
//
//  Created by circlely on 1/20/16.
//  Copyright © 2016 circlely. All rights reserved.
//

#import "PersonalCenterCell.h"

@implementation PersonalCenterCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)iconBtnClick:(UIButton *)sender {
    
    if ([self.delegate respondsToSelector:@selector(personalCenterCell:)]) {
        [self.delegate personalCenterCell:self];
    }
}
@end
