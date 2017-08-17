//
//  Refactor_RTSPStreamRender.m
//  AtHomeCam
//
//  Created by Circlely Networks on 15/12/13.
//
//

#import "Refactor_RTSPStreamRender.h"

#import "AudioStreamer.h"

#import "KxMovieDecoder.h"
#import "KxMovieGLView.h"
//#import "rtsp_client.h"
#import "AHCRTSPChannel.h"
#import <AssetsLibrary/ALAsset.h>
#import <AssetsLibrary/ALAssetsGroup.h>
//#import "VideoLibrary.h"
#import <Photos/Photos.h>
#import "AlbumManager.h"


static NSMutableDictionary* g_MainMsgDic = nil;

#define DEFAULT_DISPLAY_BOUND CGRectMake(0, 0, 320, 240)

#define K_FRAME_RATE 40

typedef enum  {

	E_Allow_Render = 0,
    
    E_DisAllow_Render
    
} T_RenderStatus;


typedef void* RTSP_HANDLE;

@interface Refactor_RTSPStreamRender () {

    AudioStreamer*      audioPlayer;
    KxMovieDecoder*     movieDecoder;

    dispatch_queue_t    videoRenderQueue;
    dispatch_queue_t    localRecordQueue;
    dispatch_source_t   getVideoTimer;
    
	
	//用于控制录像回放渲染控制
	T_RenderStatus renderStatus;     //是否控制要阻塞旧的videoframe
	int  preFrameInterval;   //上一帧的时间戳
    BOOL fistVideoFrameShowed;
    
    int serialNum;
}

@property (nonatomic, assign) BOOL listening;
@property (nonatomic, assign) BOOL speaking;

@property (nonatomic, copy) NSString* albumName;
@property (nonatomic, strong) AHCRTSPChannel* streamChannel;
@property (nonatomic, copy) CompletionBlock completionBlock;
@property (nonatomic, strong) KxMovieGLView*  displayView;
@property (nonatomic, strong) UIImage *videoIconImage;

@end

@implementation Refactor_RTSPStreamRender

+ (void)initialize {

    g_MainMsgDic = [[NSMutableDictionary alloc] initWithCapacity:3];
}

+ (int)generateSerialNum {

    static int g_SerialNum = 0;
    
    g_SerialNum++;
    
    return g_SerialNum;

}

+ (BOOL)isSerialNumInMainMsgDic:(int)sNum {

    NSString* value = [g_MainMsgDic objectForKey:[NSString stringWithFormat:@"%d", sNum]];
    
    if (value) {
    
        return YES;
    }
    
    NSLog(@"Refactor_RTSPStreamRender serialNum[%d] is not in MainMsgDic", sNum);
    
    return NO;
}

- (void)joinMainMsgDic {

    serialNum = [Refactor_RTSPStreamRender generateSerialNum];
    
    [g_MainMsgDic setObject:@"exist" forKey:[NSString stringWithFormat:@"%d", serialNum]];

    NSLog(@"Refactor_RTSPStreamRender serialNum[%d] join MainMsgDic", serialNum);
}

- (void)leaveMainMsgDic {

    [g_MainMsgDic removeObjectForKey:[NSString stringWithFormat:@"%d", serialNum]];
    
    NSLog(@"Refactor_RTSPStreamRender serialNum[%d] leave MainMsgDic", serialNum);
}



-(id)initStreamRenderWithChannel:(AHCRTSPChannel*)channel displayRatio:(CGPoint)displayRatio
{
    self = [super init];
    
    if (self) {
		
        [self joinMainMsgDic];
        
        audioPlayer    = [[AudioStreamer alloc] initWithChannel:channel];
        movieDecoder   = [[KxMovieDecoder alloc] init];
        videoRenderQueue  = dispatch_queue_create("videoRenderQueue", DISPATCH_QUEUE_SERIAL);
        localRecordQueue    = dispatch_queue_create("localRecordQueue", DISPATCH_QUEUE_SERIAL);


        self.streamChannel = channel;
        self.displayView = [[KxMovieGLView alloc] initWithFrame:DEFAULT_DISPLAY_BOUND
                                displayRatio:displayRatio
                             backgroundColor:nil
                                     decoder:movieDecoder];


        self.listening = NO;
        self.speaking  = NO;
        
    }
    
    return self;
}

