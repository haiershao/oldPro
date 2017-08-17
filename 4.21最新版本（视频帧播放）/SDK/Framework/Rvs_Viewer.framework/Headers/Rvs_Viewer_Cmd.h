/**
    Rvs_Viewer_Cmd.h
    ICHANO SDK为网络摄像机或智能设备方案商及生产商提供了基于互联网的多媒体连接服务，使设备方案商通过简明的API调用，
    就能将所采集到的音、视频等多媒体信息通过互联网传输到用户的手机、电脑上，满足用户的监控、直播、对讲等相关的各种需求.
    ICHANO SDK观看端中有Rvs_Viewer、Rvs_Viewer_StreamerInfo、Rvs_Viewer_Media、Rvs_Viewer_Cmd这4个主要的类，
    其它类和接口均是围绕和辅助这4个类进行定义和使用,该文件是对Rvs_Viewer_Cmd类的主要描述
 
 author Lvyi
 version 1.0.0 2016/6/16 Creation
 */

#import <Foundation/Foundation.h>
#import <Rvs_Viewer/Rvs_Viewer_Sys.h>

typedef enum enum_Rvs_Viewer_RotateType{
    EN_RVS_VIEWER_ROTATE_TYPE_VERTICAL   = 0x01,
    EN_RVS_VIEWER_ROTATE_TYPE_HORIZONTAL = 0x02
}EN_RVS_VIEWER_ROTATE_TYPE;

typedef enum enum_Rvs_VIEWER_PTZMoveCtrl{
    EN_RVS_VIEWER_PTZMOVE_CTRL_PTZ  = 0,
    EN_RVS_VIEWER_PTZMOVE_CTRL_MOVE = 1
}EN_RVS_VIEWER_PTZMOVE_CTRL;

typedef enum enum_RVS_VIEWER_CMD_ERROR_CODE{
    EN_RVS_VIEWER_CMD_ERROR_CODE_NOERR = 0,
    EN_RVS_VIEWER_CMD_ERROR_CODE_NOTSUPPORT,
    EN_RVS_VIEWER_CMD_ERROR_CODE_PROCESSERR,
    EN_RVS_VIEWER_CMD_ERROR_CODE_TIMEOUT,
    EN_RVS_VIEWER_CMD_ERROR_CODE_INVALIDPARAM,
    EN_RVS_VIEWER_CMD_ERROR_CODE_BREAKERR
}EN_RVS_VIEWER_CMD_ERROR_CODE;

/**
 *  cmd操作通知回调
 */
@protocol Rvs_Viewer_Cmd_Delegate <NSObject>

/**
 *  接收采集端发到观看端的自定义数据
 *
 *  @param dataBuffer 自定义数据缓冲
 *  @param bufferLen  自定义数据缓冲长度
 *  @param peerCID    采集端CID
 */
- (void)onRecvCustomData:(unsigned char*) dataBuffer
                 DataLen:(NSUInteger)bufferLen
             FromPeerCID:(unsigned long long)peerCID;


/**
 *  操作结果反馈
 *
 *  @param requestID 请求ID
 *  @param errorCode 错误码
 */
- (void)onCmdRequestStatusWithRequestID:(unsigned long long)requestID
                              ErrorCode:(NSInteger)errorCode;

/**
 *  时区设置结果反馈
 *
 *  @param requestID 请求ID
 *  @param errorCode 错误码
 *  @param time      时间
 *  @param timeZone  时区
 *  @param syncFlag  是否同步时间
 */
- (void)onCmdTimeGetResultWithRequestID:(unsigned long long)requestID
                              ErrorCode:(NSInteger)errorCode
                                   Time:(NSString*)time
                               TimeZone:(NSInteger)timeZone
                               SyncFlag:(BOOL)syncFlag;

/**
 *  SD卡容量及余量查询结果反馈
 *
 *  @param requestID  请求ID
 *  @param errorCode  错误码
 *  @param totalSize  SD卡总容量
 *  @param remainSize SD卡剩余容量
 */
- (void)onCmdSDCardInfoGetResultWithRequestID:(unsigned long long)requestID
                                    ErrorCode:(NSInteger)errorCode
                                    TotalSize:(unsigned long long)totalSize
                                   RemainSize:(unsigned long long)remainSize;

/**
 *  采集端WIFI连接状态设置结果反馈
 *
 *  @param requestID 请求ID
 *  @param errorCode 错误码
 *  @param wifiState wifi状态
 */
- (void)onCmdWifiStateGetResultWithRequestID:(unsigned long long)requestID
                                   ErrorCode:(NSInteger)errorCode
                                   WifiState:(NSUInteger)wifiState;


@end


/**
 *  Rvs_Viewer_Cmd类是在采集端与观看端之间进行信令交互处理的类，该类是单例，应调用[Rvs_Viewer defaultViewer].viewerCmd
    来获得该类的实例。用于发送实时命令到采集端，控制采集端设备的编码质量、 闪关灯开关、屏幕旋转、PTZ动作等， 查询采集端设备的sd
    卡、时间等信息
 */
@interface Rvs_Viewer_Cmd : NSObject

/**
 *  设置cmd操作通知回调
 */
@property (nonatomic, assign) id<Rvs_Viewer_Cmd_Delegate> delegate;

/**
 *  请求采集端时间信息
 *
 *  @param streamerCID 采集端CID
 *
 *  @return 请求ID
 */
- (unsigned long long)requestStreamerTimeZone:(unsigned long long)streamerCID;

/**
 *  请求采集端SD卡信息
 *
 *  @param streamerCID 采集端CID
 *
 *  @return 请求ID
 */
