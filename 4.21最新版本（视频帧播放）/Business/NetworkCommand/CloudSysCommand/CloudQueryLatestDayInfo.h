//
//  CloudQueryLatestDayInfo.h
//  AtHomeCam
//
//  Created by lvyi on 6/6/15.
//  Copyright (c) 2015 ichano. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InterfaceDefine.h"

@interface CloudQueryLatestDayInfo : NSObject


@property (nonatomic, copy) NSString* CID;

@property (nonatomic, strong, readonly) NSArray* dayArray;
@property (nonatomic, strong, readonly) NSDictionary* dayNumDic;

@property (nonatomic, assign,readonly) int erroCode;


-(void)startRequestWithCompletion:(NetworkBasicBlock)completionBlock
                      failedBlock:(NetworkBasicBlock)errorBlock;
-(void)cancelRequest;

-(NSString*)getErrorMessage;

@end
