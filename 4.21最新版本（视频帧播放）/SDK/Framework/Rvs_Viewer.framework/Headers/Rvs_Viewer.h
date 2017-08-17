/**
    Rvs_Viewer.h
 
    ICHANO SDK为网络摄像机或智能设备方案商及生产商提供了基于互联网的多媒体连接服务，使设备方案商通过简明的API调用，
    就能将所采集到的音、视频等多媒体信息通过互联网传输到用户的手机、电脑上，满足用户的监控、直播、对讲等相关的各种需求.
    ICHANO SDK观看端中有Rvs_Viewer、Rvs_Viewer_StreamerInfo、Rvs_Viewer_Media、Rvs_Viewer_Cmd这4个主要的类，
    其它类和接口均是围绕和辅助这4个类进行定义和使用,该文件是对Rvs_viewer类的主要描述
 
    author Lvyi
    version 1.0.0 2016/6/16 Creation
 */
#import <Foundation/Foundation.h>
#import <Rvs_Viewer/RVS_Viewer_StreamerInfo.h>
#import <Rvs_Viewer/RVS_Viewer_Media.h>
#import <Rvs_Viewer/RVS_Viewer_Cmd.h>


/**
 观看端语言码定义
 
 E_RVS_VIEWER_LANGUAGE_zh_CN  简体中文
 E_RVS_VIEWER_LANGUAGE_en     英语
 E_RVS_VIEWER_LANGUAGE_zh_TW  繁体中文
 E_RVS_VIEWER_LANGUAGE_fr     法语
 E_RVS_VIEWER_LANGUAGE_ja     日语
 E_RVS_VIEWER_LANGUAGE_es     西班牙语
 E_RVS_VIEWER_LANGUAGE_ko     韩语
 E_RVS_VIEWER_LANGUAGE_it     意大利语
 E_RVS_VIEWER_LANGUAGE_pt     葡萄牙语
 E_RVS_VIEWER_LANGUAGE_ru     俄语
 E_RVS_VIEWER_LANGUAGE_th     泰语
 E_RVS_VIEWER_LANGUAGE_de     德语
 E_RVS_VIEWER_LANGUAGE_ar     阿拉伯语
 E_RVS_VIEWER_LANGUAGE_el     希腊语
 */
typedef enum enum_RVS_VIEWER_LANGUAGE{
    
    E_RVS_VIEWER_LANGUAGE_zh_CN         = 1,
    E_RVS_VIEWER_LANGUAGE_en            = 2,
    E_RVS_VIEWER_LANGUAGE_zh_TW         = 3,
    E_RVS_VIEWER_LANGUAGE_fr            = 4,
    E_RVS_VIEWER_LANGUAGE_ja            = 5,
    E_RVS_VIEWER_LANGUAGE_es            = 6,
    E_RVS_VIEWER_LANGUAGE_ko            = 7,
    E_RVS_VIEWER_LANGUAGE_it            = 8,
    E_RVS_VIEWER_LANGUAGE_pt            = 9,
    E_RVS_VIEWER_LANGUAGE_ru            = 10,
    E_RVS_VIEWER_LANGUAGE_th            = 11,
    E_RVS_VIEWER_LANGUAGE_de            = 12,
    E_RVS_VIEWER_LANGUAGE_ar            = 13,
    E_RVS_VIEWER_LANGUAGE_el            = 14
    
}EN_RVS_VIEWER_LANGUAGE;


/**
    观看端登录服务器时的状态码定义
    E_RVS_VIEWER_LOGIN_STATE_IDLE       挂起状态
    E_RVS_VIEWER_LOGIN_STATE_CONNING    正在连接中
    E_RVS_VIEWER_LOGIN_STATE_CONNED     已经连接
    E_RVS_VIEWER_LOGIN_STATE_DISCONNED  与服务器断连
 */
typedef enum enum_RVS_VIEWER_LOGIN_STATE
{
    E_RVS_VIEWER_LOGIN_STATE_IDLE      = 0,
    E_RVS_VIEWER_LOGIN_STATE_CONNING   = 1,
    E_RVS_VIEWER_LOGIN_STATE_CONNED    = 2,
    E_RVS_VIEWER_LOGIN_STATE_DISCONNED = 3
}EN_RVS_VIEWER_LOGIN_STATE;


