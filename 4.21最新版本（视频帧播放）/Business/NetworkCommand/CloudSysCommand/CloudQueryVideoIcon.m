//
//  CloudQueryVideoIcon.m
//  AtHomeCam
//
//  Created by lvyi on 6/7/15.
//  Copyright (c) 2015 ichano. All rights reserved.
//

#import "CloudQueryVideoIcon.h"
#import "AHCServerCommunicator.h"

@interface CloudQueryVideoIcon ()<AHCCloudFileDelegate>

@property (nonatomic, strong) UIImage* videoIcon;

@property (nonatomic, copy) NetworkBasicBlock completionBlk;
@property (nonatomic, copy) NetworkBasicBlock failBlk;
@property (nonatomic, assign) unsigned long long requestID;

@end

@implementation CloudQueryVideoIcon


-(id)init;
{
    self = [super init];
    
    if (self) {
        
        
    }
    
    return self;
}

-(void)startRequestWithCompletion:(NetworkBasicBlock)completionBlock
                      failedBlock:(NetworkBasicBlock)errorBlock {
    
    self.completionBlk = completionBlock;
    self.failBlk = errorBlock;
    
    _requestID = [[AHCServerCommunicator sharedAHCServerCommunicator] getCloudFileIconWithStreamer:[_CID longLongValue] Eid:_Eid];
    
    [[AHCServerCommunicator sharedAHCServerCommunicator] addCloudObserver:self forRequest:_requestID];
    
}

-(void)cancelRequest {
    
    _requestID = 0;
    
    self.completionBlk = nil;
    self.failBlk = nil;
    
    [[AHCServerCommunicator sharedAHCServerCommunicator] removeCloudObserverforRequest:_requestID];
    
    
}

-(NSString*)getErrorMessage {
    
     return NSLocalizedString(@"warnning_request_failed", nil);
}

#pragma mark - AHCCloudFileDelegate


- (void)onRecvCloudFileIconWithRequestID:(unsigned long long)requestID
                                Streamer:(unsigned long long)streamerCID
                                     Eid:(NSString*)eid
                                   Image:(UIImage*)image {
    
    
    self.videoIcon = image;
    
    if (self.completionBlk) {
        
        self.completionBlk();
    }
    
    self.completionBlk = nil;
    self.failBlk = nil;
    
    
    //这句很重要，只能放在最后调用才是安全的
    [[AHCServerCommunicator sharedAHCServerCommunicator] removeCloudObserverforRequest:requestID];
    
}

@end
