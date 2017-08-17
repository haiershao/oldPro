//
//  AHCServerCommunicator.m
//  AtHomeCam
//
//  Created by Circlely Networks on 4/3/14.
//
//

#import <CommonCrypto/CommonDigest.h>
#import "AHCServerCommunicator.h"
#import "InterfaceDefine.h"
#import "MemberData.h"
#import "AVSConfigData.h"
#import "JSON.h"

#define kLocalCID         @"localCID"


#define SUCCESSFUL(result) (result >= 0)

typedef enum {
    CID_SUB_STATUS_UNKNOWN        = 0x01, //Register successfully but state unknown
    CID_SUB_STATUS_ONLINE         = 0x02,
    CID_SUB_STATUS_PASSWORD_WRONG = 0x03,
    CID_SUB_STATUS_OFFLINE        = 0x04
} CID_SUB_STATUS_INNER;

NSString *const kCIDInfoNumber   = @"AVSCIDNumber";
NSString *const kCIDInfoPassword = @"AVSCIDPassword";
NSString *const kCIDInfoUsername = @"AVSCIDUsername";

NSString *const kPeerStatusCID      = @"cid";
NSString *const kPeerOnlineState    = @"stateflag";
NSString *const kPeerFounctionState = @"founctionflag";

NSString *const kCmdMessageType     = @"msgtype";
NSString *const kCmdMessageIdentity = @"msgindict";
NSString *const kCmdMessageContent  = @"content";

NSString *const kMediaCmdParamSnapshot      = @"snapshot";
NSString *const kMediaCmdParamCamIndex      = @"cameraindex";
NSString *const kMediaCmdParamCamImageType  = @"imagetype";
NSString *const kMediaCmdName               = @"mediaCmd";
NSString *const kMediaCmdParamVideFileName  = @"videfilename";
NSString *const kMediaCmdParamFetchImageType  = @"fetchimagetype";
NSString *const kMediaCmdParamRecordType  = @"recordtype";


NSString *const kTimeoutSegment     = @"TimeSeg";

static void media_data_callback (unsigned long long peercid, unsigned long messageIdentity, unsigned char* data, int len);
static void media_data_error(unsigned long long peercid, unsigned long point, int error_id);

@interface PeerCommand : NSObject

@property (nonatomic, strong) NSString*         commandType;
@property (nonatomic, strong) NSString*         peerCID;
@property (nonatomic, strong) NSDictionary*     commandParameters;
@property (nonatomic, assign) NSTimeInterval    timeoutInterval;
@property (nonatomic, strong) NSNumber*         commandIdentity;
@property (nonatomic, copy) PeerCommandFinished peerCmdFinishedBlock;
@property (nonatomic, copy) PeerCommandFailed   peerCmdFailedBlock;




-(id)initWithCmdType:(NSString*)cmdType
            cmdParam:(NSDictionary*)cmdParam
             timeOut:(NSTimeInterval)timeInterval;


- (void)sendRequestTo:(NSString*)peerID
      completionBlock:(PeerCommandFinished)completionBlock
          failedBlock:(PeerCommandFailed)failedBlock;

@end

@implementation PeerCommand

+ commandWithCmdType:(NSString*)cmdType
            cmdParam:(NSDictionary*)cmdParam
             timeOut:(NSTimeInterval)timeInterval
{
    
    PeerCommand* peerCmd = [[PeerCommand alloc] initWithCmdType:cmdType
                                                       cmdParam:cmdParam
                                                        timeOut:timeInterval];
    
    return peerCmd;
}

-(id)initWithCmdType:(NSString*)cmdType
            cmdParam:(NSDictionary*)cmdParam
             timeOut:(NSTimeInterval)timeInterval
{
    self = [super init];
    
    if (self) {
        self.commandType       = cmdType;
        self.commandParameters = (cmdParam == nil)?[NSDictionary dictionary]:cmdParam;
        self.timeoutInterval   = (timeInterval < 0) ? 0:timeInterval;
    }
    
    return self;
}



- (unsigned long long)requestStreamerTimeZone:(unsigned long long)streamerCID {

    return [[Rvs_Viewer defaultViewer].viewerCmd requestStreamerTimeZone:streamerCID];
}

- (unsigned long long)requestStreamerSDCardInfo:(unsigned long long)streamerCID {

    return [[Rvs_Viewer defaultViewer].viewerCmd requestStreamerSDCardInfo:streamerCID];
}


- (unsigned long long)changeStreamerEncoderQulity:(unsigned long long)streamerCID  {

    
    NSInteger cameraIndex = [[self.commandParameters objectForKey:@"cameraindex"] integerValue];
    int streamIndex = 0;
    NSInteger framerate = [[self.commandParameters objectForKey:@"framerate"] integerValue];
    NSInteger bitrate = [[self.commandParameters objectForKey:@"bitrate"] integerValue];
    NSInteger keyInterval = [[self.commandParameters objectForKey:@"iframeinterval"] integerValue];
    NSInteger quality = [[self.commandParameters objectForKey:@"quality"] integerValue];
    
    
    return [[Rvs_Viewer defaultViewer].viewerCmd changeStreamerEncoderQuality:streamerCID CameraIndex:cameraIndex SreamIndex:streamIndex Bitrate:bitrate FrameRate:framerate IFrameInterval:keyInterval Quality:quality];

}


- (unsigned long long)getStreamerTimeZone:(unsigned long long)streamerCID {
    
    return [[Rvs_Viewer defaultViewer].viewerCmd requestStreamerTimeZone:streamerCID];
}


- (unsigned long long)setStreamerTimeZone:(unsigned long long)streamerCID {

    
    NSString* time = [self.commandParameters objectForKey:@"time"];
    NSInteger timeZone = [[self.commandParameters objectForKey:@"zone"] integerValue];
    BOOL syncFlag = [[self.commandParameters objectForKey:@"syncflag"] boolValue];
    
    return [[Rvs_Viewer defaultViewer].viewerCmd setStreamerTimeZone:streamerCID Time:time TimeZone:timeZone SyncFlag:syncFlag];

}


- (unsigned long long)formatStreamerSDCard:(unsigned long long)streamerCID {
    
     return [[Rvs_Viewer defaultViewer].viewerCmd formatStreamerSDCard:streamerCID];
}

- (unsigned long long)forceIFrameWithStreamer:(unsigned long long)streamerCID {
    
    NSInteger cameraIndex = [[self.commandParameters objectForKey:@"cameraindex"] integerValue];
    NSInteger streamIndex = [[self.commandParameters objectForKey:@"index"] integerValue];
    
    return [[Rvs_Viewer defaultViewer].viewerCmd forceIFrameWithStreamer:streamerCID CameraIndex:cameraIndex SreamIndex:streamIndex ];

}



- (unsigned long long)streamSwitchWithStreamer:(unsigned long long)streamerCID {
    
    NSInteger cameraIndex = 0;
    return [[Rvs_Viewer defaultViewer].viewerCmd streamSwitchWithStreamer:streamerCID CameraIndex:cameraIndex];
}



- (unsigned long long)PTZMoveCtrlWithStreamer:(unsigned long long)streamerCID {
    
    
//    PTZ_TYPE_RESET          = 0,
//    PTZ_TYPE_PAN_HORIZONTAL = 1,
//    PTZ_TYPE_PAN_VERTICAL   = 2,
//    PTZ_TYPE_ZOOM           = 3,
//    PTZ_TYPE_TAP_SINGLE     = 4

    
    NSInteger cameraIndex = 0;
    NSInteger ptzType = [[self.commandParameters objectForKey:@"ptztype"] integerValue];
    NSInteger ptzDirection = [[self.commandParameters objectForKey:@"ptzdirecton"] integerValue];
    
    NSInteger prDirect = (ptzType == 1) ? ptzDirection : 0;
    NSInteger tvDirect = (ptzType == 2) ? ptzDirection : 0;
    NSInteger zfDirect = (ptzType == 3) ? ptzDirection : 0;
    
    return [[Rvs_Viewer defaultViewer].viewerCmd PTZMoveCtrlWithStreamer:streamerCID CameraIndex:cameraIndex Type:EN_RVS_VIEWER_PTZMOVE_CTRL_PTZ PRDirect:prDirect TVDirect:tvDirect ZFDirect:zfDirect];
}

