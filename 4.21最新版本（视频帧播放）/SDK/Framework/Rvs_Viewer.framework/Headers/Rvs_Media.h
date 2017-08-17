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
#import "Rvs_Viewer_StreamerInfo.h"


typedef enum enum_RVS_STREAM_TYPE{
    EN_RVS_STREAM_TYPE_RECV					= 0,
    EN_RVS_STREAM_TYPE_SEND					= 1,
}EN_RVS_STREAM_TYPE;


typedef enum enum_RVS_MEDIA_WRITE_FLAG{
    E_RVS_MEDIA_WRITE_CLOSE                    = 0x00,
    E_RVS_MEDIA_WRITE_OPEN                     = 0x01,
}EN_RVS_MEDIA_WRITE_FLAG;


typedef enum enum_RVS_MEDIA_JPEG_TYPE{
    EN_RVS_MEDIA_JPEG_TYPE_HD           = 0,
    EN_RVS_MEDIA_JPEG_TYPE_NORMAL       = 1,
    EN_RVS_MEDIA_JPEG_TYPE_ICON         = 2,
}EN_RVS_MEDIA_JPEG_TYPE;


typedef enum enum_RVS_MEDIA_RESPONSE_TYPE{
    EN_RVS_MEDIA_RESPONSE_TYPE_ACCEPTED,
    EN_RVS_MEDIA_RESPONSE_TYPE_REJECTED,
    EN_RVS_MEDIA_RESPONSE_TYPE_NORSP,
}EN_RVS_MEDIA_RESPONSE_TYPE;


@interface RvsCameraStreamInfo : NSObject

@property (nonatomic, assign) EN_RVS_VIDEO_ENCODETYPE videoType;

@property (nonatomic, assign)  NSUInteger width;
@property (nonatomic, assign)  NSUInteger height;
@property (nonatomic, assign)  NSUInteger bitrate;
@property (nonatomic, assign)  NSUInteger framerate;
@property (nonatomic, assign)  NSUInteger qulity;
@property (nonatomic, assign)  NSUInteger frameInterval;


@end


@interface RvsMicInfo : NSObject

@property (nonatomic, assign) EN_RVS_AUDIO_ENCODETYPE audioType;

@property (nonatomic, assign)  NSUInteger sampleRate;
@property (nonatomic, assign)  NSUInteger channel;
@property (nonatomic, assign)  NSUInteger depth;



@end


@interface RvsStreamAVDesc : NSObject


@property (nonatomic, strong) RvsCameraStreamInfo* videoDesc;
@property (nonatomic, strong) RvsMicInfo* audioDesc;


@end


/**
 *  流媒体状态的通知
 */
@protocol Rvs_LiveStream_Delegate <NSObject>


- (void)onStreamInComingNotifyWithStream:(RVS_STREAM) hStream StreamType:(EN_RVS_STREAM_TYPE)streamType;
- (void)onStreamResponseNotifyWithStream:(RVS_STREAM) hStream ResponseType:(EN_RVS_MEDIA_RESPONSE_TYPE)responseType;
- (void)onStreamErroNotifyWithStream:(RVS_STREAM) hStream ErrorCode:(NSUInteger)ErrorCode;

@end


/**
 *  Jpeg文件操作回调
 */
@protocol Rvs_RecvJpeg_Delegate <NSObject>

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



@protocol Rvs_MediaWrite_Delegate <NSObject>


//需要一个IDR帧
- (void)onKeyFrameNotifyForCamera:(NSUInteger) cameraId
                             Stream:(NSUInteger) streamId;


- (void)onVideoWriteNotify:(EN_RVS_MEDIA_WRITE_FLAG)flag
                       ForCamera:(NSUInteger) cameraId
                          Stream:(NSUInteger) streamId;

- (void)onAudioWriteNotify:(EN_RVS_MEDIA_WRITE_FLAG)flag
                          ForMic:(NSUInteger)micId;


@end


@protocol Rvs_MediaDataGet_Delegate <NSObject>

- (void)onGetYUV420:(unsigned char**)ppFrameBuf
               ForCamera:(NSUInteger) cameraId
                  Stream:(NSUInteger) streamId;

- (void)onGetJpeg:(unsigned char**)ppFrameBuf
           FrameLength:(NSUInteger*) pFrameBufLength
              JpegType:(EN_RVS_MEDIA_JPEG_TYPE)jpegType
             ForCamera:(NSUInteger) cameraId
                Stream:(NSUInteger) streamId;

