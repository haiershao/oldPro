//
//  HWTopDianCell.m
//  HuaWo
//
//  Created by hwawo on 17/3/20.
//  Copyright © 2017年 HW. All rights reserved.
//

#import "HWTopDianCell.h"
#import "VideoModel.h"
#import "UIImageView+WebCache.h"
#import "SidModel.h"
@implementation HWTopDianCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}
-(void)setModel:(VideoModel *)model{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.titleLabel.text = model.title;
    HWLog(@"setModel--%@",model.gentime);
    
    //20170320
    //    NSRange range0 = {4,2};
    //    NSRange range1 = {6,2};
    //    NSRange range2 = {8,2};
    //    NSRange range3 = {10,2};
    //    HWLog(@"%@",[model.gentime substringWithRange:range0]);
    
    //    self.timeLabel.text = [NSString stringWithFormat:@"%@-%@ %@:%@",[model.gentime substringWithRange:range0],[model.gentime substringWithRange:range1],[model.gentime substringWithRange:range2],[model.gentime substringWithRange:range3]];
    self.timeLabel.text = model.gentime;
    self.seeCountLabel.text = model.viewtimes;
    HWLog(@"HWTopDianCell setModel %@",model.videoinfo.image_url);
    [self.backgroundIV sd_setImageWithURL:[NSURL URLWithString:model.videoinfo.image_url] placeholderImage:[UIImage imageNamed:@"webwxgetmsgimg2"]];
    
}

@end
