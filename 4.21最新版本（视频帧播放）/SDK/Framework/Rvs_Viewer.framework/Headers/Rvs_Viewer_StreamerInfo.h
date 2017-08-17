/**
    Rvs_Viewer_StreamerInfo.h
    ICHANO SDK为网络摄像机或智能设备方案商及生产商提供了基于互联网的多媒体连接服务，使设备方案商通过简明的API调用，
    就能将所采集到的音、视频等多媒体信息通过互联网传输到用户的手机、电脑上，满足用户的监控、直播、对讲等相关的各种需求.
    ICHANO SDK观看端中有Rvs_Viewer、Rvs_Viewer_StreamerInfo、Rvs_Viewer_Media、Rvs_Viewer_Cmd这4个主要的类，
    其它类和接口均是围绕和辅助这4个类进行定义和使用,该文件是对Rvs_Viewer_StreamerInfo类的主要描述
 
    author Lvyi
    version 1.0.0 2016/6/16 Creation
 */

#import <Foundation/Foundation.h>

typedef enum enum_RVS_AUDIO_ENCODETYPE{
    E_RVS_AUDIO_TYPE_AAC               = 1,
    E_RVS_AUDIO_TYPE_G711A             = 2,
    E_RVS_AUDIO_TYPE_G711U             = 3,
    E_RVS_AUDIO_TYPE_PCM16             = 4
}EN_RVS_AUDIO_ENCODETYPE;

/** You can support multi encode type use & */
typedef enum enum_RVS_VIDEO_ENCODETYPE{
    E_RVS_VIDEO_TYPE_H264             = 0x01,
    E_RVS_VIDEO_TYPE_JPEG             = 0x02,
    E_RVS_VIDEO_TYPE_H265             = 0x04
}EN_RVS_VIDEO_ENCODETYPE;

typedef enum enum_RVS_PTZMOVE_MODE{
    EN_RVS_PTZMOVE_MODE_NOMODE        = 0,
    EN_RVS_PTZMOVE_MODE_PCTRL         = 0x01,
    EN_RVS_PTZMOVE_MODE_TCTRL         = 0x02,
    EN_RVS_PTZMOVE_MODE_ZCTRL         = 0x04,
    EN_RVS_PTZMOVE_MODE_XMOVE         = 0x08,
    EN_RVS_PTZMOVE_MODE_YMOVE         = 0x10,
    EN_RVS_PTZMOVE_MODE_ZMOVE         = 0x20
}EN_RVS_PTZMOVE_MODE;

typedef enum enum_RVS_STREAM_MODE{
    EN_RVS_STREAM_MODE_USESINGLE     = 0x00,
    EN_RVS_STREAM_MODE_USEMULTI      = 0x01
}EN_RVS_STREAM_MODE;

typedef enum enum_RVS_STREAMERINFO_UPDATE_TYPE{
    EN_RVS_STREAMERINFO_UPDATE_TYPE_INFO,
    EN_RVS_STREAMERINFO_UPDATE_TYPE_SUPPORTS,
    EN_RVS_STREAMERINFO_UPDATE_TYPE_TIMERECORD,
    EN_RVS_STREAMERINFO_UPDATE_TYPE_MOTION,
    EN_RVS_STREAMERINFO_UPDATE_TYPE_SENSOR
}EN_RVS_STREAMERINFO_UPDATE_TYPE;

typedef enum enum_RVS_STREAMER_DETECT_FLAG{
    EN_RVS_STREAMER_DETECT_FLAG_CLOSE = 0,
    EN_RVS_STREAMER_DETECT_FLAG_OPEN = 1
    
}EN_RVS_STREAMER_DETECT_FLAG;


typedef enum enum_RVS_MOTION_LEVEL
{
    EN_RVS_STREAMER_ALARM_LEVEL_NONE = 0,
    EN_RVS_STREAMER_ALARM_LEVEL_HIGH = 1,
    EN_RVS_STREAMER_ALARM_LEVEL_MEDIUM = 2,
    EN_RVS_STREAMER_ALARM_LEVEL_LOW = 3,
    EN_RVS_STREAMER_ALARM_LEVEL_MAX
    
}EN_RVS_MOTION_LEVEL;



