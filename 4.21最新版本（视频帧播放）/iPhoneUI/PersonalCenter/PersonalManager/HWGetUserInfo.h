//
//  HWGetUserInfo.h
//  HuaWo
//
//  Created by hwawo on 16/12/13.
//  Copyright © 2016年 HW. All rights reserved.
//

#import <Foundation/Foundation.h>
//typedef void(^HeardValue)(NSArray *heardArray,NSArray *videoArray);
//typedef void (^getNickName)(NSString *nickName);
//typedef void (^getNickName0)(NSString *getNickName);

@interface HWGetUserInfo : NSObject
@property (copy, nonatomic) NSString *name;
//- (NSString *)getDeviceNickName;
- (NSString *)getDeviceNickname;

-(NSString *)readNSUserNickNameDefaults;
-(NSString *)readNSUserTokenDefaults;
@end
