//
//  HWFourBtnCell.h
//  HuaWo
//
//  Created by hwawo on 16/12/13.
//  Copyright © 2016年 HW. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HWFourBtnCell;
@protocol HWFourBtnCellDelegate <NSObject>

- (void)HWFourBtnCell:(HWFourBtnCell *)fourCell fourBtn:(UIButton *)btn;

@end
@interface HWFourBtnCell : UITableViewCell
@property (nonatomic, strong) id<HWFourBtnCellDelegate>delegate;
@end
