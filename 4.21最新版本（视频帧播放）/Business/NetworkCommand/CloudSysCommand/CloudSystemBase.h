//
//  MemberSystemBase.h
//  AtHomeCam
//
//  Created by Circlely Networks on 7/12/13.
//

#import <Foundation/Foundation.h>

#import "InterfaceDefine.h"

#define CLOUD_SYS_DEFAULT_TIME_OUT 15

@interface CloudSystemBase : NSObject

@property (nonatomic, strong) NSString* returnCode;
@property (nonatomic, readonly, strong) NSDictionary* returnDictionary;
@property (nonatomic, assign) BOOL isSyncRequest;

-(id)initWithEncryptData:(BOOL)isNeedEncrypt
              httpMethod:(NSString*)method
                 timeout:(NSTimeInterval)duration;
//Handle completion by yourself
-(void)startRequestWithCompletion:(NetworkBasicBlock)completionBlock
                      failedBlock:(NetworkBasicBlock)errorBlock;
//Handle completion by subclass, overwrite the virtual function "onRequestCompleted"
-(void)startRequest;
-(void)cancelRequest;
-(BOOL)isRequestLogicSuccess;
-(NSString*)getErrorMessage;

//virtual function
-(NSURL*)onRequestedURL;
-(NSDictionary*)onRequestBody;
-(NSMutableDictionary*)onRequestHeader;

-(void)onRequestCompleted;
-(void)onRequestFailed;
-(BOOL)onShouldStartRequest;

@end

//@interface UploadInterfaceBase : NetWorkInterfaceBase
//    
//-(void)startRequestWithCompletion:(ASIBasicBlock)completionBlock failedBlock:(ASIBasicBlock)errorBlock;
//-(void)startRequest;
//    
//-(void)onSettingUploadData:(ASIFormDataRequest*)dataRequest;
//@end
