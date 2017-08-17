/**
    Rvs_Viewer_Cmd.h
    ICHANO SDK为网络摄像机或智能设备方案商及生产商提供了基于互联网的多媒体连接服务，使设备方案商通过简明的API调用，
    就能将所采集到的音、视频等多媒体信息通过互联网传输到用户的手机、电脑上，满足用户的监控、直播、对讲等相关的各种需求.
    ICHANO SDK观看端中有Rvs_Viewer、Rvs_Viewer_StreamerInfo、Rvs_Viewer_Media、Rvs_Viewer_Cmd这4个主要的类，
    其它类和接口均是围绕和辅助这4个类进行定义和使用,该文件是对Rvs_Viewer_Media类的主要描述
 
    author Lvyi
    version 1.0.0 2016/6/16 Creation
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <Rvs_Viewer/Rvs_Viewer_Sys.h>


typedef enum enum_RVS_MEDIASTREAM_STATE{
    EN_RVS_MEDIASTREAM_STATE_CREATED        = 0,
    EN_RVS_MEDIASTREAM_STATE_CLOSED,
}EN_RVS_MEDIASTREAM_STATE;

typedef enum enum_RVS_MEDIASTREAM_FLAG{
    EN_RVS_MEDIASTREAM_FLAG_NOERR          = 0,
    EN_RVS_MEDIASTREAM_FLAG_SERVICE_NOTSUPPORT,
    EN_RVS_MEDIASTREAM_FLAG_VERSION_NOTSUPPORT,
    EN_RVS_MEDIASTREAM_FLAG_SERVICE_FULL,
    EN_RVS_MEDIASTREAM_FLAG_VERSION_NEEDUPDATE,
    EN_RVS_MEDIASTREAM_FLAG_SERVICE_ERR,
}EN_RVS_MEDIASTREAM_FLAG;

typedef enum enum_RVS_REV_STREAM_TYPE{
    EN_RVS_REV_STREAM_TYPE_AUDIO     = 0,
    EN_RVS_REV_STREAM_TYPE_VIDEO     = 1,
    EN_RVS_REV_STREAM_TYPE_AV        = 2,
}EN_RVS_REV_STREAM_TYPE;

typedef enum enum_RVS_VIEWER_VIDEO_TYPE
{
    E_RVS_VIEWER_VIDEO_TYPE_NOVIDEO            = 0,
    E_RVS_VIEWER_VIDEO_TYPE_JPEG               = 1,
    E_RVS_VIEWER_VIDEO_TYPE_H264               = 2,
    E_RVS_VIEWER_VIDEO_TYPE_H265               = 3
}EN_RVS_VIEWER_VIDEO_TYPE;

typedef enum enum_RVS_VIEWER_AUDIO_TYPE
{
    E_RVS_VIEWER_AUDIO_TYPE_NOAUDIO           = 0,
    E_RVS_VIEWER_AUDIO_TYPE_AAC               = 1,
    E_RVS_VIEWER_AUDIO_TYPE_G711A             = 2,
    E_RVS_VIEWER_AUDIO_TYPE_G711U             = 3,
    E_RVS_VIEWER_AUDIO_TYPE_PCM16             = 4,
}EN_RVS_VIEWER_AUDIO_TYPE;


typedef enum enum_RVS_MEDIA_REVDATATYPE{
    E_RVS_MEDIA_REVDATATYPE_AUDIO = 1,
    E_RVS_MEDIA_REVDATATYPE_VIDEO = 2
}EN_RVS_MEDIA_REVDATATYPE;

typedef enum enum_RVS_JPEG_TYPE
{
    EN_RVS_JPEG_TYPE_HD           = 0,
    EN_RVS_JPEG_TYPE_NORMAL       = 1,
    EN_RVS_JPEG_TYPE_ICON         = 2,
}EN_RVS_JPEG_TYPE;

typedef enum enum_RVS_RECORD_TYPE
{
    EN_RVS_RECORD_TYPE_SCHEDULE = 0x01,
    EN_RVS_RECORD_TYPE_MOTION = 0x02,
    EN_RVS_RECORD_TYPE_TIMELAPSE = 0x04,
    EN_RVS_RECORD_TYPE_CUSTOMRECORD = 0x08,
    
    EN_RVS_RECORD_TYPE_CUSTOMUSER1 = 0x10000,
    EN_RVS_RECORD_TYPE_CUSTOMUSER2 = 0x20000,
    EN_RVS_RECORD_TYPE_CUSTOMUSER3 = 0x40000,
    EN_RVS_RECORD_TYPE_CUSTOMUSER4 = 0x80000,

}EN_RVS_RECORD_TYPE;


typedef enum enum_RVS_CLOUD_ERROR_CODE {
    EN_RVS_CLOUD_NOERR                          = 100,
    EN_RVS_CLOUD_ERROR_CONFIG                   = 101,
    EN_RVS_CLOUD_ERROR_REQ                      = 102,
    EN_RVS_CLOUD_ERROR_RECV                     = 103,
    EN_RVS_CLOUD_ERROR_MALLOC                   = 104,
    EN_RVS_CLOUD_ERROR_SERVER_PARM              = 105,
    EN_RVS_CLOUD_ERROR_SERVER_AUTHORIZATION     = 106,
    EN_RVS_CLOUD_ERROR_SERVER_ERROR             = 107,
    EN_RVS_CLOUD_ERROR_OTHER                    = 108,
    EN_RVS_CLOUD_ERROR_HAS_NO_DATA_UPLOADED     = 109
}EN_RVS_CLOUD_ERROR_CODE;

/**
 *  音视频格式描述符
 */
