//
//  VideoItemCollectionViewCell.h
//  HuaWo
//
//  Created by circlely on 1/25/16.
//  Copyright © 2016 circlely. All rights reserved.
//

#import <UIKit/UIKit.h>
@class VideoItemCollectionViewCell;
@protocol VideoItemCollectionViewCellDelegate <NSObject>

- (void)videoItemImageViewAction;
@end
@interface VideoItemCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *videoItemImageView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@property (copy, nonatomic) NSString * videoPath;
@property (copy, nonatomic) NSString * imagePath;
@property (copy, nonatomic) NSString * locationPath;
@property (copy, nonatomic) NSString * cidNum;
@property (nonatomic,assign) id<VideoItemCollectionViewCellDelegate>delegate;

@end
