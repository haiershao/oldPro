//
//  CameraExpandMoreCell.m
//  HuaWo
//
//  Created by circlely on 1/21/16.
//  Copyright © 2016 circlely. All rights reserved.
//

#import "CameraExpandMoreCell.h"


@implementation CameraExpandMoreCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];


}

- (IBAction)manageBtnPressed:(id)sender {
 
    [self.delegate manageButtonAction:self.cid];
}

- (IBAction)settingBtnPressed:(id)sender {
    
    [self.delegate settingButtonAction:self.cid];
}

- (IBAction)intgralConvertBtnPressed:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(intgralConvertButtonAction:)]) {
        [self.delegate intgralConvertButtonAction:self.cid];
    }
    
//    [self.delegate deleteButtonAction:self.cid];
}

- (IBAction)bindBtnPressed:(UIButton *)sender {
    
    
    
    if ([self.delegate respondsToSelector:@selector(bindButtonAction:)]) {
        
        [self.delegate bindButtonAction:self.cid];
    }
}
@end
