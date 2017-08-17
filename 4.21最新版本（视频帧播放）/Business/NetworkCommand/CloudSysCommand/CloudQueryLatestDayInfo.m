//
//  CloudQueryLatestDayInfo.m
//  AtHomeCam
//
//  Created by lvyi on 6/6/15.
//  Copyright (c) 2015 ichano. All rights reserved.
//

#import "CloudQueryLatestDayInfo.h"
#import "AHCServerCommunicator.h"

@interface CloudQueryLatestDayInfo ()<AHCCloudFileDelegate>



@property (nonatomic, assign) unsigned long long getPerDayInfoRequestID;

@property (nonatomic, strong) NSArray* dayArray;
@property (nonatomic, strong) NSDictionary* dayNumDic;
@property (nonatomic, assign) int erroCode;

@property (nonatomic, copy) NetworkBasicBlock completionBlk;
@property (nonatomic, copy) NetworkBasicBlock failBlk;

@end

@implementation CloudQueryLatestDayInfo


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
    
    _getPerDayInfoRequestID = [[AHCServerCommunicator sharedAHCServerCommunicator] requestFileCountPerDayWithStreamer:[_CID longLongValue]];
    
    [[AHCServerCommunicator sharedAHCServerCommunicator] addCloudObserver:self forRequest:_getPerDayInfoRequestID];
    
}

-(void)cancelRequest {
    
    _getPerDayInfoRequestID = 0;
    
    self.completionBlk = nil;
    self.failBlk = nil;

    [[AHCServerCommunicator sharedAHCServerCommunicator] removeCloudObserverforRequest:_getPerDayInfoRequestID];
 
    
}

-(NSString*)getErrorMessage {
    
    return @"";
}

#pragma mark - AHCCloudFileDelegate


- (void)onCloudFilePerDayWithRequestID:(unsigned long long)requestID
                              Streamer:(unsigned long long)streamerCID
                               DayInfo:(NSArray*)dayInfos
                          FromStartDay:(NSString*)startDay
                             ErrorCode:(STREAMER_CLOUD_ERROR_CODE)errorCode{

    if (errorCode == STREAMER_CLOUD_NOERR || errorCode == STREAMER_CLOUD_ERROR_HAS_NO_DATA_UPLOADED) {
        
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"yyyyMMdd"];
        NSDate* curDate = [dateFormatter dateFromString:startDay];
        
        
        NSMutableArray* dayArr = [NSMutableArray arrayWithCapacity:3];
        NSMutableDictionary* dayDic = [NSMutableDictionary dictionaryWithCapacity:3];
        
        for(NSNumber* daynum in dayInfos) {
            
            NSString* curDateStr = [dateFormatter stringFromDate:curDate];
            
            
            [dayDic setObject:daynum forKey:curDateStr];
            [dayArr insertObject:curDateStr atIndex:0];//倒序排
            
            
            curDate = [curDate dateByAddingTimeInterval:24*60*60];
            
        }
        
        self.dayArray = dayArr;
        self.dayNumDic = dayDic;
        
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
