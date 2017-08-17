//
//  AlbumCameraItem.h
//  HuaWo
//
//  Created by circlely on 2/19/16.
//  Copyright © 2016 circlely. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AlbumCameraItem;

@protocol AlbumCameraItemDelegate <NSObject>

- (void)streamerVideoBtnClickedOnItem:(AlbumCameraItem *)item;
- (void)streamerPictureBtnClickedOnItem:(AlbumCameraItem *)item;
- (void)changeFileType:(AlbumCameraItem *)item;
@end


@interface AlbumCameraItem : UIView
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *selectImageView;
@property (weak, nonatomic) IBOutlet UILabel *itemType;
@property (weak, nonatomic) IBOutlet UIImageView *fileType;

@property (assign, nonatomic) id<AlbumCameraItemDelegate> delegate;

@end
