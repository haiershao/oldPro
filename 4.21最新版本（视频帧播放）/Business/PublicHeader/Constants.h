/*

File: Constants.h
Abstract: Common constants across source files (screen coordinate consts, etc.)

Version: 1.7

Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple Inc.
("Apple") in consideration of your agreement to the following terms, and your
use, installation, modification or redistribution of this Apple software
constitutes acceptance of these terms.  If you do not agree with these terms,
please do not use, install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and subject
to these terms, Apple grants you a personal, non-exclusive license, under
Apple's copyrights in this original Apple software (the "Apple Software"), to
use, reproduce, modify and redistribute the Apple Software, with or without
modifications, in source and/or binary forms; provided that if you redistribute
the Apple Software in its entirety and without modifications, you must retain
this notice and the following text and disclaimers in all such redistributions
of the Apple Software.
Neither the name, trademarks, service marks or logos of Apple Inc. may be used
to endorse or promote products derived from the Apple Software without specific
prior written permission from Apple.  Except as expressly stated in this notice,
no other rights or licenses, express or implied, are granted by Apple herein,
including but not limited to any patent rights that may be infringed by your
derivative works or by other works in which the Apple Software may be
incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO
WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED
WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN
COMBINATION WITH YOUR PRODUCTS.

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR
DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF
CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF
APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

Copyright (C) 2008 Apple Inc. All Rights Reserved.

*/

// these are the various screen placement constants used across all the UIViewControllers
 
//#import "UIImageHelper.h"

#import <Rvs_Viewer/Rvs_Viewer_API.h>
#include "Constants_Log.h"

#define KUIControllerIsSupportOrientionY @"IsSupportOrientionYes"
#define KUIControllerIsSupportOrientionN @"IsSupportOrientionNo"


#define kiOSVersionIs5 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0 ? YES : NO)
#define kiOSVersionIs6 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0 ? YES : NO)
#define kiOS7 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0 ? YES : NO)
#define kiOS8 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 ? YES : NO)
#define kReSize(pad,phone) (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad ? pad : phone)
#define kiPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
#define kiPhone4 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)
#define kIsPad (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad ? YES : NO)
#define kPadOrPhone(pad, phone) (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad ? pad : phone)

/*
 CG constants
 */
#define CG_FONT(x) [UIFont systemFontOfSize:x]
#define CG_BOLD_FONT(x) [UIFont boldSystemFontOfSize:x]
#define kColor(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define kUIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0  green:((float)((rgbValue & 0xFF00) >> 8))/255.0  blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define kFooterColor kColor(174.0, 167.0, 159.0, 1.0)

#define kTableViewTextLabelColor kUIColorFromRGB(0x7d7f7c)
#define kTableViewSeparatorColor kColor(231, 230, 233, 1)



#pragma mark -
#pragma mark typedef enum





typedef enum{
    
    WindowsAVS      = 0x1,//0
    iOSAVS          = 0x2,
    MacAVS          = 0x3,
    AndroidPhoneAVS = 0x4,
    IPCameraAVS     = 0x5,
    WebcamAVS       = 0x6,
    AndroidTVAVS    = 0x7,

    DefaultAVS      = 0xFF
} AVSType;



#pragma mark -
#pragma mark other macro

#define kAlphaNum   @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789./:"
#define kAlphaNumUserName   @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789.-_"
#define kAlphaNumPsw   @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"

#define kLeftButtonEdgeInsets UIEdgeInsetsMake(0.0, 7.0, 2.0, 0.0)


#if !defined (ICanSee)
#define kButtonShadowOffset CGSizeMake(0.0, 1.0)
#else
#define kButtonShadowOffset CGSizeMake(0.0, -1.0)
#endif

#define kButtonShadowColor kColor(86, 59, 16, 1)
#define kHeaderFont kPadOrPhone(CG_FONT(20.0), CG_FONT(17.0))
#define kFooterFont kPadOrPhone(CG_FONT(16.0), CG_FONT(12.0))
#define kTernaryOperator(boollean,value0,value1) boollean?value0:value1

#pragma mark -
#pragma mark notification type

#define KLoginOutMsg @"LoginOut"
#define KLoginSucceed @"LoginSucceed"
#define K_APP_SESSION_STATE_UPDATE @"App_Session_State_Update"
#define K_APP_STREAM_STATE_UPDATE @"App_Stream_State_Update"
#define kUpdateCameraList @"updateCameraList"

#define KUSERNAME_LOGOUT     @"LastLoginUsername"

//消息传输的内容定义
#define K_APP_PARAM_CID @"App_Param_CID"
#define K_APP_PARAM_SESSION_STATE @"App_Param_Session_State"


#define K_APP_PARAM_STREAM_HANDLE @"App_Param_Stream_Handle"
#define K_APP_PARAM_STREAM_STATE @"App_Param_Stream_State"
#define K_APP_PARAM_STREAM_FLAG @"App_Param_Stream_Flag"


#define clippingTime 0.5

#define K_MAX_INPUT_LIMITTED_NUM_AVSNMAE  16
#define K_MAX_INPUT_LIMITTED_NUM_USERNMAE 32
#define K_MAX_INPUT_LIMITTED_NUM_PASSWORD 32



#define kFILENAME @"fileName"
#define kFULLPATH @"fullPath"
#define kICONPATH @"iconPath"
#define kLOCATIONPATH @"locationPath"
#define kNULL     @"noIconPath"


#define K_WEEKFLAG_ALLDAY 0x7F

#import "Constants_Versions.h"
