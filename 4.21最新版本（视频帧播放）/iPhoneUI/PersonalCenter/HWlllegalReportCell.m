//
//  HWlllegalReportCell.m
//  HuaWo
//
//  Created by yjc on 2017/4/24.
//  Copyright © 2017年 HW. All rights reserved.
//

#import "HWlllegalReportCell.h"

@interface HWlllegalReportCell()
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UIButton *deleBtn;
@property (weak, nonatomic) IBOutlet UIImageView *bofangImage;
@property (weak, nonatomic) IBOutlet UILabel *process_state;

@end
@implementation HWlllegalReportCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (void)setModel:(HWlllegalReportModel *)model {
    _model = model;
    self.timeLabel.text = model.occur_time;
   
    self.locationLabel.text = model.occur_addr;
     //self.timeLabel.text = [model.occur_time substringWithRange:NSMakeRange(12, 4)];
    self.typeLabel.text = model.action_type;
    [self.bofangImage sd_setImageWithURL:[NSURL URLWithString:model.image_url] placeholderImage:[UIImage imageNamed:@"bofangqbg"]];
    self.process_state.text = @"等待处理";
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)deleBtn:(UIButton *)sender {
    self.deblock();
}

@end