- (unsigned long long)getCameraSettingsInfoWithStreamer:(unsigned long long)streamerCID {
    
    NSDictionary *requestDic = @{@"msgname":@"getAvsDataReq",
                                 @"requestId":[NSString stringWithFormat:@"%llu", (unsigned long long)self]};
    
    
    NSString *jsonStr = [requestDic JSONRepresentation];
    
    NSData *data = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    
    [[Rvs_Viewer defaultViewer].viewerCmd sendCustomDataWithStreamer:streamerCID CustomData:data.bytes DataLen:data.length];
    
    
    return (unsigned long long)self;
}

- (unsigned long long)setCameraLoopVideoWithStreamer:(unsigned long long)streamerCID {
    
    NSDictionary *paramDic = self.commandParameters;
    
    NSDictionary *requestDic = @{@"msgname":@"setLoopVideoReq",
                                 @"requestId":[NSString stringWithFormat:@"%llu", (unsigned long long)self],
                                 @"param" : paramDic};
    
    
    NSString *jsonStr = [requestDic JSONRepresentation];
    
    NSData *data = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    
    [[Rvs_Viewer defaultViewer].viewerCmd sendCustomDataWithStreamer:streamerCID CustomData:data.bytes DataLen:data.length];
    
    
    return (unsigned long long)self;
}


- (unsigned long long)setCameraSoundRecordWithStreamer:(unsigned long long)streamerCID {
    
    NSDictionary *paramDic = self.commandParameters;
    
    NSDictionary *requestDic = @{@"msgname":@"setSoundReq",
                                 @"requestId":[NSString stringWithFormat:@"%llu", (unsigned long long)self],
                                 @"param" : paramDic};
    
    
    NSString *jsonStr = [requestDic JSONRepresentation];
    
    NSData *data = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    
    [[Rvs_Viewer defaultViewer].viewerCmd sendCustomDataWithStreamer:streamerCID CustomData:data.bytes DataLen:data.length];
    
    
    return (unsigned long long)self;
}

- (unsigned long long)setCameraIndicateorLightWithStreamer:(unsigned long long)streamerCID {
    
    NSDictionary *paramDic = self.commandParameters;
    
    NSDictionary *requestDic = @{@"msgname":@"setIndicateorLightReq",
                                 @"requestId":[NSString stringWithFormat:@"%llu", (unsigned long long)self],
                                 @"param" : paramDic};
    
    
    NSString *jsonStr = [requestDic JSONRepresentation];
    
    NSData *data = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    
    [[Rvs_Viewer defaultViewer].viewerCmd sendCustomDataWithStreamer:streamerCID CustomData:data.bytes DataLen:data.length];
    
    
    return (unsigned long long)self;
}

- (unsigned long long)setCameraWarningToneWithStreamer:(unsigned long long)streamerCID {
    
    NSDictionary *paramDic = self.commandParameters;
    
    NSDictionary *requestDic = @{@"msgname":@"setWarningToneReq",
                                 @"requestId":[NSString stringWithFormat:@"%llu", (unsigned long long)self],
                                 @"param" : paramDic};
    
    
    NSString *jsonStr = [requestDic JSONRepresentation];
    
    NSData *data = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    
    [[Rvs_Viewer defaultViewer].viewerCmd sendCustomDataWithStreamer:streamerCID CustomData:data.bytes DataLen:data.length];
    
    
    return (unsigned long long)self;
}

- (unsigned long long)setCameraTouchSensitivityWithStreamer:(unsigned long long)streamerCID {
    
    NSDictionary *paramDic = self.commandParameters;
    
    NSDictionary *requestDic = @{@"msgname":@"setTouchSensitivityReq",
                                 @"requestId":[NSString stringWithFormat:@"%llu", (unsigned long long)self],
                                 @"param" : paramDic};
    
    
    NSString *jsonStr = [requestDic JSONRepresentation];
    
    NSData *data = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    
    [[Rvs_Viewer defaultViewer].viewerCmd sendCustomDataWithStreamer:streamerCID CustomData:data.bytes DataLen:data.length];
    
    
    return (unsigned long long)self;
}

- (unsigned long long)setCameraParkingProtectWithStreamer:(unsigned long long)streamerCID {
    
    NSDictionary *paramDic = self.commandParameters;
    
    NSDictionary *requestDic = @{@"msgname":@"setParkingReq",
                                 @"requestId":[NSString stringWithFormat:@"%llu", (unsigned long long)self],
                                 @"param" : paramDic};
    
    
    NSString *jsonStr = [requestDic JSONRepresentation];
    
    NSData *data = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    
    [[Rvs_Viewer defaultViewer].viewerCmd sendCustomDataWithStreamer:streamerCID CustomData:data.bytes DataLen:data.length];
    
    
    return (unsigned long long)self;
}

- (unsigned long long)changeAVSFileTypeWithStreamer:(unsigned long long)streamerCID {
    
    NSDictionary *paramDic = self.commandParameters;
    
    NSDictionary *requestDic = @{@"msgname":@"setFileStatusReq",
                                 @"requestId":[NSString stringWithFormat:@"%llu", (unsigned long long)self],
                                 @"param" : paramDic};
    
    NSString *jsonStr = [requestDic JSONRepresentation];
    
    NSData *data = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    
    [[Rvs_Viewer defaultViewer].viewerCmd sendCustomDataWithStreamer:streamerCID CustomData:data.bytes DataLen:data.length];
    
    
    return (unsigned long long)self;

}

- (unsigned long long)factoryReset:(unsigned long long)streamerCID {
    
    NSDictionary *paramDic = self.commandParameters;
    
    NSDictionary *requestDic = @{@"msgname":@"setToDefaultReq",
                                 @"requestId":[NSString stringWithFormat:@"%llu", (unsigned long long)self],
                                 @"param" : paramDic};
    
    NSString *jsonStr = [requestDic JSONRepresentation];
    
    NSData *data = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    
    [[Rvs_Viewer defaultViewer].viewerCmd sendCustomDataWithStreamer:streamerCID CustomData:data.bytes DataLen:data.length];
    
    
    return (unsigned long long)self;
    
}

- (unsigned long long)getStorageCapacity:(unsigned long long)streamerCID {
    
    NSDictionary *paramDic = self.commandParameters;
    
    NSDictionary *requestDic = @{@"msgname":@"getSpaceReq",
                                 @"requestId":[NSString stringWithFormat:@"%llu", (unsigned long long)self],
                                 @"param" : paramDic};
    
    
    NSString *jsonStr = [requestDic JSONRepresentation];
    
    NSData *data = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    
    [[Rvs_Viewer defaultViewer].viewerCmd sendCustomDataWithStreamer:streamerCID CustomData:data.bytes DataLen:data.length];
    
    
    return (unsigned long long)self;
    
}

- (unsigned long long)getUserLocation:(unsigned long long)streamerCID {
    
    NSDictionary *paramDic = self.commandParameters;
    
    NSDictionary *requestDic = @{@"msgname":@"getLocationReq",
                                 @"requestId":[NSString stringWithFormat:@"%llu", (unsigned long long)self],
                                 @"param" : paramDic};
    
    NSString *jsonStr = [requestDic JSONRepresentation];
    
    NSData *data = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    
    [[Rvs_Viewer defaultViewer].viewerCmd sendCustomDataWithStreamer:streamerCID CustomData:data.bytes DataLen:data.length];
    
    
    return (unsigned long long)self;
    
}

- (unsigned long long)upGradeHardVersion:(unsigned long long)streamerCID {
    
    NSDictionary *paramDic = self.commandParameters;
    
    NSDictionary *requestDic = @{@"msgname":@"setupdateHardDriversReq",
                                 @"requestId":[NSString stringWithFormat:@"%llu", (unsigned long long)self],
                                 @"param" : paramDic};
    
    
    NSString *jsonStr = [requestDic JSONRepresentation];
    
    NSData *data = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    
    [[Rvs_Viewer defaultViewer].viewerCmd sendCustomDataWithStreamer:streamerCID CustomData:data.bytes DataLen:data.length];
    
    
    return (unsigned long long)self;
    
}

- (unsigned long long)getRecordDayListWithStreamer:(unsigned long long)streamerCID {
    
    NSInteger pageIndex = [[self.commandParameters objectForKey:@"pageindex"] intValue];
    NSInteger countPerPage = [[self.commandParameters objectForKey:@"filenumberperpage"] intValue];
    NSInteger recordType = [[self.commandParameters objectForKey:@"filetype"] intValue];
    
    
    return [[Rvs_Viewer defaultViewer].viewerMedia requestStreamerRecordDayListWithStreamer:streamerCID
                                                                                CameraIndex:0
                                                                                  PageIndex:pageIndex
                                                                               CountPerPage:countPerPage
                                                                                 RecordType:recordType];
    
    
}