-(id)initStreamRenderWithChannel:(AHCRTSPChannel*)channel
{
    return [self initStreamRenderWithChannel:channel displayRatio:CGPointMake(0, 0)];
}

//-(void)dealloc
//{
//    self.delegate = nil;
//    [self stopStream];
//    
//    if (audioPlayer) {
//    [audioPlayer release];
//    audioPlayer = nil;
//    }
//    
//    if (movieDecoder) {
//        [movieDecoder release];
//        movieDecoder = nil;
//    }
//    
//    self.displayView = nil;
//    self.backgroundColor = nil;
//    self.streamChannel = nil;
//    self.albumName = nil;
//    self.completionBlock = nil;
//    
//    if (videoRenderQueue) {
//        dispatch_release(videoRenderQueue);
//        videoRenderQueue = NULL;
//    }
//    
//    if (localRecordQueue) {
//        dispatch_release(localRecordQueue);
//        localRecordQueue = NULL;
//    }
//    
//    [self leaveMainMsgDic];
//    NSLog(@"Refactor_RTSPStreamRender dealloc invoked!");
//    
//    [super dealloc];
//}


- (void)addDisplayViewToTarget:(UIView*)targetView {
    
    if (self.displayView.superview != targetView) {
        //self->displayView.frame = targetView.bounds;
        self.displayView.translatesAutoresizingMaskIntoConstraints = NO;
        [targetView addSubview:self.displayView];
        
        NSDictionary *viewsDictionary = @{@"displayView":self.displayView};
        
        NSArray *constraint_POS_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[displayView]-0-|"
                                                                            options:0
                                                                            metrics:nil
                                                                              views:viewsDictionary];
        
        NSArray *constraint_POS_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[displayView]-0-|"
                                                                            options:0
                                                                            metrics:nil
                                                                              views:viewsDictionary];
        
        [targetView addConstraints:constraint_POS_V];
        [targetView addConstraints:constraint_POS_H];
    }
    
}

- (void)dispathMsgToMain:(void(^)()) block{
    
    int snum = serialNum;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (![Refactor_RTSPStreamRender isSerialNumInMainMsgDic:snum]) {
        
            NSLog(@"Refactor_RTSPStreamRender dispathMsgToMain fail");
            
            return;
        }
        
        block();
        
    });
    
}


#pragma mark - public api

-(void)setBackgroundColor:(UIColor *)backgroundColor
{
    self.displayView.backgroundColor = [UIColor clearColor];
}

-(UIColor*)backgroundColor
{
    return [UIColor clearColor];
}

-(BOOL)recording
{
    return self.streamChannel.isRecording;
}


-(void)startStreamOn:(UIView*)targetView completionBlock:(CompletionBlock)aCompletionBlock
{
	[self startStreamOn:targetView completionBlock:aCompletionBlock failureBlock:nil];
}


//新增接口，可以在failureblock里监听到视频播放完成
-(void)startStreamOn:(UIView*)targetView completionBlock:(CompletionBlock)aCompletionBlock failureBlock:(FailureBlock)failureBlock {

    __block Refactor_RTSPStreamRender* safeSelf = self;
    
    [self addDisplayViewToTarget:targetView];
    self.displayView.hidden = YES;
    
	//如果channel没有初始化成功，则直接返回失败
	if (self.streamChannel.channelError != E_CHANNEL_NO_ERROR) {
		if(failureBlock){
			NSError* err = [NSError errorWithDomain:@"ChannelError" code:self.streamChannel.channelError userInfo:nil];
			failureBlock(err);
		}
	
		return;
	}
    
    NSLog(@"Refactor_RTSPStreamRender startStream");
	
    [self.streamChannel startStream:^{
        
        [safeSelf dispathMsgToMain:^{
            
//            [safeSelf addDisplayViewToTarget:targetView];
//            safeSelf.displayView.hidden = YES;
            safeSelf.completionBlock = aCompletionBlock;
            
            [safeSelf startGetVideo];
            
            //safeSelf.listening = YES;
            [safeSelf->audioPlayer startWithChannel:safeSelf.streamChannel];
        }];

    } failedBlock:^(RTSP_CHANNEL_ERROR_TYPE errorCode) {
        NSLog(@"startStream Error = %d", errorCode);

        [safeSelf dispathMsgToMain:^{
            
            if(failureBlock){
                NSError* err = [NSError errorWithDomain:@"RtspError" code:errorCode userInfo:nil];
                failureBlock(err);
            }
        }];
	
		
    }];

}

