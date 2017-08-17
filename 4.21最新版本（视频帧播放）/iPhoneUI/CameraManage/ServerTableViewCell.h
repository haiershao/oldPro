//
//  ServerTableViewCell.h
//  HuaWo
//
//  Created by circlely on 1/21/16.
//  Copyright © 2016 circlely. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ServerTableViewCellDelegate <NSObject>

@optional

- (void) expandMoreMessage:(NSString *)cidStr;
@end


@interface ServerTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *editImageView;
@property (weak, nonatomic) IBOutlet UILabel *serverName;
@property (weak, nonatomic) IBOutlet UILabel *avsStatusLabel;

@property (nonatomic, assign) id <ServerTableViewCellDelegate> delegate;

@property (nonatomic, copy) NSString *cid;
@property (nonatomic, assign) int isOnline;
@property (nonatomic, assign) BOOL isEnable;

@end