- (unsigned long long)requestStreamerSDCardInfo:(unsigned long long)streamerCID;

/**
 *  请求采集端wifi状态信息
 *
 *  @param streamerCID 采集端CID
 *
 *  @return 请求ID
 */
- (unsigned long long)requestStreamerWifiStatus:(unsigned long long)streamerCID;

/**
 *  修改采集端登录信息
 *
 *  @param streamerCID 采集端CID
 *  @param newUser     新用户名
 *  @param newPwd      新密码
 *
 *  @return 请求ID
 */
- (unsigned long long)changeStreamerLoginInfo:(unsigned long long)streamerCID
                            UserName:(NSString*)newUser
                            Password:(NSString*)newPwd;

/**
 *  调整采集端视频质量
 *
 *  @param streamerCID    采集端CID
 *  @param cameraIndex    镜头ID
 *  @param streamIndex    流ID
 *  @param bitrate        比特率
 *  @param framerate      帧率
 *  @param iFrameInterval I帧间隔
 *  @param quality         图像质量
 *
 *  @return 请求ID
 */
- (unsigned long long)changeStreamerEncoderQuality:(unsigned long long)streamerCID
                         CameraIndex:(NSUInteger)cameraIndex
                          SreamIndex:(NSUInteger)streamIndex
                             Bitrate:(NSUInteger)bitrate
                           FrameRate:(NSUInteger)framerate
                      IFrameInterval:(NSUInteger)iFrameInterval
                              Quality:(NSUInteger)quality;


/**
 *  设置采集端时间
 *
 *  @param streamerCID 采集端CID
 *  @param time        时间
 *  @param timeZone    时区
 *  @param syncFlag    是否同步
 *
 *  @return 请求ID
 */
- (unsigned long long)setStreamerTimeZone:(unsigned long long)streamerCID
                                     Time:(NSString*)time
                                 TimeZone:(NSInteger)timeZone
                                 SyncFlag:(BOOL)syncFlag;

/**
 *  格式化采集端SD卡
 *
 *  @param streamerCID 采集端CID
 *
 *  @return 请求ID
 */
- (unsigned long long)formatStreamerSDCard:(unsigned long long)streamerCID;

/**
 *  设置wifi状态
 *
 *  @param streamerCID 采集端CID
 *  @param ssid        ssid信息
 *  @param encType     加密方式
 *  @param password    密码
 *
 *  @return 请求ID
 */
- (unsigned long long)setStreamerWifi:(unsigned long long)streamerCID
                                 SSID:(NSString*)ssid
                              EncType:(NSUInteger)encType
                             Password:(NSString*)password;

/**
 *  请求关键帧
 *
 *  @param streamerCID 采集端CID
 *  @param cameraIndex 镜头ID
 *  @param streamIndex 流ID
 *
 *  @return 请求ID
 */
- (unsigned long long)forceIFrameWithStreamer:(unsigned long long)streamerCID
                                  CameraIndex:(NSUInteger)cameraIndex
                                   SreamIndex:(NSUInteger)streamIndex;

/**
 *  镜头翻转
 *
 *  @param streamerCID 采集端CID
 *  @param cameraIndex 镜头ID
 *  @param rotateType  旋转方式，取枚举EN_RVS_VIEWER_ROTATE_TYPE里的值
 *
 *  @return 请求ID
 */
- (unsigned long long)cameraRotateWithStreamer:(unsigned long long)streamerCID
                                   CameraIndex:(NSUInteger)cameraIndex
                                    RotateType:(NSUInteger)rotateType;

/**
 *  切换前后摄像头
 *
 *  @param streamerCID 采集端CID
 *  @param cameraIndex 镜头ID
 *
 *  @return 请求ID
 */
- (unsigned long long)streamSwitchWithStreamer:(unsigned long long)streamerCID
                                   CameraIndex:(NSUInteger)cameraIndex;

/**
 *  开关闪光灯
 *
 *  @param streamerCID 采集端CID
 *  @param cameraIndex 镜头ID
 *
 *  @return 请求ID
 */
- (unsigned long long)torchSwitchWithStreamer:(unsigned long long)streamerCID
                                   CameraIndex:(NSUInteger)cameraIndex;


/**
 *  色彩模式切换
 *
 *  @param streamerCID 采集端CID
 *
 *
 *  @return 请求ID
 */
- (unsigned long long)colorModeSwitchWithStreamer:(unsigned long long)streamerCID;

/**
 *  PTZ
 *
 *  @param streamerCID 采集端CID
 *  @param cameraIndex 镜头ID
 *  @param type        类型
 *  @param prDirect    P方向值
 *  @param tvDirect    V方向值
 *  @param zfDirect    Z方向值
 *
 *  @return  请求ID
 */
- (unsigned long long)PTZMoveCtrlWithStreamer:(unsigned long long)streamerCID
                                   CameraIndex:(NSUInteger)cameraIndex
                                         Type:(EN_RVS_VIEWER_PTZMOVE_CTRL)type
                                     PRDirect:(NSInteger)prDirect
                                     TVDirect:(NSInteger)tvDirect
                                     ZFDirect:(NSInteger)zfDirect;

/**
 *  发送自定义指令
 *
 *  @param streamerCID 集端CID
 *  @param dataBuffer  自定义数据
 *  @param BufferLen   自定义数据长度
 *
 *  @return 请求ID
 */
- (NSInteger)sendCustomDataWithStreamer:(unsigned long long)streamerCID
                             CustomData:(unsigned char*) dataBuffer
                                DataLen:(NSUInteger)BufferLen;

@end