@interface RvsScheduleSetting : NSObject

@property (nonatomic, assign) NSUInteger  seq;//该设置的序列号
@property (nonatomic, assign) BOOL enable;//是否启用该设置。
@property (nonatomic, assign) NSUInteger  startPoint;//开始时间，值为相对零点的偏移秒数
@property (nonatomic, assign) NSUInteger  endPoint;//结束时间，值为相对零点的偏移秒数
@property (nonatomic, assign) NSUInteger  weekFlag;//周日到周六标识，0表示周日，6表示周六

@end

@interface RvsTimeRecordSetting : NSObject

@property (nonatomic, retain) RvsScheduleSetting* schedule;
@property (nonatomic, assign) NSUInteger  param;

@end

@interface RvsMotionDetectSetting : NSObject

@property (nonatomic, retain) RvsScheduleSetting* schedule;
@property (nonatomic, assign) EN_RVS_MOTION_LEVEL  sensitive;

@end

@interface RvsSensorsDetectSetting : NSObject

@property (nonatomic, retain) RvsScheduleSetting* schedule;
@property (nonatomic, assign) NSUInteger  threshold;

@end


@interface RvsStreamerMicInfo : NSObject

@property (nonatomic, assign) NSUInteger samplerate;
@property (nonatomic, assign) NSUInteger channel;
@property (nonatomic, assign) NSUInteger depth;
@property (nonatomic, assign) NSUInteger encodeType;

@end


@interface RvsStreamerCameraStreamInfo : NSObject

@property (nonatomic, assign) NSInteger streamIndex;
@property (nonatomic, assign) NSInteger framerate;
@property (nonatomic, assign) NSInteger bitrate;
@property (nonatomic, assign) NSInteger frameInterval;
@property (nonatomic, assign) NSInteger quality;
@property (nonatomic, assign) NSInteger width;
@property (nonatomic, assign) NSInteger height;
@property (nonatomic, assign) NSUInteger encodeType;
@end



@interface RvsStreamerCameraInfo : NSObject

@property (nonatomic, assign) NSInteger camIndex;
@property (nonatomic, copy) NSString*  cameraName;
@property (nonatomic, assign) NSUInteger PTZMoveEnable;
@property (nonatomic, assign) NSUInteger torchEnable;
@property (nonatomic, assign) NSUInteger rotateEnable;
@property (nonatomic, assign) NSUInteger  streamType;
@property (nonatomic, retain) NSArray* cameraStreams;

@end

@interface RvsStreamerSensorInfo : NSObject

@property (nonatomic, assign) NSInteger sensorIndex;//当前传感器索引
@property (nonatomic, assign) NSInteger sensorType;//当前传感器的类型
@property (nonatomic, copy) NSString* sensorName; //当前传感器的名称
@property (nonatomic, retain) NSArray* scheduleSettings;//时间计划任务设置信息,数组里的内容是RvsSensorsDetectSetting

@end

@interface  RvsStreamerTimeRecordInfo : NSObject
@property (nonatomic, assign) NSInteger camIndex;//当前录制设置信息的镜头索引。
@property (nonatomic, retain) NSArray* scheduleSettings;//定时录制计划任务信息，数组里的内容是RvsTimeRecordSetting
@end

@interface  RvsStreamerAlarmRecordInfo : NSObject

@property (nonatomic, assign) NSInteger camIndex;//当前设置信息的镜头索引。
@property (nonatomic, retain) NSArray* scheduleSettings;//时间计划任务设置信息,数组里的内容是RvsMotionDetectSetting

@end


@interface RvsStreamerInfo : NSObject

