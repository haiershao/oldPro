//
//  AlbumTableViewCell.h
//  HuaWo
//
//  Created by circlely on 2/3/16.
//  Copyright © 2016 circlely. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kCidStr  @"cidstring"

@protocol AlbumTableViewCellDelegate <NSObject>

- (void)videoPlayed:(NSString *)videoPath imageIcon:(NSString *)imagePath;
- (void)pictureShowed:(NSString *)path;

- (void)streamerVideoPlayedWithStreamURL:(NSString*)streamURL
                                FileName:(NSString *)fileName
                                  AVSCID:(NSString *)CIDNubmer
                               timeRange:(NSString *)tiemRange
                              recordType:(NSUInteger)type;

- (void)postPreVideoItemForDeleteData:(NSMutableArray *)arr;
- (void)postPrePictureItemForDeleteData:(NSMutableArray *)arr;
- (void)showDetailItem:(NSArray *)items;

- (void)updateAlbum;

@end

@interface AlbumTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIButton *moreBtn;

@property (strong, nonatomic) NSArray *albumItems;

@property (strong, nonatomic) NSArray *albumCameraItems;

@property (assign, nonatomic) id<AlbumTableViewCellDelegate> delegate;
@property (copy, nonatomic) NSString *CIDNumber;
@property (assign, nonatomic) NSInteger fileType;

@end