-(void)switchStreamToChannel:(AHCRTSPChannel*)channel completionBlock:(CompletionBlock)aCompletionBlock {

	[self switchStreamToChannel:channel completionBlock:aCompletionBlock failureBlock:nil];
}



/*
函数名：switchStreamToChannel:completionBlock:
 
参数列表：channel：新的流通道
		aCompletionBlock：当操作成功时候执行的block
 
功能描述：该API在不切换渲染视图，只是切换流通道的时候调用，主要完成以下三个功能，
		 1. 如果当前流通道存在，则关闭
		 2. 启动新的流通道
		 3. 新流通道启动成功后，声音默认打开，mirophone默认关闭，
			如果需要调节声音和mirophone状态可以在aCompletionBlock调整
 
备注：
*/

-(void)switchStreamToChannel:(AHCRTSPChannel*)channel completionBlock:(CompletionBlock) aCompletionBlock failureBlock:(FailureBlock)failureBlock;
{
    
    NSLog(@"Refactor_RTSPStreamRender switchStream");
	
    [self stopStream];
    
    self.streamChannel = channel;
    
    //如果channel没有初始化成功，则直接返回失败
    if (self.streamChannel.channelError != E_CHANNEL_NO_ERROR) {
        
        if(failureBlock){
            NSError* err = [NSError errorWithDomain:@"ChannelError" code:self.streamChannel.channelError userInfo:nil];
            failureBlock(err);
        }
        
        return;
    }
    
    __typeof(self) __block safeSelf = self;
    
    [self.streamChannel startStream:^{
        
        [safeSelf dispathMsgToMain:^{
            
            safeSelf.completionBlock = aCompletionBlock;
            
            [safeSelf startGetVideo];
            [safeSelf->audioPlayer startWithChannel:safeSelf.streamChannel];
            //safeSelf.listening = YES;
            
            NSLog(@"Streaming restart!");
            
        }];
        
    } failedBlock:^(RTSP_CHANNEL_ERROR_TYPE errorCode) {
        
        NSLog(@"switchStream Error = %d", errorCode);
        
        [safeSelf dispathMsgToMain:^{
            
            if(failureBlock){
                NSError* err = [NSError errorWithDomain:@"RtspError" code:errorCode userInfo:nil];
                failureBlock(err);
            }
        }];
    }];
    

}

-(void)stopStream
{
    NSLog(@"Refactor_RTSPStreamRender stopStream");
    
    //self.listening = NO;
    self.speaking = NO;
    self.displayView.hidden = YES;
    
    renderStatus = E_DisAllow_Render;
    
    [audioPlayer stop];
    [self stopGetVideo];
    [self.streamChannel stopStream];
    
}



