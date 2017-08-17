//
//  Refactor_RTSPStreamRender.m
//  AtHomeCam
//
//  Created by Circlely Networks on 15/12/13.
//
//

#import "StreamAVRender.h"
#import "AudioRender.h"
#import "KxMovieGLView.h"
#import "KxMovieDecoder.h"
#import "AHCServerCommunicator.h"
#import "CommonUtility.h"
#import "AlbumManager.h"


#define K_FRAME_RATE 25


typedef enum  {

    E_AVRENDER_INIT = 0,
    
    E_AVRENDER_WAIT_FOR_SESSION_READY, //等待tunnel建立

    E_AVRENDER_STARTSTREAM, //启动流申请
    
    E_AVRENDER_STOPSTREAM, //停止流
    
    E_AVRENDER_STARTGETVIDEO, //开始获取视频
    
}T_AVRENDER_STATUS;


typedef enum{
    
    E_AVRENDER_REALTIME_STREAMING = 0,
    
    E_AVRENDER_RECORD_STREAMING,
    
    E_AVRENDER_CLOUD_STREAMING
    
}T_AVRENDER_TYPE;



NSString* KErrorStreamParam = @"KErrorStreamParam";
NSString *KErrorRecordingDomain  = @"KErrorRecordingDomain";
NSString *KErrorStreamStatus  = @"KErrorStreamStatus";


@interface StreamAVRender (){

    
    T_AVRENDER_TYPE _avRenderType;
    
    unsigned long long _peerCID;
    int _cameraIndex;
    int _streamIndex;
    
    NSString* _fileName;
    NSUInteger _recordType;
    
    NSString* _eid;
    
    
    
    
    RVS_HANDLE _handle;
    RvsMediaAVDesc* _MediaDesc;
    dispatch_queue_t _renderQueue;
    dispatch_source_t _getVideoTimer;
    KxMovieDecoder* _movieDecoder;
    
    
    T_AVRENDER_STATUS _renderStatus;

    

    int  _preFrameInterval;
    BOOL _fistVideoFrameShowed;
    
    
    int _openStreamCount;
    
    NSString *_videoName;
    
    
    
    

}



@property (nonatomic, copy) RenderCompletionBlock streamChannelCreatedBlock;
@property (nonatomic, copy) RenderCompletionBlock firstVideoFrameShowBlock;
@property (nonatomic, copy) RenderFinishedBlock playEndedBlock;
@property (nonatomic, copy) RenderTimeStampChangedBlock timeStampChangedBlock;
@property (nonatomic, strong) KxMovieGLView* displayView;

@property (nonatomic, copy) NSString* albumName;
@property (nonatomic, strong) UIImage *videoIconImage;


@property (nonatomic, assign) BOOL isStreamRecording;
@property (nonatomic, assign) BOOL isAudioPlaying;
@property (nonatomic, assign) BOOL isAudioRecording;
@property (nonatomic, assign) BOOL allowRender;
@property (nonatomic, copy) NSString *iconPath;
@end


static unsigned long long g_curActivateVoiceCID = 0;

@implementation StreamAVRender


-(void)dealloc
{
    
    [self stopStream];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)initRenderEnvWithTargetView:(UIView*)targetView {

    _movieDecoder   = [[KxMovieDecoder alloc] init];
    
    static int rnd = 0;
    rnd++;
    
    NSString* ren = [NSString stringWithFormat:@"RenderQueue_%d", rnd];
    
    _renderQueue    = dispatch_queue_create(ren.UTF8String, DISPATCH_QUEUE_SERIAL);
    
    _displayView    =  [[KxMovieGLView alloc] initWithFrame:targetView.bounds
                                               displayRatio:CGPointMake(0, 0)
                                            backgroundColor:nil
                                                    decoder:_movieDecoder];
    [self addDisplayViewToTarget:targetView];
    
    self.displayView.hidden = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recvMediaStreamState:) name:K_APP_STREAM_STATE_UPDATE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recvSessionState:) name:K_APP_SESSION_STATE_UPDATE object:nil];
    
    _renderStatus = E_AVRENDER_INIT;
    
    _isAudioPlaying = NO;
    _isAudioRecording = NO;
    
    
    _openStreamCount = 0;

}

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