- (unsigned long long)setCameraQualityWithStreamer:(unsigned long long)streamerCID {
    
    NSDictionary *paramDic = self.commandParameters;
    
    NSDictionary *requestDic = @{@"msgname":@"setQualityReq",
                                 @"requestId":[NSString stringWithFormat:@"%llu", (unsigned long long)self],
                                 @"param" : paramDic};
    
    
    NSString *jsonStr = [requestDic JSONRepresentation];
    
    NSData *data = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    
    [[Rvs_Viewer defaultViewer].viewerCmd sendCustomDataWithStreamer:streamerCID CustomData:data.bytes DataLen:data.length];
    
    return (unsigned long long)self;
    
}

- (unsigned long long)setStreamerName:(unsigned long long)streamerCID {
    
    NSString* newname = [self.commandParameters objectForKey:@"newname"];
    
    [[Rvs_Viewer defaultViewer].viewerStreamerInfo setStreamer:streamerCID Name:newname];

    
    
    //这里特别注意，由于修改设备名称在新的sdk里不在是一个command命令，这里为了能兼容旧的command的命令已经兼容旧的处理方式，这里需要虚构一个handle，这里就使用self，并且需要立即虚构一个成功响应
    

    [self simulateOldSDKRecvSucessResponse];
   
    return (unsigned long long)self;
    
}



- (unsigned long long)requestStreamerRecordFilesWithStreamer:(unsigned long long)streamerCID {
    
    
    
    NSInteger cameraIndex = [[self.commandParameters objectForKey:@"cameraindex"] integerValue];
    

    NSInteger pageIndex = [[self.commandParameters objectForKey:@"pageindex"] integerValue];
    
    //新的sdk从1开始，旧的从0开始
   // pageIndex += 1;
    
    NSInteger rowCount = [[self.commandParameters objectForKey:@"filenumberperpage"] integerValue];
    NSInteger fileType = [[self.commandParameters objectForKey:@"filetype"] integerValue];
    
    NSString* begintime = nil;
    NSString* endtime = nil;
    
    //兼容旧协议的参数
//    if (cameraIndex == 99) {
//        cameraIndex = -1;
//    }

    begintime = [self.commandParameters objectForKey:@"date"];
    endtime = [self.commandParameters objectForKey:@"date"];
    
//    if ([begintime isEqualToString:@"all"]) {
//        
//        begintime = @"2013-01-01 00:00:00";
//        endtime = @"2100-01-01 00:00:00";
//    }
//    else {
//        
        //规整下时间
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        
        [dateFormatter setDateFormat: @"yyyyMMdd"];
    
        NSDate* destDate= [dateFormatter dateFromString:begintime];
    
    
        NSDateFormatter *dstDateFormatter = [[NSDateFormatter alloc] init];
    
        [dstDateFormatter setDateFormat: @"yyyy-MM-dd"];
    
    
        NSString* destDateString = [dstDateFormatter stringFromDate:destDate];
        
        begintime = [NSString stringWithFormat:@"%@ 00:00:00", destDateString];
        endtime = [NSString stringWithFormat:@"%@ 23:59:59", destDateString];
//    }


    return [[Rvs_Viewer defaultViewer].viewerMedia requestStreamerRecordFilesWithStreamer:streamerCID
                                                                       CameraIndex:cameraIndex
                                                                         PageIndex:pageIndex
                                                                      CountPerPage:rowCount
                                                                         BeginTime:begintime
                                                                           EndTime:endtime
                                                                        RecordType:fileType];
    
}


- (unsigned long long)removeRecordFileByNameWithStreamer:(unsigned long long)streamerCID {
    
    NSString* filename = [self.commandParameters objectForKey:@"filename"];
    NSInteger fileType = [[self.commandParameters objectForKey:@"filetype"] integerValue];
    NSString *selectedDate = [self.commandParameters objectForKey:@"selecteddate"];
    
    if ([filename isEqualToString:@"all"]){
    
        return [[Rvs_Viewer defaultViewer].viewerMedia removeAllRecordFilesWithStreamer:streamerCID RecordType:fileType selectedDate:selectedDate];
        
    }
    
    
    return [[Rvs_Viewer defaultViewer].viewerMedia removeRecordFileByNameWithStreamer:streamerCID
                                                                             FileName:filename
                                                                           RecordType:fileType];
    
}

- (unsigned long long)removeRecordFileByNameWithStreamer:(unsigned long long)streamerCID selectedDate:(NSString *)selectedDate {
    
    //NSString* filename = [self.commandParameters objectForKey:@"filename"];
    NSInteger fileType = [[self.commandParameters objectForKey:@"filetype"] integerValue];
    
    
    return [[Rvs_Viewer defaultViewer].viewerMedia removeAllRecordFilesWithStreamer:streamerCID RecordType:fileType selectedDate:selectedDate];
    
    
}



- (unsigned long long)setMotionSettingWithStreamer:(unsigned long long)streamerCID {

    NSInteger cameraIndex = [[self.commandParameters objectForKey:@"cameraindex"] integerValue];
    
    NSMutableArray* motionSettingArray = [NSMutableArray arrayWithCapacity:3];
    NSArray* motionSettings = [self.commandParameters objectForKey:@"motionsettings"];
    
    NSInteger i = 0;
    for (NSDictionary* motionDic in motionSettings) {
    
    
        RvsMotionDetectSetting* rmds = [[RvsMotionDetectSetting alloc] init];
        rmds.sensitive = [[motionDic objectForKey:@"sensitivity"] integerValue];
        
        
        RvsScheduleSetting* rss = [[RvsScheduleSetting alloc] init];
        
        rss.enable = [[motionDic objectForKey:@"motionstatus"] integerValue];
        rss.seq = i;
        rss.startPoint = [[motionDic objectForKey:@"starttime"] integerValue];
        rss.endPoint = [[motionDic objectForKey:@"endtime"] integerValue];
        rss.weekFlag = [[motionDic objectForKey:@"dayFlag"] integerValue];
        
        
        rmds.schedule = rss;
        
        
        [motionSettingArray addObject:rmds];
        
        i++;
    }
    
    
    
    RvsStreamerAlarmRecordInfo* rai = [[RvsStreamerAlarmRecordInfo alloc] init];
    rai.scheduleSettings = motionSettingArray;
    rai.camIndex = cameraIndex;
    //rai.setFlag = [[self.commandParameters objectForKey:@"setFlag"] integerValue];
    
    [[Rvs_Viewer defaultViewer].viewerStreamerInfo setStreamer:streamerCID
                                                   CameraIndex:cameraIndex
                                               AlarmRecordInfo:rai];
    
    

    NSUInteger alarmSetFlag = [[Rvs_Viewer defaultViewer].viewerStreamerInfo getStreamerDetectFlag:streamerCID];
    
    [self simulateOldSDKRecvSucessResponseWithAlarmSetFlag:alarmSetFlag];
    
    return (unsigned long long)self;
    
}

- (unsigned long long)setAlarmSettingWithStreamer:(unsigned long long)streamerCID {
    
    
    BOOL emailEnable = [[self.commandParameters objectForKey:@"emailalertstatus"] boolValue];
    NSString* emailAddr = [self.commandParameters objectForKey:@"emailaddr"];
    BOOL pushEnable = [[self.commandParameters objectForKey:@"pushalertstatus"] boolValue];
    
    
    [[Rvs_Viewer defaultViewer].viewerStreamerInfo setStreamer:streamerCID EmailEnable:emailEnable EmailAddr:emailAddr];
    [[Rvs_Viewer defaultViewer].viewerStreamerInfo setStreamer:streamerCID PushEnable:pushEnable];
    

    [self simulateOldSDKRecvSucessResponse];
    
    
    return (unsigned long long)self;
    
}

