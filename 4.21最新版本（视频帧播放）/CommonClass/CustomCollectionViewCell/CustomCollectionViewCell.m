//
//  CustomCollectionViewCell.m
//  HuaWo
//
//  Created by circlely on 3/16/16.
//  Copyright © 2016 circlely. All rights reserved.
//

#import "CustomCollectionViewCell.h"

@implementation CustomCollectionViewCell

- (void)awakeFromNib {
    // Initialization code
    
    self.textLabel.textAlignment = NSTextAlignmentCenter;
    self.textLabel.font = [UIFont systemFontOfSize:20];
    self.textLabel.textColor = [UIColor grayColor];

    self.textLabel.highlightedTextColor = kHuaWoTintColor;

    
}

- (void)setCellIndexPath:(NSIndexPath *)cellIndexPath{

    _cellIndexPath = cellIndexPath;
}

- (void)setFrame:(CGRect)frame{

    CGFloat screenw = screenW;
    if (self.cellIndexPath.item == 0 || self.cellIndexPath.item == 1 || self.cellIndexPath.item == 2) {
        frame.size.width = screenw / 4;
    }
    [super setFrame:frame];
}
@end
