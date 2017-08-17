//
//  cityInfo.m
//  聚合
//
//  Created by 刘海 on 16/3/9.
//  Copyright © 2016年 刘海. All rights reserved.
//

#import "CityInfo.h"

@implementation CityInfo

- (instancetype)initWithDict:(NSDictionary *)dict{

    if (self = [super init]) {
       [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}

+ (instancetype)cityInfoDict:(NSDictionary *)dict{

    return [[self alloc] initWithDict:dict];
}
@end
