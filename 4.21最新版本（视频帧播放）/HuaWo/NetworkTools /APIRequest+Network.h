//
//  APIRequest+Network.h
//  CustomerPublic
//
//  Created by yjc on 15/12/10.
//  Copyright © 2015年 tsy. All rights reserved.
//

#import "APIRequest.h"

@interface APIRequest (Network)
+ (APIRequest *)requestFristPageInformationWithUserId:(NSString *)userId type:(NSString *)type;
+ (APIRequest *)requestUserNickNameDid:(NSString *)did stype:(NSString *)stype license:(NSString *)license;
+(APIRequest *)requestNickNameAction:(NSString *)action para:(NSDictionary *)para;
@end
