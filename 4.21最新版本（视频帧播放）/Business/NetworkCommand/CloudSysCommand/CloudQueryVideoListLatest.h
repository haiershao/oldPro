//
//  MemberSubmitPushToken.h
//  AtHomeCam
//
//  Created by Circlely Networks on 20/5/14.
//  Copyright (c) 2014 ichano. All rights reserved.
//

#import "CloudSystemBase.h"

@interface CloudQueryVideoListLatest : NSObject {


}


@property (nonatomic, copy) NSString* CID;
@property (nonatomic, copy) NSString* userName;
@property (nonatomic, copy) NSString* pwd;
@property (nonatomic, assign) int size;


@property (nonatomic, readonly, strong) NSMutableArray* lastestCloudVideoList;
@property (nonatomic, assign,readonly) int erroCode;


-(void)startRequestWithCompletion:(NetworkBasicBlock)completionBlock
                      failedBlock:(NetworkBasicBlock)errorBlock;
-(void)cancelRequest;

-(NSString*)getErrorMessage;


@end
