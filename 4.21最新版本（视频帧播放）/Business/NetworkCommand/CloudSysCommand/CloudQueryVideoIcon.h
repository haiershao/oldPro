//
//  CloudQueryVideoIcon.h
//  AtHomeCam
//
//  Created by lvyi on 6/7/15.
//  Copyright (c) 2015 ichano. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "InterfaceDefine.h"

@interface CloudQueryVideoIcon : NSObject

@property (nonatomic, copy) NSString* CID;
@property (nonatomic, copy) NSString* Eid;

@property (nonatomic, strong, readonly) UIImage* videoIcon;


-(void)startRequestWithCompletion:(NetworkBasicBlock)completionBlock
                      failedBlock:(NetworkBasicBlock)errorBlock;
-(void)cancelRequest;

-(NSString*)getErrorMessage;

@end
