//
//  HWUserInstanceInfo.m
//  HuaWo
//
//  Created by yjc on 2017/3/30.
//  Copyright © 2017年 HW. All rights reserved.
//

#import "HWUserInstanceInfo.h"

@implementation HWUserInstanceInfo

+ (instancetype)shareUser {
    static HWUserInstanceInfo *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc]init];
    });
    
    return instance;
}

+ (instancetype)accountWithDict:(NSDictionary *)dict {
    HWUserInstanceInfo *info = [self shareUser];
    info.nickname = dict[@"data"][@"nickname"];
    info.driverno = dict[@"data"][@"driverno"];
    info.isactive = dict[@"data"][@"isactive"];
    info.isbind =   dict[@"data"][@"isbind"];
    
    info.result = dict[@"result"];
    info.token = dict[@"token"];
    return info;
}



@end