- (unsigned long long)setTimeRecordSettingWithStreamer:(unsigned long long)streamerCID {
    
    
    NSInteger cameraIndex = [[self.commandParameters objectForKey:@"cameraindex"] integerValue];
    
    NSMutableArray* recordSettingArray = [NSMutableArray arrayWithCapacity:3];
    NSArray* recordSettings = [self.commandParameters objectForKey:@"recordingsettings"];
    
    NSInteger i = 0;
    for (NSDictionary* recordDic in recordSettings) {
        
        
        RvsTimeRecordSetting* rmds = [[RvsTimeRecordSetting alloc] init];
        
        RvsScheduleSetting* rss = [[RvsScheduleSetting alloc] init];
        
        rss.enable = [[recordDic objectForKey:@"recordingstatus"] integerValue];
        rss.seq = i;
        rss.startPoint = [[recordDic objectForKey:@"starttime"] integerValue];
        rss.endPoint = [[recordDic objectForKey:@"endtime"] integerValue];
        rss.weekFlag = K_WEEKFLAG_ALLDAY;
        
        
        rmds.schedule = rss;
        
        
        [recordSettingArray addObject:rmds];
        
        i++;
    }
    
    
    
    RvsStreamerTimeRecordInfo* rstr = [[RvsStreamerTimeRecordInfo alloc] init];
    rstr.scheduleSettings = recordSettingArray;
    rstr.camIndex = cameraIndex;
    //rstr.setFlag = [[self.commandParameters objectForKey:@"setFlag"] integerValue];
    
    [[Rvs_Viewer defaultViewer].viewerStreamerInfo setStreamer:streamerCID
                                                   CameraIndex:cameraIndex
                                               TimeReocrdInfo:rstr];
    
    

    [self simulateOldSDKRecvSucessResponse];
    
    return (unsigned long long)self;

    
}

- (unsigned long long)setAutoDeleteSettingWithStreamer:(unsigned long long)streamerCID {
    
    
    NSUInteger autoDelDays = [[self.commandParameters objectForKey:@"autodeldays"] integerValue];
    BOOL autoDelStatus = [[self.commandParameters objectForKey:@"autodelstatus"] boolValue];
    
    int delDay = autoDelStatus ? autoDelDays : 0;
    
    
    [[Rvs_Viewer defaultViewer].viewerStreamerInfo setStreamer:streamerCID RecordDelDays:delDay];
    
 
    [self simulateOldSDKRecvSucessResponse];
    
    
    return (unsigned long long)self;
    
}

- (unsigned long long)sendTestEmailWithStreamer:(unsigned long long)streamerCID {
    
    
    return 0;
    
}

- (unsigned long long)setDetectFlagWithStreamer:(unsigned long long)streamerCID {
    
    
    NSInteger setFlag = [[self.commandParameters objectForKey:@"setFlag"] integerValue];
    
    [[Rvs_Viewer defaultViewer].viewerStreamerInfo setStreamer:streamerCID DetectFlag:setFlag];
    
    

    [self simulateOldSDKRecvSucessResponse];
    
    return (unsigned long long)self;
    
}

- (unsigned long long)changeStreamerNameAndPwdWithStreamer:(unsigned long long)streamerCID{
    
    NSString* userName = [self.commandParameters objectForKey:@"username"];
    NSString* pwd = [self.commandParameters objectForKey:@"password"];

    
    return [[Rvs_Viewer defaultViewer].viewerCmd changeStreamerLoginInfo:streamerCID UserName:userName Password:pwd];
    
}

- (void)simulateOldSDKRecvSucessResponseWithAlarmSetFlag:(NSUInteger)alarmSetFlag{
    
    unsigned long long identity = (unsigned long long)self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSDictionary* parameters = @{@"status" : [NSNumber numberWithInt:0],
                                     @"alarmSetFlag": [NSNumber numberWithInt:alarmSetFlag]};
        [[AHCServerCommunicator sharedAHCServerCommunicator] onCommandFinished:parameters
                                                                   cmdIdentity:[NSNumber numberWithUnsignedLongLong:identity]];
        
    });
    
}

- (void)simulateOldSDKRecvSucessResponse{
    
    unsigned long long identity = (unsigned long long)self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSDictionary* parameters = @{@"status" : [NSNumber numberWithInt:0]};
        [[AHCServerCommunicator sharedAHCServerCommunicator] onCommandFinished:parameters
                                                                   cmdIdentity:[NSNumber numberWithUnsignedLongLong:identity]];
        
    });
    
}



- (void)sendRequestTo:(NSString*)peerCID
      completionBlock:(PeerCommandFinished)completionBlock
          failedBlock:(PeerCommandFailed)failedBlock
{
    
    NSInteger result = 1;
    if (SUCCESSFUL(result)) {
        self.peerCmdFinishedBlock = completionBlock;
        self.peerCmdFailedBlock   = failedBlock;
        self.peerCID              = peerCID;
    }
    else{
        failedBlock(COMMAND_ERROR_REQUEST_FAILED);
    }
}

@end

@interface PeerMeidaCommand : PeerCommand
{
    NSUInteger cameraIndex;
    NSUInteger imageType;
    
    NSUInteger fetchImageType;
    
}

@property (nonatomic, copy) NSString* videoFileName;
@property (nonatomic, assign) NSUInteger recordType;

-(id)initWithCmdType:(NSString*)cmdType
            cmdParam:(NSDictionary*)cmdParam
             timeOut:(NSTimeInterval)timeInterval;


- (void)sendRequestTo:(NSString*)peerCID
      completionBlock:(PeerCommandFinished)completionBlock
          failedBlock:(PeerCommandFailed)failedBlock;



@end

@implementation PeerMeidaCommand

+ commandWithCmdType:(NSString*)cmdType
            cmdParam:(NSDictionary*)cmdParam
             timeOut:(NSTimeInterval)timeInterval
{
    
    PeerMeidaCommand* peerCmd = [[PeerMeidaCommand alloc] initWithCmdType:cmdType
                                                                 cmdParam:cmdParam
                                                                  timeOut:timeInterval];
    
    return peerCmd;
}


-(id)initWithCmdType:(NSString*)cmdType
            cmdParam:(NSDictionary*)cmdParam
             timeOut:(NSTimeInterval)timeInterval
{
    self = [super initWithCmdType:cmdType cmdParam:cmdParam timeOut:timeInterval];
    
    if (self) {
        
        fetchImageType = [[cmdParam objectForKey:kMediaCmdParamFetchImageType] integerValue];
        
        if (fetchImageType == E_FETCH_SNAPSHOT) {
            
            imageType   = [[cmdParam objectForKey:kMediaCmdParamCamImageType] integerValue];
            cameraIndex = [[cmdParam objectForKey:kMediaCmdParamCamIndex] integerValue];
        }
        else {
            
            self.videoFileName = [cmdParam objectForKey:kMediaCmdParamVideFileName];
            self.recordType = [[cmdParam objectForKey:kMediaCmdParamRecordType] integerValue];
        }
        
        
        
    }
    
    return self;
}


- (void)sendRequestTo:(NSString*)peerCID
      completionBlock:(PeerCommandFinished)completionBlock
          failedBlock:(PeerCommandFailed)failedBlock
{
    
    unsigned long long requestID = 0;
    
    if (fetchImageType == E_FETCH_SNAPSHOT) {
        
        requestID = [[Rvs_Viewer defaultViewer].viewerMedia requestJpegWithStreamer:[peerCID longLongValue] CameraIndex:cameraIndex JpegType:imageType];
    }
    else {
        
        requestID = [[Rvs_Viewer defaultViewer].viewerMedia requestJpegFileWithStreamerEx:[peerCID longLongValue] FileName:self.videoFileName RecordType:self.recordType];
    }
    
    self.commandIdentity = [NSNumber numberWithUnsignedLongLong:requestID];
    
    
    
    self.peerCmdFinishedBlock = completionBlock;
    self.peerCmdFailedBlock   = failedBlock;
    self.peerCID              = peerCID;
    
}

@end


@interface AHCServerCommunicator() <Rvs_Viewer_Delegate, Rvs_Viewer_Cmd_Delegate, Rvs_Viewer_Media_StreamState_Delegate, Rvs_Viewer_Media_RevStream_Delegate, Rvs_Viewer_Media_RecvJpeg_Delegate, Rvs_Viewer_Media_RecordFile_Delegate,Rvs_Viewer_StreamerInfo_Delegate>
{
    dispatch_queue_t commandQueue;
    dispatch_source_t  checkCmdTimeoutTimer;
    dispatch_queue_t channelQueue;
}

@property (nonatomic, strong) NSMutableDictionary* observerDict;
@property (nonatomic, strong) NSMutableDictionary* commandDict;

