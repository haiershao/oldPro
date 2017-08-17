//
//  RecordInterface.h
//  iosRecordSdk
//
//  Created by Chin on 17/2/14.
//  Copyright © 2017年 Chin. All rights reserved.
//

#import <Foundation/Foundation.h>

/********
    SDK需要访问摄像头和相册权限
    生成的录像文件放入自定义相册，当占用空间大于设定的值时，删除旧视频文件
 ********/

NS_ASSUME_NONNULL_BEGIN

@protocol RecordInterfaceDelegate <NSObject>
@required
- (void) fileWillAddToAlbum:(NSString*) filePath;

- (void) fileWillAddToDirectory:(NSString*) filePath;

- (void) fileWillDelFromDirectory:(NSString*) filePath;

@end

NS_ASSUME_NONNULL_END


@class UIView;
@class AVCaptureSession;
@interface RecordInterface : NSObject


@property id<RecordInterfaceDelegate> __nullable delegate;

/* 抓录 录像文件时长 default 8 second
 */
@property (nonatomic) NSUInteger fileTime;

/* 抓录 预录像时长 default 1 second
 */
@property (nonatomic) NSUInteger advanceTime;

/* 循环录像时长 default 1 miniter
 */
@property (nonatomic) NSUInteger normalFileTime;

/* 录像占用空间 default 1024 MB
 */
@property (nonatomic) NSUInteger memorySize;


/* 自定义相册名称 default "我的录像" "抓录"
 */
@property (nonatomic) NSString * __nullable  albumName;
@property (nonatomic) NSString * __nullable  quickAlbumName;


/*  AVCaptureSessionPreset***
    参考苹果官方定义
    默认 AVCaptureSessionPreset640x480
 */
@property (nonatomic) NSString * __nullable sessionPreset;


typedef enum {
    DevicePositionFront,
    DevicePositionBack
}DevicePosition;


////
+ (__nonnull instancetype) instance;
////

/* 初始化SDK
 */
- (void) initSDK;

/* 注销SDK
 */
- (void) deinitSDK;


/* 开始预览
 */
- (void) startPreview:(UIView* __nullable)preview
       devicePosition:(DevicePosition)devicePos
      completeHandler:(void(^ __nonnull)(AVCaptureSession * __nonnull))handler;

/* 停止预览
 */
- (void) stopPreview;

/////////

/* 开始录像 循环录像
 */
- (void) startRecord;

/* 停止录像
 */
- (void) stopRecord;

/* 抓录
 */
- (void) quickRecord;


@end






