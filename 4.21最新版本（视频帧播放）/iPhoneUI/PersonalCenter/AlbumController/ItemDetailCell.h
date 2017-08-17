//
//  ItemDetailCell.h
//  HuaWo
//
//  Created by circlely on 2/20/16.
//  Copyright © 2016 circlely. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol ItemDetailCellDelegate <NSObject>

- (void)itemDeleteButtonPressed:(NSInteger)btnTag;

@end

@interface ItemDetailCell : UITableViewCell
@property (assign, nonatomic) id<ItemDetailCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UIImageView *fileTypeImageView;
@property (weak, nonatomic) IBOutlet UILabel *fileStyleLabel;
@property (weak, nonatomic) IBOutlet UILabel *createDate;
@property (weak, nonatomic) IBOutlet UILabel *timeRangeLabel;
@property (weak, nonatomic) IBOutlet UILabel *fileSizeLabel;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;

@end
