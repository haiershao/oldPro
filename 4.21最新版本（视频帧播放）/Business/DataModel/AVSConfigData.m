//
//  AVSConfigData.m
//  AtHomeCam
//
//  Created by Circlely Networks on 27/3/14.
//
//

#import "AVSConfigData.h"
#import "AHCServerCommunicator.h"


#define kCid				@"cid"
#define kCommonsettings   @"commonsettings"
#define kCameraCount      @"camcount"
#define kAVSVersion       @"avsversion"
#define kAVSType         @"avstype"
#define kAVSName         @"avsname"
#define kEmailAlertStatus @"emailalertstatus"
#define kEmailAddress     @"emailaddr"
#define kPushAlertStatus  @"pushalertstatus"
#define kAlarmReserve1    @"alarmres1"
#define kAlarmReserve2    @"alarmres2"
#define kAlarmReserve3    @"alarmres3"
#define kAutoDelStatus    @"autodelstatus"
#define kAutoDelDays      @"autodeldays"
#define kAlarmFlag        @"alarmFlag"
#define kIpcinfo         @"ipcInfo"
#define kHoistFlag        @"hoistFlag"
#define kRecordFlag       @"recordFlag"

#define kSyncFlag        @"syncflag"
#define kTime            @"time"
#define kZone            @"zone"

#define kWifiInfo        @"wifiInfo"
#define kWifiSsid        @"wifiSsid"

#define kSdkTotalSize     @"sdktotalsize"
#define kSdkFreeSize      @"sdkfreesize"

#define kSDCardInfo      @"sdCardInfo"


#define	kCamInfo		  @"caminfo"

#define kCameraSettings   @"camsettings"
#define kCameraIndex      @"camindex"
#define kCameraName       @"camname"
#define KCameraEable      @"enable"

#define kStreamSettings   @"streamsettings"
#define kStreamIndex      @"streamindex"
#define kStreamQuality    @"streamquality"
#define kStreamWidth      @"streamwidth"
#define kStreamHeight     @"streamheight"

#define kMotionSettings   @"motionsettings"
#define kMotionStatus     @"status"
#define kSensitivity      @"sensitivity"
#define kdayflag		  @"dayFlag"

#define kRecordingsettings @"recordingsettings"
#define kRecordingstatus   @"status"

#define kStarttime        @"starttime"
#define kEndtime         @"endtime"


@interface AVSConfigData ()



@end

@implementation AVSConfigData

+(AVSConfigData*) sharedAVSConfigData
{
    static AVSConfigData *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[AVSConfigData alloc] init];
    });
    return shared;
}

-(id)init
{
    self = [super init];
    
    if (self) {


    }
    
    return self;
}

- (AVS_ALARMFLAG)getAvsAlarmFlag{

    
    switch (self.streamerInfo.alarmSetFlag) {
        case 0:
            
            return ALARM_FLAG_NOT_SET;
            
            break;
        case 1:
            
            return ALARM_FLAG_ON;
            
            break;
        case 2:
            
            return ALARM_FLAG_OFF;
            
            break;
        default:
            break;
    }

    return ALARM_FLAG_NOT_SET;

}

#pragma mark - construct function

- (void)configWithAVSConfigData:(AVSConfigData*)avsConfigData {
    
    self.CIDNumber = avsConfigData.CIDNumber;
    
    self.streamerInfo = [avsConfigData.streamerInfo copy];
    self.streamerSensors = [avsConfigData.streamerSensors copy];
    self.streamerSupportService = [avsConfigData.streamerSupportService copy];

}

- (void)configWithCID:(NSString*)CID
         StreamerInfo:(RvsStreamerInfo*)rvsStreamerInfo
      SupportServices:(RvsStreamerSupportServices*)rvsStreamerSupportService
              Sensors:(RvsStreamerSensors*)rvsStreamerSensors {

    self.CIDNumber = CID;
    
    self.streamerInfo = [[StreamerInfo alloc] initWithStreamerInfo:rvsStreamerInfo];
    self.streamerSensors = [[StreamerSensors alloc] initWithSensors:rvsStreamerSensors] ;
    self.streamerSupportService = [[StreamerSupportServices alloc] initWithSupportServices:rvsStreamerSupportService];
    
    
}


- (id)copyWithZone:(NSZone *)zone {

    
    AVSConfigData* avsconfig = [[AVSConfigData alloc] init];
    
    avsconfig.CIDNumber = self.CIDNumber;
    
    avsconfig.streamerInfo = [self.streamerInfo copy];
    avsconfig.streamerSensors = [self.streamerSensors copy];
    avsconfig.streamerSupportService = [self.streamerSupportService copy];
    
    
    return avsconfig;
}


-(NSArray*)streamAddressForCamera:(NSInteger)camIndex;
{
    CameraSettings* camSettings = nil;
    
    if (self.streamerInfo.CameraSettingsArray.count > camIndex) {
        camSettings = [self.streamerInfo.CameraSettingsArray objectAtIndex:camIndex];
    }
    
    
    NSMutableArray* streamAddress = [NSMutableArray arrayWithCapacity:2];
    
    for (StreamSettings *streamSetting in camSettings.streamSettingsArray) {
        
        [streamAddress addObject: [NSString stringWithFormat:@"rtsp://127.0.0.1:554/sdp?cameraid=%d&streamid=%d&streamtype=av",camSettings.camIndex, streamSetting.streamIndex]];
    }
    
    return streamAddress;
}

