//
//  HWHWPersonalHomeCenterViewCell.h
//  HuaWo
//
//  Created by hwawo on 16/12/22.
//  Copyright © 2016年 HW. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface HWHWPersonalHomeCenterViewCell : UITableViewCell

@property (nonatomic, strong) UIButton         * playButton;

@property (nonatomic, strong) Video            * video;

@property (weak, nonatomic) IBOutlet UIView *videoView;
@property (weak, nonatomic) IBOutlet UIView *shangView;

@property (weak, nonatomic) IBOutlet UIImageView *bofangImage;

@property (weak, nonatomic) IBOutlet UILabel *titleLbael;

@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (nonatomic, strong) FMGVideoPlayView * fmVideoPlayer; // 播放器
typedef void(^Blo)();
@property (nonatomic, copy) Blo block;
@end
