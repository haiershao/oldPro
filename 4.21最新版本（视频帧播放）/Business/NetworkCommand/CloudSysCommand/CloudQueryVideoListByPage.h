//
//  MemberSubmitPushToken.h
//  AtHomeCam
//
//  Created by Circlely Networks on 20/5/14.
//  Copyright (c) 2014 ichano. All rights reserved.
//

#import "CloudSystemBase.h"

#define K_START_PAGE 1

@interface CloudQueryVideoListByPage : NSObject


@property (nonatomic, copy) NSString* CID;
@property (nonatomic, assign) int pageNum;
@property (nonatomic, assign) int pageCount;
@property (nonatomic, copy) NSString* userName;
@property (nonatomic, copy) NSString* pwd;
@property (nonatomic, copy) NSString* fromtime;
@property (nonatomic, copy) NSString* totime;
@property (nonatomic, assign) int cameraID;

@property (nonatomic, assign,readonly) int erroCode;



@property (nonatomic, readonly, assign) BOOL isRequestLastPage;
@property (nonatomic, readonly, strong) NSArray* cloudVideoList;


-(void)startRequestWithCompletion:(NetworkBasicBlock)completionBlock
                      failedBlock:(NetworkBasicBlock)errorBlock;
-(void)cancelRequest;

-(NSString*)getErrorMessage;

@end
