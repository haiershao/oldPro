//
//  Constants_Versions.h
//  AtHomeCam
//
//  Created by Lvyi on 8/18/14.
//  Copyright (c) 2014 ichano. All rights reserved.
//510

#ifndef AtHomeCam_Constants_Versions_h
#define AtHomeCam_Constants_Versions_h


#define APPIRATER_APP_ID            1112964552


#define kRatingAddress_IOS7 [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%d", APPIRATER_APP_ID]

#define kNavigation7Color kColor(37, 37, 44, 1)
#define kBackgroundColor  kColor(31, 31, 35, 1)
#define kTableViewCellColor  kColor(37, 37, 44, 1)
#define kHuaWoTintColor kColor(82, 207, 233, 1)

#define kLocalRecodFolder @"AtHomeCam"
#define HWCellFont [UIFont systemFontOfSize:14]

//#define identifierForVendor0 [[UIDevice currentDevice].identifierForVendor UUIDString]
//#define identifierForVendor [identifierForVendor0 stringByReplacingOccurrencesOfString:@"-" withString:@""]

#define kPrivacyPolicyCN @"iChanoPrivacyPolicyCN.htm"
#define kPrivacyPolicyEN @"iChanoPrivacyPolicyEN.html"

//#define KCompanyID @"86661dc6cab443a2bbf5cf2c003908ad"
//#define KCompanyKey 1446562712031 
//#define KAppID @"b2d026a6b86947fe86191e4b3a9a7437"

#define KCompanyID @"11122016122610292501481855028808"
#define KCompanyKey @"85c27db40402434f935d92e9d12ebfdc"
#define KAppID @"31112016122610363601481854635597"

#define kUserNickName    @"NickName"
#define kUserToken    @"token"


//端口号
//#define kPort @""
//#define kPort1 @""
//#define kPort2 @""

#define kPort @":8190"      //正式打开
#define kPort1 @":28080"     //正式打开
#define kPort2 @":38080"     //正式打开
//服务器头部
//#define kUrlHead @"http://112.124.22.129"
#define kUrlHead @"http://find.hwawo.com"
//#define kUrlHead @"http://112.124.22.101"

//用户认证
//#define SERVER_ADR @"http://112.124.22.101/user/"
//#define SERVER_ADR @"http://112.124.22.129/user/"
//#define SERVER_ADR @"http://112.124.22.101:8190/user/"
#define SERVER_ADR [NSString stringWithFormat:@"%@%@/user/",kUrlHead,kPort]
//#define SERVER_ADR [NSString stringWithFormat:@"http://user%@%@/user/",kUrlHead,kPort]

//头像接口
//#define kUserIconUrl @"http://112.124.22.129/user/postUserPhoto"
//#define kUserIconUrl @"http://112.124.22.101:8190/user/postUserPhoto"
#define kUserIconUrl [NSString stringWithFormat:@"%@%@/user/postUserPhoto",kUrlHead,kPort]
//#define kUserIconUrl [NSString stringWithFormat:@"http://user%@%@/user/postUserPhoto",kUrlHead,kPort]

//发现接口
//#define kDiscoveryPageUrl   @"http://112.124.22.101/find/index.html"
//#define kDiscoveryPageUrl   @"http://112.124.22.129/find/index.html"
//#define kDiscoveryPageUrl   @"http://112.124.22.101:28080/find/index.html"
#define kDiscoveryPageUrl [NSString stringWithFormat:@"%@%@/find/index.html?uid=%@",kUrlHead,kPort1,identifierForVendor]
//#define kDiscoveryPageUrl [NSString stringWithFormat:@"http://find%@%@/find/index.html",kUrlHead,kPort1]
//#define kDiscoveryPageUrl   @"http://192.168.0.29:8080/find/index.html"

//评论接口
//#define kCommentUrl @"http://112.124.22.129/alarm/v2/restapi/postComment"
//#define kCommentUrl @"http://112.124.22.101:28080/alarm/v2/restapi/postComment"
#define kCommentUrl [NSString stringWithFormat:@"%@%@/alarm/v2/restapi/postComment",kUrlHead,kPort1]
//#define kCommentUrl [NSString stringWithFormat:@"http://find%@%@/alarm/v2/restapi/postComment",kUrlHead,kPort1]

//分享接口
//#define kKeyShareUrl @"http://112.124.22.129/alarm/v2/restapi/postAlarmInfo"
//#define kKeyShareUrl @"http://112.124.22.101:28080/alarm/v2/restapi/postAlarmInfo"
#define kKeyShareUrl [NSString stringWithFormat:@"%@%@/alarm/v2/restapi/postAlarmInfo",kUrlHead,kPort1]
//#define kKeyShareUrl [NSString stringWithFormat:@"http://find%@%@/alarm/v2/restapi/postAlarmInfo",kUrlHead,kPort1]

