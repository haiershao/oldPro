//
//  APIRequest.m
//  CustomerPublic
//
//  Created by yjc on 15/12/10.
//  Copyright © 2015年 tys. All rights reserved.
//

#import "APIRequest.h"

@implementation APIRequest

- (instancetype)initWithApiPath:(NSString *)apiPath method:(APIRequestMethod)method
{
    if (self = [super init]) {
        _method = method;
        _apiPath = [apiPath copy];
    }
    return self;
}


@end
