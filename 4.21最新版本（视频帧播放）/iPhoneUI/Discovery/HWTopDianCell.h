//
//  HWTopDianCell.h
//  HuaWo
//
//  Created by hwawo on 17/3/20.
//  Copyright © 2017年 HW. All rights reserved.
//

#import <UIKit/UIKit.h>
@class VideoModel;
@interface HWTopDianCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundIV;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (weak, nonatomic) IBOutlet UILabel *seeCountLabel;
@property (nonatomic, retain) VideoModel *model; 
@end