@interface RvsMediaAVDesc : NSObject

/**
 *  视频格式类型
 */
@property (nonatomic, assign) EN_RVS_VIEWER_VIDEO_TYPE videoType;

/**
 *  视频分辨率之宽度
 */
@property (nonatomic, assign) NSInteger width;

/**
 *  视频分辨率之高度
 */
@property (nonatomic, assign) NSInteger height;

/**
 *  音频格式类型
 */
@property (nonatomic, assign) EN_RVS_VIEWER_AUDIO_TYPE audioType;

/**
 *  音频采样率
 */
@property (nonatomic, assign) NSUInteger sampleRate;

/**
 *  音频声道数
 */
@property (nonatomic, assign) NSUInteger channel;

/**
 *  音频数据位深，16位还是8位
 */
@property (nonatomic, assign) NSUInteger depth;

@end




/**
 *  采集端录像文件详情
 */
@interface RvsRecordFileInfo  : NSObject

/**
 *  录像文件名
 */
@property (nonatomic, copy) NSString* fileName;

/**
 *  录像图标的扩展名，图标的名字和文件名是一样的，扩展名不同，图标的扩展名可能为jpg,png等
 */
@property (nonatomic, copy) NSString* iconExname;

/**
 *  录像创建时间
 */
@property (nonatomic, copy) NSString* createTime;


/**
 *  录像文件大小
 */
@property (nonatomic, assign) NSUInteger fileSize;


/**
 *  录像时长
 */
@property (nonatomic, assign) NSUInteger fileDuration;


/**
 *  录像类型,取值见EN_RVS_RECORD_TYPE
 */
@property (nonatomic, assign) NSUInteger recordType;

@end


/**
 *  云录像文件详情
 */
@interface RvsCloudFileInfo  : NSObject

/**
 *  eid号，用于在云端标示一个录像文件
 */
@property (nonatomic, copy) NSString* eid;

/**
 *  镜头ID
 */
@property (nonatomic, assign) NSUInteger camIndex;

/**
 *  云录像创建时间
 */
@property (nonatomic, copy) NSString* createTime;

/**
 *  云录像时长
 */
@property (nonatomic, assign) NSUInteger duration;

/**
 *  云录像文件大小
 */
@property (nonatomic, assign) NSUInteger fileSize;

@end




/**
 *  流媒体状态的通知
 */
@protocol Rvs_Viewer_Media_StreamState_Delegate <NSObject>


/**
 *  媒体流状态通知，当streamState为EN_RVS_MEDIASTREAM_STATE_CREATED时,标示流媒体通道已经建立成功，可以接收来自采集端的音视频流
 *
 *  @param handle      流句柄
 *  @param streamState 流状态
 *  @param streamFlag  流错误
 */
- (void)onMediaStreamStateWithHandle:(RVS_HANDLE)handle
                         StreamState:(EN_RVS_MEDIASTREAM_STATE)streamState
                          StreamFlag:(EN_RVS_MEDIASTREAM_FLAG) streamFlag;


@end

/**
 *  采集端录像文件操作通知
 */
@protocol Rvs_Viewer_Media_RecordFile_Delegate <NSObject>