@property (nonatomic, strong) NSMutableDictionary* sessionStateDic;
@property (nonatomic, strong) NSString* sessionStateMutex;


-(void) onCommandFailed:(NSInteger)ErrorCode peerCID:(NSString*)peerCID;
-(void) onCommandFinished:(NSDictionary*)returnValue cmdIdentity:(NSNumber*)identity;

@end


@implementation AHCServerCommunicator

+ (AHCServerCommunicator *)sharedAHCServerCommunicator {
    static AHCServerCommunicator *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[AHCServerCommunicator alloc] init];
    });
    return shared;
}

+ (void)initialize
{
    
}




+ (NSString*)classToKey:(Class)keyValue
{
    return [NSString stringWithFormat:@"ALL-%@", keyValue];
}

-(id)init
{
    self = [super init];
    
    if (self) {
        self.observerDict = [NSMutableDictionary dictionaryWithCapacity:0];
        self.commandDict  = [NSMutableDictionary dictionaryWithCapacity:0];
        self.sessionStateDic  = [[NSMutableDictionary alloc] initWithCapacity:3];
        
        commandQueue = dispatch_queue_create("commandQueue", DISPATCH_QUEUE_SERIAL);
        channelQueue = dispatch_queue_create("channelQueueInCommunication", DISPATCH_QUEUE_SERIAL);
    }
    
    return self;
}


- (void)start {
    
    Rvs_Viewer* viewer = [Rvs_Viewer defaultViewer];
    viewer.delegate = self;
    viewer.viewerStreamerInfo.delegate = self;
    viewer.viewerMedia.streamStateDelegate = self;
    viewer.viewerMedia.RecvJpegDelegate = self;
    viewer.viewerMedia.recordFileDelegate = self;
    viewer.viewerCmd.delegate = self;
    
    
    NSString *appVersion  = [[[NSBundle mainBundle] infoDictionary]
                             valueForKey:[NSString stringWithFormat:@"CFBundleShortVersionString"]];
    
    [viewer initViewerWithWorkPath:[CommonUtility getSDKWorkPath] CachePath:[CommonUtility getSDKCachePath] AppVersion:appVersion];
    [viewer setLoginInfoWithCompanyID:KCompanyID CompanyKey:KCompanyKey AppID:KAppID License:nil Symbol:nil];
    
#if defined(DEBUG)
    [viewer setLogEnabled:YES];
#endif
    
    
    RvsMediaAVDesc* avdes = [[RvsMediaAVDesc alloc] init];
    
    avdes.audioType = E_RVS_VIEWER_AUDIO_TYPE_G711U;
    avdes.channel = 1;
    avdes.sampleRate = 8000;
    avdes.depth = 16;
    
    [viewer.viewerMedia setRevStreamProperty:avdes];
    
    [viewer login];
    
    [self loadLocalCIDConfigFromSDK];
    
}

- (void)stop {
    
    Rvs_Viewer* viewer = [Rvs_Viewer defaultViewer];
    [viewer logout];
}


- (void)loadLocalCIDConfigFromSDK {
    
    
    NSArray* cidlist = [[MemberData memberData] getMemberCIDList];
    
    
    for (NSDictionary* cidinfo in cidlist) {
        
        NSString* cidStr = [cidinfo objectForKey:kMemberCIDNumber];
        
        if (cidStr == nil) {
            
            continue;
        }
        
        unsigned long long cid = [cidStr longLongValue];
        NSString* userName = [cidinfo objectForKey:kMemberCIDUserName];
        NSString* pwd = [cidinfo objectForKey:kMemberCIDPassword];
        
        [[Rvs_Viewer defaultViewer] connectStreamer:cid UserName:userName Password:pwd];
        
        AVSConfigData* configData = [self getAvsConfigFromSDK:cid];
        
        if (configData) {
            
            [[MemberData memberData] updateDetailConfigInfo:configData ForCID:cidStr];
        }
        
    }
    
    
}



-(void)subscribeCID:(NSDictionary*)CIDInfo
{
    unsigned long long cid = [[CIDInfo objectForKey:kCIDInfoNumber] longLongValue];
    NSString* userName = [CIDInfo objectForKey:kCIDInfoUsername];
    NSString* pwd = [CIDInfo objectForKey:kCIDInfoPassword];
    
    Rvs_Viewer* viewer = [Rvs_Viewer defaultViewer];
    [viewer connectStreamer:cid UserName:userName Password:pwd];
    
}

-(void)resubscribeCID:(NSDictionary*)CIDInfo
{
    //[self unsubscribeCID:CIDInfo];
    [self subscribeCID:CIDInfo];
}

-(void)unsubscribeCID:(NSDictionary*)CIDInfo
{
    NSString* CIDStr = [CIDInfo objectForKey:kCIDInfoNumber];
    
    if (!CIDStr) {
        
        return;
    }
    
    unsigned long long cid = [CIDStr longLongValue];
    Rvs_Viewer* viewer = [Rvs_Viewer defaultViewer];
    [viewer disconnectStreamer:cid];
    
    //cid删除后，本地存的presence和tunnel status 要清除
    [[MemberData memberData] removeAvsStatusforCID:CIDStr];
    [[MemberData memberData] removeAvsTunnelStatusforCID:CIDStr];
}

#pragma mark - Observer Managerment

- (void)addObserver:(NSObject<AHCServerCommunicatorDelegate>*)observer
{
    [self.observerDict setObject:observer
                          forKey:[AHCServerCommunicator classToKey:[observer class]]];
}

- (void)addObserver:(NSObject<AHCServerCommunicatorDelegate>*)observer
             forCID:(NSString*)CIDNumber
{
    [self.observerDict setObject:observer forKey:CIDNumber];
}

- (void)removeObserver:(NSObject<AHCServerCommunicatorDelegate>*)observer
{
    NSArray* keyArray = [self.observerDict allKeysForObject:observer];
    [self.observerDict removeObjectsForKeys:keyArray];
}

#pragma mark - Command Msg

-(COMMAND_HANDLER) sendCommandToPeer:(NSString *)peerID
                             cmdName:(NSString *)cmdName
                            cmdParam:(NSDictionary *) cmdParam
                             timeout:(NSTimeInterval)timeinterval
                     completionBlock:(PeerCommandFinished) completionBlock
                         failedBlock:(PeerCommandFailed) failedBlock

{
    /*__block*/ COMMAND_HANDLER handler;
    
    PeerCommand* peerCmd = nil;
    
    if ([cmdName isEqualToString:kMediaCmdName]) {
        peerCmd = [PeerMeidaCommand commandWithCmdType:cmdName cmdParam:cmdParam timeOut:timeinterval];
    }
    else {
        peerCmd = [PeerCommand commandWithCmdType:cmdName cmdParam:cmdParam timeOut:timeinterval];
    }
    
    //这个的第一个就找到了
    [peerCmd sendRequestTo:peerID completionBlock:completionBlock failedBlock:failedBlock];
    
    handler = [peerCmd.commandIdentity longValue];
    
    dispatch_async(commandQueue, ^{
        
        //if (handler) {
        
        HWLog(@"=================%@=====================%@",peerCmd,peerCmd.commandIdentity);
        
        [self startTimeoutTimer];
        // }
        
        
        
    });
    
    return handler;
}

-(void)cancelCommand:(COMMAND_HANDLER)handler
{
    dispatch_async(commandQueue, ^{
        if ([[self.commandDict allKeys] containsObject:[NSNumber numberWithUnsignedLongLong:handler]]) {
            
            [self.commandDict removeObjectForKey:[NSNumber numberWithUnsignedLongLong:handler]];
            
            [self timeoutTimerStopCheck];
        }
    });
}

-(void) onCommandFinished:(NSDictionary*)returnValue cmdIdentity:(NSNumber*)identity
{
    dispatch_async(commandQueue, ^{
        
        if ([[self.commandDict allKeys] containsObject:identity]) {
            PeerCommand* peerCmd = (PeerCommand*)[self.commandDict objectForKey:identity];
            
            PeerCommandFinished finishBlock = peerCmd.peerCmdFinishedBlock;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                finishBlock(returnValue);
                
            });
            
            [self.commandDict removeObjectForKey:identity];
            [self timeoutTimerStopCheck];
        }
        
        
    });

}