- (void)startGetVideo {
    
    __typeof(self) __block safeSelf = self;
    
    dispatch_async(videoRenderQueue, ^{
        
        NSLog(@"Refactor_RTSPStreamRender startGetVideo");
        
        if (safeSelf->getVideoTimer) {
            
             NSLog(@"Refactor_RTSPStreamRender startGetVideo Warning,because the timer is exists");
            
            return ;
        }
        
        safeSelf->getVideoTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, safeSelf->videoRenderQueue);
        
        if (safeSelf->getVideoTimer) {
            
            dispatch_source_set_timer(safeSelf->getVideoTimer,
                                      dispatch_walltime(DISPATCH_TIME_NOW, NSEC_PER_SEC/K_FRAME_RATE),
                                      NSEC_PER_SEC/K_FRAME_RATE,
                                      0);
            
            dispatch_source_set_event_handler(safeSelf->getVideoTimer, ^{
                
                [safeSelf timerCallBack];
                
            });
            
            dispatch_resume(safeSelf->getVideoTimer);
            
            
            safeSelf->renderStatus = E_Allow_Render;
            safeSelf->preFrameInterval = 0;
            safeSelf->fistVideoFrameShowed = NO;
            
            
             NSLog(@"Refactor_RTSPStreamRender startGetVideo create timer success");
        }
    });
    
}

- (void)timerCallBack{
    
    //获取视频数据渲染
    @autoreleasepool {
        
        __typeof(self) __block safeSelf = self;
        
        AVVideoYUVFrame yuvFrame;
        memset(&yuvFrame, 0, sizeof(AVVideoYUVFrame));
        
        int ret = [self.streamChannel readVideoYUVFrame:&yuvFrame];
        
        if (ret > 0 && renderStatus == E_Allow_Render) {
            

            
            
            KxVideoFrameYUV* kxyuvFrame = [movieDecoder decodeVideoFrame:&yuvFrame];
            
            [self.displayView updateVertices];
            
            [self.displayView render:kxyuvFrame];
            
            
            
            //当第一帧video渲染完成后，通知ui刷新
            if (!fistVideoFrameShowed) {
                
                fistVideoFrameShowed = YES;
                
                [self dispathMsgToMain:^{
                    
                    safeSelf.displayView.hidden = NO;
                    if (safeSelf.completionBlock != nil) {
                        safeSelf.completionBlock();
                        safeSelf.completionBlock = nil;
                    }
                }];
                
            }
            
            
            if (preFrameInterval != kxyuvFrame.timetmp ) {
                preFrameInterval = kxyuvFrame.timetmp;
                
                int time = kxyuvFrame.timetmp;
                
                [self dispathMsgToMain:^{
                    
                    //抛通知 ，更新时间戳
                    if ((safeSelf->renderStatus == E_Allow_Render) && [safeSelf.delegate respondsToSelector:@selector(timeTampChange:)]){
                        
                        //NSLog(@"ensure to updata time %d",time);
                        [safeSelf.delegate timeTampChange:time];
                    }
                }];
            
                    
            }
            
        }
    }
    
}


- (void)stopGetVideo {
    
    __typeof(self) __block safeSelf = self;
    
    dispatch_sync(videoRenderQueue, ^{
        
        NSLog(@"Refactor_RTSPStreamRender stopGetVideo");
        
        if (safeSelf->getVideoTimer) {
            
            dispatch_source_cancel(safeSelf->getVideoTimer);
            //dispatch_release(safeSelf->getVideoTimer);
            safeSelf->getVideoTimer = NULL;
            
            NSLog(@"Refactor_RTSPStreamRender stopGetVideo stopTimer");
        }
        
        safeSelf->renderStatus = E_DisAllow_Render;
        
    });
}


//暂停录像播放
- (void)pauseRecordStream{
    
    [self.streamChannel pausePlayingRecordVideo];
    
}

//继续视频
- (void)resumeRecordStream{
    
    [self.streamChannel contiunePlayingRecordVideo];
    
}
//快进 ／ 后退
- (void)moveRecordStreamToTimePoint:(unsigned int)milliSecond{

    renderStatus = E_DisAllow_Render;
    
    [self.streamChannel moveVideoToTimePoint:milliSecond];
    
    renderStatus = E_Allow_Render;
    

}

- (int)getStreamHeight {
    
    return [_streamChannel getStreamHeight];
    
}

- (int)getStreamWidth {
    
    return [_streamChannel getStreamWidth];
}

- (void)setIsScreenRotating:(BOOL)isScreenRotating {
    
    _isScreenRotating = isScreenRotating;
    
    self.displayView.isScreenRotating = isScreenRotating;
    
}

