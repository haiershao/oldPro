//
//  AlbumTableViewCell.m
//  HuaWo
//
//  Created by circlely on 2/3/16.
//  Copyright © 2016 circlely. All rights reserved.
//

#import "AlbumTableViewCell.h"
#import "AlbumManager.h"
#import "AlbumItem.h"
#import "UIImageView+WebCache.h"
#import "UIImageView+RecodPictureCache.h"
#import "MBProgressHUD.h"

#define FIRST_ITEM_X   8
#define SECOND_ITEM_X  164
#define FIRST_ITEM_Y   27
#define SECOND_ITEM_Y  129
#define ITEM_WIDTH     148
#define ITEM_HIGHT     98

#define kMoreButtonTag 1111
#define kDateLabelTag 1234

#define kIsSelected  @"isselected"



@interface AlbumTableViewCell ()<AlbumItemDelegate,UIAlertViewDelegate>


@property (strong, nonatomic) NSArray *itemList;
@property (strong, nonatomic) NSMutableArray *videoItemsForDelete;
@property (strong, nonatomic) NSMutableArray *pictureItemsForDelete;
@property (strong, nonatomic) NSMutableArray *cacheItemArray;
@property (strong, nonatomic) UIAlertView *alertViewChangeFileType;
@property (assign, nonatomic) BOOL isLocalAlbum;
@property (strong, nonatomic) NSString *fileName;
@property (strong, nonatomic) NSMutableArray *albumItemArray;

@end


@implementation AlbumTableViewCell

- (void)awakeFromNib {
    
    [self.moreBtn setTitle:NSLocalizedString(@"cloudservice_purchase_item_more_label", nil) forState:UIControlStateNormal];
    self.moreBtn.tintColor = [UIColor whiteColor];
    self.backgroundColor = kBackgroundColor;
    self.contentView.backgroundColor = kBackgroundColor;
    self.videoItemsForDelete = [[NSMutableArray alloc] initWithCapacity:42];
    self.pictureItemsForDelete = [[NSMutableArray alloc] initWithCapacity:42];
    self.cacheItemArray = [[NSMutableArray alloc] initWithCapacity:3];
    
    self.albumItemArray = [NSMutableArray array];
    
    [self initUI];
}