- (id)initRealTimeStreamWithCID:(unsigned long long)cid
                    CameraIndex:(int)cameraIndex
                    StreamIndex:(int)streamIndex
                     TargetView:(UIView*)targetView {
    self = [super init];
    
    if (self) {
        
        [self initRenderEnvWithTargetView:targetView];
        
        _peerCID = cid;
        _cameraIndex = cameraIndex;
        _streamIndex = streamIndex;
        _avRenderType = E_AVRENDER_REALTIME_STREAMING;
        

    }
    
    return self;
}


- (id)initRecordStreamStreamWithCID:(unsigned long long)cid
                           FileName:(NSString*)fileName
                         RecordType:(NSUInteger)recordType
                         TargetView:(UIView*)targetView{
    
    self = [super init];
    
    if (self) {
        
        [self initRenderEnvWithTargetView:targetView];
        
         _peerCID = cid;
        _fileName = [fileName copy];
        _recordType = recordType;
        _avRenderType = E_AVRENDER_RECORD_STREAMING;
        
    }
    
    return self;
}


-(void)startStreamOnStreamChannelCreated:(RenderCompletionBlock)streamChannelCreatedBlock
                     FirstVideoFrameShow:(RenderCompletionBlock)firstVideoFrameShowBlock
                               PlayEnded:(RenderFinishedBlock)playEndedBlock {

    [self startStreamOnStreamChannelCreated:streamChannelCreatedBlock
                        FirstVideoFrameShow:firstVideoFrameShowBlock
                                  PlayEnded:playEndedBlock
                           TimeStampChanged:nil];

}

-(void)startStreamOnStreamChannelCreated:(RenderCompletionBlock)streamChannelCreatedBlock
                     FirstVideoFrameShow:(RenderCompletionBlock)firstVideoFrameShowBlock
                               PlayEnded:(RenderFinishedBlock)playEndedBlock
                        TimeStampChanged:(RenderTimeStampChangedBlock)timeStampChangedBlock {

    
    
    self.displayView.hidden = YES;
    

    if (_avRenderType == E_AVRENDER_REALTIME_STREAMING){
        
        
        T_STREAM_PARAM_ERROR streamParamErr = [CommonUtility getStreamParamErrorWithCID:_peerCID
                                                                            cameraIndex:_cameraIndex
                                                                            streamIndex:_streamIndex];
        
        if(streamParamErr != E_STREAM_CHANNEL_NO_ERROR) {
            
            if(playEndedBlock) {
            
                playEndedBlock([NSError errorWithDomain:KErrorStreamParam code:streamParamErr userInfo:nil]);
            }
            
            
            return;
        }
        
        
    }
    
    self.streamChannelCreatedBlock = streamChannelCreatedBlock;
    self.firstVideoFrameShowBlock = firstVideoFrameShowBlock;
    self.playEndedBlock = playEndedBlock;
    self.timeStampChangedBlock = timeStampChangedBlock;
    
    
    dispatch_async(_renderQueue, ^{
        
        //每次外部重启流的时候，流计数清0
        _openStreamCount = 0;
        
        [self startStreamInRender];
    });
    
}


-(void)switchStreamWithCID:(unsigned long long)cid
               CameraIndex:(int)cameraIndex
               StreamIndex:(int)streamIndex
    OnStreamChannelCreated:(RenderCompletionBlock)streamChannelCreatedBlock
       FirstVideoFrameShow:(RenderCompletionBlock)firstVideoFrameShowBlock
                 PlayEnded:(RenderFinishedBlock)playEndedBlock {

    
    if (_avRenderType != E_AVRENDER_REALTIME_STREAMING) {
    
    
        return;
    }
    
    [self stopStream];
    
    _peerCID = cid;
    _cameraIndex = cameraIndex;
    _streamIndex = streamIndex;
    
    [self startStreamOnStreamChannelCreated:streamChannelCreatedBlock
                        FirstVideoFrameShow:firstVideoFrameShowBlock
                                  PlayEnded:playEndedBlock];
    
}


//暂停录像播放
- (void)pauseRecordStream {

    if (_avRenderType == E_AVRENDER_REALTIME_STREAMING) {
        
        
        return;
    }
    
    
    
    dispatch_async(_renderQueue, ^{
        
        if (_handle != 0) {
        
            [[Rvs_Viewer defaultViewer].viewerMedia pauseStreamWithHandle:_handle];
        }
    });

}

//继续视频
- (void)resumeRecordStream {

    if (_avRenderType == E_AVRENDER_REALTIME_STREAMING) {
        
        
        return;
    }
    
    
    dispatch_async(_renderQueue, ^{
        
        if (_handle != 0) {
        
            [[Rvs_Viewer defaultViewer].viewerMedia resumeStreamWithHandle:_handle];
        }
    });
}