/**
 *  获取已录制文件的列表通知
 *
 *  @param requestID    请求ID
 *  @param totalCount   录像列表总个数
 *  @param currentCount 当前的查询的个数
 *  @param FileInfos    录像列表,数组内部是RvsRecordFileInfo
 */
- (void)onRecordFilesWithRequestID:(unsigned long long)requestID
                        TotalCount:(NSUInteger)totalCount
                      CurrentCount:(NSUInteger)currentCount
                          FileInfo:(NSArray*)FileInfos;

/**
 *  删除录制文件状态通知
 *
 *  @param requestID 请求ID
 *  @param status    删除是否成功
 */
- (void)onRecordFileDeleteStatusWithRequestID:(unsigned long long)requestID
                                       Status:(BOOL)status;


- (void)onRecordDayListWithRequestID:(unsigned long long)requestID
                          TotalCount:(NSUInteger)totalCount
                        CurrentCount:(NSUInteger)currentCount
                            DayInfo:(NSArray*)dayInfos;

@end

/**
 *  云录像文件操作通知
 */
@protocol Rvs_Viewer_Media_CloudFile_Delegate <NSObject>

/**
 *  查询每天云视频数量的回调，返回文件统计数据给查询者
 *
 *  @param requestID   请求ID
 *  @param streamerCID 采集端CID
 *  @param dayInfos    文件统计数据,是个NSNumber的数组
 *  @param startDay    起始时间
 *  @param errorCode   错误码
 */
- (void)onCloudFilePerDayWithRequestID:(unsigned long long)requestID
                             Streamer:(unsigned long long)streamerCID
                             DayInfo:(NSArray*)dayInfos
                        FromStartDay:(NSString*)startDay
                           ErrorCode:(EN_RVS_CLOUD_ERROR_CODE)errorCode;

/**
 *  查询云视频列表的回调方法
 *
 *  @param requestID    请求ID
 *  @param totalCount   录像列表总个数
 *  @param currentCount 当前的查询的个数
 *  @param FileInfos    录像列表,数组内部是RvsCloudFileInfo
 *  @param errorCode   错误码
 */
- (void)onCloudFilesWithRequestID:(unsigned long long)requestID
                       TotalCount:(NSUInteger)totalCount
                     CurrentCount:(NSUInteger)currentCount
                         FileInfo:(NSArray*)FileInfos
                        ErrorCode:(EN_RVS_CLOUD_ERROR_CODE)errorCode;

/**
 *  回调接收请求云视频图标数据
 *
 *  @param requestID   请求ID
 *  @param streamerCID 采集端CID
 *  @param eid         云录像Eid号
 *  @param buffer      图标数据缓冲指针
 *  @param bufferLen   图标数据缓冲长度
 */
- (void)onRecvCloudFileIconWithRequestID:(unsigned long long)requestID
                                Streamer:(unsigned long long)streamerCID
                                    Eid:(NSString*)eid
                                 Buffer:(unsigned char*)buffer
                              BufferLen:(NSUInteger)bufferLen;

@end

/**
 *  逆向流音视频请求回调
 */
@protocol Rvs_Viewer_Media_RevStream_Delegate <NSObject>


/**
 *  采集端对逆向码流是否接受的结果反馈
 *
 *  @param streamerCID 采集端CID
 *  @param streamState 流状态
 *  @param streamFlag  流信息
 */
- (void)onRevSreamStateWithStreamer:(unsigned long long)streamerCID
                        StreamState:(EN_RVS_MEDIASTREAM_STATE)streamState
                         StreamFlag:(EN_RVS_MEDIASTREAM_FLAG) streamFlag;


@end


/**
 *  Jpeg文件操作回调
 */
@protocol Rvs_Viewer_Media_RecvJpeg_Delegate <NSObject>

/**
 *  获取一帧JPEG图片
 *
 *  @param requestID  请求ID
 *  @param jpegBuffer jpeg数据缓冲指针
 *  @param bufferLen  jpeg数据缓冲长度
 */
- (void)onRecvJpegWithRequestID:(unsigned long long)requestID
                   JpegBuffer:(unsigned char*)jpegBuffer
                    BufferLen:(NSUInteger)bufferLen;


@end



/**
 *  Rvs_Viewer_Media是ICHANO SDK中，对音、视频码流进行处理的类，应调用[Rvs_Viewer defaultViewer].viewerMedia来获得该类的实例。
    主要用于和采集端建立连接，读取视频流和音频流。提供查询采集端录像文件、云端视频文件，播放录像和云视频等功能
 */