- (void)initUI {
    
    for (int i = 0; i < 4; i++) {
        
        AlbumItem *item = [[[NSBundle mainBundle] loadNibNamed:@"AlbumItem" owner:self options:nil] firstObject];
        item.tag = i;
        item.delegate = self;
        
        item.hidden = YES;
        
        [self.albumItemArray addObject:item];
        
        [self.contentView addSubview:item];
        
        switch (i) {
            case 0:
            {
                item.frame = CGRectMake(FIRST_ITEM_X, FIRST_ITEM_Y, ITEM_WIDTH, ITEM_HIGHT);
            }
                break;
            case 1:
            {
                item.frame = CGRectMake(SECOND_ITEM_X, FIRST_ITEM_Y, ITEM_WIDTH, ITEM_HIGHT);
            }
                break;
            case 2:
            {
                item.frame = CGRectMake(FIRST_ITEM_X, SECOND_ITEM_Y, ITEM_WIDTH, ITEM_HIGHT);
            }
                break;
            case 3:
            {
                item.frame = CGRectMake(SECOND_ITEM_X, SECOND_ITEM_Y, ITEM_WIDTH, ITEM_HIGHT);
            }
                break;
                
            default:
                break;
        }

    
    }
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setAlbumItems:(NSArray *)albumItems {
    
    self.isLocalAlbum = YES;
    
    if (!albumItems || albumItems.count == 0) {
        return;
    }
    
    self.itemList = albumItems;
    
    NSArray *items = [NSArray array];
    
    if (albumItems.count > 4) {
        
        items = [albumItems subarrayWithRange:NSMakeRange(0, 4)];
        
    }
    else {
        
        items = albumItems;
        
        for (int i = items.count; i<4; i++) {
            AlbumItem *item = (AlbumItem *)[self.albumItemArray objectAtIndex:i];
            item.hidden = YES;
        
        }
        
    }
    
    for (int i = 0; i < items.count; i++) {
        
        AlbumInfo *itemInfo = ((AlbumInfo *)[items objectAtIndex:i]);
        AlbumItem *item = (AlbumItem *)[self.albumItemArray objectAtIndex:i];
        
        
        item.hidden = NO;
        
        item.itemType.hidden = YES;
        item.fileType.hidden = YES;
        
        if ([itemInfo.iconPath isEqualToString:kNULL]) {
            
            item.playBtn.hidden = YES;
            
            [item.imageView sd_setImageWithURL:[NSURL fileURLWithPath:itemInfo.fullPath] placeholderImage:[UIImage imageNamed:@"videorecord_icon_pic"]];
            
        }
        else {
            
            item.playBtn.hidden = NO;
            
            [item.imageView sd_setImageWithURL:[NSURL fileURLWithPath:itemInfo.iconPath] placeholderImage:[UIImage imageNamed:@"videorecord_icon_pic"]];
            
        }
        
        item.dateLabel.text = [NSString stringWithFormat:@"%@:%@:%@",
                               [itemInfo.fileName substringWithRange:NSMakeRange(8, 2)],
                               [itemInfo.fileName substringWithRange:NSMakeRange(10, 2)],
                               [itemInfo.fileName substringWithRange:NSMakeRange(12, 2)]];
        
        
        
        item.selectImageView.hidden = !itemInfo.isSelected;
        
    }
    
    
}

- (void)setAlbumCameraItems:(NSArray *)albumCameraItems {
    
    
    self.isLocalAlbum = NO;
    
    if (!albumCameraItems || albumCameraItems.count == 0) {
        return;
    }
    
     NSArray *items = [NSArray array];
    
    if (albumCameraItems.count > 4) {
        
        items = [albumCameraItems subarrayWithRange:NSMakeRange(0, 4)];
    }
    else {
        
        items = albumCameraItems;
        
        for (int i = items.count; i<4; i++) {
            AlbumItem *item = (AlbumItem *)[self.albumItemArray objectAtIndex:i];
            item.hidden = YES;
            
        }
    }

    self.itemList = albumCameraItems;

    for (int i = 0; i < items.count; i++) {
        
        
        AlbumItem *item = (AlbumItem *)[self.albumItemArray objectAtIndex:i];
        
        item.hidden = NO;
        
        item.fileType.hidden = NO;
        item.itemType.hidden = NO;
        
        item.selectImageView.hidden = YES;
        
    }
    
}

- (NSString *)itemType:(NSString *)fileName {
    
    HWLog(@"fileName[%@]",fileName);
    
    NSRange foundObjLoop = [fileName rangeOfString:@"loop"];
    NSRange foundObjParking = [fileName rangeOfString:@"parking"];
    NSRange foundObjTouch = [fileName rangeOfString:@"touch"];
    
    if (foundObjLoop.location != NSNotFound) {
        return NSLocalizedString(@"avs_album_video_type_text_loop", nil);
    }
    
    else if (foundObjParking.location != NSNotFound) {
        return NSLocalizedString(@"avs_album_video_type_text_parking", nil);
    }
    
    else if (foundObjTouch.location != NSNotFound) {
        
        return NSLocalizedString(@"avs_album_video_type_text_touch", nil);
    }
    
    return nil;
    
}
- (IBAction)moreBtnPressed:(id)sender {
    
    
    if (_delegate) {
        
        [_delegate showDetailItem:self.itemList];
    }
    
    
}

- (void)dealloc {
    
    
}

#pragma mark AlbumItemDelegate
-(void)videoBtnClickedOnItem:(AlbumItem *)item {
    
    if (!self.isLocalAlbum) {
        return;
    }
    
    AlbumInfo *itemInfo = (AlbumInfo *)[self.itemList objectAtIndex:item.tag];
    
    BOOL isSelecting = [[[NSUserDefaults standardUserDefaults] objectForKey:kIsSelected] boolValue];

    if (isSelecting) {
        
        item.selectImageView.hidden = !item.selectImageView.hidden;
        
        itemInfo.isSelected = !item.selectImageView.hidden;
        
        if (!item.selectImageView.hidden && ![self.videoItemsForDelete containsObject:itemInfo]) {
            
            [self.videoItemsForDelete addObject:itemInfo];
        }else{
            
            [self.videoItemsForDelete removeObject:itemInfo];
        }
        
        if (_delegate) {
            
            [_delegate postPreVideoItemForDeleteData:self.videoItemsForDelete];
        }
        
        return;
    }
    
    
    if (_delegate) {
        
        [_delegate videoPlayed:itemInfo.fullPath imageIcon:itemInfo.iconPath];
    }
    
    HWLog(@"--------------itemInfo.fullPath--------------%@------%@",itemInfo.fullPath, self.CIDNumber);

}



- (void)showPictureBtnClickedOnItem:(AlbumItem *)item {
    
    if (!self.isLocalAlbum) {
        return;
    }
    
    AlbumInfo *itemInfo = (AlbumInfo *)[self.itemList objectAtIndex:item.tag];
    
    BOOL isSelecting = [[[NSUserDefaults standardUserDefaults] objectForKey:kIsSelected] boolValue];
    
    if (isSelecting) {
        
        item.selectImageView.hidden = !item.selectImageView.hidden;
        
        itemInfo.isSelected = !item.selectImageView.hidden;
        
        if (!item.selectImageView.hidden && ![self.pictureItemsForDelete containsObject:itemInfo]) {
            
            [self.pictureItemsForDelete addObject:itemInfo];
        }else{
            
            [self.pictureItemsForDelete removeObject:itemInfo];
        }
        
        if (_delegate) {
            
            [_delegate postPrePictureItemForDeleteData:self.pictureItemsForDelete];
        }
        
        
        
        return;
    }

    
    if (_delegate) {
        
        [_delegate pictureShowed:itemInfo.fullPath];
    }

    
}

#pragma mark AlbumCameraItemDelegate

- (void)streamerVideoBtnClickedOnItem:(AlbumItem *)item {
    
    if (self.isLocalAlbum) {
        return;
    }

    BOOL isSelecting = [[[NSUserDefaults standardUserDefaults] objectForKey:kIsSelected] boolValue];
    
    if (isSelecting) {
        
        item.selectImageView.hidden = !item.selectImageView.hidden;
        
        
        if (_delegate) {
            
            [_delegate postPreVideoItemForDeleteData:self.videoItemsForDelete];
        }
        
        return;
    }

    if (_delegate) {
        
    
    }
    
    
}

- (void)streamerPictureBtnClickedOnItem:(AlbumItem *)item {
    
    if (self.isLocalAlbum) {
        return;
    }
    
    //NSDictionary *itemInfo = [self.itemList objectAtIndex:item.tag];
    
    BOOL isSelecting = [[[NSUserDefaults standardUserDefaults] objectForKey:kIsSelected] boolValue];
    
    if (isSelecting) {
        
        item.selectImageView.hidden = !item.selectImageView.hidden;
        
        
        
        
        if (_delegate) {
            
            [_delegate postPrePictureItemForDeleteData:self.pictureItemsForDelete];
        }
        
        
        
        return;
    }
    
    
    if (_delegate) {
    }

}

- (void)changeFileType:(AlbumItem *)item {
    
    
    if (self.isLocalAlbum) {
        return;
    }
    
    if (self.alertViewChangeFileType) {
        return;
    }
    
}

#pragma mark AlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    self.alertViewChangeFileType = nil;
    
    if (buttonIndex == 1) {
        
        
    }
    
}

/**
 * 让当前控制器对应的状态栏是白色
 */
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
@end
