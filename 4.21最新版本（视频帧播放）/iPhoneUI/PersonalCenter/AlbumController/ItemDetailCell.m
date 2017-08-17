//
//  ItemDetailCell.m
//  HuaWo
//
//  Created by circlely on 2/20/16.
//  Copyright © 2016 circlely. All rights reserved.
//

#import "ItemDetailCell.h"

@implementation ItemDetailCell

- (void)awakeFromNib {
    // Initialization code
    
    self.iconImageView.layer.masksToBounds = YES;
    self.iconImageView.layer.cornerRadius = 4;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)deleteBtnPressed:(id)sender {
    
    if (_delegate) {
        
        UIButton *button = sender;
        
        [_delegate itemDeleteButtonPressed:button.tag];
    }
    
    
}



@end
