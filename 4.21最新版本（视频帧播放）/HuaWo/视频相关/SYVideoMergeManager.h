//
//  SYVideoMergeManager.h
//  HuaWo
//
//  Created by leju_esf on 17/3/29.
//  Copyright © 2017年 HW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SYShareVideoModel.h"
#import "SYVideoModel.h"
@interface SYVideoMergeManager : NSObject
+ (instancetype)sharedManager;
- (void)detailModel:(SYShareVideoModel *)model;
@property(nonatomic,assign)BOOL iSWIFI;
-(void)netWork;
@end
