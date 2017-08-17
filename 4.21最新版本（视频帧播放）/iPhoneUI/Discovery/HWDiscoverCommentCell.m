//
//  HWDiscoverCommentCell.m
//  HuaWo
//
//  Created by hwawo on 17/3/25.
//  Copyright © 2017年 HW. All rights reserved.
//

#import "HWDiscoverCommentCell.h"
#import "VideoModel.h"
#import "SidModel.h"
#import "HWCommentModel.h"
@implementation HWDiscoverCommentCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setModel:(HWCommentModel *)model{

    _model = model;
    [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:model.photourl] placeholderImage:[UIImage imageNamed:@"find_new_head_bg"]];
    
    self.nickNameLabel.text = model.nickname;
    
    
    
    NSRange range0 = {4,2};
    NSRange range1 = {6,2};
    NSRange range2 = {8,2};
    NSRange range3 = {10,2};
    self.timeLabel.text = [NSString stringWithFormat:@"%@-%@ %@:%@",[model.gentime substringWithRange:range0],[model.gentime substringWithRange:range1],[model.gentime substringWithRange:range2],[model.gentime substringWithRange:range3]];
    
    self.titleLabel.text = model.comment;
}
@end