-(void) onCommandFailed:(NSInteger)ErrorCode peerCID:(NSString*)peerCID
{
    dispatch_async(commandQueue, ^{
        
        NSMutableArray* errorItem = [NSMutableArray arrayWithCapacity:0];
        
        [self.commandDict enumerateKeysAndObjectsUsingBlock:^(id key, PeerCommand* peerCmd, BOOL *stop) {
            
            if ([peerCmd.peerCID isEqualToString:peerCID]) {
                
                PeerCommandFailed failBlock = peerCmd.peerCmdFailedBlock;
                [errorItem addObject:key];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    failBlock(COMMAND_ERROR_REQUEST_FAILED);
                    
                });
            }
            
        }];
        
        [self.commandDict removeObjectsForKeys:errorItem];
        [self timeoutTimerStopCheck];
        
    });

}

-(void)onUpdateTimeupCmd
{
    
    // dispatch_async(commandQueue, ^{
    NSMutableArray* timeupItem = [NSMutableArray arrayWithCapacity:0];
    [self.commandDict enumerateKeysAndObjectsUsingBlock:^(id key, PeerCommand* cmd, BOOL *stop) {
        cmd.timeoutInterval = cmd.timeoutInterval - 1;
        
        if (cmd.timeoutInterval <= 0) {
            [timeupItem addObject:key];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (cmd.peerCmdFailedBlock) {
                    
                    cmd.peerCmdFailedBlock(COMMAND_ERROR_REQUEST_TIMEOUT);
                }
            });
        }
    }];
    
    [self.commandDict removeObjectsForKeys:timeupItem];
    [self timeoutTimerStopCheck];
    //  });
}


#pragma mark -  Rvs_Viewer_Cmd_Delegate




- (void)onRecvCustomData:(unsigned char*) dataBuffer
                 DataLen:(NSUInteger)BufferLen
             FromPeerCID:(unsigned long long)peerCID {
    
    
    @autoreleasepool {
        
        NSString* jsonString = [[NSString alloc] initWithBytes:dataBuffer length:BufferLen encoding:NSUTF8StringEncoding];
        
        
        if (!jsonString){
            
            return ;
        }
        
        
        NSData* jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        
        
        if (!jsonData){
            
            return;
        }
        
        
        NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:nil];
        
        
        if (!dic){
            
            return;
        }
        
        NSString* requestIDStr = [dic objectForKey:@"request"];
        
        if (!requestIDStr) {
            
            return;
        }
        
        NSDictionary* paramDic = [dic objectForKey:@"paarm"];
        
        if (!paramDic) {
            
            return;
        }
        
        
        [[AHCServerCommunicator sharedAHCServerCommunicator] onCommandFinished:paramDic
                                                                   cmdIdentity:[NSNumber numberWithUnsignedLongLong:[requestIDStr longLongValue]]];
        
        
        
    }
    
    
}


- (void)onCmdRequestStatusWithRequestID:(unsigned long long)requestID
                              ErrorCode:(NSInteger)errorCode {
    
    @autoreleasepool {
        
        NSDictionary* parameters = @{@"statsu" : [NSNumber numberWithInt:errorCode]};
        [[AHCServerCommunicator sharedAHCServerCommunicator] onCommandFinished:parameters
                                                                   cmdIdentity:[NSNumber numberWithUnsignedLongLong:requestID]];
    }
    
}


- (void)onCmdTimeGetResultWithRequestID:(unsigned long long)requestID
                              ErrorCode:(NSInteger)errorCode
                                   Time:(NSString*)time
                               TimeZone:(NSInteger)timeZone
                               SyncFlag:(BOOL)syncFlag {
    
    @autoreleasepool {
        
        NSDictionary* parameters = @{@"status" : [NSNumber numberWithInt:errorCode],
                                     @"tmie": time,
                                     @"zone": [NSNumber numberWithLong:timeZone],
                                     @"syncflag":[NSNumber numberWithBool:syncFlag]};
        
        
        [[AHCServerCommunicator sharedAHCServerCommunicator] onCommandFinished:parameters
                                                                   cmdIdentity:[NSNumber numberWithUnsignedLongLong:requestID]];
    }
}


- (void)onCmdSDCardInfoGetResultWithRequestID:(unsigned long long)requestID
                                    ErrorCode:(NSInteger)errorCode
                                    TotalSize:(unsigned long long)totalSize
                                   RemainSize:(unsigned long long)remainSize {
    
    @autoreleasepool {
        
        NSDictionary* parameters = @{@"status" : [NSNumber numberWithInt:errorCode],
                                     @"sdktotalsize": [NSNumber numberWithLong:totalSize],
                                     @"sdkfreesize": [NSNumber numberWithLong:remainSize]};
        
        [[AHCServerCommunicator sharedAHCServerCommunicator] onCommandFinished:parameters
                                                                   cmdIdentity:[NSNumber numberWithUnsignedLongLong:requestID]];
    }
    
}


- (void)onCmdWifiStateGetResultWithRequestID:(unsigned long long)requestID
                                   ErrorCode:(NSInteger)errorCode
                                   WifiState:(NSUInteger)wifiState {
    @autoreleasepool {
        
        NSDictionary* parameters = @{@"status" : [NSNumber numberWithInt:errorCode]};
        [[AHCServerCommunicator sharedAHCServerCommunicator] onCommandFinished:parameters
                                                                   cmdIdentity:[NSNumber numberWithUnsignedLongLong:requestID]];
    }
    
}

#pragma mark - Rvs_Viewer_Media_RecordFile_Delegate


- (void)onRecordFilesWithRequestID:(unsigned long long)requestID
                        TotalCount:(NSUInteger)totalCount
                      CurrentCount:(NSUInteger)currentCount
                          FileInfo:(NSArray*)FileInfos {
    
    @autoreleasepool {
        
        NSMutableArray* fileList = [NSMutableArray arrayWithCapacity:3];
        
        for (RvsRecordFileInfo* file in FileInfos) {
            
            NSDictionary* fileDic = @{@"createtime" : file.createTime,
                                      @"filename" : file.fileName,
                                      @"filesize" : [NSString stringWithFormat:@"%lu", (unsigned long)file.fileSize],
                                      @"profileimageaddr" :@"1", //是否有icon
                                      @"timerange" : [NSString stringWithFormat:@"%lu", (unsigned long)file.fileDuration],
                                      @"iconExname" : file.iconExname
                                      };
            
            [fileList addObject:fileDic];
            
        }
        
        
        
        
        NSDictionary* parameters = @{@"status" : [NSNumber numberWithInt:0],
                                     @"filelist" : fileList};
        [[AHCServerCommunicator sharedAHCServerCommunicator] onCommandFinished:parameters
                                                                   cmdIdentity:[NSNumber numberWithUnsignedLongLong:requestID]];
    }
    
}

- (void)onRecordFileDeleteStatusWithRequestID:(unsigned long long)requestID
                                       Status:(BOOL)status {
    
    @autoreleasepool {
        
        NSDictionary* parameters = @{@"status" : [NSNumber numberWithInt:status ? 0 : -1]};
        [[AHCServerCommunicator sharedAHCServerCommunicator] onCommandFinished:parameters
                                                                   cmdIdentity:[NSNumber numberWithUnsignedLongLong:requestID]];
    }
    
}



- (void)onRecordDayListWithRequestID:(unsigned long long)requestID
                          TotalCount:(NSUInteger)totalCount
                        CurrentCount:(NSUInteger)currentCount
                             DayInfo:(NSArray*)dayInfos {
    
    
    @autoreleasepool {
        
        
        //        NSDictionary* parameters = nil;
        //
        //        if (!dayInfos) {
        //
        //            parameters = @{@"status" : [NSNumber numberWithInt:0],
        //                           @"daylist" : [NSNull null]};
        //        }else{
        //
        //            parameters = @{@"status" : [NSNumber numberWithInt:0],
        //                           @"daylist" : dayInfos};
        //        }
        
        int status = dayInfos ? 0 : -1;
        NSArray *parameterDayInfos = dayInfos ? dayInfos : @[];
        
        NSDictionary* parameters = @{@"status" : [NSNumber numberWithInt:status],
                                     @"daylist" : parameterDayInfos};
        
        
        [[AHCServerCommunicator sharedAHCServerCommunicator] onCommandFinished:parameters
                                                                   cmdIdentity:[NSNumber numberWithUnsignedLongLong:requestID]];
    }
    
}





