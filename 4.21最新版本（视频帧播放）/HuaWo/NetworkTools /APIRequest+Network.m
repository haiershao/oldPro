//
//  APIRequest+Network.m
//  CustomerPublic
//
//  Created by yjc on 15/12/10.
//  Copyright © 2015年 Jianxin. All rights reserved.
//

#import "APIRequest+Network.h"

@implementation APIRequest (Network)
+ (APIRequest *)requestFristPageInformationWithUserId:(NSString *)userId type:(NSString *)type {
    APIRequest *request = [[APIRequest alloc] initWithApiPath:@"/retest/PhotoInfo/findPhotoInfos" method:APIRequestMethodGet];
    request.urlQueryParameters = @{@"userId":userId,@"type":type};
    return request;
}
+(APIRequest *)requestNickNameAction:(NSString *)action para:(NSString *)para{
    APIRequest *request = [[APIRequest alloc] initWithApiPath:@"/ServiceCenter/v3/restapi/doaction"method:APIRequestMethodPost];
   
    request.urlQueryParameters = @{
                                   @"action":action,
                                   @"para":para
                                   };
    return request;
}
+ (APIRequest *)requestUserNickNameDid:(NSString *)did stype:(NSString *)stype license:(NSString *)license {
    APIRequest *request = [[APIRequest alloc] initWithApiPath:@"" method:APIRequestMethodPost];
    
     request.urlQueryParameters = @{@"did":did,@"stype":stype,@"license":license};
    
    
    return request;
}
@end