-(void)openVoiceByType:(VOICE_TYPE)type
{
    if (type&VOICE_TYPE_RECIEVE) {
        [audioPlayer resumePlay];
        self.listening = YES;
    }
    else if (type&VOICE_TYPE_SEND) {
		[audioPlayer resumeRecord];
        self.speaking = YES;
    }
}

-(void)muteVoiceBytype:(VOICE_TYPE)type
{
    if (type&VOICE_TYPE_RECIEVE) {
        [audioPlayer pausePlay];
        self.listening = NO;
    }
    else if (type&VOICE_TYPE_SEND) {
		[audioPlayer pauseRecord];
        self.speaking = NO;
    }
}


-(UIImage*)caputreVideoImage
{
    return [self.streamChannel captureImage];
}


-(BOOL)startRecordToLocalAlbum:(NSString*)albumName
{
    self.albumName = albumName;
    
    self.videoIconImage = [self caputreVideoImage];
    
    return [self.streamChannel startRecordMovie:CGSizeMake(movieDecoder.frameWidth, movieDecoder.frameHeight)];
}

- (void)saveImage:(UIImage *)image ToLocal:(NSString *)path WithCompletionBlock:(CompletionBlock)aCompletionBlock failureBlock:(FailureBlock)aFailureBlock{
    
    NSDate *recordDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYYMMDDHHmmss"];
    NSString *recordDir = [dateFormatter stringFromDate:recordDate];
    
    NSString *fileName = [recordDir stringByAppendingPathExtension:@"png"];
    
    NSString *filePath = [path stringByAppendingPathComponent:fileName];

    NSError *error = nil;
    
    BOOL result = [UIImagePNGRepresentation(image) writeToFile:filePath options:NSDataWritingFileProtectionComplete error:&error];
    
    if (result) {
        
        
        
        
        
        NSDictionary *item = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:fileName, filePath, kNULL, nil] forKeys:[NSArray arrayWithObjects:kFILENAME, kFULLPATH, kICONPATH, nil]];
        
        AlbumInfo *albumInfo = [[AlbumInfo alloc] initWithDictionary:item];
        
        [[AlbumManager shareAlbumManager] insertItemInAlbumList:albumInfo forVideo:NO];
        
        
        
        
        
        aCompletionBlock();
    }else{
        aFailureBlock(error);
    }
    
    
}


- (void)saveRecordVideoToLocalWithCompletionBlock:(CompletionBlock)aCompletionBlock failureBlock:(FailureBlock)aFailureBlock{
    
    [self.streamChannel stopRecordMovie:^(NSString *moviePath) {
 
        NSError *error = nil;
        
        NSString *fileName = [moviePath lastPathComponent];
        NSString *filePath = [self.albumName stringByAppendingPathComponent:fileName];
        [[NSFileManager  defaultManager] copyItemAtPath:moviePath toPath:filePath error:&error];
        
        
        //截取一个视频的icon用于UI显示
        NSString *iconPicName = [[fileName stringByDeletingPathExtension] stringByAppendingPathExtension:@"png"];
        NSString *iconPath = [self.albumName stringByAppendingPathComponent:iconPicName];
        
        error = nil;
        [UIImagePNGRepresentation(self.videoIconImage) writeToFile:iconPath options:NSDataWritingFileProtectionComplete error:&error];
        
        if (error) {
            APP_LOG_ERR(@"save icon error[%@]",error);
            
            aFailureBlock(error);
            
        }else{
            
            
            
            NSDictionary *item = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:fileName, filePath, iconPath, nil] forKeys:[NSArray arrayWithObjects:kFILENAME, kFULLPATH, kICONPATH, nil]];
            
            AlbumInfo *albumInfo = [[AlbumInfo alloc] initWithDictionary:item];
            
            [[AlbumManager shareAlbumManager] insertItemInAlbumList:albumInfo forVideo:YES];
            
            aCompletionBlock();
        }
        
        
    } failedBolck:^(NSError *errors) {
        
        APP_LOG_ERR(@"saveRecordVideoERROR[%@]",errors);
        
    }];
    
    
    
    
}

@end
