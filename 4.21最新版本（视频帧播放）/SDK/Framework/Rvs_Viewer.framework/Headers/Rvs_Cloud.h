#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <Rvs_Viewer/Rvs_Viewer_API.h>




@interface RvsCloudFile  : NSObject

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
 *  云录像文件操作通知
 */
@protocol Rvs_Cloud_RecordFile_Delegate <NSObject>

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
 *  Rvs_Cloud
 */
@interface Rvs_Cloud : NSObject

/**
 *  设置云录像文件操作通知
 */
@property (nonatomic, assign) id<Rvs_Cloud_RecordFile_Delegate> cloudRecordFileDelegate;


/**
 *  打开流云录像音视频流通道
 *
 *  @param streamerCID 采集端CID
 *  @param eid         云录像Eid
 *
 *  @return 流通道句柄
 */
- (RVS_STREAM)openStreamWithStreamer:(unsigned long long)streamerCID
                                           Eid:(NSString*)eid;

/**
 *  关闭流通道
 *
 *  @param hStream 流通道句柄
 *
 *  @return 0 代表成功，非0代表失败
 */
- (NSInteger)closeStreamWithStream:(RVS_STREAM)hStream;

/**
 *  获取流参数
 *
 *  @param hStream 流通道句柄
 *
 *  @return 流参数
 */
- (RvsMediaAVDesc*)getStreamDescWithStream:(RVS_STREAM)hStream;

/**
 *  获取未解码视频数据流
 *
 *  @param hStream       流通道句柄
 *  @param streamBuffer 输出参数,视频缓冲
 *  @param bufLen       输出参数,视频缓冲长度
 *  @param timeStamp    输出参数,时间戳
 *
 *  @return 大于0代表数据长度，其他代表未获取到数据
 */
- (NSInteger)readVideoDataWithStream:(RVS_STREAM)hStream
                       streamBuffer:(unsigned char**)streamBuffer
                             BufLen:(NSUInteger*)bufLen
                          TimeStamp:(NSUInteger*)timeStamp;

/**
 *  获取解码后YUV420视频数据流
 *
 *  @param hStream    流通道句柄
 *  @param pData     输出参数,YUV20视频缓冲,YUV420长度是 分辨率高＊宽＊3/2
 *  @param timeStamp 输出参数,时间戳
 *
 *  @return 大于0代表数据长度，其他代表未获取到数据
 */
- (NSInteger) readYUV420DataWithStream:(RVS_STREAM)hStream
                              YUVData:(unsigned char**)pData
                            TimeStamp:(NSUInteger*)timeStamp;


/**
 *  获取未解码音频数据流
 *
 *  @param hStream       流通道句柄
 *  @param streamBuffer 输出参数,音频缓冲
 *  @param bufLen       输出参数,音频缓冲长度
 *  @param timeStamp    输出参数,时间戳
 *
 *  @return 大于0代表数据长度，其他代表未获取到数据
 */
- (NSInteger) readAudioDataWithStream:(RVS_STREAM)hStream
                        streamBuffer:(unsigned char**)streamBuffer
                              BufLen:(NSUInteger*)bufLen
                           TimeStamp:(NSUInteger*)timeStamp;

/**
 *  暂停流
 *
 *  @param hStream 流通道句柄
 *
 *  @return  0 代表成功，非0代表失败
 */
- (NSInteger)pauseStreamWithStream:(RVS_STREAM)hStream;

/**
 *  恢复流
 *
 *  @param hStream 流通道句柄
 *
 *  @return 0 代表成功，非0代表失败
 */
- (NSInteger)resumeStreamWithStream:(RVS_STREAM)hStream;

/**
 *  流跳转到指定时间戳
 *
 *  @param hStream    流通道句柄
 *  @param timeStamp 时间戳
 *
 *  @return 0 代表成功，非0代表失败
 */
- (NSInteger)seekStreamWithStream:(RVS_STREAM)hStream TimeStamp:(NSUInteger)timeStamp;


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
- (unsigned long long)requestRecordFilesWithStreamer:(unsigned long long)streamerCID
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
- (unsigned long long)requestCloudFileIconWithStreamer:(unsigned long long)streamerCID
                                               Eid:(NSString*)eid;


/**
 *  通知采集端云服务器立即生效
 *
 *  @param streamerCID 采集端CID
 *
 *  @return 0 代表成功，非0代表失败
 */
- (NSInteger)setBegin:(unsigned long long)streamerCID;


@end
