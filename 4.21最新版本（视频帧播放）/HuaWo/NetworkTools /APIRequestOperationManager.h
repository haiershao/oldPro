//
//  TSYRequestOperationManager.h
//  CustomerPublic
//
//  Created by yjc on 15/12/10.
//  Copyright © 2015年 tsy. All rights reserved.
//

#import<AFNetworking/AFNetworking.h>
#import "APIRequest.h"

@interface APIRequestOperationManager : AFHTTPSessionManager

+ (instancetype)sharedRequestOperationManager;

- (NSURLSessionDataTask *)requestAPI:(APIRequest *)api completion:(void (^)(id result, NSError *error))completion;

@end
