//
//  HWConst.h
//  HuaWo
//
//  Created by Hwawo on 16/4/29.
//  Copyright © 2016年 circlely. All rights reserved.
//

#import <Foundation/Foundation.h>
#define screenFrame [UIScreen mainScreen].bounds
#define screenW [UIScreen mainScreen].bounds.size.width
#define screenH [UIScreen mainScreen].bounds.size.height

#define DZColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]

#define listCollectionCellCount 2

#define DZNotificationCenter [NSNotificationCenter defaultCenter]
#define identifierForVendor0 [[UIDevice currentDevice].identifierForVendor UUIDString]
#define identifierForVendor [identifierForVendor0 stringByReplacingOccurrencesOfString:@"-" withString:@""]
//#define identifierForVendor [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier]
#define kUid [[MemberData memberData] getMemberAccount]
#define kNickName [[MemberData memberData] getMemberNickName]
#define isLogin [[MemberData memberData] isMemberLogin]
//#define deviceNickName [[HWGetUserInfo alloc] getDeviceNickname]
#define kDeviceNickName [[HWGetUserInfo alloc] readNSUserNickNameDefaults]
#define kDeviceToken [[HWGetUserInfo alloc] readNSUserTokenDefaults]
#define HWLog(...) NSLog(__VA_ARGS__)