typedef enum enum_RVS_VIEWER_LOGIN_ERR
{
    E_RVS_VIEWER_LOGIN_ERR_NOERR      = 0,
    E_RVS_VIEWER_LOGIN_ERR_SERVICEGETERR,
    E_RVS_VIEWER_LOGIN_ERR_AUTH_ERRCOMPANYINFO,
    E_RVS_VIEWER_LOGIN_ERR_AUTH_ERRAPPID,
    E_RVS_VIEWER_LOGIN_ERR_AUTH_ERRLICENSE,
    E_RVS_VIEWER_LOGIN_ERR_AUTH_FULLLICENSE,
    E_RVS_VIEWER_LOGIN_ERR_AUTH_TIMEOUT,
    E_RVS_VIEWER_LOGIN_ERR_CONNECT_ERR,
    E_RVS_VIEWER_LOGIN_ERR_REGISTER_ERR,
    E_RVS_VIEWER_LOGIN_ERR_ALLOCATE_ERR,
    E_RVS_VIEWER_LOGIN_ERR_GETSYSCONFIG_ERR,
    E_RVS_VIEWER_LOGIN_ERR_UPLOADINFO_ERR,
    E_RVS_VIEWER_LOGIN_ERR_CONNECT_INTERUPT,
    E_RVS_VIEWER_LOGIN_ERR_DEFAULT
}EN_RVS_VIEWER_LOGIN_ERR;

typedef enum enum_RVS_VIEWER_LOGIN_PROGRESS{
    
    E_RVS_VIEWER_LOGIN_PROGRESS_INIT     = 0,
    E_RVS_VIEWER_LOGIN_PROGRESS_SERVICEGET,
    E_RVS_VIEWER_LOGIN_PROGRESS_SERVICEGETTED,
    E_RVS_VIEWER_LOGIN_PROGRESS_AUTHING,
    E_RVS_VIEWER_LOGIN_PROGRESS_AUTHED,
    E_RVS_VIEWER_LOGIN_PROGRESS_CONNECTING,
    E_RVS_VIEWER_LOGIN_PROGRESS_CONNECTED,
    E_RVS_VIEWER_LOGIN_PROGRESS_REGISTING,
    E_RVS_VIEWER_LOGIN_PROGRESS_REGISTED,
    E_RVS_VIEWER_LOGIN_PROGRESS_ALLOCATING,
    E_RVS_VIEWER_LOGIN_PROGRESS_ALLOCATED,
    E_RVS_VIEWER_LOGIN_PROGRESS_GETSYSCONFIG,
    E_RVS_VIEWER_LOGIN_PROGRESS_UPLOADINFO,
    E_RVS_VIEWER_LOGIN_PROGRESS_STARTSERVICES,
    E_RVS_VIEWER_LOGIN_PROGRESS_STARTED
    
}EN_RVS_VIEWER_LOGIN_PROGRESS;


typedef enum enum_RVS_STREAMER_CONF_STATE{
    
    E_RVS_STREAMER_CONF_STATE_INIT     = 0,
    E_RVS_STREAMER_CONF_STATE_INFOGETING,
    E_RVS_STREAMER_CONF_STATE_INFOGETSUCCESS,
    E_RVS_STREAMER_CONF_STATE_INFOGETERR_NOTEXIST,
    E_RVS_STREAMER_CONF_STATE_INFOGETERR_APPNOTSUPPORT,
    E_RVS_STREAMER_CONF_STATE_INFOGETERR_VERSIONNEEDUPDATE,
    E_RVS_STREAMER_CONF_STATE_INFOGETERR_VERSIONNOTSUPPORT,
    E_RVS_STREAMER_CONF_STATE_INFOGETERR
    
}EN_RVS_STREAMER_CONF_STATE;


typedef enum enum_RVS_STREAMER_PRESENCE_STATE
{
    E_RVS_STREAMER_PRESENCE_STATE_INIT = 0,
    E_RVS_STREAMER_PRESENCE_STATE_ONLINE,
    E_RVS_STREAMER_PRESENCE_STATE_OFFLINE,
    E_RVS_STREAMER_PRESENCE_STATE_ERRUSERPWD
    
}EN_RVS_STREAMER_PRESENCE_STATE;


typedef enum enum_RVS_STREAMER_CONN_STATE
{
    E_RVS_STREAMER_CONN_STATE_INIT = 0,
    E_RVS_STREAMER_CONN_STATE_CONNECTING,
    E_RVS_STREAMER_CONN_STATE_CONNECTED,
    E_RVS_STREAMER_CONN_STATE_CONNECT_ERROR
    
}EN_RVS_STREAMER_CONN_STATE;


