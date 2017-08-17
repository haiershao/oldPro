
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVCaptureVideoPreviewLayer.h>

@protocol WCLRecordEngineDelegate <NSObject>

- (void)recordProgress:(CGFloat)progress;

@end
@class FocusImageView ;
@interface WCLRecordEngine : NSObject

@property (atomic, assign, readonly) BOOL isCapturing;//正在录制
@property (atomic, assign, readonly) BOOL isPaused;//是否暂停
@property (atomic, assign, readonly) CGFloat currentRecordTime;//当前录制时间
@property (atomic, assign) CGFloat maxRecordTime;//录制最长时间
@property (weak, nonatomic) id<WCLRecordEngineDelegate>delegate;
@property (atomic, strong) NSString *videoPath;//视频路径
@property (nonatomic, assign) BOOL isSoundOff;//是否静音 默认否
@property (nonatomic, strong) FocusImageView             *focusRectView;
//捕获到的视频呈现的layer
- (AVCaptureVideoPreviewLayer *)previewLayer;
//启动录制功能
- (void)startUp;
//关闭录制功能
- (void)shutdown;
//开始录制
- (void) startCapture;
//暂停录制
- (void) pauseCapture;
//停止录制
- (void) stopCaptureHandler:(void (^)(CGFloat totalTime))handler;
//继续录制
- (void) resumeCapture;
//开启闪光灯
- (void)openFlashLight;
//关闭闪光灯
- (void)closeFlashLight;
//切换前后置摄像头
- (void)changeCameraInputDeviceisFront:(BOOL)isFront;
//切换前后置摄像头
- (void)switchCamera;
//将mov的视频转成mp4
- (void)changeMovToMp4:(NSURL *)mediaURL dataBlock:(void (^)(UIImage *movieImage))handler;
//设置聚焦点
- (void)setFocusCursorWithPoint:(CGPoint)tapPoint;
//获取截图
- (void)movieToImageHandler:(void (^)(UIImage *movieImage))handler;
- (UIImage*)thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time;
@end