#pragma mark - Rvs_Viewer_Delegate
//连接状态通知
- (void)onLoginResultWithLoginState:(EN_RVS_VIEWER_LOGIN_STATE)loginState
                       ProgressRate:(EN_RVS_VIEWER_LOGIN_PROGRESS)progressRate
                            errCode:(EN_RVS_VIEWER_LOGIN_ERR)errCode {
    
    
    @synchronized(_sessionStateMutex) {
        
        [_sessionStateDic removeAllObjects];
        
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [[MemberData memberData] clearAllAvsStatus];
        [[MemberData memberData] clearAllAvsTunnelStatus];
        
        NSDictionary* observerDict = [AHCServerCommunicator sharedAHCServerCommunicator].observerDict;
        
        [observerDict enumerateKeysAndObjectsUsingBlock:^(NSString* key, id<AHCServerCommunicatorDelegate> delegate, BOOL *stop) {
            
            if ([delegate respondsToSelector:@selector(onRecieveConnectServerStatusChanged:)]) {
                [delegate onRecieveConnectServerStatusChanged:loginState];
            }
        }];
        
    });
    
    
}

//CID变化通知
- (void)onUpdateCID:(unsigned long long)localCID {
    
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithUnsignedLongLong:localCID] forKey:kLocalCID];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
}

- (int)getSessionState:(unsigned long long)streamerCID {
    
    
    @synchronized(_sessionStateMutex) {
        
        @autoreleasepool {
            
            NSString* sessionStr = [_sessionStateDic objectForKey:[NSString stringWithFormat:@"%llu", streamerCID]];
            
            if (sessionStr) {
                
                return [sessionStr integerValue];
            }
            
            return 0;
        }
        
        
    }
}


- (void)onStreamer:(unsigned long long)streamerCID
         ConnState:(EN_RVS_STREAMER_CONN_STATE)streamerConnState {
    
    
    @synchronized(_sessionStateMutex) {
        
        @autoreleasepool {
            
            [_sessionStateDic setObject:[NSString stringWithFormat:@"%d", streamerConnState] forKey:[NSString stringWithFormat:@"%llu", streamerCID]];
        }
    }
    
    [CommonUtility notifyStreamerSessionStateWithCID:streamerCID SessionState:streamerConnState];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSString* peerCID = [NSString stringWithFormat:@"%llu",streamerCID];
        [[MemberData  memberData] setAvsTunnelStatus:streamerConnState forCID:peerCID];
        
        
        NSDictionary* observerDict = [AHCServerCommunicator sharedAHCServerCommunicator].observerDict;
        
        [observerDict enumerateKeysAndObjectsUsingBlock:^(NSString* key, id<AHCServerCommunicatorDelegate> delegate, BOOL *stop) {
            
            if ([key hasPrefix:@"ALL"] ||
                [key isEqualToString:[NSString stringWithFormat:@"%llu", streamerCID]]) {
                
                if ([delegate respondsToSelector:@selector(onRecieveStreamerStateChanged:withState:)]) {
                    
                    NSString* peerCID = [NSString stringWithFormat:@"%llu", streamerCID];
                    
                    [delegate onRecieveStreamerStateChanged:peerCID withState:streamerConnState];
                    
                }
            }
        }];
        
        
        
    });
    
}

- (void)onStreamer:(unsigned long long)streamerCID
         ConfState:(EN_RVS_STREAMER_CONF_STATE)streamerConfState {
    
    if (streamerConfState == E_RVS_STREAMER_CONF_STATE_INFOGETSUCCESS) {
        
        [self streamerConfigGetSuccess:streamerCID];
        
    }
}

- (void)onStreamer:(unsigned long long)streamerCID
     PresenceState:(EN_RVS_STREAMER_PRESENCE_STATE)streamerPresenceState {
    
    [self updateStreamer:streamerCID OnlineOrOffline:streamerPresenceState];
}



- (void)onUpdateSymbol:(NSString*)symbol {
    
    
    if(!symbol) {
        
        return;
    }
    
    
}

- (void)onLanSearchStreamer:(unsigned long long)streamerCID
               StreamerName:(NSString*)streamerName
                     OSType:(NSUInteger)osType {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (_lanSearchDelegate) {
            
            [_lanSearchDelegate onLanSearchStreamer:streamerCID StreamerName:streamerName OSType:osType];
        }
        
    });
}

- (AVSConfigData*)getAvsConfigFromSDK:(unsigned long long)streamerCID {
    
    RvsStreamerInfo* streamerInfo = [[Rvs_Viewer defaultViewer].viewerStreamerInfo getStreamerInfo:streamerCID];
    
    RvsStreamerSupportServices* streamerSupportServices = [[Rvs_Viewer defaultViewer].viewerStreamerInfo getStreamerSupportServices:streamerCID];
    
    
    RvsStreamerSensors* sensors = [[Rvs_Viewer defaultViewer].viewerStreamerInfo  getStreamerSensors:streamerCID];
    
    
    AVSConfigData* configData = [[AVSConfigData alloc] init];
    
    NSString* CIDStr = [NSString stringWithFormat:@"%llu", streamerCID];
    
    [configData configWithCID:CIDStr
                 StreamerInfo:streamerInfo
              SupportServices:streamerSupportServices
                      Sensors:sensors];
    
    for(CameraSettings* cam in configData.streamerInfo.CameraSettingsArray) {
        
        
        RvsStreamerAlarmRecordInfo* rvsAlarmRecordInfo = [[Rvs_Viewer defaultViewer].viewerStreamerInfo getStreamerMotionSchedule:streamerCID CameraIndex:cam.camIndex];
        
        
        [cam updateMotionSettings:rvsAlarmRecordInfo];
        
        
        RvsStreamerTimeRecordInfo* rvsTimeRecordInfo = [[Rvs_Viewer defaultViewer].viewerStreamerInfo getStreamerRecordSchedule:streamerCID CameraIndex:cam.camIndex];
        
        [cam updateScheduleRecrodSettings:rvsTimeRecordInfo];
        
        
    }
    
    return configData;
    
}

#pragma mark - Rvs_Viewer_Delegate - private

- (void)streamerConfigGetSuccess:(unsigned long long)streamerCID {
    
    @autoreleasepool {
        
        AVSConfigData* configData = [self getAvsConfigFromSDK:streamerCID];
        NSString* CIDStr = [NSString stringWithFormat:@"%llu", streamerCID];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //缓存进memdata
            [[MemberData memberData] updateDetailConfigInfo:configData ForCID:CIDStr];
            
            NSDictionary* observerDict = [AHCServerCommunicator sharedAHCServerCommunicator].observerDict;
            
            [observerDict enumerateKeysAndObjectsUsingBlock:^(NSString* key, id<AHCServerCommunicatorDelegate> delegate, BOOL *stop) {
                
                if ([key hasPrefix:@"ALL"] ||
                    [key isEqualToString:[NSString stringWithFormat:@"%llu", streamerCID]]) {
                    
                    if ([delegate respondsToSelector:@selector(onCfgGetSuc:)]) {
                        
                        NSString* peerCID = [NSString stringWithFormat:@"%llu", streamerCID];
                        [delegate onCfgGetSuc:peerCID];
                        
                    }
                }
            }];
            
            
            
        });
        
    }
    
}

- (void)updateStreamer:(unsigned long long)streamerCID OnlineOrOffline:(EN_RVS_STREAMER_PRESENCE_STATE)streamerState {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSString* peerCID = [NSString stringWithFormat:@"%llu",streamerCID];
        
        [[MemberData  memberData] setAvsStatus:streamerState forCID:peerCID];
        
        NSDictionary* statusInfo = nil;
        
        switch (streamerState) {
                
            case E_RVS_STREAMER_PRESENCE_STATE_ERRUSERPWD:
            {
                statusInfo = @{kPeerOnlineState: [NSNumber numberWithUnsignedInteger:PEER_STATUS_STATE_ERRUSERPWD]};
                
            }
                break;
            case E_RVS_STREAMER_PRESENCE_STATE_ONLINE:
            {
                statusInfo = @{kPeerOnlineState: [NSNumber numberWithUnsignedInteger:PEER_STATUS_STATE_ONLINE]};
            }
                break;
            case E_RVS_STREAMER_PRESENCE_STATE_OFFLINE:
            {
                statusInfo = @{kPeerOnlineState: [NSNumber numberWithUnsignedInteger:PEER_STATUS_STATE_OFFLINE]};
            }
                break;
                
            default:{
                
                statusInfo = @{kPeerOnlineState: [NSNumber numberWithUnsignedInteger:PEER_STATUS_STATE_UNKNOWN]};
            }
                break;
        }
        
        
        NSDictionary* observerDict = [AHCServerCommunicator sharedAHCServerCommunicator].observerDict;
        
        [observerDict enumerateKeysAndObjectsUsingBlock:^(NSString* key, id<AHCServerCommunicatorDelegate> delegate, BOOL *stop) {
            
            if ([key hasPrefix:@"ALL"] ||
                [key isEqualToString:[NSString stringWithFormat:@"%llu", streamerCID]]) {
                
                if ([delegate respondsToSelector:@selector(onRecievePeerStatusChanged:withStatus:)]) {
                    
                    
                    [delegate onRecievePeerStatusChanged:peerCID
                                              withStatus:statusInfo];
                    
                }
            }
        }];
        
        
    });
    
}


