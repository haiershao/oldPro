//
//  HWDiscoverCommentCell.h
//  HuaWo
//
//  Created by hwawo on 17/3/25.
//  Copyright © 2017年 HW. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HWCommentModel;
@interface HWDiscoverCommentCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (strong, nonatomic) HWCommentModel *model;
@end
