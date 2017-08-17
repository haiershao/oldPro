//
//  CameraExpandMoreCell.h
//  HuaWo
//
//  Created by circlely on 1/21/16.
//  Copyright © 2016 circlely. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ExpandMoreCellDelegate <NSObject>

@optional

- (void) settingButtonAction:(NSString *)cid; //设置

- (void) manageButtonAction:(NSString *)cid;    //管理

- (void) deleteButtonAction:(NSString *)cid; //加入云套餐

- (void) bindButtonAction:(NSString *)cid;   //记录仪管理
//integral  convert
- (void) intgralConvertButtonAction:(NSString *)cid;
@end


@interface CameraExpandMoreCell : UITableViewCell

@property (nonatomic,assign) id<ExpandMoreCellDelegate>delegate;
@property (nonatomic,copy) NSString *cid;

@end
