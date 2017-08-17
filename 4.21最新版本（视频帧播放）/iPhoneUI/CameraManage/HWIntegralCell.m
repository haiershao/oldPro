//
//  HWIntegralCell.m
//  HuaWo
//
//  Created by hwawo on 16/7/12.
//  Copyright © 2016年 HW. All rights reserved.
//

#import "HWIntegralCell.h"
#import "HWIntegral.h"
@interface HWIntegralCell ()
@property (weak, nonatomic) IBOutlet UILabel *gentimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *pointTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *pointLabel;

@property (weak, nonatomic) IBOutlet UILabel *leftPointLabel;
@end
@implementation HWIntegralCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setIntegral:(HWIntegral *)integral{
    HWLog(@"cell -- %@",integral.pointtype);
    self.gentimeLabel.text = integral.gentime;
    self.pointTypeLabel.text = integral.pointtype;
    self.pointLabel.text = integral.point;
    self.leftPointLabel.text = integral.leftpoint;
    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