typedef enum enum_RVS_LOG_LEVEL
{
    EN_RVS_LOG_LEVEL_DEBUG = 0,
    EN_RVS_LOG_LEVEL_INFO,
    EN_RVS_LOG_LEVEL_WARNNING,
    EN_RVS_LOG_LEVEL_ERROR
    
}EN_RVS_LOG_LEVEL;



/**
 * Rvs_Viewer_Delegate回调接口用于反馈当前Rvs_Viewer的登录过程和结果
 */
@protocol Rvs_Viewer_Delegate <NSObject>


/**
 *  观看端sdk登录过程中发生状态变化、错误、登录进度通知
 *
 *  @param loginState   观看端登录状态
 *  @param progressRate 观看端登录过程状态
 *  @param errCode      观看端登录过程中的错误码
 */
- (void)onLoginResultWithLoginState:(EN_RVS_VIEWER_LOGIN_STATE)loginState
                       ProgressRate:(EN_RVS_VIEWER_LOGIN_PROGRESS)progressRate
                            errCode:(EN_RVS_VIEWER_LOGIN_ERR)errCode;

/**
 *  观看端cid发生变化时通知应用
 *
 *  @param localCID 观看端CID
 */
- (void)onUpdateCID:(unsigned long long)localCID;


/**
 * 用于CID持久化的标示符通知
 *
 *  @param symbol 用于CID持久化的标示符号
 */
- (void)onUpdateSymbol:(NSString*)symbol;


/**
 *  观看端与采集端的连接状态变化通知
 *
 *  @param streamerCID       采集端CID
 *  @param streamerConnState 观看端与采集端的连接状态
 */
- (void)onStreamer:(unsigned long long)streamerCID
             ConnState:(EN_RVS_STREAMER_CONN_STATE)streamerConnState;

/**
 *  与观看端绑定的采集端的配置获取状态变化通知
 *
 *  @param streamerCID       采集端CID
 *  @param streamerConfState 与观看端绑定的采集端的配置获取状态
 */
- (void)onStreamer:(unsigned long long)streamerCID
         ConfState:(EN_RVS_STREAMER_CONF_STATE)streamerConfState;

/**
 *  采集端的在线状态通知
 *
 *  @param streamerCID           采集端CID
 *  @param streamerPresenceState 采集端的在线状态
 */
- (void)onStreamer:(unsigned long long)streamerCID
         PresenceState:(EN_RVS_STREAMER_PRESENCE_STATE)streamerPresenceState;


/**
 *  局域网内搜索采集端的结果反馈
 *
 *  @param streamerCID  搜索到的采集端CID
 *  @param streamerName 搜索到的采集端名称
 *  @param osType       搜索到的采集端系统类型
 */
- (void)onLanSearchStreamer:(unsigned long long)streamerCID
               StreamerName:(NSString*)streamerName
                     OSType:(NSUInteger)osType;

@end



/**
 *  Rvs_Viewer类是ICHANO SDK观看端的总体处理的类，负责登录鉴权、处理消息回调通知上层应用。
    该类是单例，调用 [Rvs_Viewer defaultViewer]来获得该类的实例。
    此外，Rvs_Viewer_StreamerInfo、Rvs_Viewer_Media、Rvs_Viewer_Cmd三个类都是Rvs_Viewer的成员。
    Rvs_Viewer_StreamerInfo用于对关联的采集端进行管理（包括进行信息查询和参数设置等）；
    Rvs_Viewer_Media用于对音、视频码流相关的处理进行设置；
    Rvs_Viewer_Cmd用于观看端与采集端之间的信令交互处理
 */
@interface Rvs_Viewer : NSObject

/**
*  只读属性，获取观看端CID号
*/
@property (nonatomic, assign, readonly) unsigned long long CID;

/**
 *  只读属性，获取Rvs_Viewer_StreamerInfo对象
 */
@property (nonatomic, strong, readonly) Rvs_Viewer_StreamerInfo* viewerStreamerInfo;

/**
 *  只读属性，获取Rvs_Viewer_Media对象
 */
@property (nonatomic, strong, readonly) Rvs_Viewer_Media* viewerMedia;

/**
 *  只读属性，获取Rvs_Viewer_Cmd对象
 */
@property (nonatomic, strong, readonly) Rvs_Viewer_Cmd* viewerCmd;