//滑动滑块
- (void)moveRecordStreamToTimePoint:(unsigned int)milliSecond {

    if (_avRenderType == E_AVRENDER_REALTIME_STREAMING) {
        
        
        return;
    }
    
    
    
    _allowRender = NO;
    
    
    
    dispatch_sync(_renderQueue, ^{
        
        
        if (_handle != 0) {
        
            [[Rvs_Viewer defaultViewer].viewerMedia seekStreamWithHandle:_handle TimeStamp:milliSecond];
        }
    });
    
    _allowRender = YES;
}



-(UIImage*)caputreVideoImage {
    

    if (_avRenderType == E_AVRENDER_REALTIME_STREAMING && _handle != 0) {
        
        
        return [[Rvs_Viewer defaultViewer].viewerMedia getSnapshotWithHandle:_handle];
    }
    
    

    return nil;

}

-(BOOL)startRecordToLocalAlbum:(NSString*)albumName {
    
    if (_handle && !_isStreamRecording)
    {
        
        
        
        
        self.videoIconImage = [self caputreVideoImage];
        
        self.albumName = albumName;
        
        NSDate *recordDate = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
        _videoName = [[dateFormatter stringFromDate:recordDate] stringByAppendingString:[NSString stringWithFormat:@"_%llu",_peerCID]];
        
        NSString *filePath = [[albumName stringByAppendingPathComponent:_videoName] stringByAppendingPathExtension:@"mp4"];
        
        HWLog(@"===============path------------%@",filePath);
        
        if (_avRenderType == E_AVRENDER_REALTIME_STREAMING) {
            
            _isStreamRecording = ([[Rvs_Viewer defaultViewer].viewerMedia startLocalRecordWithHandle:_handle PathFileName:filePath] >= 0);
        }
    }
    else {
    
    }
    
    return _isStreamRecording;

    
}

- (void)saveImage:(UIImage *)image ToLocal:(NSString *)path WithCompletionBlock:(RenderCompletionBlock)aCompletionBlock failureBlock:(RenderFailureBlock)aFailureBlock{
    
    NSDate *recordDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
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


-(void)saveRecordVideoToLocalWithCompletionBlock:(RenderCompletionBlock)completionBlock
                        failureBlock:(RenderFailureBlock)failureBlock {
    
    
    if (_handle != 0) {
        
        
        NSInteger ret = 0;
        
        if (_avRenderType == E_AVRENDER_REALTIME_STREAMING) {
            
            ret = [[Rvs_Viewer defaultViewer].viewerMedia stopLocalRecordWithHandle:_handle];
        }
        
        
        if (ret < 0) {
            
            
            if (failureBlock) {
                
                NSError *err = [NSError errorWithDomain:KErrorRecordingDomain code:ret userInfo:nil];
                failureBlock(err);
                
            }
            
        }
        else {
            
            NSError *error = nil;
            
            NSString *videoFilePath = [self.albumName stringByAppendingPathComponent:_videoName];
            //[[NSFileManager  defaultManager] copyItemAtPath:moviePath toPath:filePath error:&error];
            
            //截取一个视频的icon用于UI显示
            NSString *iconPath = [videoFilePath stringByAppendingPathExtension:@"png"];
            self.iconPath = iconPath;
            
            error = nil;
            [UIImagePNGRepresentation(self.videoIconImage) writeToFile:iconPath options:NSDataWritingFileProtectionComplete error:&error];
            
            if (error) {
                APP_LOG_ERR(@"save icon error[%@]",error);
                
                failureBlock(error);
                
            }else{
                
                
                
                
                
                NSDictionary *item = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:_videoName, [videoFilePath stringByAppendingPathExtension:@"mp4"], iconPath, nil] forKeys:[NSArray arrayWithObjects:kFILENAME, kFULLPATH, kICONPATH, nil]];
                
                AlbumInfo *albumInfo = [[AlbumInfo alloc] initWithDictionary:item];
                
                [[AlbumManager shareAlbumManager] insertItemInAlbumList:albumInfo forVideo:YES];
                
                completionBlock();
            }
        }
        
        _isStreamRecording = NO;
    }
    else {
        
        
    }
}