@interface Rvs_Viewer_Media : NSObject

/**
 *  设置媒体流状态回调
 */
@property (nonatomic, assign) id<Rvs_Viewer_Media_StreamState_Delegate> streamStateDelegate;

/**
 *  设置采集端录像文件操作通知回调
 */
@property (nonatomic, assign) id<Rvs_Viewer_Media_RecordFile_Delegate> recordFileDelegate;

/**
 *  设置云录像文件操作通知
 */
@property (nonatomic, assign) id<Rvs_Viewer_Media_RevStream_Delegate> revStreamDelegate;

/**
 * 设置Jpeg文件操作回调
 */
@property (nonatomic, assign) id<Rvs_Viewer_Media_RecvJpeg_Delegate> RecvJpegDelegate;

/**
 *  设置逆向流音视频请求回调
 */
@property (nonatomic, assign) id<Rvs_Viewer_Media_CloudFile_Delegate> cloudFileDelegate;

/**
 *  打开一路实时音视频流通道
 *
 *  @param streamerCID 采集端CID
 *  @param cameraIndex 镜头id
 *  @param streamIndex 流id
 *  @param micIndex    麦id
 *
 *  @return 流通道句柄
 */
- (RVS_HANDLE) openLiveStreamWithStreamer:(unsigned long long)streamerCID
                              CameraIndex:(NSUInteger)cameraIndex
                              StreamIndex:(NSUInteger)streamIndex
                                 MicIndex:(NSUInteger)micIndex;

/**
 *  打开采集端录像音视频流通道
 *
 *  @param streamerCID 采集端CID
 *  @param fileName    录像文件名
 *
 *  @return 流通道句柄
 */
- (RVS_HANDLE)openRemoteRecordFileStreamithStreamer:(unsigned long long)streamerCID
                                           FileName:(NSString*)fileName;


- (RVS_HANDLE)openRemoteRecordFileStreamithStreamerEx:(unsigned long long)streamerCID
                                             FileName:(NSString*)fileName
                                           RecordType:(EN_RVS_RECORD_TYPE)recordType;

/**
 *  打开流云录像音视频流通道
 *
 *  @param streamerCID 采集端CID
 *  @param eid         云录像Eid
 *
 *  @return 流通道句柄
 */
- (RVS_HANDLE)openCloudRecordFileStreamWithStreamer:(unsigned long long)streamerCID
                                           Eid:(NSString*)eid;

/**
 *  关闭流通道
 *
 *  @param handle 流通道句柄
 *
 *  @return 0 代表成功，非0代表失败
 */
- (NSInteger)closeStreamWithHandle:(RVS_HANDLE)handle;

/**
 *  获取流参数
 *
 *  @param handle 流通道句柄
 *
 *  @return 流参数
 */
- (RvsMediaAVDesc*)getStreamDescWithHandle:(RVS_HANDLE)handle;

/**
 *  获取未解码视频数据流
 *
 *  @param handle       流通道句柄
 *  @param streamBuffer 输出参数,视频缓冲
 *  @param bufLen       输出参数,视频缓冲长度
 *  @param timeStamp    输出参数,时间戳
 *
 *  @return 大于0代表数据长度，其他代表未获取到数据
 */
- (NSInteger)getVideoDataWithHandle:(RVS_HANDLE)handle
                       streamBuffer:(unsigned char**)streamBuffer
                             BufLen:(NSUInteger*)bufLen
                          TimeStamp:(NSUInteger*)timeStamp;

/**
 *  获取解码后YUV420视频数据流
 *
 *  @param handle    流通道句柄
 *  @param pData     输出参数,YUV20视频缓冲,YUV420长度是 分辨率高＊宽＊3/2
 *  @param timeStamp 输出参数,时间戳
 *
 *  @return 大于0代表数据长度，其他代表未获取到数据
 */
- (NSInteger) getYUV420DataWithHandle:(RVS_HANDLE)handle
                              YUVData:(unsigned char**)pData
                            TimeStamp:(NSUInteger*)timeStamp;

- (NSInteger) getYUV420DataWithHandle:(RVS_HANDLE)handle
                              YUVData:(unsigned char**)pData
                            TimeStamp:(NSUInteger*)timeStamp
                                Width:(NSUInteger*)frameWidth
                               Height:(NSUInteger*)frameHeigth;


