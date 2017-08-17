//
//  InterfaceDefine.h
//  AtHomeCam
//
//  Created by Circlely Networks on 6/12/13.
//
//

#ifndef AtHomeCam_InterfaceDefine_h
#define AtHomeCam_InterfaceDefine_h

#pragma mark - member_system interface



#define GET_US_URL(x) [CommonUtility getUserSystemUrl:x]


//添加CID
#define IMEMBER_ADDCID GET_US_URL(@"cid_add")
//DeviceID 置换 CID
#define IMEMBER_GET_CID_BY_DEVICEID GET_US_URL(@"getcidbycode")
//获取CID列表
#define IMEMBER_GET_CID_LIST GET_US_URL(@"synccid")
//用户注销
#define IMEMBER_LOGOUT GET_US_URL(@"logout")
//删除CID
#define IMEMBER_DEL_CID GET_US_URL(@"cid_del")
//更新CID
#define IMEMBER_UPDATE_CID GET_US_URL(@"updatecid")
//用户登录
#define IMEMBER_LOGIN GET_US_URL(@"login")
//注册用户
#define IMEMBER_REGISTER GET_US_URL(@"reg")
//编辑昵称
#define IMEMBER_EDIT_NICKNAME   GET_US_URL(@"updatememberexinfo")

//上传头像时的uid
#define IMEMBER_UPLOAD_UID   GET_US_URL(@"uid")

//找回密码
#define IMEMBER_RETRIEVE_PASSWORD GET_US_URL(@"retrieve")
//第三方登录
#define IMEMBER_LOGIN_THIRD   GET_US_URL(@"loginthird")



#define IMEMBER_CID_CHECK GET_US_URL(@"cid_add_check")





#pragma mark - UserSystermErrorCode

/*
 1000	成功
 1001	无效参数
 1002	失败
 1003	sessionid失效
 1004	解析异常
 1005	用户名密码错误/信息不符
 1006	该deviceid已存在／账号已存在
 1007	不需要更新
 1008	cid已存在
 1009	密码错误
 1010	该cid已删除/不存在
 1011	该用户为免费用户
 1012	授权码失效
 1013	找不到相关信息/活动已结束
 1014	注册失败
 1015	cid 已被其他用户绑定
 1016	没有权限取消绑定、独占
 1017	校验失败
 
 1020	用户名不存在
 1021	cid info未上传
 
 1027	需要更新cid list
 1030	已签到
 
 
 1040   cid存在于其他账号中
 
 1041   cid被其他人绑定或者不存在
 1042   cid已被其他人绑定

 */

#define kSuccessCode                        @"1000"
#define kError_Invalid_Parameter            @"1001"
#define kError_Request_Fail                 @"1002"
#define kError_Session_Invalid              @"1003"
#define kError_Parse_Fail                   @"1004"
#define kError_Invalid_AccountorPwd         @"1005"
#define kError_Account_Exist                @"1006"
#define kError_Already_Lastest              @"1007"
#define kError_CID_Server_Exist             @"1008"
#define kError_Pwd_Wrong                    @"1009"
#define kError_CID_Server_Not_Exist         @"1010"
#define kError_Account_Is_Free              @"1011"
#define kError_AuthCode_Invalid             @"1012"
#define kError_Activity_End                 @"1013"
#define kError_Register_Fail                @"1014"
//#define kError_Cid_Is_BindedByOtherAccount  @"1015"
#define kError_No_Auth_Cancel_Bind          @"1016"
#define kError_Verification_Fail            @"1017"

#define kError_UserName_Not_Exist           @"1020"
#define kError_CidInfo_Not_Uploaded         @"1021"

#define kError_CID_Info_Updated             @"1027"
#define KError_Account_Had_SignInToday      @"1030"
///


#define KError_CID_Is_InOtherAccount           @"1040"
#define KError_CID_Is_Not_Exist @"1041"
#define KError_CID_Is_BindedByOtherAccount     @"1042"


#define KError_CID_Number_Reach_Upper_Limit @"1050"


#define KError_Point_Not_Enough             @"1101"


//自定义的错误
#define  kError_CID_Local_Exist             @"1600"
#define kError_Client_CID_IsNotExist        @"9998"
#define  kError_Request_Timeout             @"9999"


#pragma mark - AVS interface
//AVS Command


#define CAM_REQUEST_IFRAME        @"requestiframe"


#define CAM_SET_DEVICE_NAME       @"setdevicename"


#define CAM_GET_SDCARD_INFO       @"getsdcardinfo"
#define CAM_FORMAT_SDCARD         @"formatsdcard"
#define CAM_RESET_LOGIN_INFO      @"setnewlogininfo"
#define CAM_SET_CAMERA_NAME       @"setcameraname"
#define CAM_GET_RECORD_FILE_LIST  @"getrecordvideolist"
#define CAM_GET_RECORD_DAY_LIST  @"getrecorddaylist"
#define CAM_GET_TIME              @"gettime"

#define CAM_PTZ_CONTROL           @"ptzcontrol"
#define CAM_SWITCH_FRONT_REAR     @"switchfrontrearcamera"
#define CAM_DELETE_RECORDED_VIDEO @"deletemediafile"



#define CAM_AUTO_DEL_RECORDED_VIDEO @"setautodelete"
#define CAM_ALARM_SETTINGS        @"setalarmsettings"
#define CAM_MOTION_SETTINGS       @"setmotiondetection"
#define CAM_SCHEDULED_RECORD_SETTINGS @"setschedulerecording"
#define CAM_SEND_TEST_EMAIL       @"sendtestemail"

#define CAM_SET_DETECT_FLAG     @"setdetectflag"                 //新增，这个在旧的协议里不需要支持

#define CAM_GET_AVS_SETTINGS    @"getAvsDataReq"                 //获取采集端基本数据
#define CAM_SET_AVS_LOOPVIDEO    @"setAvsLoopVideo"              //循环录制
#define CAM_SET_AVS_SOUNDRECORD    @"setAvsSoundRecord"          //声音录制
#define CAM_SET_AVS_INDICATEORLIGHT    @"setAvsIndicateorLight"  //记录仪指示灯
#define CAM_SET_AVS_WARNINGTONE    @"setAvsWarningTone"          //
#define CAM_SET_AVS_TOUCHSENSITIVITY    @"setAvsTouchSensitivity"//碰撞灵敏度
#define CAM_SET_AVS_PARKING    @"setAvsParking"                  //停车安防
#define CAM_SET_AVS_QUALITY    @"setAvsQuality"                  //视频质量
#define CAM_CHANGE_FILE_TYPE   @"changeAvsFileType"              //

#define CAM_SET_DEFAULT_REQ   @"setToDefaultReq"                 //恢复出厂设置
#define CAM_SET_UPDATE_HARD_DRIVERS_REQ   @"setupdateHardDriversReq" //固件版本升级
#define CAM_GET_SPACE_REQ   @"getSpaceReq"
#define kStatus  @"status"

#define CAM_GET_USER_LOCATION_REQ @"getLocationReq"               //获取用户位置

#define HTTP_GET  @"GET"
#define HTTP_POST @"POST"
#define HTTP_PUT  @"PUT"
#define HTTP_DELETE @"DELETE"


typedef void (^NetworkBasicBlock)(void);




#endif
