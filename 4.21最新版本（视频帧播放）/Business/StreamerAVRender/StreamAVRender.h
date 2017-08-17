//
//  Refactor_RTSPStreamRender.h
//  AtHomeCam
//
//  Created by Circlely Networks on 15/12/13.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


extern NSString* KErrorStreamParam;
extern NSString *KErrorRecordingDomain;
extern NSString *KErrorStreamStatus;


typedef void (^RenderCompletionBlock)(void);
typedef void (^RenderFinishedBlock)(NSError *error);
typedef void (^RenderFailureBlock)(NSError *error);
typedef void (^RenderTimeStampChangedBlock)(unsigned int timeStamp);


@interface StreamAVRender : NSObject


@property (nonatomic, assign) BOOL isScreenRotating;
@property (nonatomic, assign, readonly) NSUInteger streamWidth;
@property (nonatomic, assign, readonly) NSUInteger streamHeight;
@property (nonatomic, assign, readonly) BOOL isStreamRecording;
@property (nonatomic, assign, readonly) BOOL isAudioPlaying;
@property (nonatomic, assign, readonly) BOOL isAudioRecording;

@property (nonatomic, assign) UIColor* backgroundColor;


- (id)initRealTimeStreamWithCID:(unsigned long long)cid
                    CameraIndex:(int)cameraIndex
                    StreamIndex:(int)streamIndex
                     TargetView:(UIView*)targetView;


- (id)initRecordStreamStreamWithCID:(unsigned long long)cid
                           FileName:(NSString*)fileName
                         RecordType:(NSUInteger)recordType
                         TargetView:(UIView*)targetView;





-(void)startStreamOnStreamChannelCreated:(RenderCompletionBlock)streamChannelCreatedBlock
                     FirstVideoFrameShow:(RenderCompletionBlock)firstVideoFrameShowBlock
                               PlayEnded:(RenderFinishedBlock)playEndedBlock;

-(void)startStreamOnStreamChannelCreated:(RenderCompletionBlock)streamChannelCreatedBlock
                     FirstVideoFrameShow:(RenderCompletionBlock)firstVideoFrameShowBlock
                               PlayEnded:(RenderFinishedBlock)playEndedBlock
                        TimeStampChanged:(RenderTimeStampChangedBlock)timeStampChangedBlock;


-(void)switchStreamWithCID:(unsigned long long)cid
               CameraIndex:(int)cameraIndex
               StreamIndex:(int)streamIndex
    OnStreamChannelCreated:(RenderCompletionBlock)streamChannelCreatedBlock
       FirstVideoFrameShow:(RenderCompletionBlock)firstVideoFrameShowBlock
                 PlayEnded:(RenderFinishedBlock)playEndedBlock;


//暂停录像播放
- (void)pauseRecordStream;

//继续视频
- (void)resumeRecordStream;

//滑动滑块
- (void)moveRecordStreamToTimePoint:(unsigned int)milliSecond;


-(void)stopStream;

- (void)activateVoice;

- (void)startTalk;

- (void)stopTalk;

- (void)startMute;

- (void)stopMute;


- (UIImage*)caputreVideoImage;

-(BOOL)startRecordToLocalAlbum:(NSString*)albumName;

- (void)saveRecordVideoToLocalWithCompletionBlock:(RenderCompletionBlock)completionBlock
                        failureBlock:(RenderFailureBlock)failureBlock;

- (void)saveImage:(UIImage *)image ToLocal:(NSString *)path WithCompletionBlock:(RenderCompletionBlock)aCompletionBlock failureBlock:(RenderFailureBlock)aFailureBlock;


- (void)forceIFrame;

@end