- (BOOL)isAvsSupportRecordCategory{

    if (self.streamerInfo.streamerType == IPCameraAVS) {
        return YES;
    }
    
    if (!self.streamerInfo.AppVersion || [self.streamerInfo.AppVersion isEqualToString:@""]) {
    
        return YES;
    }
    
    
    NSArray *arr = [self.streamerInfo.AppVersion componentsSeparatedByString:@"."];
    
    int ver1 = 0, ver2 = 0, ver3 = 0;
    
    if ([arr count] > 0) {
        ver1 = [[arr objectAtIndex:0] intValue];
    }
    if ([arr count] > 1) {

        ver2 = [[arr objectAtIndex:1] intValue];
    }
    if ([arr count] > 2) {
        ver3 = [[arr objectAtIndex:2] intValue];
    }
    
    if (ver1 < 2 ||(ver1 == 2 && ver2 == 0 && ver3 < 3)) {
        return NO;
        
    } else{
    
        return YES;
    }

}
- (BOOL)isCameraEnabled:(NSInteger)cameraIndex{

    int streamIndex = 0;
    CameraSettings* camersetting = [self.streamerInfo.CameraSettingsArray objectAtIndex:cameraIndex];
    
    if (!camersetting.cameraEnable) {
		
        return NO;
    }
    else {
		
        NSArray* addressArray = [self streamAddressForCamera:cameraIndex];
        
        if (addressArray && [addressArray count] > streamIndex) {
           
           return YES;
        }
        else {
           
           return NO;
           
        }
		
    }
}

- (BOOL)isAvsDataAvailable {

	for(CameraSettings* cameraSetting in self.streamerInfo.CameraSettingsArray){
	
		if (![cameraSetting isCameraDataAvailable]){
		
			return NO;
		}
	}

	return YES;
}

- (BOOL)isDetectFlagOpen {
    
    return self.streamerInfo.alarmSetFlag > 0;
}

- (BOOL)isRecordFlagOpen {

    
    BOOL flag = NO;
    
    for(CameraSettings* cs in self.streamerInfo.CameraSettingsArray) {
        
        for(ScheduledRecordingSettings* srs in cs.scheduleRecordingSettingsArray) {
            
            
            flag |= srs.enable;
        }
    }
    
    
    return flag;
}

- (BOOL)isSupportEchoCancel{

    if (self.streamerInfo.echoCancelFlag != 0) {
        
        return YES;
    
    }
    
    return NO;
}

- (BOOL) isSupportColorSwitch {

    //版本 >= 3.0.1 才支持colorswitch
    
    if (!self.streamerInfo.AppVersion || [self.streamerInfo.AppVersion isEqualToString:@""]) {
        
        return NO;
    }

    NSArray *arr = [self.streamerInfo.AppVersion componentsSeparatedByString:@"."];
    
    int ver1 = 0, ver2 = 0, ver3 = 0;
    
    if ([arr count] > 0) {
        ver1 = [[arr objectAtIndex:0] intValue];
    }
    if ([arr count] > 1) {
        
        ver2 = [[arr objectAtIndex:1] intValue];
    }
    if ([arr count] > 2) {
        ver3 = [[arr objectAtIndex:2] intValue];
    }
    
    if (ver1 < 3 ||(ver1 == 3 && ver2 == 0 && ver3 < 1)) {
        
        return NO;
        
    }
        
    return YES;
    

}


-(NSArray*)cameraNames
{
    NSMutableArray* nameArray = [NSMutableArray array];
    for (CameraSettings* setting in self.streamerInfo.CameraSettingsArray) {
        if (self.streamerInfo.streamerType == WindowsAVS) {
            //这里对于cameraname做个保护，使其不crash
            [nameArray addObject: (setting.cameraName ? setting.cameraName : @"")];
        }
        else {
            NSString* streamName = self.streamerInfo.deviceName ? self.streamerInfo.deviceName : @"";
            
           [nameArray addObject:streamName];
        }
    }
    
    return nameArray;
}

-(MotionSettings*)motionSettingForCamera:(NSInteger)camIndex motionIndex:(NSInteger)motionIndex
{
    MotionSettings* motionSetting = nil;
    
    if (self.streamerInfo.CameraSettingsArray.count > camIndex) {
        CameraSettings* camSetting = self.streamerInfo.CameraSettingsArray[camIndex];
        
        if (camSetting.motionSettingsArray.count > motionIndex) {
           motionSetting = camSetting.motionSettingsArray[motionIndex];
        }
    }
    
    return motionSetting;
}

-(void)setMotionSettingsForCamera:(NSInteger)camIndex
                    motionIndex:(NSInteger)motionIndex
                 motionSettings:(MotionSettings*)motionSettings
{
    MotionSettings* motionSetting = nil;
    
    if (self.streamerInfo.CameraSettingsArray.count > camIndex) {
        CameraSettings* camSetting = self.streamerInfo.CameraSettingsArray[camIndex];
        
        if (camSetting.motionSettingsArray.count > motionIndex) {
           motionSetting = camSetting.motionSettingsArray[motionIndex];
           
           motionSetting.enable = motionSettings.enable;
           motionSetting.sensitive   = motionSettings.sensitive;
           motionSetting.seq     = motionSettings.seq;
           motionSetting.startPoint       = motionSettings.startPoint;
           motionSetting.endPoint       = motionSettings.endPoint;
           motionSetting.weekFlg       = motionSettings.weekFlg;
           motionSetting.endPoint       = motionSettings.endPoint;
        
        }
    }
}

