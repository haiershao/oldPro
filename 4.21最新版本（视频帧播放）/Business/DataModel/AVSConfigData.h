//
//  AVSConfigData.h
//  AtHomeCam
//
//  Created by Circlely Networks on 27/3/14.
//
//

#import <Foundation/Foundation.h>

@class MotionSettings;
@class ScheduledRecordingSettings;
@class StreamSettings;
@class StreamerSupportServices;
@class StreamerSensors;
@class StreamerInfo;
@class StreamerSensorInfo;


typedef enum {
    ALARM_FLAG_NOT_SET      = 0,
    ALARM_FLAG_ON           = 1,
    ALARM_FLAG_OFF          = 2
  
} AVS_ALARMFLAG;



@interface AVSConfigData : NSObject< NSCopying>

@property (nonatomic, copy) NSString* CIDNumber;

@property (nonatomic, strong) StreamerInfo* streamerInfo;
@property (nonatomic, strong) StreamerSupportServices* streamerSupportService;
@property (nonatomic, strong) StreamerSensors* streamerSensors;

+(AVSConfigData*) sharedAVSConfigData;

- (AVS_ALARMFLAG)getAvsAlarmFlag;
- (void)configWithAVSConfigData:(AVSConfigData*)avsConfigData;

- (void)configWithCID:(NSString*)CID
                StreamerInfo:(RvsStreamerInfo*)rvsStreamerInfo
             SupportServices:(RvsStreamerSupportServices*)rvsStreamerSupportService
                     Sensors:(RvsStreamerSensors*)rvsStreamerSensors;

-(NSArray*)streamAddressForCamera:(NSInteger)camIndex;

-(NSArray*)cameraNames;

-(MotionSettings*)motionSettingForCamera:(NSInteger)camIndex
                             motionIndex:(NSInteger)motionIndex;

-(void)setMotionSettingsForCamera:(NSInteger)camIndex
                      motionIndex:(NSInteger)motionIndex
                   motionSettings:(MotionSettings*)motionSettings;

-(ScheduledRecordingSettings*)scheduledRecordingForCamera:(NSInteger)camIndex
                                           recordingIndex:(NSInteger)recordingIndex;

-(void)setScheduledRecordingForCamera:(NSInteger)camIndex
                       recordingIndex:(NSInteger)recordingIndex
                        recordSetting:(ScheduledRecordingSettings*)recordSettings;


-(StreamSettings*)streamSettingsForCamera:(NSInteger)camIndex
                              streamIndex:(NSInteger)streamIndex;


- (void)setSensorInfoForSensorIndex:(NSInteger)sensorIndex
                         SensorType:(NSInteger)sensorType
                         SensorName:(NSString*)sensorName;

- (StreamerSensorInfo*)getSensorInfoForSensorIndex:(NSInteger)sensorIndex
                         SensorType:(NSInteger)sensorType;


-(void)setStreamSettingsForCamera:(NSInteger)camIndex
                      streamIndex:(NSInteger)streamIndex
                    streamQuality:(NSInteger)streamQuality;


- (BOOL)isAvsSupportRecordCategory;


- (BOOL)isAvsDataAvailable;

- (BOOL)isCameraEnabled:(NSInteger)cameraIndex;

- (BOOL)isDetectFlagOpen;

- (BOOL)isRecordFlagOpen;


//是否支持回音消除
- (BOOL)isSupportEchoCancel;

- (BOOL) isSupportColorSwitch;

@end

@interface StreamerInfo : NSObject< NSCopying>

- (instancetype)initWithStreamerInfo:(RvsStreamerInfo*)rvsStreamerInfo;
- (void)updateStreamerInfo:(RvsStreamerInfo*)rvsStreamerInfo;