-(KxMovieGLView*) create_displayView:(CGRect)displayBounds
{
    
    KxMovieGLView* tmpView = [[KxMovieGLView alloc] initWithFrame:displayBounds
                                      displayRatio:CGPointMake(0, 0)
                                   backgroundColor:nil
                                           decoder:_movieDecoder];

    
    tmpView.contentMode = UIViewContentModeScaleAspectFit;
    tmpView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    

    return tmpView;
}

-(void)stopStream{
    
    
    //这个标志置为NO，可以加速内部线程退出
    _allowRender = NO;
    
    dispatch_sync(_renderQueue, ^{
        
        [self stopStreamInRender];
    });
    
    self.streamChannelCreatedBlock = nil;
    self.firstVideoFrameShowBlock = nil;
    self.playEndedBlock = nil;
    self.timeStampChangedBlock = nil;
    
//    [self cancelAllCmdRequest];
    
    self.displayView.hidden = YES;
    
}


- (void)activateVoice {
    
    dispatch_async(_renderQueue, ^{
        
        if (_renderStatus == E_AVRENDER_INIT || _renderStatus == E_AVRENDER_STOPSTREAM) {
            
            return;
        }
        
        g_curActivateVoiceCID = _peerCID;
        

        
        if (_renderStatus == E_AVRENDER_STARTGETVIDEO) {
            
            [[AudioRender shareRender] activateVoiceWithCID:_peerCID Handle:_handle Play:_isAudioPlaying Record:_isAudioRecording];
            
        }
        else {
            
            
        }
        
    });

}

- (void)startTalk {
    
    dispatch_async(_renderQueue, ^{
        
        if (_renderStatus == E_AVRENDER_INIT || _renderStatus == E_AVRENDER_STOPSTREAM) {
            
            return;
        }
        
        _isAudioRecording = YES;
        [[AudioRender shareRender] resumeRecord:_handle];
        
    });
}

- (void)stopTalk {
    
    dispatch_async(_renderQueue, ^{
        
        if (_renderStatus == E_AVRENDER_INIT || _renderStatus == E_AVRENDER_STOPSTREAM) {
            
            return;
        }
        
        
        _isAudioRecording = NO;
        
        [[AudioRender shareRender] pauseRecord:_handle];
        
    });
    

}

- (void)startMute {
    
    dispatch_async(_renderQueue, ^{
        
        if (_renderStatus == E_AVRENDER_INIT || _renderStatus == E_AVRENDER_STOPSTREAM) {
            
            return;
        }
        
        
        _isAudioPlaying = NO;
        
        [[AudioRender shareRender] pausePlay:_handle];
        
    });
    

}
- (void)stopMute {
    
    dispatch_async(_renderQueue, ^{
        
        if (_renderStatus == E_AVRENDER_INIT || _renderStatus == E_AVRENDER_STOPSTREAM) {
            
            return;
        }
        
        
        _isAudioPlaying = YES;
        
        [[AudioRender shareRender] resumePlay:_handle];
        
    });
    
    

}

- (void)setIsScreenRotating:(BOOL)isScreenRotating {
    
    _isScreenRotating = isScreenRotating;
    
    self.displayView.isScreenRotating = isScreenRotating;
    
}

- (NSUInteger)streamWidth {

    if (_MediaDesc){
        
        return _MediaDesc.width;
    }
    
    return 0;
    
}

- (NSUInteger)streamHeight {
    
    if (_MediaDesc){
        
        return _MediaDesc.height;
    }
    
    return 0;
    
}

-(void)setBackgroundColor:(UIColor *)backgroundColor
{
    self.displayView.backgroundColor = [UIColor clearColor];
}

-(UIColor*)backgroundColor
{
    return [UIColor clearColor];
}


-(void)startStreamInRender {
    
    
    if (_renderStatus != E_AVRENDER_INIT && _renderStatus != E_AVRENDER_STOPSTREAM) {
        
        return;
    }
    
    int sessionsate = [[AHCServerCommunicator sharedAHCServerCommunicator] getSessionState:_peerCID];
    
    if (_avRenderType == E_AVRENDER_CLOUD_STREAMING || sessionsate == E_RVS_STREAMER_CONN_STATE_CONNECTED) {
        
        [self readyToOpenStream];
        
        
        _renderStatus = E_AVRENDER_STARTSTREAM;
        
    }
    else {
        
        _renderStatus = E_AVRENDER_WAIT_FOR_SESSION_READY;
        
    }
    
}