@property (nonatomic, assign) NSInteger streamerType;//获取采集端类型，用户自定义值，和采集端注册时类型一致
@property (nonatomic, copy) NSString* OSVersion; //获取采集端操作系统版本
@property (nonatomic, copy) NSString* SDKVersion; //获取采集端SDK版本
@property (nonatomic, copy) NSString* AppVersion; //获取采集端应用版本
@property (nonatomic, assign) NSInteger language; //获取采集端语言标识。取值参见枚举RvsLanguage的定义
@property (nonatomic, assign) BOOL pushFlag; //该采集端发生报警时，平台是否发送push到观看端
@property (nonatomic, assign) BOOL emailFlag; //该采集端发生报警时，平台是否发送邮件到指定邮箱
@property (nonatomic, assign) BOOL noticeFlag; //该采集端发生报警时，是否有报警通知如响铃
@property (nonatomic, assign) NSUInteger setFlag; //该采集端报警总开关
@property (nonatomic, assign) NSUInteger runMode; //获取采集端支持的运行模式
@property (nonatomic, assign) NSUInteger recordMode; //获取采集端录制模式
@property (nonatomic, assign) NSUInteger timeZoneMode; //获取采集端时区模式
@property (nonatomic, assign) NSUInteger echoCancelFlag; //采集端回声消除支持与否
@property (nonatomic, assign) NSUInteger delDays; //采集端录像的过期删除的天数
@property (nonatomic, copy) NSString* emailAddr; //获取采集端相关的email地址。
@property (nonatomic, copy) NSString* deviceName; //获取采集端名称
@property (nonatomic, retain) NSArray* micInfos; //获取麦克风描述信息。
@property (nonatomic, retain) NSArray* cameras; //获取镜头描述信息

@end


@interface RvsStreamerSupportServices : NSObject

@property (nonatomic, assign) NSUInteger supportBCloud; //采集端是否支持录制视频云存储
@property (nonatomic, assign) NSUInteger supportBTimeRecord;//采集端是否支持定时录制
@property (nonatomic, assign) NSUInteger supportBAlarmRecord;//采集端是否支持报警录制
@property (nonatomic, assign) NSUInteger supportBShortRecord;//采集端是否支持短视频录制
@property (nonatomic, assign) NSUInteger supportBSnapShot;//采集端是否支持截图
@property (nonatomic, assign) NSUInteger supportBRebackTalk;//采集端是否支持逆向语音
@property (nonatomic, assign) NSUInteger supportBRealIcon;//采集端是否支持实时图标
@property (nonatomic, assign) NSUInteger supportBWLan;//采集端支持的无线连接模式
@property (nonatomic, assign) NSUInteger supportBSensors;//采集端是否支持传感器

@end


@interface RvsStreamerSensors : NSObject

@property (nonatomic, retain) NSArray* sensorInfos;

@end


/**
 *  采集端信息变更通知
 */
@protocol Rvs_Viewer_StreamerInfo_Delegate<NSObject>

/**
 *  采集端信息变更通知
 *
 *  @param streamerCID 采集端CID
 *  @param updateType  更新类型
 */
- (void)onStreamer:(unsigned long long)streamerCID InfoUpdate:(EN_RVS_STREAMERINFO_UPDATE_TYPE) updateType;

@end


/**
 *  能力类，用于设置该设备提供的能力
 */
@interface Rvs_Viewer_StreamerInfo: NSObject

/**
 *  设置采集端信息变更通知回调
 */
@property (nonatomic, assign) id<Rvs_Viewer_StreamerInfo_Delegate> delegate;

/**
 *  获取采集端基本信息
 *
 *  @param streamerCID 采集端CID
 *
 *  @return 采集端基本信息
 */
- (RvsStreamerInfo*)getStreamerInfo:(unsigned long long)streamerCID;

/**
 *  获取采集端能力集
 *
 *  @param streamerCID 采集端CID
 *
 *  @return 采集端能力集
 */
- (RvsStreamerSupportServices*)getStreamerSupportServices:(unsigned long long)streamerCID;

/**
 *  获取采集端定时录制配置信息
 *
 *  @param streamerCID 采集端CID
 *  @param cameraIndex 镜头ID
 *
 *  @return 采集端定时录制配置信息
 */
- (RvsStreamerTimeRecordInfo*)getStreamerRecordSchedule:(unsigned long long)streamerCID
                                            CameraIndex:(NSUInteger)cameraIndex;

/**
 *  获取采集端移动侦测报警配置信息
 *
 *  @param streamerCID 采集端CID
 *  @param cameraIndex 镜头ID
 *
 *  @return 采集端移动侦测报警配置信息
 */