@property (nonatomic, assign) NSInteger streamerType;
@property (nonatomic, copy) NSString* OSVersion;
@property (nonatomic, copy) NSString* SDKVersion;
@property (nonatomic, copy) NSString* AppVersion;
@property (nonatomic, assign) NSInteger language;
@property (nonatomic, assign) BOOL pushFlag;
@property (nonatomic, assign) BOOL emailFlag;
@property (nonatomic, assign) BOOL noticeFlag;
@property (nonatomic, assign) NSUInteger runMode; /** 0x00 Manual Run; 0x01 Auto Run; 0x02 Background Run; 0x04 Suspend Run; */
@property (nonatomic, assign) NSUInteger recordMode; /** 0x00 No Record; 0x01 SDCard Record; 0x02 Storage Record; */
@property (nonatomic, assign) NSUInteger timeZoneMode; /** 0x00 Not Support set timezone; 0x01 Support. */
@property (nonatomic, assign) NSUInteger echoCancelFlag; /** 0x00 Not support echo cancel, 0x01 Support. */
@property (nonatomic, copy) NSString* emailAddr;
@property (nonatomic, copy) NSString* deviceName;
@property (nonatomic, strong) NSMutableArray* micInfos;
@property (nonatomic, strong) NSMutableArray* CameraSettingsArray;
@property (nonatomic, assign) NSUInteger alarmSetFlag;

@property (nonatomic, assign) BOOL autoDelRecordEndabled;
@property (nonatomic, assign) NSUInteger autoDelDays;




@end

@interface CameraSettings : NSObject<NSCopying>

- (instancetype)initWithCameraInfo:(RvsStreamerCameraInfo*)rvsStreamerCameraInfo;

//这里用assign，防止双向引用，并且注意copy时该指针的赋值
@property (nonatomic, assign) StreamerInfo* streamerInfo;

@property (nonatomic, assign) NSInteger camIndex;
@property (nonatomic, copy) NSString*  cameraName;
@property (nonatomic, assign) NSUInteger PTZMoveEnable;
@property (nonatomic, assign) NSUInteger torchEnable;
@property (nonatomic, assign) NSUInteger rotateEnable;
@property (nonatomic, assign) NSUInteger  streamType;
@property (nonatomic, strong) NSMutableArray* streamSettingsArray;
@property (nonatomic, strong) NSMutableArray* motionSettingsArray;
@property (nonatomic, strong) NSMutableArray* scheduleRecordingSettingsArray;
@property (nonatomic, assign) BOOL cameraEnable;

- (void)updateMotionSettings:(RvsStreamerAlarmRecordInfo*)motionInfo;
- (void)updateScheduleRecrodSettings:(RvsStreamerTimeRecordInfo*)timeRecordInfo;

- (BOOL)isCameraDataAvailable;

@end

@interface StreamSettings : NSObject<NSCopying>

- (instancetype)initWithStreamSettings:(RvsStreamerCameraStreamInfo*)cameraStreamInfo;

@property (nonatomic, assign) NSInteger streamIndex;
@property (nonatomic, assign) NSInteger framerate;
@property (nonatomic, assign) NSInteger bitrate;
@property (nonatomic, assign) NSInteger frameInterval;
@property (nonatomic, assign) NSInteger quality;
@property (nonatomic, assign) NSInteger width;
@property (nonatomic, assign) NSInteger height;
@property (nonatomic, assign) NSUInteger encodeType;

@end

@interface MotionSettings : NSObject< NSCopying>

- (instancetype)initWithMotionSettings:(RvsMotionDetectSetting*)motionInfo;

@property (nonatomic, assign) NSUInteger  seq;
@property (nonatomic, assign) BOOL enable;
@property (nonatomic, assign) NSUInteger  startPoint;
@property (nonatomic, assign) NSUInteger  endPoint;
@property (nonatomic, assign) NSUInteger  weekFlg;
@property (nonatomic, assign) NSUInteger  sensitive;


@property (nonatomic, assign,readonly) NSInteger stHour;
@property (nonatomic, assign,readonly) NSInteger stMinute;
@property (nonatomic, assign,readonly) NSInteger stSecond;
@property (nonatomic, assign,readonly) NSInteger etHour;
@property (nonatomic, assign,readonly) NSInteger etMinute;
@property (nonatomic, assign,readonly) NSInteger etSecond;

-(void)setStartTime:(NSUInteger)hour minutes:(NSUInteger)minute seconds:(NSUInteger)second;
-(void)setEndTime:(NSUInteger)hour minutes:(NSUInteger)minute seconds:(NSUInteger)second;

