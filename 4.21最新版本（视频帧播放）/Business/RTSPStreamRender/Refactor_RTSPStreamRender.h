//
//  Refactor_RTSPStreamRender.h
//  AtHomeCam
//
//  Created by Circlely Networks on 15/12/13.
//
//

#import <Foundation/Foundation.h>

typedef enum  {
    VOICE_TYPE_RECIEVE = 1 << 0, //for listening
    VOICE_TYPE_SEND    = 1 << 1, //for speaking
    VOICE_TYPE_ALL     = 0xF
} VOICE_TYPE;

//typedef enum {
//    DISPLAY_RATIO_16_9,
//    DISPLAY_RATIO_4_3,
//    DISPLAY_RATIO_DEFAULT
//} DISPLAY_RATIO;

@class AHCRTSPChannel;

typedef void (^CompletionBlock)(void);
typedef void (^FailureBlock)(NSError *error);



@protocol Refactor_RTSPStreamRenderDelegate <NSObject>

@optional
-(void)timeTampChange:(unsigned int)timeTamp;

@end


@interface Refactor_RTSPStreamRender : NSObject


@property (nonatomic, readonly, assign) BOOL listening; //if the sound is playing
@property (nonatomic, readonly, assign) BOOL speaking;  //if the voice could be sent
@property (nonatomic, readonly, assign) BOOL recording;

@property (nonatomic, assign) BOOL isScreenRotating;

@property (nonatomic,assign) id<Refactor_RTSPStreamRenderDelegate> delegate;

//@property (nonatomic) DISPLAY_RATIO displayRatio;
@property (nonatomic, assign) UIColor* backgroundColor;

-(id)initStreamRenderWithChannel:(AHCRTSPChannel*)channel;
-(id)initStreamRenderWithChannel:(AHCRTSPChannel*)channel displayRatio:(CGPoint)displayRatio;

-(void)startStreamOn:(UIView*)targetView completionBlock:(CompletionBlock)completionBlock;

//新增接口，可以在failureblock里监听到视频播放完成
-(void)startStreamOn:(UIView*)targetView completionBlock:(CompletionBlock)completionBlock failureBlock:(FailureBlock)failureBlock;

-(void)switchStreamToChannel:(AHCRTSPChannel*)channel completionBlock:(CompletionBlock)aCompletionBlock;

-(void)switchStreamToChannel:(AHCRTSPChannel*)channel completionBlock:(CompletionBlock)aCompletionBlock failureBlock:(FailureBlock)failureBlock;
-(void)stopStream; //You must stop stream before releasing the render

-(void)openVoiceByType:(VOICE_TYPE)type;
-(void)muteVoiceBytype:(VOICE_TYPE)type;
-(UIImage*)caputreVideoImage;
-(BOOL)startRecordToLocalAlbum:(NSString*)albumName;

- (void)saveRecordVideoToLocalWithCompletionBlock:(CompletionBlock)aCompletionBlock failureBlock:(FailureBlock)aFailureBlock;

- (void)saveImage:(UIImage *)image ToLocal:(NSString *)path WithCompletionBlock:(CompletionBlock)aCompletionBlock failureBlock:(FailureBlock)aFailureBlock;

-(void)SaveImageToLocalAlbum:(NSString*)albumName
                       Image:(UIImage*)image
         WithCompletionBlock:(CompletionBlock)aCompletionBlock
                failureBlock:(FailureBlock)aFailureBlock;
//暂停录像播放
- (void)pauseRecordStream;

//继续视频
- (void)resumeRecordStream;
//滑动滑块
- (void)moveRecordStreamToTimePoint:(unsigned int)milliSecond;

//得到长宽
- (int)getStreamHeight;
- (int)getStreamWidth;

@end
