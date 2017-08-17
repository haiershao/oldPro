//
//  HWZuiXinCell.h
//  HuaWo
//
//  Created by hwawo on 17/3/20.
//  Copyright © 2017年 HW. All rights reserved.
//

#import <UIKit/UIKit.h>
@class VideoModel;
@class HWZuiXinCell;
@class HWCellBtn;
@protocol zuiXinCellDelegate <NSObject>

- (void)zuiXinCellCommentBtnClick:(HWZuiXinCell *)zuiXinCell videoModel:(VideoModel *)model;

- (void)zuiXinCellAgreeBtnClick:(HWZuiXinCell *)zuiXinCell videoModel:(VideoModel *)model;

- (void)zuiXinCellShareBtnClick:(HWZuiXinCell *)zuiXinCell videoModel:(VideoModel *)model;

@end


@interface HWZuiXinCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundIV;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *nickLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *seeCountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UIButton *commentBtn;

@property (strong, nonatomic) IBOutlet UIButton *agreeBtn;


@property (nonatomic, retain) VideoModel *model;
@property (nonatomic, weak) id<zuiXinCellDelegate> delegate;
@end