- (RvsStreamerAlarmRecordInfo*)getStreamerMotionSchedule:(unsigned long long)streamerCID
                                             CameraIndex:(NSUInteger)cameraIndex;

/**
 *  获取采集端传感器配置信息
 *
 *  @param streamerCID 采集端CID
 *
 *  @return 采集端传感器配置信息
 */
- (RvsStreamerSensors*)getStreamerSensors:(unsigned long long)streamerCID;

/**
 *  设置采集端名称
 *
 *  @param streamerCID  采集端CID
 *  @param streamerName 采集端名称
 *
 *  @return 0 代表成功，非0代表失败
 */
- (NSInteger)setStreamer:(unsigned long long)streamerCID
               Name:(NSString*)streamerName;

/**
 *  设置采集端邮件信息
 *
 *  @param streamerCID 采集端CID
 *  @param emailEnable 是否使用邮件
 *  @param emailAddr   邮件地址
 *
 *  @return 0 代表成功，非0代表失败
 */
- (NSInteger)setStreamer:(unsigned long long)streamerCID
        EmailEnable:(BOOL)emailEnable
          EmailAddr:(NSString*)emailAddr;

/**
 *  设置采集端push开关
 *
 *  @param streamerCID 采集端CID
 *  @param pushEnable  push开关
 *
 *  @return  0 代表成功，非0代表失败
 */
- (NSInteger)setStreamer:(unsigned long long)streamerCID
         PushEnable:(BOOL)pushEnable;

/**
 *  设置采集端报警输出开关
 *
 *  @param streamerCID  采集端CID
 *  @param noticeEnable notice开关
 *
 *  @return 0 代表成功，非0代表失败
 */
- (NSInteger)setStreamer:(unsigned long long)streamerCID
       NoticeEnable:(BOOL)noticeEnable;

/**
 *  设置采集端录像自动删除天数
 *
 *  @param streamerCID  采集端CID
 *  @param delDays      删除天数
 *
 *  @return 0 代表成功，非0代表失败
 */
- (NSInteger)setStreamer:(unsigned long long)streamerCID RecordDelDays:(NSUInteger)delDays;

/**
 *  设置采集端移动侦测检测开关
 *
 *  @param streamerCID 采集端CID
 *  @param flag        移动侦测检测开关
 *
 *  @return 0 代表成功，非0代表失败
 */
- (NSInteger)setStreamer:(unsigned long long)streamerCID DetectFlag:(NSUInteger)flag;

/**
 *  设置采集端定时录制配置信息
 *
 *  @param streamerCID    采集端CID
 *  @param cameraIndex    镜头ID
 *  @param timeRecordInfo 定时录制配置信息
 *
 *  @return 0 代表成功，非0代表失败
 */
- (NSInteger)setStreamer:(unsigned long long)streamerCID
        CameraIndex:(NSUInteger)cameraIndex
     TimeReocrdInfo:(RvsStreamerTimeRecordInfo*)timeRecordInfo;

/**
 *  设置采集端移动侦测报警配置信息
 *
 *  @param streamerCID     采集端CID
 *  @param cameraIndex     采集端CID
 *  @param alarmRecordInfo 移动侦测报警配置信息
 *
 *  @return 0 代表成功，非0代表失败
 */
- (NSInteger)setStreamer:(unsigned long long)streamerCID
        CameraIndex:(NSUInteger)cameraIndex
    AlarmRecordInfo:(RvsStreamerAlarmRecordInfo*)alarmRecordInfo;

/**
 *  设置采集端传感器配置信息
 *
 *  @param streamerCID 采集端CID
 *  @param sensorType  传感器类型
 *  @param sensorIndex 传感器ID
 *  @param sensorInfo  传感器配置信息
 *
 *  @return 0 代表成功，非0代表失败
 */
- (NSInteger)setStreamer:(unsigned long long)streamerCID
         SensorType:(NSInteger)sensorType
        SensorIndex:(NSInteger)sensorIndex
         SensorInfo:(RvsStreamerSensorInfo*)sensorInfo;


- (NSUInteger)getStreamerDetectFlag:(unsigned long long)streamerCID;
@end
