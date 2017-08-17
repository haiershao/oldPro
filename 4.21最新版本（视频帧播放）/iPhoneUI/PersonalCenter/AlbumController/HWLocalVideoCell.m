//
//  HWLocalVideoCell.m
//  HuaWo
//
//  Created by hwawo on 16/9/23.
//  Copyright © 2016年 HW. All rights reserved.
//

#import "HWLocalVideoCell.h"
@interface HWLocalVideoCell ()
@property (weak, nonatomic) IBOutlet UILabel *videoNameLabel;

@property (weak, nonatomic) IBOutlet UIImageView *videoImageView;
@end

@implementation HWLocalVideoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setVideoName:(NSString *)videoName{
    _videoName = videoName;
    self.videoNameLabel.text = videoName;
}

- (void)setVideoIconPath:(NSString *)videoIconPath{
    _videoIconPath = videoIconPath;
    
    NSError *error = nil;
    if ([UIImagePNGRepresentation(self.videoImageView.image) writeToFile:videoIconPath options:NSDataWritingFileProtectionComplete error:&error]) {
    
        self.videoImageView.image = [UIImage imageWithContentsOfFile:videoIconPath];
    }

    
    HWLog(@"----error--------%@",error);
}

- (void)setIconImage:(UIImage *)iconImage{

    self.videoImageView.image = iconImage;
}
@end