@end



@interface Rvs_Media : NSObject


@property (nonatomic, assign) id<Rvs_MediaWrite_Delegate> mediaWriteDelegate;
@property (nonatomic, assign) id<Rvs_MediaDataGet_Delegate> mediaDataGetDelegate;
@property (nonatomic, assign) id<Rvs_RecvJpeg_Delegate> RecvJpegDelegate;


- (NSInteger)setCameraCount:(NSUInteger) cameraCount;
- (NSInteger)setStreamCount:(NSUInteger) streamCount
                  ForCamera:(NSUInteger) cameraId;
- (NSInteger)setCameraStreamProperty:(const RvsCameraStreamInfo*)videoInfo
                           ForCamera:(NSUInteger) cameraId
                              Stream:(NSUInteger) streamId;


- (NSInteger)setMicCount:(NSUInteger) micCount;
- (NSInteger)setAudioProperty:(const RvsMicInfo*)audioInfo
                       ForMic:(NSUInteger)micId;



- (NSUInteger)getCameraCount;
- (NSUInteger)getStreamCountForCamera:(NSUInteger) cameraId;
- (RvsCameraStreamInfo*)getCameraStreamPropertyForCamera:(NSUInteger) cameraId
                              Stream:(NSUInteger) streamId;


- (NSUInteger)getMicCount;
- (RvsMicInfo*)getAudioPropertyForMic:(NSUInteger)micId;



- (RVS_STREAM) openLiveStreamWithStreamer:(unsigned long long)streamerCID
                              CameraIndex:(NSUInteger)cameraIndex
                              StreamIndex:(NSUInteger)streamIndex
                                 MicIndex:(NSUInteger)micIndex
                               StreamType:(EN_RVS_STREAM_TYPE)streamType;

- (NSInteger)closeLiveStreamWithStream:(RVS_STREAM)hStream;


- (NSInteger)acceptStreamWithStream:(RVS_STREAM)hStream;
- (NSInteger)rejectStreamWithStream:(RVS_STREAM)hStream;
- (NSInteger)closeLiveStreamWithStream:(RVS_STREAM)hStream;

- (NSInteger)pauseLiveStreamWithStream:(RVS_STREAM)hStream;
- (NSInteger)resumeLiveStreamWithStream:(RVS_STREAM)hStream;

- (RvsStreamAVDesc*)getStreamDescWithStream:(RVS_STREAM)hStream;


- (unsigned long long)getStreamPeerCIDWithStream:(RVS_STREAM)hStream;

- (NSInteger)startRecordStreamWithStream:(RVS_STREAM)hStream
                           PathFileName:(NSString*)pathFileName;

- (NSInteger)stopRecordStreamWithStream:(RVS_STREAM)hStream;


- (unsigned long long)requestJpegWithStreamer:(unsigned long long)streamerCID
                         CameraIndex:(NSUInteger)cameraIndex
                            JpegType:(EN_RVS_MEDIA_JPEG_TYPE) jpegType;


- (NSInteger)readVideoDataWithStream:(RVS_STREAM)hStream
                       streamBuffer:(unsigned char**)streamBuffer
                             BufLen:(NSUInteger*)bufLen
                          TimeStamp:(NSUInteger*)timeStamp;


- (NSInteger)readYUV420DataWithStream:(RVS_STREAM)hStream
                             YUVData:(unsigned char**)pData
                           TimeStamp:(NSUInteger*)timeStamp;

- (NSInteger)readAudioDataWithStream:(RVS_STREAM)hStream
                       streamBuffer:(unsigned char**)streamBuffer
                             BufLen:(NSUInteger*)bufLen
                          TimeStamp:(NSUInteger*)timeStamp;


//发送视频流
- (NSInteger)writeVideoData:(unsigned char*) videoData
                 DataLength:(NSUInteger) dataLength
                  TimeStamp:(NSUInteger) timeStamp
                   IsIFrame:(BOOL)isIFrame
                  ForCamera:(NSUInteger) cameraId
                     Stream:(NSUInteger) streamId;

//发送音频流
- (NSInteger)writeAudioData:(unsigned char*)audioData
                 DataLength:(NSUInteger) dataLength
                  TimeStamp:(NSUInteger) timeStamp
                     ForMic:(NSUInteger)micId;




@end