-(void)stopStreamInRender{

    
    if (_renderStatus == E_AVRENDER_INIT || _renderStatus == E_AVRENDER_STOPSTREAM) {
        
        return;
    }
    
    
    [[AudioRender shareRender] deactivateVoiceWithCID:_peerCID Handle:_handle];
    
    [self stopGetVideo];
    
    [[Rvs_Viewer defaultViewer].viewerMedia closeStreamWithHandle:_handle];
    
    
    _handle = 0;
    
    
    _renderStatus = E_AVRENDER_STOPSTREAM;
    

    
}


- (void)readyToOpenStream {
    
    
    
    if (_avRenderType == E_AVRENDER_REALTIME_STREAMING) {
    
        _handle = [[Rvs_Viewer defaultViewer].viewerMedia openLiveStreamWithStreamer:_peerCID CameraIndex:_cameraIndex StreamIndex:_streamIndex MicIndex:0];
    
    }
    else if (_avRenderType == E_AVRENDER_RECORD_STREAMING) {
        
        _handle = [[Rvs_Viewer defaultViewer].viewerMedia openRemoteRecordFileStreamithStreamerEx:_peerCID FileName:_fileName RecordType:_recordType];
            
    }
    else if (_avRenderType == E_AVRENDER_CLOUD_STREAMING) {
        
        _handle = [[Rvs_Viewer defaultViewer].viewerMedia openCloudRecordFileStreamWithStreamer:_peerCID Eid:_eid];
    }
    else {
    }
    
    _openStreamCount++;

}

- (void)startGetVideo {
    
    if (_getVideoTimer) {
        
        
        return ;
    }
    
    _getVideoTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, _renderQueue);
    
    if (_getVideoTimer) {
        
        dispatch_source_set_timer(_getVideoTimer,
                                  dispatch_walltime(DISPATCH_TIME_NOW, NSEC_PER_SEC/K_FRAME_RATE),
                                  NSEC_PER_SEC/K_FRAME_RATE,
                                  0);
        
        dispatch_source_set_event_handler(_getVideoTimer, ^{
            
            [self timerCallBack];
            
        });
        
        dispatch_resume(_getVideoTimer);
        
        
        _allowRender = YES;
        _preFrameInterval = 0;
        _fistVideoFrameShowed = NO;
        
    }
    
    
}

- (void)timerCallBack{
    
    //获取视频数据渲染

    unsigned char* pData = NULL;
    NSUInteger timestamp = 0;
    NSInteger ret = [[Rvs_Viewer defaultViewer].viewerMedia getYUV420DataWithHandle:_handle
                                                                  YUVData:&pData
                                                                TimeStamp:&timestamp];
    
    if (ret <= 0 || !_allowRender) {
    
        return;
    }
    
    KxVideoFrameYUV* frame = [_movieDecoder decodeVideoFrame:pData Width:_MediaDesc.width Height:_MediaDesc.height TimeStamp:timestamp];
    
    [_displayView updateVertices];
    
    [_displayView render:frame];
    
    
    __weak typeof(self) weakSelf = self;
    
    if (!_fistVideoFrameShowed) {
    
        _fistVideoFrameShowed = YES;
        
        
        [self dispathMsgToMain:^{
            
            
            if (!weakSelf) {
            
                return ;
            }
            
            weakSelf.displayView.hidden = NO;
            
            if (weakSelf.firstVideoFrameShowBlock) {
                weakSelf.firstVideoFrameShowBlock ();
                weakSelf.firstVideoFrameShowBlock = nil;
            }
            
        }];
        
    
    }
    
    
    
    if (_preFrameInterval != timestamp) {
    
        _preFrameInterval = timestamp;
        
        [self dispathMsgToMain:^{
            
            if (!weakSelf) {
                
                return ;
            }
            
            if (weakSelf.allowRender && weakSelf.timeStampChangedBlock) {
            
                weakSelf.timeStampChangedBlock(timestamp);
                
            }
        }];
        
    }
    
}


- (void)stopGetVideo {

    if (_getVideoTimer) {
        
        dispatch_source_cancel(_getVideoTimer);
        //dispatch_release(encodeTimer);
        _getVideoTimer = nil;
    }
    
    _allowRender = NO;
    

}

- (void)dispathMsgToMain:(void(^)()) block{
    
    __weak typeof(self) weakself = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (!weakself) {
        
        
            return ;
        }
        
        
        block();
        
    });
    
}

#pragma mark -  handle notification

