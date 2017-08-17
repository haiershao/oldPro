//
//  CommonUtility.h
//  AtHomeCam
//
//  Created by lvyi on 8/25/15.
//  Copyright (c) 2015 ichano. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum {
    
    E_STREAM_CHANNEL_NO_ERROR = 0, //通道初始化正常
    
    E_STREAM_CHANNEL_ERROR_CAMERA_DISABEL = 1,//对方摄像头被禁用了
    
    E_STREAM_CHANNEL_ERROR_CAMERA_NO_STREAMURL = 2, //该摄像头没有流URL
    
    E_STREAM_CHANNEL_ERROR_CAMERA_NOT_FOUND = 3  //Camera 没找到
    
} T_STREAM_PARAM_ERROR;

typedef void (^SaveCompletionBlock)(void);
typedef void (^SaveFailureBlock)(NSError *error);


@interface CommonUtility : NSObject


+ (NSString*)getUserSystemUrl:(NSString*)body;

+ (NSString*)getSDKCachePath;

+ (NSString*)getSDKWorkPath;

+ (int)getLanuageCode;

+(NSString *)getDefaultErrorString:(NSString *)errorCode;

+ (void)notifyStreamStateWithHanlde:(unsigned long long)handle
                        StreamState:(int)streamState
                         StreamFlag:(int)streamFlag;

+ (void)notifyStreamerSessionStateWithCID:(unsigned long long)cid
                             SessionState:(int)sessionState;

//根据cid，camid，streamid流通道有效性
+ (T_STREAM_PARAM_ERROR)getStreamParamErrorWithCID:(unsigned long long)cid
                                       cameraIndex:(int)cameraIndex
                                       streamIndex:(int)streamIndex;


@end
