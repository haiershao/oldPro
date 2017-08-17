//
//  AlbumItem.h
//  HuaWo
//
//  Created by circlely on 2/3/16.
//  Copyright © 2016 circlely. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AlbumItem;

@protocol AlbumItemDelegate <NSObject>

- (void)videoBtnClickedOnItem:(AlbumItem *)item;
- (void)showPictureBtnClickedOnItem:(AlbumItem *)item;

- (void)streamerVideoBtnClickedOnItem:(AlbumItem *)item;
- (void)streamerPictureBtnClickedOnItem:(AlbumItem *)item;

- (void)changeFileType:(AlbumItem *)item;


@end


@interface AlbumItem : UIView

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UIImageView *selectImageView;

@property (weak, nonatomic) IBOutlet UILabel *itemType;
@property (weak, nonatomic) IBOutlet UIImageView *fileType;



@property (assign, nonatomic) id<AlbumItemDelegate> delegate;

@end