#pragma mark -  Rvs_Viewer_StreamerInfo_Delegate
- (void)onStreamer:(unsigned long long)streamerCID
        InfoUpdate:(EN_RVS_STREAMERINFO_UPDATE_TYPE) updateType {
    
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        AVSConfigData* avsData = [[MemberData memberData] getDetailConfigInfoForCID:[NSString stringWithFormat:@"%llu", streamerCID]];
        
        
        if (!avsData) {
            
            return ;
            
        }
        
        
        switch (updateType) {
            case EN_RVS_STREAMERINFO_UPDATE_TYPE_INFO: {
                
                RvsStreamerInfo* rvsStreamerInfo = [[Rvs_Viewer defaultViewer].viewerStreamerInfo getStreamerInfo:streamerCID];
                [avsData.streamerInfo updateStreamerInfo:rvsStreamerInfo];
                break;
            }
                
            case EN_RVS_STREAMERINFO_UPDATE_TYPE_SUPPORTS: {
                
                RvsStreamerSupportServices* rvsStreamerSupportServices = [[Rvs_Viewer defaultViewer].viewerStreamerInfo getStreamerSupportServices:streamerCID];
                
                StreamerSupportServices* supports = [[StreamerSupportServices alloc] initWithSupportServices:rvsStreamerSupportServices];
                avsData.streamerSupportService = supports;
                
                break;
            }
            case EN_RVS_STREAMERINFO_UPDATE_TYPE_TIMERECORD: {
                
                for(CameraSettings* cam in avsData.streamerInfo.CameraSettingsArray) {
                    
                    
                    RvsStreamerTimeRecordInfo* rvsTimeRecordInfo = [[Rvs_Viewer defaultViewer].viewerStreamerInfo getStreamerRecordSchedule:streamerCID CameraIndex:cam.camIndex];
                    
                    [cam updateScheduleRecrodSettings:rvsTimeRecordInfo];
                    
                }
                break;
            }
            case EN_RVS_STREAMERINFO_UPDATE_TYPE_MOTION: {
                
                for(CameraSettings* cam in avsData.streamerInfo.CameraSettingsArray) {
                    
                    RvsStreamerAlarmRecordInfo* rvsAlarmRecordInfo = [[Rvs_Viewer defaultViewer].viewerStreamerInfo getStreamerMotionSchedule:streamerCID CameraIndex:cam.camIndex];
                    
                    
                    [cam updateMotionSettings:rvsAlarmRecordInfo];
                    
                }
                
                //motion 修改后重新调整报警总开关状态
                avsData.streamerInfo.alarmSetFlag = [[Rvs_Viewer defaultViewer].viewerStreamerInfo getStreamerDetectFlag:streamerCID];
                
                
                break;
            }
            case EN_RVS_STREAMERINFO_UPDATE_TYPE_SENSOR: {
                
                
                RvsStreamerSensors* rvsSensors = [[Rvs_Viewer defaultViewer].viewerStreamerInfo  getStreamerSensors:streamerCID];
                
                StreamerSensors* sensors = [[StreamerSensors alloc] initWithSensors:rvsSensors];
                
                avsData.streamerSensors = sensors;
                
                //sensor 修改后重新调整报警总开关状态
                avsData.streamerInfo.alarmSetFlag = [[Rvs_Viewer defaultViewer].viewerStreamerInfo getStreamerDetectFlag:streamerCID];
                
                break;
            }
                
            default:
                break;
        }
        
        //缓存进memdata
        [[MemberData memberData] updateDetailConfigInfo:avsData ForCID:[NSString stringWithFormat:@"%llu", streamerCID]];
        
        NSDictionary* observerDict = [AHCServerCommunicator sharedAHCServerCommunicator].observerDict;
        
        [observerDict enumerateKeysAndObjectsUsingBlock:^(NSString* key, id<AHCServerCommunicatorDelegate> delegate, BOOL *stop) {
            
            if ([key hasPrefix:@"ALL"] ||
                [key isEqualToString:[NSString stringWithFormat:@"%llu", streamerCID]]) {
                
                if ([delegate respondsToSelector:@selector(onCfgGetSuc:)]) {
                    
                    NSString* peerCID = [NSString stringWithFormat:@"%llu", streamerCID];
                    [delegate onCfgGetSuc:peerCID];
                    
                }
            }
        }];
    });
}



#pragma mark - Rvs_Viewer_Media_StreamState_Delegate

- (void)onMediaStreamStateWithHandle:(RVS_HANDLE)handle
                         StreamState:(EN_RVS_MEDIASTREAM_STATE)streamState
                          StreamFlag:(EN_RVS_MEDIASTREAM_FLAG) streamFlag {
    
    
    [CommonUtility notifyStreamStateWithHanlde:handle StreamState:streamState StreamFlag:streamFlag];
    
}


#pragma mark - Rvs_Viewer_Media_RecvJpeg_Delegate
- (void)onRecvJpegWithRequestID:(unsigned long long)requestID
                     JpegBuffer:(unsigned char*)jpegBuffer
                      BufferLen:(NSUInteger)bufferLen {
    
    
    if (bufferLen > 0) {
        @autoreleasepool {
            NSData* imageData = [NSData dataWithBytes:jpegBuffer length:bufferLen];
            UIImage* image    = [UIImage imageWithData:imageData];
            
            NSDictionary* parameters = @{ kMediaCmdParamSnapshot: image };
            
            [[AHCServerCommunicator sharedAHCServerCommunicator] onCommandFinished:parameters
                                                                       cmdIdentity:[NSNumber numberWithUnsignedLongLong:requestID]];
        }
        
    }
    else {
        
    }
    
}


#pragma mark - lansearch

- (NSInteger)startLANSearchStreamer {
    
    
    return [[Rvs_Viewer defaultViewer] LANSearchStreamer];
}
- (NSInteger)stopLANSearchStreamer {
    
    return 0;
}


#pragma mark - private method
-(void)startTimeoutTimer
{
    
    if (!checkCmdTimeoutTimer) {
        
        
        checkCmdTimeoutTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, commandQueue);
        
        if (checkCmdTimeoutTimer) {
            
            dispatch_source_set_timer(checkCmdTimeoutTimer,
                                      dispatch_walltime(DISPATCH_TIME_NOW, NSEC_PER_SEC),
                                      NSEC_PER_SEC,
                                      0);
            
            dispatch_source_set_event_handler(checkCmdTimeoutTimer, ^{
                
                [self onUpdateTimeupCmd];
                
            });
            
            dispatch_resume(checkCmdTimeoutTimer);
        }
    }
    
    
    
    
    //    if (self.timeoutTimer == nil) {
    //        self.timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(onUpdateTimeupCmd) userInfo:nil repeats:YES];
    //        [self.timeoutTimer fire];
    //    }
}

-(void)timeoutTimerStopCheck
{
    if (self.commandDict.count == 0) {
        //        
        //        if (self.timeoutTimer) {
        //        
        //        [self.timeoutTimer invalidate];
        //        self.timeoutTimer = nil;
        //        }
        
        if (checkCmdTimeoutTimer) {
                        
            dispatch_source_cancel(checkCmdTimeoutTimer);
            //            dispatch_release(checkCmdTimeoutTimer);
            checkCmdTimeoutTimer = NULL;
        }
    }
}


#pragma mark - adjudge in same LAN
- (BOOL)isInSameLanWithStreamer:(unsigned long long)streamerCID {
    
    return [[Rvs_Viewer defaultViewer] checkSameLanNetwork:streamerCID];
    
}


@end