-(ScheduledRecordingSettings*)scheduledRecordingForCamera:(NSInteger)camIndex
                                       recordingIndex:(NSInteger)recordingIndex
{
    ScheduledRecordingSettings* recordSetting = nil;
    
    if (self.streamerInfo.CameraSettingsArray.count > camIndex) {
        CameraSettings* camSetting = self.streamerInfo.CameraSettingsArray[camIndex];
        
        if (camSetting.scheduleRecordingSettingsArray.count > recordingIndex) {
           recordSetting = camSetting.scheduleRecordingSettingsArray[recordingIndex];
        }
    }
    
    return recordSetting;
}

-(void)setScheduledRecordingForCamera:(NSInteger)camIndex
                                         recordingIndex:(NSInteger)recordingIndex
                                          recordSetting:(ScheduledRecordingSettings*)recordSettings
{
    ScheduledRecordingSettings* recordSetting;
    
    if (self.streamerInfo.CameraSettingsArray.count > camIndex) {
        CameraSettings* camSetting = self.streamerInfo.CameraSettingsArray[camIndex];
        
        if (camSetting.scheduleRecordingSettingsArray.count > recordingIndex) {
           recordSetting = camSetting.scheduleRecordingSettingsArray[recordingIndex];
           
           recordSetting.seq = recordSettings.seq;
           recordSetting.enable        = recordSettings.enable;
           recordSetting.startPoint         = recordSettings.startPoint;
           
           recordSetting.endPoint = recordSettings.endPoint;
           recordSetting.weekFlg        = recordSettings.weekFlg;

        }
    }
}

-(StreamSettings*)streamSettingsForCamera:(NSInteger)camIndex
                           streamIndex:(NSInteger)streamIndex
{
    StreamSettings* streamSetting = nil;
    
    if (self.streamerInfo.CameraSettingsArray.count > camIndex) {
        CameraSettings* camSetting = self.streamerInfo.CameraSettingsArray[camIndex];
        
        if (camSetting.streamSettingsArray.count > streamIndex) {
           streamSetting = camSetting.streamSettingsArray[streamIndex];
        }
    }
    
    return streamSetting;
}

-(void)setStreamSettingsForCamera:(NSInteger)camIndex
                    streamIndex:(NSInteger)streamIndex
                  streamQuality:(NSInteger)streamQuality
{
    StreamSettings* streamSetting;
    
    if (self.streamerInfo.CameraSettingsArray.count > camIndex) {
        CameraSettings* camSetting = self.streamerInfo.CameraSettingsArray[camIndex];
        
        if (camSetting.scheduleRecordingSettingsArray.count > streamIndex) {
           streamSetting = camSetting.streamSettingsArray[streamIndex];
           streamSetting.quality  = streamQuality;

        }
    }
}


- (void)setSensorInfoForSensorIndex:(NSInteger)sensorIndex
                         SensorType:(NSInteger)sensorType
                         SensorName:(NSString*)sensorName {


    for (StreamerSensorInfo* ssi in self.streamerSensors.sensorInfos) {
    
        if (ssi.sensorIndex == sensorIndex && ssi.sensorType == ssi.sensorType) {
        
            ssi.sensorName = sensorName;
        }
    
    }

}

- (StreamerSensorInfo*)getSensorInfoForSensorIndex:(NSInteger)sensorIndex
                                        SensorType:(NSInteger)sensorType {

    for (StreamerSensorInfo* ssi in self.streamerSensors.sensorInfos) {
        
        if (ssi.sensorIndex == sensorIndex && ssi.sensorType == ssi.sensorType) {
            
            return ssi;
        }
        
    }
    
    return nil;
}

@end

@interface StreamerInfo ()



@end

@implementation StreamerInfo

-(id)init
{
    self = [super init];
    
    if (self) {
        
        self.micInfos = [NSMutableArray arrayWithCapacity:3];
        self.CameraSettingsArray = [NSMutableArray arrayWithCapacity:3];
    }
    
    return self;
}

- (instancetype)initWithStreamerInfo:(RvsStreamerInfo*)rvsStreamerInfo {
    
    self  = [super init];
    
    if (self) {

        self.streamerType = rvsStreamerInfo.streamerType;
        self.OSVersion = rvsStreamerInfo.OSVersion;
        self.SDKVersion = rvsStreamerInfo.SDKVersion;
        self.AppVersion = rvsStreamerInfo.AppVersion;
        self.language = rvsStreamerInfo.language;
        self.pushFlag = rvsStreamerInfo.pushFlag;
        self.emailFlag = rvsStreamerInfo.emailFlag;
        self.noticeFlag = rvsStreamerInfo.noticeFlag;
        self.runMode = rvsStreamerInfo.runMode;
        self.recordMode = rvsStreamerInfo.recordMode;
        self.timeZoneMode = rvsStreamerInfo.timeZoneMode;
        self.echoCancelFlag = rvsStreamerInfo.echoCancelFlag;
        self.emailAddr = rvsStreamerInfo.emailAddr;
        self.deviceName = rvsStreamerInfo.deviceName;
        self.alarmSetFlag = rvsStreamerInfo.setFlag;

        if (rvsStreamerInfo.delDays > 0) {
            
            self.autoDelRecordEndabled  = YES;
            self.autoDelDays = rvsStreamerInfo.delDays;
        
        }
        else {
        
            self.autoDelRecordEndabled  = NO;
            self.autoDelDays = 0;
        }

        

        
        self.micInfos = [NSMutableArray arrayWithCapacity:3];
        self.CameraSettingsArray = [NSMutableArray arrayWithCapacity:3];
        
        for(RvsStreamerCameraInfo* rvsCamInfo in rvsStreamerInfo.cameras) {
            
            CameraSettings* cs = [[CameraSettings alloc] initWithCameraInfo:rvsCamInfo];
            cs.streamerInfo = self;
            [self.CameraSettingsArray addObject:cs];
        }
        
        
        for(RvsStreamerMicInfo* rvsMicInfo in rvsStreamerInfo.micInfos) {
            
            StreamerMicInfo* smi = [[StreamerMicInfo alloc] initWithMicInfo:rvsMicInfo];
            [self.micInfos addObject:smi];
        }
    
    }

    return self;
}

