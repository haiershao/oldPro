//
//  cityInfo.m
//  聚合
//
//  Created by 刘海 on 16/3/9.
//  Copyright © 2016年 刘海. All rights reserved.
//

#import "CityInfo.h"

@implementation CityInfo
+ (instancetype)CityUser {
    static CityInfo *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc]init];
    });
    
    return instance;
}

//- (instancetype)initWithDict:(NSDictionary *)dict{
//
//    if (self = [super init]) {
//       [self setValuesForKeysWithDictionary:dict];
//    }
//    return self;
//}

+ (instancetype)cityInfoDict:(NSDictionary *)dict{
    CityInfo *info = [self CityUser];
    info.City = dict[@"City"];
    info.Country = dict[@"Country"];
    info.CountryCode = dict[@"CountryCode"];
    info.FormattedAddressLines = dict[@"FormattedAddressLines"];
    info.Name = dict[@"Name"];
    info.State = dict[@"State"];
    info.Street = dict[@"Street"];
    info.SubLocality = dict[@"SubLocality"];
    info.SubThoroughfare = dict[@"SubThoroughfare"];
    info.Thoroughfare = dict[@"Thoroughfare"];
    //return [[self alloc] initWithDict:dict];
    return info;
}
@end
