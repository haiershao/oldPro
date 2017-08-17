//
//  APIRequest.h
//  CustomerPublic
//
//  Created by yjc on 15/12/10.
//  Copyright © 2015年 tys. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, APIRequestMethod) {
    APIRequestMethodGet,
    APIRequestMethodHead,
    APIRequestMethodPost,
    APIRequestMethodPut,
    APIRequestMethodPatch,
    APIRequestMethodDelete
};

@interface APIRequest : NSObject

@property (nonatomic) APIRequestMethod method;

@property (nonatomic, copy) NSString *apiPath;

@property (nonatomic, copy) NSDictionary *urlQueryParameters;

- (instancetype)initWithApiPath:(NSString *)apiPath method:(APIRequestMethod)method;


@end
