//
//  MemberSubmitPushToken.m
//  AtHomeCam
//
//  Created by Circlely Networks on 20/5/14.
//  Copyright (c) 2014 ichano. All rights reserved.
//

#import "CloudQueryVideoListByPage.h"
#import "MemberData.h"
#import "InterfaceDefine.h"
#import "CloudVideoObject.h"
#import "AHCServerCommunicator.h"

@interface CloudQueryVideoListByPage ()<AHCCloudFileDelegate>


@property (nonatomic, strong) NSArray* cloudVideoList;
@property (nonatomic, assign) BOOL isRequestLastPage;

@property (nonatomic, copy) NetworkBasicBlock completionBlk;
@property (nonatomic, copy) NetworkBasicBlock failBlk;

@property (nonatomic, assign) unsigned long long requestID;

@property (nonatomic, assign) int erroCode;

@end

@implementation CloudQueryVideoListByPage


-(id)init;
{
	self = [super init];
	
	if (self) {
		
	}
	
	return self;
}


-(NSString*)getErrorMessage
{
	
    if (_erroCode == STREAMER_CLOUD_ERROR_SERVER_PARM) {
        
        return NSLocalizedString(@"cloud_videolist_request_user_pwd_error_tips", nil);
    }
    else {
        
        return NSLocalizedString(@"warnning_request_failed", nil);
    }
}

-(void)startRequestWithCompletion:(NetworkBasicBlock)completionBlock
                      failedBlock:(NetworkBasicBlock)errorBlock {

    self.completionBlk = completionBlock;
    self.failBlk = errorBlock;
    
    _requestID = [[AHCServerCommunicator sharedAHCServerCommunicator] requestCloudRecordFilesWithStreamer:[_CID longLongValue] CameraIndex:_cameraID PageIndex:_pageNum CountPerPage:_pageCount BeginTime:_fromtime RecordType:1];

    [[AHCServerCommunicator sharedAHCServerCommunicator] addCloudObserver:self forRequest:_requestID];
}

-(void)cancelRequest {
    
    _requestID = 0;
    
    self.completionBlk = nil;
    self.failBlk = nil;

    [[AHCServerCommunicator sharedAHCServerCommunicator] removeCloudObserverforRequest:_requestID];

    
}

#pragma mark - AHCCloudFileDelegate


- (void)onCloudFilesWithRequestID:(unsigned long long)requestID
                       TotalCount:(NSUInteger)totalCount
                     CurrentCount:(NSUInteger)currentCount
                         FileInfo:(NSArray*)FileInfos
                        ErrorCode:(STREAMER_CLOUD_ERROR_CODE)errorCode{

    if (errorCode == STREAMER_CLOUD_NOERR || errorCode == STREAMER_CLOUD_ERROR_HAS_NO_DATA_UPLOADED) {
        
        NSMutableArray* videoList = [NSMutableArray arrayWithCapacity:3];
        
        for (RvsCloudFileInfo* cFileInfo in FileInfos) {
            
            
            
            CloudVideoObject* cvo = [[CloudVideoObject alloc] init];
            
            cvo.eid = cFileInfo.eid;
            cvo.event_long = cFileInfo.duration;
            cvo.createTime = cFileInfo.createTime;
            cvo.cameraID = cFileInfo.camIndex;
            cvo.size = cFileInfo.fileSize;
            [videoList addObject:cvo];
            
        }
        
        self.cloudVideoList = videoList;
        
        _isRequestLastPage = ([videoList count] < _pageCount);
        
        
        
        
        if (self.completionBlk) {
            
            self.completionBlk();
        }
    }
    else {
    
        self.erroCode = errorCode;
        
        if (self.failBlk) {
        
            self.failBlk();
        }
    
    }
    
    self.completionBlk = nil;
    self.failBlk = nil;
    
    //这句很重要，只能放在最后调用才是安全的
    [[AHCServerCommunicator sharedAHCServerCommunicator] removeCloudObserverforRequest:requestID];
}

@end