- (void)recvSessionState:(NSNotification*)notice {
    
    
    NSDictionary* userinfo = [notice userInfo];
    
    int sessionState = [[userinfo objectForKey:K_APP_PARAM_SESSION_STATE] integerValue];
    long long cid = [[userinfo objectForKey:K_APP_PARAM_CID] longLongValue];
    
    
   
    if (cid != _peerCID) {
        
        return;
    }
    
    dispatch_async(_renderQueue, ^{
        
        
         //云视频不用监听tunnel状态，或者 录制视频不需要自动重练
        if (_avRenderType == E_AVRENDER_CLOUD_STREAMING || (_avRenderType == E_AVRENDER_RECORD_STREAMING && _openStreamCount > 0)) {
        
        
            return;
        }
        
        
        
        if (sessionState == E_RVS_STREAMER_CONN_STATE_CONNECTED){
            
            
            if (_renderStatus == E_AVRENDER_WAIT_FOR_SESSION_READY) {
            
                [self readyToOpenStream];
                
                _renderStatus = E_AVRENDER_STARTSTREAM;
                
            
            }
            else {
            
                [self stopStreamInRender];
                [self startStreamInRender];
                
            }
            
        }
        else {
            
            //dealwithfail
            
            if (_renderStatus == E_AVRENDER_WAIT_FOR_SESSION_READY) {
            
            
            }
            else if (_renderStatus == E_AVRENDER_STARTSTREAM || _renderStatus == E_AVRENDER_STARTGETVIDEO) {
            
                
                [self stopStreamInRender];
                
                [self startStreamInRender];
                
            }
            else {
            
            
            }
            
        }
        
    });
    
    

    
}

- (void)recvMediaStreamState:(NSNotification*)notice {


    NSDictionary* userinfo = [notice userInfo];
    
    int streamState = [[userinfo objectForKey:K_APP_PARAM_STREAM_STATE] integerValue];
    int streamFlag = [[userinfo objectForKey:K_APP_PARAM_STREAM_FLAG] integerValue];
    
    long long mediaHandle = [[userinfo objectForKey:K_APP_PARAM_STREAM_HANDLE] longLongValue];
    
    
    
    dispatch_async(_renderQueue, ^{
        
        if (mediaHandle != _handle) {
            
            return;
        }
        
        
        
        __weak typeof(self) weakSelf = self;
        
        if (streamState == EN_RVS_MEDIASTREAM_STATE_CREATED){
            
            
            if (_renderStatus == E_AVRENDER_STARTSTREAM) {
            
                _MediaDesc = [[Rvs_Viewer defaultViewer].viewerMedia getStreamDescWithHandle:_handle];
                [self startGetVideo];
                
                if (g_curActivateVoiceCID == _peerCID) {
                
                    [[AudioRender shareRender] activateVoiceWithCID:_peerCID Handle:_handle Play:_isAudioPlaying Record:_isAudioRecording];
                }
                
                
                _renderStatus = E_AVRENDER_STARTGETVIDEO;
                
                
                
                [self dispathMsgToMain:^{
                    
                    if (!weakSelf) {
                        
                        return ;
                    }
                    
                    if (weakSelf.streamChannelCreatedBlock) {
                        
                        weakSelf.streamChannelCreatedBlock();
                        weakSelf.streamChannelCreatedBlock = nil;
                    }
                    
                }];
                
                
            
            }
            else {
            
            
            }
            
            

        }
        else {
            
            //dealwithfail
            
            if (_avRenderType == E_AVRENDER_CLOUD_STREAMING || _avRenderType == E_AVRENDER_RECORD_STREAMING) {
            
                
                
                [self dispathMsgToMain:^{
                    
                    if (!weakSelf) {
                        
                        return ;
                    }
                    
                    if (weakSelf.playEndedBlock) {
                        
                        NSError* playErr = nil;
                        
                        if (streamFlag == MEDIA_STREAM_FLAG_NOERR || streamFlag >= MEDIA_STREAM_FLAG_SERVICE_ERR) {
                            
                            
                        }
                        else {
                        
                            playErr = [NSError errorWithDomain:KErrorStreamStatus code:streamFlag userInfo:nil];
                        
                        }
                        
                        weakSelf.playEndedBlock(playErr);
                        
                        weakSelf.playEndedBlock = nil;
                    }
                    
                }];
                
                return;
            }
            
            
            
            
            if (_renderStatus == E_AVRENDER_STARTSTREAM || _renderStatus == E_AVRENDER_STARTGETVIDEO) {
                
                [self stopStreamInRender];
                [self startStreamInRender];
                
                
            }
            else {
                
                
            }
            
        }
        
    });
}



@end


