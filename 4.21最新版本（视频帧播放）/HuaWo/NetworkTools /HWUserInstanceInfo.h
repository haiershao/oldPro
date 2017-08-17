//
//  HWUserInstanceInfo.h
//  HuaWo
//
//  Created by yjc on 2017/3/30.
//  Copyright © 2017年 HW. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HWUserInstanceInfo : NSObject
@property (nonatomic,copy)NSString *nickname;
@property (nonatomic,copy)NSString *driverno;
@property (nonatomic, copy)NSString *isactive;
@property (nonatomic, copy)NSString *isbind;

@property (nonatomic,copy)NSString *token;
@property (nonatomic ,copy)NSString *result;
@property (nonatomic,assign)CGFloat coordinate;
@property (nonatomic,assign)CGFloat longitude;

+(instancetype)shareUser;
+ (instancetype)accountWithDict:(NSDictionary *)dict;
@end