/**
 *  获取未解码音频数据流
 *
 *  @param handle       流通道句柄
 *  @param streamBuffer 输出参数,音频缓冲
 *  @param bufLen       输出参数,音频缓冲长度
 *  @param timeStamp    输出参数,时间戳
 *
 *  @return 大于0代表数据长度，其他代表未获取到数据
 */
- (NSInteger) getAudioDataWithHandle:(RVS_HANDLE)handle
                        streamBuffer:(unsigned char**)streamBuffer
                              BufLen:(NSUInteger*)bufLen
                           TimeStamp:(NSUInteger*)timeStamp;

/**
 *  暂停流
 *
 *  @param handle 流通道句柄
 *
 *  @return  0 代表成功，非0代表失败
 */
- (NSInteger)pauseStreamWithHandle:(RVS_HANDLE)handle;

/**
 *  恢复流
 *
 *  @param handle 流通道句柄
 *
 *  @return 0 代表成功，非0代表失败
 */
- (NSInteger)resumeStreamWithHandle:(RVS_HANDLE)handle;

/**
 *  流跳转到指定时间戳
 *
 *  @param handle    流通道句柄
 *  @param timeStamp 时间戳
 *
 *  @return 0 代表成功，非0代表失败
 */
- (NSInteger)seekStreamWithHandle:(RVS_HANDLE)handle TimeStamp:(NSUInteger)timeStamp;



/**
 *  开始本地录像
 *
 *  @param handle       流通道句柄
 *  @param pathFileName 录像文件名
 *
 *  @return 0 代表成功，非0代表失败
 */
- (NSInteger)startLocalRecordWithHandle:(RVS_HANDLE)handle
                           PathFileName:(NSString*)pathFileName;


/**
 *  停止本地录像
 *
 *  @param handle 流通道句柄
 *
 *  @return 0 代表成功，非0代表失败
 */
- (NSInteger)stopLocalRecordWithHandle:(RVS_HANDLE)handle;

/**
 *  从视频流中请求jpeg图片
 *
 *  @param streamerCID 采集端CID
 *  @param cameraIndex 镜头id
 *  @param jpegType    jpeg类型
 *
 *  @return 请求ID
 */
- (unsigned long long)requestJpegWithStreamer:(unsigned long long)streamerCID
                         CameraIndex:(NSUInteger)cameraIndex
                            JpegType:(EN_RVS_JPEG_TYPE) jpegType;


/**
 *  请求一张jpeg图片
 *
 *  @param streamerCID 采集端CID
 *  @param fileName    jepg文件名
 *
 *  @return 请求ID
 */
- (unsigned long long)requestJpegFileWithStreamer:(unsigned long long)streamerCID
                                FileName:(NSString*)fileName;

- (unsigned long long)requestJpegFileWithStreamerEx:(unsigned long long)streamerCID
                                           FileName:(NSString*)fileName
                                         RecordType:(EN_RVS_RECORD_TYPE)recordType;


- (unsigned long long)requestStreamerRecordDayListWithStreamer:(unsigned long long)streamerCID
                                                   CameraIndex:(NSUInteger)cameraIndex
                                                     PageIndex:(NSUInteger)pageIndex
                                                  CountPerPage:(NSUInteger)CountPerPage
                                                    RecordType:(EN_RVS_RECORD_TYPE)recordType;

/**
 *  查询采集端录像视频列表
 *
 *  @param streamerCID  采集端CID
 *  @param cameraIndex  镜头ID
 *  @param pageIndex    页数
 *  @param CountPerPage 每页个数
 *  @param beginTime    开始时间
 *  @param endTime      结束时间
 *  @param recordType   录像类型
 *
 *  @return 请求ID
 */

- (unsigned long long)requestStreamerRecordFilesWithStreamer:(unsigned long long)streamerCID
                                        CameraIndex:(NSUInteger)cameraIndex
                                          PageIndex:(NSUInteger)pageIndex
                                       CountPerPage:(NSUInteger)CountPerPage
                                          BeginTime:(NSString*)beginTime
                                            EndTime:(NSString*)endTime
                                         RecordType:(EN_RVS_RECORD_TYPE)recordType;


/**
 *  删除采集端录像文件
 *
 *  @param streamerCID 采集端CID
 *  @param fileName    录像文件名
 *  @param recordType   录像类型
 *
 *  @return 请求ID
 */
