//
//  HWFindCommonCell.h
//  HuaWo
//
//  Created by hwawo on 17/4/15.
//  Copyright © 2017年 HW. All rights reserved.
//

#import <UIKit/UIKit.h>
@class VideoModel;
@class HWFindCommonCell;
@class HWCellBtn;
@protocol findCommonCellDelegate <NSObject>

- (void)findCommonCellCommentBtnClick:(HWFindCommonCell *)findCommonCell videoModel:(VideoModel *)model;

- (void)findCommonCellAgreeBtnClick:(HWFindCommonCell *)findCommonCell videoModel:(VideoModel *)model;

- (void)findCommonCellShareBtnClick:(HWFindCommonCell *)findCommonCell videoModel:(VideoModel *)model;

@end


@interface HWFindCommonCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundIV;
@property (weak, nonatomic) IBOutlet UIButton *commonBtn;
@property (weak, nonatomic) IBOutlet UIButton *agreeBtn;
@property (weak, nonatomic) IBOutlet UIButton *shareBtn;
@property (weak, nonatomic) IBOutlet UILabel *seeCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;

@property (nonatomic, retain) VideoModel *model;
@property (nonatomic, weak) id<findCommonCellDelegate> delegate;
@end