- (void)updateStreamerInfo:(RvsStreamerInfo*)rvsStreamerInfo {


    self.streamerType = rvsStreamerInfo.streamerType;
    self.OSVersion = rvsStreamerInfo.OSVersion;
    self.SDKVersion = rvsStreamerInfo.SDKVersion;
    self.AppVersion = rvsStreamerInfo.AppVersion;
    self.language = rvsStreamerInfo.language;
    self.pushFlag = rvsStreamerInfo.pushFlag;
    self.emailFlag = rvsStreamerInfo.emailFlag;
    self.noticeFlag = rvsStreamerInfo.noticeFlag;
    self.runMode = rvsStreamerInfo.runMode;
    self.recordMode = rvsStreamerInfo.recordMode;
    self.timeZoneMode = rvsStreamerInfo.timeZoneMode;
    self.echoCancelFlag = rvsStreamerInfo.echoCancelFlag;
    self.emailAddr = rvsStreamerInfo.emailAddr;
    self.deviceName = rvsStreamerInfo.deviceName;
    self.alarmSetFlag = rvsStreamerInfo.setFlag;
    
    if (rvsStreamerInfo.delDays > 0) {
        
        self.autoDelRecordEndabled  = YES;
        self.autoDelDays = rvsStreamerInfo.delDays;
        
    }
    else {
        
        self.autoDelRecordEndabled  = NO;
        self.autoDelDays = 0;
    }
    
    self.micInfos = [NSMutableArray arrayWithCapacity:3];
    
    for(RvsStreamerMicInfo* rvsMicInfo in rvsStreamerInfo.micInfos) {
        
        StreamerMicInfo* smi = [[StreamerMicInfo alloc] initWithMicInfo:rvsMicInfo];
        [self.micInfos addObject:smi];
    }

    //这里必须retain，否则在下面crash
    NSMutableArray* oldCameraSettings = self.CameraSettingsArray;

    self.CameraSettingsArray = [NSMutableArray arrayWithCapacity:3];
    
    for(RvsStreamerCameraInfo* rvsCamInfo in rvsStreamerInfo.cameras) {
        
        CameraSettings* cs = [[CameraSettings alloc] initWithCameraInfo:rvsCamInfo];
        cs.streamerInfo = self;
        [self.CameraSettingsArray addObject:cs];
        
        BOOL bFindFlag = NO;
        
        for(CameraSettings* oldCS in oldCameraSettings) {
        
            if (oldCS.camIndex == cs.camIndex) {
            
                bFindFlag = YES;
                
                //将其motion和定时录制内容copy进来
                cs.motionSettingsArray = oldCS.motionSettingsArray;
                cs.scheduleRecordingSettingsArray = oldCS.scheduleRecordingSettingsArray;
                
                break;
            }
        
        }
        
        //如果没有找到，说明新增了一个camera，此时还没有motion和定时录制信息，需要补齐，否则上层ui会因为数据不全而crash
        if (!bFindFlag) {
            
            NSMutableArray* newMotions = [NSMutableArray arrayWithCapacity:3];
        
            
            for(int i = 0; i < 2; i++){
            
                MotionSettings* ms = [[MotionSettings alloc] init];
                ms.seq = i;
                ms.enable = NO;
                ms.startPoint = 0;
                ms.endPoint = 24*60*60 - 1;
                ms.weekFlg = K_WEEKFLAG_ALLDAY;
                ms.sensitive = STREAMER_ALARM_LEVEL_LOW;//默认是低
                
                [newMotions addObject:ms];
            }
            

            cs.motionSettingsArray = newMotions;
            
            
             NSMutableArray* newSchedules = [NSMutableArray arrayWithCapacity:3];
            
            for(int i = 0; i < 2; i++){
            
            
                ScheduledRecordingSettings* srs = [[ScheduledRecordingSettings alloc] init];
                
                srs.seq = i;
                srs.enable = NO;
                srs.startPoint = 0;
                srs.endPoint = 24*60*60 - 1;
                srs.weekFlg = K_WEEKFLAG_ALLDAY;
                
                [newSchedules addObject:srs];
            
            }
            
            cs.scheduleRecordingSettingsArray = newSchedules;
        
        }
    }
}


- (id)copyWithZone:(NSZone *)zone {

    StreamerInfo* si = [[StreamerInfo alloc] init];

    si.streamerType = self.streamerType;
    si.OSVersion = self.OSVersion;
    si.SDKVersion = self.SDKVersion;
    si.AppVersion = self.AppVersion;
    si.language = self.language;
    si.pushFlag = self.pushFlag;
    si.emailFlag = self.emailFlag;
    si.noticeFlag = self.noticeFlag;
    si.runMode = self.runMode;
    si.recordMode = self.recordMode;
    si.timeZoneMode = self.timeZoneMode;
    si.echoCancelFlag = self.echoCancelFlag;
    si.emailAddr = self.emailAddr;
    si.deviceName = self.deviceName;
    
    si.alarmSetFlag = self.alarmSetFlag;
    si.autoDelRecordEndabled  = self.autoDelRecordEndabled;
    si.autoDelDays = self.autoDelDays;
    
    for(CameraSettings* camInfo in self.CameraSettingsArray) {
        
        CameraSettings* cs = [camInfo copy];
        cs.streamerInfo = si;//这里对复制后的CameraSettings里的streamerinfo重新赋值
        
        [si.CameraSettingsArray addObject:cs];

    }
    
    for(StreamerMicInfo* micInfo in self.micInfos) {
        
        [self.micInfos addObject:[micInfo copy]];

    }

    return si;
    
}

