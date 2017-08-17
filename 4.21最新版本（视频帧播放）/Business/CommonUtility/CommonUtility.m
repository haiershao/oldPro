//
//  CommonUtility.m
//  AtHomeCam
//
//  Created by lvyi on 8/25/15.
//  Copyright (c) 2015 ichano. All rights reserved.
//

#import "CommonUtility.h"
#import "NSString+MD5.h"
#import "MemberData.h"
#import "AHCServerCommunicator.h"


enum {
    
    E_NETWORK_CHINESE_HANS = 1,
    
    E_NETWORK_ENGLISH,
    
    E_NETWORK_CHINESE_HANT
    
}
T_NETWORK_LANGUAGE_CODE;


@implementation CommonUtility


+ (NSString*)getUserSystemUrl:(NSString*)body {
    
    return [NSString stringWithFormat:@"%@%@", SERVER_ADR, body];
    
    
}


+ (NSString*)getSDKWorkPath {
    
    NSArray *documents = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask,
                                                             YES);
    NSMutableString *path = [NSMutableString stringWithString:documents[0]];
    [path appendString:@"/iChano/Config"];
    
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:path]) {
        
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    //SDK api要求路径最后以反斜杠结束
    [path appendString:@"/"];
    
    HWLog(@"getSDKWorkPath[%@]", path);
    
    return path;
}

+ (NSString*)getSDKCachePath{
    
    NSArray *documents = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask,
                                                             YES);
    NSMutableString *path = [NSMutableString stringWithString:documents[0]];
    [path appendString:@"/iChano/Record"];
    
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:path]) {
        
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    //SDK api要求路径最后以反斜杠结束
    [path appendString:@"/"];
    
    HWLog(@"getSDKCachePath[%@]", path);
    
    return path;
}


+ (int)getLanuageCode {
    
    NSString* curLan = [[NSLocale preferredLanguages] objectAtIndex:0];
    
    int lanCode = E_NETWORK_ENGLISH;
    
    if([curLan hasPrefix:@"zh-Hans"]) {
        
        lanCode = E_NETWORK_CHINESE_HANS;
    }
    else if([curLan hasPrefix:@"zh-Hant"]  || [curLan hasPrefix:@"zh-HK"] || [curLan hasPrefix:@"zh-TW"]) {
        
        lanCode = E_NETWORK_CHINESE_HANT;
    }
    
    return lanCode;
}

+(NSString *)getDefaultErrorString:(NSString *)errorCode{
    return [NSString stringWithFormat:@"%@\n(code = %@)",NSLocalizedString(@"warnning_request_failed", nil),errorCode];
}


+ (void)notifyStreamStateWithHanlde:(unsigned long long)handle
                        StreamState:(int)streamState
                         StreamFlag:(int)streamFlag {
    
    NSDictionary* param = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:streamState], K_APP_PARAM_STREAM_STATE,
                           [NSNumber numberWithInt:streamFlag] , K_APP_PARAM_STREAM_FLAG,
                           [NSNumber numberWithLongLong:handle], K_APP_PARAM_STREAM_HANDLE, nil];
    
    NSNotification* notification = [NSNotification notificationWithName:K_APP_STREAM_STATE_UPDATE object:nil userInfo:param];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}


+ (void)notifyStreamerSessionStateWithCID:(unsigned long long)cid
                             SessionState:(int)sessionState {
    
    NSDictionary* param =[NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithInt:sessionState] , K_APP_PARAM_SESSION_STATE,
                          [NSNumber numberWithLongLong:cid] , K_APP_PARAM_CID, nil];
    
    NSNotification* notification = [NSNotification notificationWithName:K_APP_SESSION_STATE_UPDATE object:nil userInfo:param];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}


+ (T_STREAM_PARAM_ERROR)getStreamParamErrorWithCID:(unsigned long long)cid
                                       cameraIndex:(int)cameraIndex
                                       streamIndex:(int)streamIndex {
    
    T_STREAM_PARAM_ERROR channelError = E_STREAM_CHANNEL_NO_ERROR;
    
    AVSConfigData* avsConf = [[MemberData memberData] getDetailConfigInfoForCID:[NSString stringWithFormat:@"%llu", cid]];
    
    
    NSArray* cameraSettingsArray = avsConf.streamerInfo.CameraSettingsArray;
    
    if (!cameraSettingsArray || [cameraSettingsArray count] <=  cameraIndex) {
        
        channelError = E_STREAM_CHANNEL_ERROR_CAMERA_NOT_FOUND;
    }
    else {
        
        CameraSettings* camersetting = [cameraSettingsArray objectAtIndex:cameraIndex];
        
        if (!camersetting.cameraEnable) {
            
            channelError = E_STREAM_CHANNEL_ERROR_CAMERA_DISABEL;
        }
        else {
            
            NSArray* addressArray = [avsConf streamAddressForCamera:cameraIndex];
            
            if (!addressArray || [addressArray count] <= streamIndex) {
                
                channelError = E_STREAM_CHANNEL_ERROR_CAMERA_NO_STREAMURL;
            }
            
        }
        
    }
    
    return channelError;
    
}




@end
