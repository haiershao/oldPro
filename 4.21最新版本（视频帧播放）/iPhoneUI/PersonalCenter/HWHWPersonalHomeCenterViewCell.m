//
//  HWHWPersonalHomeCenterViewCell.m
//  HuaWo
//
//  Created by hwawo on 16/12/22.
//  Copyright © 2016年 HW. All rights reserved.
//

#import "HWHWPersonalHomeCenterViewCell.h"
#import <videoPlayer/FMGVideoPlayView.h>
#import "Video.h"
#import "VideoSid.h"

@interface HWHWPersonalHomeCenterViewCell ()


@end
@implementation HWHWPersonalHomeCenterViewCell

- (void)setVideo:(Video *)video
{
    _video = video;
    self.titleLbael.text = video.title;
    
    [self.bofangImage sd_setImageWithURL:[NSURL URLWithString:video.videoinfo.image_url] placeholderImage:[UIImage imageNamed:@"bofangqbg"]];
    
    //[_fmVideoPlayer setUrlString: video.videoinfo.video_url];
    
    
}
- (IBAction)deleteBtnClick:(UIButton *)sender {
    self.block();
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
}


-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
}
- (void)awakeFromNib {
    [super awakeFromNib];
    //    [self.contentView addSubview: self.fmVideoPlayer];
    //    [self.contentView bringSubviewToFront:self.fmVideoPlayer];
}
@end