- (unsigned long long)removeRecordFileByNameWithStreamer:(unsigned long long)streamerCID
                                                FileName:(NSString*)fileName
                                              RecordType:(EN_RVS_RECORD_TYPE)recordType;

/**
 *  根据时间删除录像文件
 *
 *  @param streamerCID 采集端CID
 *  @param cameraIndex 镜头ID
 *  @param beginTime   开始时间
 *  @param endTime     结束时间
 *  @param recordType  录像类型
 *
 *  @return 请求ID
 */
- (unsigned long long)removeRecordFilesByTimeWithStreamer:(unsigned long long)streamerCID
                                              CameraIndex:(NSUInteger)cameraIndex
                                                BeginTime:(NSString*)beginTime
                                                  EndTime:(NSString*)endTime
                                               RecordType:(EN_RVS_RECORD_TYPE)recordType;
/**
 *  删除采集端全部录像文件
 *
 *  @param streamerCID 采集端CID
 *  @param recordType  录像类型
 *
 *  @return 请求ID
 */
- (unsigned long long)removeAllRecordFilesWithStreamer:(unsigned long long)streamerCID RecordType:(EN_RVS_RECORD_TYPE)recordType;

- (unsigned long long)removeAllRecordFilesWithStreamer:(unsigned long long)streamerCID RecordType:(EN_RVS_RECORD_TYPE)recordType selectedDate:(NSString *)selectedDate;
/**
 *  获取每一天的云视频文件数目
 *
 *  @param streamerCID 采集端CID
 *
 *  @return 请求ID
 */
- (unsigned long long)requestFileCountPerDayWithStreamer:(unsigned long long)streamerCID;

/**
 *  查询某一天的云视频文件详情
 *
 *  @param streamerCID  采集端CID
 *  @param cameraIndex  镜头ID
 *  @param pageIndex    页数
 *  @param CountPerPage 每页个数
 *  @param day          开始时间
 *  @param recordType   录像类型
 *
 *  @return 请求ID
 */
- (unsigned long long)requestCloudRecordFilesWithStreamer:(unsigned long long)streamerCID
                                              CameraIndex:(NSUInteger)cameraIndex
                                                PageIndex:(NSUInteger)pageIndex
                                             CountPerPage:(NSUInteger)CountPerPage
                                                BeginTime:(NSString*)day
                                               RecordType:(EN_RVS_RECORD_TYPE)recordType;
/**
 *  请求云视频文件的图标
 *
 *  @param streamerCID 采集端CID
 *  @param eid         云录像Eid号
 *
 *  @return 请求ID
 */
- (unsigned long long)getCloudFileIconWithStreamer:(unsigned long long)streamerCID
                                               Eid:(NSString*)eid;

/**
 *  设置逆向流参数
 *
 *  @param streamFormat 音视频参数
 *
 *  @return 0 代表成功，非0代表失败
 */
- (NSInteger)setRevStreamProperty:( RvsMediaAVDesc*)streamFormat;

/**
 *  发送逆向音视频数据
 *
 *  @param streamData 音视频数据缓冲
 *  @param dataLen    缓冲长度
 *  @param timeStamp  时间戳
 *  @param streamType 音视频类型
 *
 *  @return 0 代表成功，非0代表失败
 */
- (NSInteger)writeRevStreamData:(unsigned char*)streamData
                        DataLen:(NSInteger)dataLen
                      TimeStamp:(NSUInteger)timeStamp
                     StreamType:(EN_RVS_REV_STREAM_TYPE)streamType;

/**
 *  发起逆向流请求
 *
 *  @param streamerCID 采集端CID
 *
 *  @return 逆向流句柄
 */
- (RVS_HANDLE) startRevStreamWithStreamer:(unsigned long long)streamerCID;

/**
 *  关闭逆向流
 *
 *  @param handle 向流句柄
 *
 *  @return 0 代表成功，非0代表失败
 */
- (NSInteger)stopRevStreamWithHandle:(RVS_HANDLE)handle;


/**
 *  通知采集端云服务器立即生效
 *
 *  @param streamerCID 采集端CID
 *
 *  @return 0 代表成功，非0代表失败
 */
- (NSInteger)setCloudBegin:(unsigned long long)streamerCID;

- (UIImage*)getSnapshotWithHandle:(RVS_HANDLE)handle;


@end