@end

@interface ScheduledRecordingSettings : NSObject<NSCopying>

- (instancetype)initWithScheduleRecrodSettings:(RvsTimeRecordSetting*)timeRecordInfo;

@property (nonatomic, assign) NSUInteger  seq;
@property (nonatomic, assign) BOOL enable;
@property (nonatomic, assign) NSUInteger  startPoint;
@property (nonatomic, assign) NSUInteger  endPoint;
@property (nonatomic, assign) NSUInteger  weekFlg;

@property (nonatomic, assign,readonly) NSInteger stHour;
@property (nonatomic, assign,readonly) NSInteger stMinute;
@property (nonatomic, assign,readonly) NSInteger stSecond;
@property (nonatomic, assign,readonly) NSInteger etHour;
@property (nonatomic, assign,readonly) NSInteger etMinute;
@property (nonatomic, assign,readonly) NSInteger etSecond;

-(void)setStartTime:(NSUInteger)hour minutes:(NSUInteger)minute seconds:(NSUInteger)second;
-(void)setEndTime:(NSUInteger)hour minutes:(NSUInteger)minute seconds:(NSUInteger)second;

@end

@interface StreamerMicInfo : NSObject<NSCopying>

- (instancetype)initWithMicInfo:(RvsStreamerMicInfo*)rvsStreamerMicInfo;

@property (nonatomic, assign) NSUInteger samplerate;
@property (nonatomic, assign) NSUInteger channel;
@property (nonatomic, assign) NSUInteger depth;
@property (nonatomic, assign) NSUInteger encodeType;

@end


@interface StreamerSupportServices : NSObject<NSCopying>

- (instancetype)initWithSupportServices:(RvsStreamerSupportServices*)rvsStreamerSupportService;

@property (nonatomic, assign) NSUInteger supportBCloud;  /**0x00 NOT support; 0x01 Support */
@property (nonatomic, assign) NSUInteger supportBTimeRecord;
@property (nonatomic, assign) NSUInteger supportBAlarmRecord;
@property (nonatomic, assign) NSUInteger supportBShortRecord;
@property (nonatomic, assign) NSUInteger supportBSnapShot;
@property (nonatomic, assign) NSUInteger supportBRebackTalk;
@property (nonatomic, assign) NSUInteger supportBRealIcon;
@property (nonatomic, assign) NSUInteger supportBWLan;
@property (nonatomic, assign) NSUInteger supportBSensors;

@end


@interface StreamerSensors : NSObject<NSCopying>

- (instancetype)initWithSensors:(RvsStreamerSensors*)rvsStreamerSensors;

@property (nonatomic, strong) NSMutableArray* sensorInfos;

@property (nonatomic, assign)BOOL alarmSwitchFlag; //报警布防开关，这个开关在sdk中不存在，实现的时候以sensor列表中所有sensor的调度周期的enable字段为准，只要有1个调度周期打开，则开关打开，否则关闭，如果一个sensor都没有，默认关闭，设置它也无效

@end

@interface StreamerSensorInfo : NSObject<NSCopying>

- (instancetype)initWithSensorInfo:(RvsStreamerSensorInfo*)rvsStreamerSensorInfo;

@property (nonatomic, assign) NSInteger sensorIndex;
@property (nonatomic, assign) NSInteger sensorType;
@property (nonatomic, copy) NSString* sensorName;
@property (nonatomic, strong) NSMutableArray* scheduleSettings;

- (NSArray*)getRvsSensorDetectSettings;

@end

@interface SensorsDetectSetting : NSObject<NSCopying>


- (instancetype)initWithSensorDetectSetting:(RvsSensorsDetectSetting*)rvsSensorDetectSetting;

@property (nonatomic, assign) NSUInteger  seq;
@property (nonatomic, assign) BOOL enable;
@property (nonatomic, assign) NSUInteger  startPoint;
@property (nonatomic, assign) NSUInteger  endPoint;
@property (nonatomic, assign) NSUInteger  weekFlg;
@property (nonatomic, assign) NSUInteger  threshold;

- (RvsSensorsDetectSetting*)getRvsSensorDetectSetting;

@end