/**
 *  设置回调接口Rvs_Viewer_Delegate，此回调接口用于反馈当前Rvs_Viewer的登录过程和结果
 */
@property (nonatomic, assign) id<Rvs_Viewer_Delegate> delegate;

/**
 *  获取Rvs_Viewer单例
 *
 *  @return 返回Rvs_Viewer单例对象
 */
+ (Rvs_Viewer*)defaultViewer;

/**
 *  销毁Rvs_Viewer单例，停止Rvs SDK工作，释放资源
 */
+ (void)destroy;

/**
 *  获取 Rvs SDK 版本号
 *
 *  @return Rvs SDK 版本号
 */
- (NSString*)getRvsVersion;

/**
 *  初始化Rvs SDK 工作环境
 *
 *  @param workPath   Rvs SDK 工作配置路径
 *  @param cachePath  Rvs SDK 录像缓存路径
 *  @param appVersion app版本号
 *
 *  @return 0 代表成功，非0代表失败
 */
- (NSInteger)initViewerWithWorkPath:(NSString*)workPath
                          CachePath:(NSString*)cachePath
                         AppVersion:(NSString*)appVersion;

/**
 *  设置授权信息
 *
 *  @param companyID  公司ID
 *  @param companyKey 公司key
 *  @param appID      应用ID
 *  @param license    license号
 *  @param symbol     持久化cid标示符号
 *
 *  @return 0 代表成功，非0代表失败
 */
- (NSInteger)setLoginInfoWithCompanyID:(NSString*)companyID
                            CompanyKey:(unsigned long long)companyKey
                                 AppID:(NSString*)appID
                               License:(NSString*)license
                                Symbol:(NSString*)symbol;

/**
 *  设置观看端语言版本
 *
 *  @param language 语言码
 *
 *  @return 0 代表成功，非0代表失败
 */
- (NSInteger)setLanguage:(EN_RVS_VIEWER_LANGUAGE)language;

/**
 *  设置观看端推送Token，用于收push用
 *
 *  @param token token字符串
 *
 *  @return 0 代表成功，非0代表失败
 */
- (NSInteger)setPushToken:(NSString*)token;

/**
 *  观看端登陆服务器
 *
 *  @return 0 代表成功，非0代表失败
 */
- (NSInteger)login;

/**
 *  观看端从服务器注销
 *
 *  @return 0 代表成功，非0代表失败
 */
- (NSInteger)logout;

/**
 *  连接采集端
 *
 *  @param streamerCID 采集端CID
 *  @param userName    采集端访问用户名
 *  @param password    采集端访问密码
 *
 *  @return 0 代表成功，非0代表失败
 */
- (NSInteger)connectStreamer:(unsigned long long)streamerCID
               UserName:(NSString*)userName
               Password:(NSString*)password;

/**
 *  与采集端断连
 *
 *  @param streamerCID 采集端CID
 *
 *  @return 0 代表成功，非0代表失败
 */
- (NSInteger)disconnectStreamer:(unsigned long long)streamerCID;

/**
 *  局域网内搜索采集端
 *
 *  @return 0 代表成功，非0代表失败
 */
- (NSInteger)LANSearchStreamer;

/**
 *  检测观看端和采集端是否在同一个局域网内
 *
 *  @param streamerCID 采集端CID
 *
 *  @return 0 代表成功，非0代表失败
 */
- (BOOL)checkSameLanNetwork:(unsigned long long)streamerCID;


/**
 *  设置调试模式
 *
 *  @param enable 是否打开调试模式，如果打开会在控制台输出log
 *
 *  @return NA
 */
- (void)setLogEnabled:(BOOL)enable;


/**
 *  打印log
 *
 *  @param logLevel : 日志级别
 *           format : 日志格式化字符串
 *  @return NA
 */
- (void)logWithLogLevel:(EN_RVS_LOG_LEVEL)logLevel LogFormat:(NSString *)format, ...;


- (void)reconnectServer;

- (NSUInteger)encHttpBuffWithSrcBuf:(unsigned char*)srcBuf SrcBufLen:(NSUInteger)srcBufLen DstBuf:(unsigned char**)dstBuf DstBufLen:(NSUInteger*) dstBufLen;


- (void)decHttpBuffWithBuf:(unsigned char*)buf BufLen:(NSUInteger)bufLen;

- (void)freeEncOutHttpBuff:(unsigned char*)buf;

@end
