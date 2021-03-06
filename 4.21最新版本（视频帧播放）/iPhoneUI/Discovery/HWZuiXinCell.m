//
//  HWZuiXinCell.m
//  HuaWo
//
//  Created by hwawo on 17/3/20.
//  Copyright © 2017年 HW. All rights reserved.
//

#import "HWZuiXinCell.h"
#import "VideoModel.h"
#import "SidModel.h"
@interface HWZuiXinCell ()

@end

@implementation HWZuiXinCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

-(void)setModel:(VideoModel *)model{
    _model = model;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.titleLabel.text = model.title;
    self.seeCountLabel.text = model.viewtimes;
    self.locationLabel.text = model.location;
    self.nickLabel.text = model.videoinfo.nickname;
    
    NSRange range0 = {4,2};
    NSRange range1 = {6,2};
    NSRange range2 = {8,2};
    NSRange range3 = {10,2};
    //    HWLog(@"model.gen_time %@",[model.gentime substringWithRange:range0]);
    //
    //    HWLog(@"setModel self.commentBtn.titleLabel.frame%@",NSStringFromCGRect(self.commentBtn.titleLabel.frame));
    //    HWLog(@"setModel self.commentBtn.titleLabel%@ -- %@",_model.comtimes, _model.goodtimes);
    [self.commentBtn setTitle:[NSString stringWithFormat:@"%@",_model.comtimes] forState:UIControlStateNormal];
    [self.agreeBtn setTitle:[NSString stringWithFormat:@"%@",_model.goodtimes]
     
                   forState:UIControlStateNormal];
    
    self.timeLabel.text = model.gentime;
    [self.backgroundIV sd_setImageWithURL:[NSURL URLWithString:model.videoinfo.image_url] placeholderImage:[UIImage imageNamed:@"webwxgetmsgimg2"]];
    [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:model.videoinfo.photo_url] placeholderImage:[UIImage imageNamed:@"find_new_head_bg"]];
    self.iconImageView.layer.cornerRadius = 0.5*self.iconImageView.width;
    self.iconImageView.layer.masksToBounds = YES;
    
}


- (IBAction)commentBtnClick:(UIButton *)sender {
    
    if ([self.delegate respondsToSelector:@selector(zuiXinCellCommentBtnClick:videoModel:)]) {
        [self.delegate zuiXinCellCommentBtnClick:self videoModel:_model];
    }
}
- (IBAction)agreeBtnClick:(UIButton *)sender {
    
    if ([self.delegate respondsToSelector:@selector(zuiXinCellAgreeBtnClick:videoModel:)]) {
        [self.delegate zuiXinCellAgreeBtnClick:self videoModel:_model];
    }
}
- (IBAction)shareBtnClick:(UIButton *)sender {
    
    if ([self.delegate respondsToSelector:@selector(zuiXinCellShareBtnClick:videoModel:)]) {
        [self.delegate zuiXinCellShareBtnClick:self videoModel:_model];
    }
}
@end
