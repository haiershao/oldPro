//
//  MemberSubmitPushToken.m
//  AtHomeCam
//
//  Created by Circlely Networks on 20/5/14.
//  Copyright (c) 2014 ichano. All rights reserved.
//

#import "CloudQueryVideoListLatest.h"
#import "MemberData.h"
#import "InterfaceDefine.h"
#import "CloudVideoObject.h"
#import "MemberData.h"
#import "AHCServerCommunicator.h"
#import "MemberData.h"

#import "CloudQueryLatestDayInfo.h"
#import "CloudQueryVideoListByPage.h"

#define K_NUMBER_PER_PAGE 10

@interface CloudQueryVideoListLatest ()


@property (nonatomic, strong) NSMutableArray* lastestCloudVideoList;

@property (nonatomic, copy) NetworkBasicBlock completionBlk;
@property (nonatomic, copy) NetworkBasicBlock failBlk;


@property (nonatomic, strong) CloudQueryLatestDayInfo* dayInfoRequest;
@property (nonatomic, strong) NSMutableDictionary* cloudListDic;

@property (nonatomic, assign) int erroCode;


@end

@implementation CloudQueryVideoListLatest


-(id)init;
{
	self = [super init];
	
	if (self) {
		
		_size = 4;
        
        _cloudListDic = [[NSMutableDictionary alloc] initWithCapacity:3];
        _dayInfoRequest = [[CloudQueryLatestDayInfo alloc] init];
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
    
    
    [self cancelRequest];
    
    self.completionBlk = completionBlock;
    self.failBlk = errorBlock;
    
    
    _dayInfoRequest.CID = self.CID;
    
    
    __block typeof(self) safeSelf = self;
    
    [_dayInfoRequest startRequestWithCompletion:^{
        
        NSArray* dayArray = safeSelf.dayInfoRequest.dayArray;
        NSDictionary* dayNumDic = safeSelf.dayInfoRequest.dayNumDic;
        
    
        NSMutableArray* list = [NSMutableArray arrayWithCapacity:3];
        
        for(NSString* curday in dayArray) {
        
            CloudVideoListOneDay* oneDay = [[CloudVideoListOneDay alloc] init];
            
            oneDay.date = curday;
            oneDay.isMore = NO;
            oneDay.cloudVideoObjectArray = [NSMutableArray arrayWithCapacity:3];
            
            
            int dayCount = [[dayNumDic objectForKey:curday] integerValue];
            
            if (dayCount > 0) {
            
            
                CloudQueryVideoListByPage* requestByPage = [[[CloudQueryVideoListByPage alloc] init] autorelease];
                
                requestByPage.CID = safeSelf.CID;
                requestByPage.pageNum = 1;
                requestByPage.pageCount = safeSelf.size + 1;
                requestByPage.userName = safeSelf.userName;
                requestByPage.pwd = safeSelf.pwd;
                requestByPage.fromtime = curday;
                requestByPage.cameraID = -1;
   
                [safeSelf.cloudListDic setObject:requestByPage forKey:curday];
                
                [requestByPage startRequestWithCompletion:^{
                    
                    
                    CloudVideoListOneDay* curDayInfo = nil;
                    for (CloudVideoListOneDay* dayInfo in safeSelf.lastestCloudVideoList) {
                        
                        if([dayInfo.date isEqualToString:requestByPage.fromtime]) {
                            
                            curDayInfo = dayInfo;
                            break;
                        }
                        
                    }
                    
                    if (curDayInfo == nil) {
                        
                        
                        NSLog(@"Error!! can not found [%@] info in lastestCloudVideoList", requestByPage.fromtime);
                        return ;
                    }
                    
                    
                    

                    
                    
                    if ([requestByPage.cloudVideoList count] == 0) {
                    
                        NSLog(@"Error !!, get day info show [%@] have [%d] CloudVideiClips, but  CloudQueryVideoListByPage have 0 ", requestByPage.fromtime, dayCount);
                        //对于有数据，但是请求详情没数据的情况做个特殊处理
                        [safeSelf.lastestCloudVideoList removeObject:curDayInfo];
                    }
                    else {
                        
                        curDayInfo.isMore = [requestByPage.cloudVideoList count] > safeSelf.size ? YES : NO;
                        int needCount =  curDayInfo.isMore  ? safeSelf.size : [requestByPage.cloudVideoList count];
                        
                        for (int i = 0; i < needCount; i++) {
                            
                            [curDayInfo.cloudVideoObjectArray addObject:(requestByPage.cloudVideoList)[i]];
                        }
                        
                    }
                    
                    
                    [safeSelf.cloudListDic removeObjectForKey:requestByPage.fromtime];
                    
                    if ([safeSelf.cloudListDic count] == 0) {
                        
                        //更新本地缓存数据
                        [[MemberData memberData] updateCloudList:safeSelf.lastestCloudVideoList ForCID:safeSelf.CID];
                        
                        if (safeSelf.completionBlk) {
                            
                            safeSelf.completionBlk();
                        }
                        
                        safeSelf.completionBlk = nil;
                        safeSelf.failBlk = nil;
                        
                    }
                    
                } failedBlock:^{
                    
                    [safeSelf.cloudListDic removeObjectForKey:requestByPage.fromtime];
                    
                    [safeSelf handleError:requestByPage.erroCode];
                    
                    
                }];
            
                [list addObject:oneDay];
            }
            else {
            
                //这个分支可以先不处理
            }
            
            
        }
        
        
        safeSelf.lastestCloudVideoList = list;
        
        if ([safeSelf.cloudListDic count] == 0) {
            
            //这里坐下筛选，如果是获取失败则不要刷新云视频列表缓存，但是如果是根本就没有云视频，还是需要刷新下缓存的
            if ([dayArray count] > 0) {
            
                [[MemberData memberData] updateCloudList:safeSelf.lastestCloudVideoList ForCID:safeSelf.CID];
            }
            
            if (safeSelf.completionBlk) {
            
                safeSelf.completionBlk();
            }
            
            safeSelf.completionBlk = nil;
            safeSelf.failBlk = nil;
            
        }
        
        
    } failedBlock:^{
        
        [safeSelf handleError:safeSelf.dayInfoRequest.erroCode];
        
    }];


}


- (void)handleError:(int)errorCode {

    self.lastestCloudVideoList = nil;
    self.erroCode = errorCode;
    
    //如果是用户名密码错误，需要清空本地缓存，其他错误保留本地缓存
    if (errorCode == STREAMER_CLOUD_ERROR_SERVER_PARM) {
    
        [[MemberData memberData] updateCloudList:[NSArray array] ForCID:self.CID];
    }
    
    if (self.failBlk) {
        
        self.failBlk();
    }
    
    self.completionBlk = nil;
    self.failBlk = nil;
    
    
    NSArray* requestList = [self.cloudListDic allValues];
    
    for(CloudQueryVideoListByPage* request in requestList) {
    
    
        [request cancelRequest];
    }
    
    [self.cloudListDic removeAllObjects];

}

-(void)cancelRequest {

    self.completionBlk = nil;
    self.failBlk = nil;
    
    [_dayInfoRequest cancelRequest];
    

    NSArray* values = [_cloudListDic allValues];
    
    for(CloudQueryVideoListByPage* requestByPage in values ) {
    
        [requestByPage cancelRequest];
    }
    
    [_cloudListDic removeAllObjects];
     
    self.lastestCloudVideoList = nil;
}

@end