@end

@interface CameraSettings ()

@end

@implementation CameraSettings


-(id)init
{
    self = [super init];
    
    if (self) {

        self.streamSettingsArray = [NSMutableArray arrayWithCapacity:3];
        self.motionSettingsArray = [NSMutableArray arrayWithCapacity:3];
        self.scheduleRecordingSettingsArray = [NSMutableArray arrayWithCapacity:3];
    }
    
    return self;
}

- (instancetype)initWithCameraInfo:(RvsStreamerCameraInfo*)rvsStreamerCameraInfo

{

    self = [super init];
    
    if (self) {
        self.camIndex = rvsStreamerCameraInfo.camIndex;
        self.cameraName = rvsStreamerCameraInfo.cameraName;
        self.PTZMoveEnable = rvsStreamerCameraInfo.PTZMoveEnable;
        self.torchEnable = rvsStreamerCameraInfo.torchEnable;
        self.rotateEnable = rvsStreamerCameraInfo.rotateEnable;
        self.streamType = rvsStreamerCameraInfo.streamType;
        self.cameraEnable = YES;
        
        self.streamSettingsArray = [NSMutableArray arrayWithCapacity:3];
        self.motionSettingsArray = [NSMutableArray arrayWithCapacity:3];
        self.scheduleRecordingSettingsArray = [NSMutableArray arrayWithCapacity:3];
        
        for(RvsStreamerCameraStreamInfo* rvsCamStreamInfo in rvsStreamerCameraInfo.cameraStreams) {
        
            [self.streamSettingsArray addObject:[[StreamSettings alloc] initWithStreamSettings:rvsCamStreamInfo]];
        
        }

    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone {

    CameraSettings* csi = [[CameraSettings alloc] init];
    

    csi.camIndex = self.camIndex;
    csi.cameraName = self.cameraName;
    csi.PTZMoveEnable = self.PTZMoveEnable;
    csi.torchEnable = self.torchEnable;
    csi.rotateEnable = self.rotateEnable;
    csi.streamType = self.streamType;
    csi.cameraEnable = self.cameraEnable;
    
    for(StreamSettings* camStreamInfo in self.streamSettingsArray) {
        
        [csi.streamSettingsArray addObject:[camStreamInfo copy]];
        
    }
    
    for(MotionSettings* motion in self.motionSettingsArray) {
        
        [csi.motionSettingsArray addObject:[motion copy]];
        
    }
    
    for(ScheduledRecordingSettings* srs in self.scheduleRecordingSettingsArray) {
        
        [csi.scheduleRecordingSettingsArray addObject:[srs copy]];
        
    }
    
    return csi;
}

- (void)updateMotionSettings:(RvsStreamerAlarmRecordInfo*)motionInfo {


    [self.motionSettingsArray removeAllObjects];
    
    
    int startSeq = -1;
    
    BOOL motionFlag = NO;
    
    for(RvsMotionDetectSetting* rvsMotion in motionInfo.scheduleSettings) {
        
        MotionSettings* ms = [[MotionSettings alloc] initWithMotionSettings:rvsMotion];
        
        //这里做校正，如果是时间段开关是关闭的，时间段参数使用默认配置
        
        if (!ms.enable) {
        
            ms.startPoint = 0;
            ms.endPoint = 24*60*60 - 1;
            ms.weekFlg = K_WEEKFLAG_ALLDAY;
            ms.sensitive = STREAMER_ALARM_LEVEL_LOW;//默认是低
        
        }
//        else {
//        
//            //规整灵敏度
//            ms.sensitive = [CommonUtility getOrderedSensitivity:ms.sensitive SDKVersion:_streamerInfo.SDKVersion];
//        
//        }
//
        
        [self.motionSettingsArray addObject:ms];
        
        if (rvsMotion.schedule.seq > startSeq) {
        
            startSeq = rvsMotion.schedule.seq;
        }
        
        motionFlag = (motionFlag && ms.enable);

    }
    
    
    int disCount = 2 - [self.motionSettingsArray count];
    
    if (disCount > 0) {
    
        for(int i = 0; i < disCount; i++) {
            
            startSeq++;
        
            MotionSettings* add = [[MotionSettings alloc] init];
        
            add.seq = startSeq;
            add.enable = NO;
            add.startPoint = 0;
            add.endPoint = 24*60*60 - 1;
            add.weekFlg = K_WEEKFLAG_ALLDAY;
            add.sensitive = STREAMER_ALARM_LEVEL_LOW;//默认是低
            
            [self.motionSettingsArray addObject:add];
        }
        
        
    }

}

- (void)updateScheduleRecrodSettings:(RvsStreamerTimeRecordInfo*)timeRecordInfo {
    
    [self.scheduleRecordingSettingsArray removeAllObjects];
    
    
    int startSeq = -1;
    
    for(RvsTimeRecordSetting* rvsTimeRecord in timeRecordInfo.scheduleSettings) {
        
        ScheduledRecordingSettings* srs = [[ScheduledRecordingSettings alloc] initWithScheduleRecrodSettings:rvsTimeRecord];
        
         //这里做校正，如果是时间段开关是关闭的，时间段参数使用默认配置
        if (!srs.enable) {
            
            srs.startPoint = 0;
            srs.endPoint = 24*60*60 - 1;
            srs.weekFlg = K_WEEKFLAG_ALLDAY;
        }

        
        [self.scheduleRecordingSettingsArray addObject:srs];
        
        if (rvsTimeRecord.schedule.seq > startSeq) {
            
            startSeq = rvsTimeRecord.schedule.seq;
        }
    }
    
    int disCount = 2 - [self.scheduleRecordingSettingsArray count];
    
    if (disCount > 0) {
        
        for(int i = 0; i < disCount; i++) {
            
            startSeq++;
            
            ScheduledRecordingSettings* add = [[ScheduledRecordingSettings alloc] init];
            
            add.seq = startSeq;
            add.enable = NO;
            add.startPoint = 0;
            add.endPoint = 24*60*60 - 1;
            add.weekFlg = K_WEEKFLAG_ALLDAY;
            
            [self.scheduleRecordingSettingsArray addObject:add];
            
        }
        
        
    }
}

- (BOOL)isCameraDataAvailable {
    
    
    //	if ([self.streamSettingsArray count] < 1){
    //
    //		return NO;
    //	}
    
    if ([self.motionSettingsArray count] < 2){
        
        return NO;
    }
    
    if ([self.scheduleRecordingSettingsArray count] < 2){
        
        return NO;
    }
    
    return YES;
}

@end

@interface StreamSettings ()


@end

@implementation StreamSettings


-(id)init
{
    self = [super init];
    
    if (self) {

    }
    
    return self;
}

- (instancetype)initWithStreamSettings:(RvsStreamerCameraStreamInfo*)cameraStreamInfo {

    self = [super init];
    
    if (self) {
        self.streamIndex = cameraStreamInfo.streamIndex;
        self.framerate = cameraStreamInfo.framerate;
        self.bitrate = cameraStreamInfo.bitrate;
        self.frameInterval = cameraStreamInfo.frameInterval;
        self.quality = cameraStreamInfo.quality;
        self.width = cameraStreamInfo.width;
        self.height = cameraStreamInfo.height;
        self.encodeType = cameraStreamInfo.encodeType;
        
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    
    StreamSettings* ss = [[StreamSettings alloc] init];
    
    
    ss.streamIndex = self.streamIndex;
    ss.framerate = self.framerate;
    ss.bitrate = self.bitrate;
    ss.frameInterval = self.frameInterval;
    ss.quality = self.quality;
    ss.width = self.width;
    ss.height = self.height;
    ss.encodeType = self.encodeType;
    
    return ss;
    
}

@end







@interface MotionSettings ()


@end

@implementation MotionSettings

-(id)init
{
    self = [super init];
    
    if (self) {
        
        self.weekFlg = K_WEEKFLAG_ALLDAY;
    }
    
    return self;
}

- (instancetype)initWithMotionSettings:(RvsMotionDetectSetting*)motionInfo {


    self = [super init];
    
    if (self) {
        
        self.seq = motionInfo.schedule.seq;
        self.enable = motionInfo.schedule.enable;
        self.startPoint = motionInfo.schedule.startPoint;
        self.endPoint = motionInfo.schedule.endPoint;
        self.weekFlg = motionInfo.schedule.weekFlag;
        self.sensitive = motionInfo.sensitive;
        
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
	MotionSettings *motionsettings = [[MotionSettings alloc] init];
    
    motionsettings.seq = self.seq;
    motionsettings.enable = self.enable;
    motionsettings.startPoint = self.startPoint;
    motionsettings.endPoint = self.endPoint;
    motionsettings.weekFlg = self.weekFlg;
    motionsettings.sensitive = self.sensitive;
    
	return motionsettings;
}

-(void)setStartTime:(NSUInteger)hour minutes:(NSUInteger)minute seconds:(NSUInteger)second
{
    self.startPoint = hour*60*60 + minute*60 + second;
}

-(void)setEndTime:(NSUInteger)hour minutes:(NSUInteger)minute seconds:(NSUInteger)second
{
    self.endPoint = hour*60*60 + minute*60 + second;
}

-(NSInteger)stHour
{
    return (self.startPoint/(60*60))%24;
}

-(NSInteger)stMinute
{
    return (self.startPoint%(60*60))/60;
}

-(NSInteger)stSecond
{
    return (self.startPoint%(60*60*60));
}

-(NSInteger)etHour
{
    return (self.endPoint/(60*60))%24;
}

-(NSInteger)etMinute
{
    return (self.endPoint%(60*60))/60;
}

-(NSInteger)etSecond
{
    return (self.endPoint%(60*60*60));
}

@end


@interface ScheduledRecordingSettings ()


@end


@implementation ScheduledRecordingSettings

-(id)init
{
    self = [super init];
    
    if (self) {

        self.weekFlg = K_WEEKFLAG_ALLDAY;
    }
    
    return self;
}

- (instancetype)initWithScheduleRecrodSettings:(RvsTimeRecordSetting*)timeRecordInfo {
    
    self = [super init];
    
    if (self) {
        
        self.seq = timeRecordInfo.schedule.seq;
        self.enable = timeRecordInfo.schedule.enable;
        self.startPoint = timeRecordInfo.schedule.startPoint;
        self.endPoint = timeRecordInfo.schedule.endPoint;
        self.weekFlg = timeRecordInfo.schedule.weekFlag;
        
    }
    return self;

    
}

- (id)copyWithZone:(NSZone *)zone
{
    ScheduledRecordingSettings *recordsettings = [[ScheduledRecordingSettings alloc] init];
    
    recordsettings.seq = self.seq;
    recordsettings.enable = self.enable;
    recordsettings.startPoint = self.startPoint;
    recordsettings.endPoint = self.endPoint;
    recordsettings.weekFlg = self.weekFlg;
    
    return recordsettings;
}

-(void)setStartTime:(NSUInteger)hour minutes:(NSUInteger)minute seconds:(NSUInteger)second
{
    self.startPoint = hour*60*60 + minute*60 + second;
}

-(void)setEndTime:(NSUInteger)hour minutes:(NSUInteger)minute seconds:(NSUInteger)second
{
    self.endPoint   = hour*60*60 + minute*60 + second;
}

-(NSInteger)stHour
{
    return (self.startPoint/(60*60))%24;
}

-(NSInteger)stMinute
{
    return (self.startPoint%(60*60))/60;
}

-(NSInteger)stSecond
{
    return (self.startPoint%(60*60*60));
}

-(NSInteger)etHour
{
    return (self.endPoint/(60*60))%24;
}

-(NSInteger)etMinute
{
    return (self.endPoint%(60*60))/60;
}

-(NSInteger)etSecond
{
    return (self.endPoint%(60*60*60));
}

@end


@interface StreamerMicInfo ()





@end

@implementation StreamerMicInfo

-(id)init
{
    self = [super init];
    
    if (self) {
        
    }
    
    return self;
}

- (instancetype)initWithMicInfo:(RvsStreamerMicInfo*)rvsStreamerMicInfo {

    self = [super init];
    
    if (self) {
        
        self.samplerate = rvsStreamerMicInfo.samplerate;
        self.channel = rvsStreamerMicInfo.channel;
        self.depth = rvsStreamerMicInfo.depth;
        self.encodeType = rvsStreamerMicInfo.encodeType;
        
    }
    return self;
}



- (id)copyWithZone:(NSZone *)zone
{
    StreamerMicInfo *mic = [[StreamerMicInfo alloc] init];
    
    mic.samplerate = self.samplerate;
    mic.channel = self.channel;
    mic.depth = self.depth;
    mic.encodeType = self.encodeType;
    
    return mic;
}

@end




@interface  StreamerSupportServices()

@end

@implementation StreamerSupportServices

-(id)init
{
    self = [super init];
    
    if (self) {
        
    }
    
    return self;
}

- (instancetype)initWithSupportServices:(RvsStreamerSupportServices*)rvsStreamerSupportService {

    
    self = [super init];
    
    if (self) {
        
        self.supportBCloud = rvsStreamerSupportService.supportBCloud;
        self.supportBTimeRecord = rvsStreamerSupportService.supportBTimeRecord;
        self.supportBAlarmRecord = rvsStreamerSupportService.supportBAlarmRecord;
        self.supportBShortRecord = rvsStreamerSupportService.supportBShortRecord;
        self.supportBSnapShot = rvsStreamerSupportService.supportBSnapShot;
        self.supportBRebackTalk = rvsStreamerSupportService.supportBRebackTalk;
        self.supportBRealIcon = rvsStreamerSupportService.supportBRealIcon;
        self.supportBWLan = rvsStreamerSupportService.supportBWLan;
        self.supportBSensors = rvsStreamerSupportService.supportBSensors;
        
    }
    return self;
    
}


- (id)copyWithZone:(NSZone *)zone
{
    StreamerSupportServices *service = [[StreamerSupportServices alloc] init];
    
    service.supportBCloud = self.supportBCloud;
    service.supportBTimeRecord = self.supportBTimeRecord;
    service.supportBAlarmRecord = self.supportBAlarmRecord;
    service.supportBShortRecord = self.supportBShortRecord;
    service.supportBSnapShot = self.supportBSnapShot;
    service.supportBRebackTalk = self.supportBRebackTalk;
    service.supportBRealIcon = self.supportBRealIcon;
    service.supportBWLan = self.supportBWLan;
    service.supportBSensors = self.supportBSensors;
    
    return service;
}

@end


@interface StreamerSensors ()

@end

@implementation StreamerSensors

-(id)init
{
    self = [super init];
    
    if (self) {
        
        self.sensorInfos = [NSMutableArray arrayWithCapacity:3];
    }
    
    return self;
}

- (instancetype)initWithSensors:(RvsStreamerSensors*)rvsStreamerSensors {

    self = [super init];
    
    if (self) {
    
         self.sensorInfos = [NSMutableArray  arrayWithCapacity:3];
        
        for (RvsStreamerSensorInfo* rvsSenInfo in rvsStreamerSensors.sensorInfos) {
        
            [self.sensorInfos addObject:[[StreamerSensorInfo alloc] initWithSensorInfo:rvsSenInfo] ];
        
        }
        
    }
    
    return self;
    
}

- (id)copyWithZone:(NSZone *)zone
{
    StreamerSensors *sensors = [[StreamerSensors alloc] init];
    
    for (StreamerSensorInfo* senInfo in self.sensorInfos) {
        
        [sensors.sensorInfos addObject:[senInfo copy]];
        
    }
    
    return sensors;
}

- (BOOL)alarmSwitchFlag {

    for (StreamerSensorInfo* sensorInfo in _sensorInfos) {
    
    
        for (SensorsDetectSetting* sds in sensorInfo.scheduleSettings) {
        
            
            if (sds.enable) {
            
                return YES;
            }
        
        }
    
    
    }
    
    return NO;
}

- (void)setAlarmSwitchFlag:(BOOL)alarmSwitchFlag {
    
    
    for (StreamerSensorInfo* sensorInfo in _sensorInfos) {
        
        
        if ([sensorInfo.scheduleSettings count] > 0) {
            
            for (SensorsDetectSetting* sds in sensorInfo.scheduleSettings) {
                
                sds.enable = alarmSwitchFlag;
                sds.startPoint = 0;
                sds.endPoint = 24*60*60 - 1;
                sds.weekFlg = K_WEEKFLAG_ALLDAY;
                sds.threshold = 50;
                
            }
        }
        else {
        
            //如果这个sensor没有时间段信息，在设置alarmswitchflag的时候设置一个时间段信息进去
            SensorsDetectSetting* oneSensorDetectSetting = [[SensorsDetectSetting alloc] init];
            
            oneSensorDetectSetting.enable = alarmSwitchFlag;
            
            oneSensorDetectSetting.seq = 0;
            oneSensorDetectSetting.startPoint = 0;
            oneSensorDetectSetting.endPoint = 24*60*60 - 1;
            oneSensorDetectSetting.weekFlg = K_WEEKFLAG_ALLDAY;
            oneSensorDetectSetting.threshold = 50;
            
            [sensorInfo.scheduleSettings addObject:oneSensorDetectSetting];
        
        }
        
    }

}
         
@end

@interface StreamerSensorInfo ()

@end

@implementation StreamerSensorInfo



- (instancetype)initWithSensorInfo:(RvsStreamerSensorInfo*)rvsStreamerSensorInfo {

    
    self = [super init];
    
    if (self) {
        
        self.sensorIndex = rvsStreamerSensorInfo.sensorIndex;
        self.sensorType = rvsStreamerSensorInfo.sensorType;
        self.sensorName = rvsStreamerSensorInfo.sensorName;
        self.scheduleSettings = [NSMutableArray arrayWithCapacity:3];
        
        for (RvsSensorsDetectSetting* rds in rvsStreamerSensorInfo.scheduleSettings) {
        
            [self.scheduleSettings addObject:[[SensorsDetectSetting alloc] initWithSensorDetectSetting:rds]];
        
        }
        
        
        
    }
    
    return self;
}

- (NSArray*)getRvsSensorDetectSettings {

    NSMutableArray* schedules = [NSMutableArray arrayWithCapacity:3];
    
    for (SensorsDetectSetting* sds in self.scheduleSettings){
    
        [schedules addObject:[sds getRvsSensorDetectSetting]];
    }
    
    return schedules;

}


-(id)init
{
    self = [super init];
    
    if (self) {
        

    }
    
    return self;
}



- (id)copyWithZone:(NSZone *)zone
{
    StreamerSensorInfo *senInfo = [[StreamerSensorInfo alloc] init];
    
    senInfo.sensorIndex = self.sensorIndex;
    senInfo.sensorType = self.sensorType;
    senInfo.sensorName = self.sensorName;
    senInfo.scheduleSettings = [NSMutableArray arrayWithCapacity:3];
    
    for(SensorsDetectSetting* sds  in self.scheduleSettings) {
        
        [senInfo.scheduleSettings addObject:[sds copy]];
    }
    
    return senInfo;
}

@end


@interface SensorsDetectSetting ()

@end

@implementation SensorsDetectSetting


- (instancetype)initWithSensorDetectSetting:(RvsSensorsDetectSetting*)rvsSensorDetectSetting {
    
    self = [super init];
    
    if (self) {
        
        self.seq = rvsSensorDetectSetting.schedule.seq;
        self.enable = rvsSensorDetectSetting.schedule.enable;
        self.startPoint = rvsSensorDetectSetting.schedule.startPoint;
        self.endPoint = rvsSensorDetectSetting.schedule.endPoint;
        self.weekFlg = rvsSensorDetectSetting.schedule.weekFlag;
        self.threshold = rvsSensorDetectSetting.threshold;
        
    }
    
    return self;

}


-(id)init
{
    self = [super init];
    
    if (self) {
        
        
    }
    
    return self;
}



- (id)copyWithZone:(NSZone *)zone
{
    SensorsDetectSetting *sendetect = [[SensorsDetectSetting alloc] init];
    
    sendetect.seq = self.seq;
    sendetect.enable = self.enable;
    sendetect.startPoint = self.startPoint;
    sendetect.endPoint = self.endPoint;
    sendetect.weekFlg = self.weekFlg;
    sendetect.threshold = self.threshold;
    
    return sendetect;
}

- (RvsSensorsDetectSetting*)getRvsSensorDetectSetting {

    RvsSensorsDetectSetting* rvsSensorDetectSetting = [[RvsSensorsDetectSetting alloc] init];
    
    rvsSensorDetectSetting.schedule.seq = self.seq;
    rvsSensorDetectSetting.schedule.enable = self.enable;
    rvsSensorDetectSetting.schedule.startPoint = self.startPoint;
    rvsSensorDetectSetting.schedule.endPoint = self.endPoint;
    rvsSensorDetectSetting.schedule.weekFlag = self.weekFlg;
    rvsSensorDetectSetting.threshold = self.threshold;
    
    return rvsSensorDetectSetting;
}

@end




