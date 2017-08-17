//
//  TSYRequestOperationManager.m
//  CustomerPublic
//
//  Created by yjc on 15/12/10.
//  Copyright © 2015年 tsy. All rights reserved.
//
#import "APIRequestOperationManager.h"

NSString *const kBaseUrl = @"http://find.hwawo.com:9090";

@implementation APIRequestOperationManager

+ (instancetype)sharedRequestOperationManager {
    static dispatch_once_t onceToken;
    static APIRequestOperationManager *manager;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] initWithBaseURL:[NSURL URLWithString:kBaseUrl]];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObjectsFromArray:@[@"text/html", @"text/plain"]];

    });
    return manager;
}

- (NSURLSessionDataTask *)requestAPI:(APIRequest *)api completion:(void (^)(id result, NSError *error,NSProgress *downloadProgress))completion {
    
    
    NSDictionary *urlParams = api.urlQueryParameters;
    
    void (^success)(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) = ^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject){
        
        if (completion) {
            completion(responseObject, nil,nil);
        }
    };
    
    void (^failure)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) = ^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error){
        if (completion) {
            completion(nil,error,nil);
        }
    };
    
    NSURLSessionDataTask *result;
    switch (api.method) {
        case APIRequestMethodGet:{
            result = [self GET:api.apiPath parameters:urlParams progress:nil success:success failure:failure];
        }
            break;
        case APIRequestMethodPost:{
            result = [self POST:api.apiPath parameters:urlParams progress:nil success:success failure:failure];
        }
            break;
        case APIRequestMethodPut:{
            result = [self PUT:api.apiPath parameters:urlParams success:success failure:failure];
        }
            break;
        case APIRequestMethodPatch:{
            result = [self PATCH:api.apiPath parameters:urlParams success:success failure:failure];
        }
            break;
        case APIRequestMethodDelete:{
            result = [self DELETE:api.apiPath parameters:urlParams success:success failure:failure];
        }
            break;
        default:
            break;
    }
    return result;
}


@end
