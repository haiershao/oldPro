//
//  PersonalCenterCell.h
//  HuaWo
//
//  Created by circlely on 1/20/16.
//  Copyright © 2016 circlely. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PersonalCenterCell;
@protocol PersonalCenterCellDelegate <NSObject>

- (void)personalCenterCell:(PersonalCenterCell *)personalCenterCell;

@end
@interface PersonalCenterCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UILabel *loginStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *clickTipslabel;
@property (weak, nonatomic) IBOutlet UIImageView *accountIconImageView;
@property (weak, nonatomic) IBOutlet UILabel *accountLabel;
@property (weak, nonatomic) id<PersonalCenterCellDelegate>delegate;
@end