//采集端绑定接口
//#define kDeviceBindUrl @"http://112.124.22.129/illegalreport/restapi/cidbinduser"
//#define kDeviceBindUrl @"http://112.124.22.101:8190/illegalreport/restapi/cidbinduser"
#define kDeviceBindUrl [NSString stringWithFormat:@"%@%@/illegalreport/restapi/cidbinduser",kUrlHead,kPort]
//#define kDeviceBindUrl [NSString stringWithFormat:@"http://report%@%@/illegalreport/restapi/cidbinduser",kUrlHead,kPort]

//采集端绑定查询接口
//#define kStreamerBindQueryUrl @"http://112.124.22.129/illegalreport/restapi/checkCidBindState"
//#define kStreamerBindQueryUrl @"http://112.124.22.101:8190/illegalreport/restapi/checkCidBindState"
#define kStreamerBindQueryUrl [NSString stringWithFormat:@"%@%@/illegalreport/restapi/checkCidBindState",kUrlHead,kPort2]
//#define kStreamerBindQueryUrl [NSString stringWithFormat:@"http://report%@%@/illegalreport/restapi/checkCidBindState",kUrlHead,kPort]

//解除绑定接口
//#define kStreamerUnbindUrl @"http://112.124.22.129/illegalreport/restapi/cidunbinduser"
//#define kStreamerUnbindUrl @"http://112.124.22.101:8190/illegalreport/restapi/cidunbinduser"
#define kStreamerUnbindUrl [NSString stringWithFormat:@"%@%@/illegalreport/restapi/cidunbinduser",kUrlHead,kPort]
//#define kStreamerUnbindUrl [NSString stringWithFormat:@"http://report%@%@/illegalreport/restapi/cidunbinduser",kUrlHead,kPort]

#define kStreamerUnbindUrlCamera [NSString stringWithFormat:@"http://112.124.22.101:38080/illegalreport/restapi/cidunbinduser"]


//积分接口
//#define kIntegralUrl @"http://112.124.22.129/illegalreport/restapi/getPointsDetails"
//#define kIntegralUrl @"http://112.124.22.101:28080/illegalreport/restapi/getPointsDetails"
#define kIntegralUrl [NSString stringWithFormat:@"%@%@/illegalreport/restapi/getPointsDetails",kUrlHead,kPort1]
//#define kIntegralUrl [NSString stringWithFormat:@"http://report%@%@/illegalreport/restapi/getPointsDetails",kUrlHead,kPort1]

//积分对换接口
//#define integralConvertUrl @"http://112.124.22.129/illegalreport/restapi/doPointExchange"
#define integralConvertUrl [NSString stringWithFormat:@"%@%@/illegalreport/restapi/doPointExchange",kUrlHead,kPort1]
//#define integralConvertUrl [NSString stringWithFormat:@"http://report%@%@/illegalreport/restapi/doPointExchange",kUrlHead,kPort1]

//商城
#define kMyStoreUrl         @"http://weidian.com/?userid=1973621&wfr=c"

//我要举报
//#define kKeyReportUrl @"http://sh.122.gov.cn/jb"
//#define kKeyReportUrl @"http://112.124.22.129/find/myreport.html"
//#define kKeyReportUrl @"http://112.124.22.101:28080/find/myreport.html"
#define kKeyReportUrl [NSString stringWithFormat:@"%@%@/find/myreport.html",kUrlHead,kPort1]
//#define kKeyReportUrl [NSString stringWithFormat:@"http://report%@%@/find/myreport.html",kUrlHead,kPort1]

#define kUmengAppkey @"56d69fc267e58e4c010010ce"
#define kShareSDKAppkey @"e35a5688d39b"
#define kWeiXinAppId @"wx4c921d5c1f895133"
#define kWeiXinAppSecret @"cd91dbd14d332db040d49707818a40a7"
#define kQQAppId @"1105140479"
#define kQQAppKey @"cqk0HsWS4JaLme1z"

#define KSinaWeiboAppKey_ssdk  @"1171099905"
#define KSinaWeiboAppSecret_ssdk @"b09b615ecda40ebf5b89710b9751300f"

#define KWeiChatAppKey_ssdk  @"wx2d97ba84c592ea5c"
#define KWeiChatAppSecret_ssdk @"09a95258c716a381911949dcc8124d43"
#define KQQAppKey_ssdk  @"1105140479"


#endif
