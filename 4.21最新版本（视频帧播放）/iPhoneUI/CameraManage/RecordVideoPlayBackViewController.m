//
//  IPCamVideoPlayerViewController.m
//  AtHomeCam
//
//  Created by Circlely Networks on 24/12/13.
//
//

#import "RecordVideoPlayBackViewController.h"
#import "AVSConfigData.h"
#import "MemberData.h"
#import "StreamAVRender.h"

@interface RecordVideoPlayBackViewController ()
{

    BOOL isPause;
    BOOL isTap;
    UITapGestureRecognizer* singleRecognizer;
    
    
    CGFloat upSpaceConstrant;
    CGFloat leftSpaceConstrant;
    CGFloat rightSpaceConstrant;
    CGFloat playerViewLeftSpaceConstrant;
    CGFloat playerViewRightSpaceConstrant;
    CGFloat playerViewUpSpaceConstrant;
    
    CGFloat videoPlayerHeightConstrant;
    
    
    BOOL isFullScreen;

    
    
	
    
 @public
    BOOL isSliderMoving;
	BOOL isCloudPlay;
    
}

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView* loadingIndicator;


@property (nonatomic, retain) UIView* adView;
@property (nonatomic, retain) NSTimer *Timer;
@property (nonatomic, copy) NSString *cidStr;
@property (nonatomic, retain)UIAlertView *alert;
@end

@implementation RecordVideoPlayBackViewController

-(id)initWithStreamURL:(NSString*)streamURL
              FileName:(NSString *)fileName
                AVSCID:(NSString *)CIDNubmer
          andTimeRange:(NSString *)timeRange
            recordType:(NSUInteger)recordType
{
    
    self = [super initWithNibName:@"RecordVideoPlayBackViewController" bundle:nil];
    if (self) {
        // Custom initialization
       // AHCRTSPChannel* channel = [[[AHCRTSPChannel alloc] initRDStreamingChannelForCID:CIDNubmer StreamURL:streamURL FileName:fileName] autorelease];


//        streamRender.delegate = self;
        self.cidStr = CIDNubmer;
        self.timeRange = timeRange;
        self.fileName = fileName;
        self.recordType = recordType;
        self.streamURL = streamURL;

		//isCloudPlay = NO;
    }
    return self;
}

-(id)initWithStreamURL:(NSString*)streamURL
              FileName:(NSString *)fileName
                AVSCID:(NSString *)CIDNubmer
            recordType:(NSUInteger)type
{
    self = [super initWithNibName:@"IPCamVideoPlayerViewController" bundle:nil];
    if (self) {
        // Custom initialization
//        AHCRTSPChannel* channel =  [[[AHCRTSPChannel alloc] initRDStreamingChannelForCID:CIDNubmer StreamURL:streamURL FileName:fileName] autorelease];
        
        streamRender = [[StreamAVRender alloc] initRecordStreamStreamWithCID:[CIDNubmer longLongValue] FileName:fileName RecordType:type TargetView:self.playimageView];

        self.cidStr = CIDNubmer;
//        streamRender.delegate = self;
    }
    return self;
}


- (void)timeTampChange:(unsigned int)timeTamp{
    
    if (isSliderMoving) {
        return;
    }
    
    self.loadingIndicator.hidden = YES;
    [self.loadingIndicator stopAnimating];
    
    self.timeSlider.value = (float)timeTamp;
    int leftTimeMin = (int)self.timeSlider.value/60000;
    int leftTimeSec = ((int)self.timeSlider.value%60000)/1000;
    NSString *leftTimeStr;
    if (leftTimeMin < 10 && leftTimeSec < 10) {
        leftTimeStr =[NSString stringWithFormat:@"0%d:0%d", leftTimeMin,leftTimeSec] ;
        
    }
    if (leftTimeMin < 10 && leftTimeSec >=10) {
        leftTimeStr = [NSString stringWithFormat:@"0%d:%d",leftTimeMin,leftTimeSec];
    }
    if (leftTimeMin >= 10 && leftTimeSec < 10) {
        leftTimeStr =[NSString stringWithFormat:@"%d:0%d", leftTimeMin,leftTimeSec] ;
        
    }if (leftTimeMin >= 10 && leftTimeSec >= 10) {
        leftTimeStr =[NSString stringWithFormat:@"%d:%d", leftTimeMin,leftTimeSec] ;
        
    }
    
    self.leftTimeLabel.text = leftTimeStr;
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.backgroundColor = kBackgroundColor;
    [self setUpNav];
    
    
    streamRender = [[StreamAVRender alloc] initRecordStreamStreamWithCID:[self.cidStr longLongValue] FileName:self.fileName RecordType:self.recordType TargetView:self.playimageView];
    
    
    [self setCenterFrame];
    
    isFullScreen = NO;
    
    self.fullScreenPlayBtn.hidden = YES;
    
    self.playerView.backgroundColor = kColor(0, 0, 0, 0.8);
    
    upSpaceConstrant = self.upSpace.constant;
    leftSpaceConstrant = self.leftSpace.constant;
    rightSpaceConstrant = self.rightSpace.constant;
    
    playerViewLeftSpaceConstrant = self.playerViewLeftSpace.constant;
    playerViewRightSpaceConstrant = self.playerViewRightSpace.constant;
    playerViewUpSpaceConstrant = self.playerViewUpSpace.constant;
    videoPlayerHeightConstrant = self.videoPlayerViewHeightSpace.constant;
    
    isPause = NO;
    isSliderMoving = NO;
    isTap = NO;
    
    [self.playerView bringSubviewToFront:self.videoplayerVIew];
    [self.loadingIndicator startAnimating];
//    self.playerView.userInteractionEnabled = NO;
    self.playerBtn.enabled = NO;
    self.timeSlider.enabled = NO;
    
    self.timeSlider.continuous = NO;
    [self.timeSlider addTarget:self action:@selector(sliderTouchDown:) forControlEvents:UIControlEventTouchDown];
    [self.timeSlider addTarget:self action:@selector(sliderTouchCancel:) forControlEvents:UIControlEventTouchCancel];
    
	__typeof (self) __block safeSelf = self;
    
    [streamRender startStreamOnStreamChannelCreated:^{
        //底层音频模块更新，默认是把声音播放关闭的，所以当录像流通道打开时需要把声音打开
        [safeSelf->streamRender activateVoice];
        [safeSelf->streamRender stopMute];
        
    } FirstVideoFrameShow:^{
        
        if(!safeSelf->isFullScreen){
            
            [safeSelf setplayViewFrame];
        }
        
        safeSelf.playerBtn.enabled = YES;
        safeSelf.timeSlider.enabled = YES;
        
        
        [safeSelf.loadingIndicator stopAnimating];
        safeSelf.loadingIndicator.hidden = YES;
        
    } PlayEnded:^(NSError *error) {
        
        if (!error) {
            
            //            if(safeSelf->isFullScreen){
            //
            //                [safeSelf fullScreenBtnClicked:nil];
            //
            //            }
            
            [safeSelf.navigationController popViewControllerAnimated:YES];
            [safeSelf.navigationController setNavigationBarHidden:NO animated:YES];
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
            
        }
        
        
    } TimeStampChanged:^(unsigned int timeStamp) {
        
        [safeSelf timeTampChange:timeStamp];
        
    }];

    [self addNotification];

    [self setUpSliderContent];

    [self moveTimeSliderMove];
}

- (void)setUpSliderContent{

    // 设置进度条的内容
    [self.timeSlider setThumbImage:[UIImage imageNamed:@"thumbImage"] forState:UIControlStateNormal];
    [self.timeSlider setMaximumTrackImage:[UIImage imageNamed:@"MaximumTrackImage"] forState:UIControlStateNormal];
    [self.timeSlider setMinimumTrackImage:[UIImage imageNamed:@"MinimumTrackImage"] forState:UIControlStateNormal];
}

- (void)addNotification{

    //监听APP切入后台的通知，用于资源清理
    [DZNotificationCenter addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [DZNotificationCenter addObserver:self selector:@selector(applicationEnterForeBackground) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)setUpNav{

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"title_back_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonItemAction)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];

}

- (void)moveTimeSliderMove{

    self.timeSlider.maximumValue = [self.timeRange floatValue];
    self.timeSlider.minimumValue = 0;
    
    UIImage *leftImage = [UIImage imageNamed:@"time_slider_left"] ;
    UIImage *rightImage = [UIImage imageNamed:@"time_slider_right"];
    
    leftImage = [leftImage stretchableImageWithLeftCapWidth:8 topCapHeight:1];
    rightImage = [rightImage stretchableImageWithLeftCapWidth:8 topCapHeight:1];
    
    int rightTimeMin = [self.timeRange intValue]/60000;
    int rightTimeSec = ([self.timeRange intValue]%60000)/1000;
    NSString *rihgtTimeStr;
    if (rightTimeMin < 10 && rightTimeSec < 10) {
        rihgtTimeStr =[NSString stringWithFormat:@"/0%d:0%d", rightTimeMin,rightTimeSec] ;
        
    }
    if (rightTimeMin < 10 && rightTimeSec >=10) {
        rihgtTimeStr = [NSString stringWithFormat:@"/0%d:%d",rightTimeMin,rightTimeSec];
    }
    if (rightTimeMin >= 10 && rightTimeSec < 10) {
        rihgtTimeStr =[NSString stringWithFormat:@"/%d:0%d", rightTimeMin,rightTimeSec] ;
        
    }if (rightTimeMin >= 10 && rightTimeSec >= 10) {
        rihgtTimeStr =[NSString stringWithFormat:@"/%d:%d", rightTimeMin,rightTimeSec] ;
        
    }
    self.rightTimeLabel.text = rihgtTimeStr;
}

- (void)leftBarButtonItemAction {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)popView{

    [self.navigationController popViewControllerAnimated:YES];

}
- (void)setCenterFrame{
    
//    self.upSpace.constant = (self.videoPlayerViewHeightSpace.constant - 46) / 2;
//    upSpaceConstrant = self.upSpace.constant;
    
}

- (void)setplayViewFrame{

    int width = [streamRender streamWidth];
    int height = [streamRender streamHeight];
    if((width == 0 || height == 0) || (width > 3840 || height > 2160)){
    
        width  = 320;
        height = 240;
    
    }
    
    self.videoPlayerViewHeightSpace.constant = ([UIScreen mainScreen].bounds.size.width * height) / width;
        
    videoPlayerHeightConstrant = self.videoPlayerViewHeightSpace.constant;
    
    [self setCenterFrame];
    
}
- (void)applicationDidEnterBackground{
    
    [streamRender stopStream];
    
    
}
- (void)applicationEnterForeBackground{

//    if (isCloudPlay) {
//        [self.navigationController popViewControllerAnimated:NO];
//    }
}
- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    NSNotification	*note = [NSNotification notificationWithName:KUIControllerIsSupportOrientionY object:nil userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:note];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    
    [super viewDidDisappear:animated];
    [streamRender stopStream];
    
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
//    [UIApplication sharedApplication].statusBarHidden = NO;
    self.navigationController.navigationBarHidden = NO;
    if(kiOS7){
        
        [[UIDevice currentDevice] setValue: [NSNumber numberWithInteger: UIDeviceOrientationPortrait] forKey:@"orientation"];
        
    }
    NSNotification	*note = [NSNotification notificationWithName:KUIControllerIsSupportOrientionN object:nil userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:note];
    
   
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration  {

    
    streamRender.isScreenRotating = YES;
    
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    streamRender.isScreenRotating = NO;
    
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
        toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        
        [_adView removeFromSuperview];
        
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        
        self.upSpace.constant = 0;
    
        self.videoPlayerViewHeightSpace.constant = kiOS8?[UIScreen mainScreen].bounds.size.height:[UIScreen mainScreen].bounds.size.width;
        self.leftSpace.constant = 0;
        self.rightSpace.constant = 0;

        self.playerViewUpSpace.constant = -50;
        self.playerViewLeftSpace.constant = 15;
        self.playerViewRightSpace.constant = 15;
        

        //添加手势
        singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(SingleTap:)];
        //点击的次数
        singleRecognizer.numberOfTapsRequired = 1;
        [self.videoplayerVIew addGestureRecognizer:singleRecognizer];
        
        
        
        isFullScreen = YES;
    }
    else if (toInterfaceOrientation == UIInterfaceOrientationPortrait)
    {
        
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
        
        self.upSpace.constant                       = upSpaceConstrant;
        self.videoPlayerViewHeightSpace.constant    = videoPlayerHeightConstrant;
        self.leftSpace.constant                     = leftSpaceConstrant;
        self.rightSpace.constant                    = rightSpaceConstrant;
        
        self.playerViewUpSpace.constant = playerViewUpSpaceConstrant;
        self.playerViewLeftSpace.constant = playerViewLeftSpaceConstrant;
        self.playerViewRightSpace.constant = playerViewRightSpaceConstrant;
        
        
        [self.videoplayerVIew removeGestureRecognizer:singleRecognizer];
        

        
        if (isPause) {
            //play
            [self.playerBtn setImage:[UIImage imageNamed:@"full_play_btn_hl"] forState:UIControlStateNormal];
            
        }else{
            //pause
            [self.playerBtn setImage:[UIImage imageNamed:@"full_pause_btn_hl"] forState:UIControlStateNormal];
        }
        
        isFullScreen = NO;
        
        
        [self setplayViewFrame];
    }
    
    self.playerView.hidden = NO;
    
    if (isFullScreen) {
        
    
        if (self.Timer) {
        
            [self.Timer invalidate];
        }
        
      self.Timer =  [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(dismisplayerView) userInfo:nil repeats:NO];

    }
    else {
        
        if (self.Timer) {
        
            [self.Timer invalidate];
            
            self.Timer = nil;
        }
    
    }
    
    //full_minimize_btn_hl
    //mini_launchFullScreen_btn_hl
    [self.fullScreenBtn setImage:isFullScreen?[UIImage imageNamed:@"movie_play_button"]:[UIImage imageNamed:@"movie_play_button"] forState:UIControlStateNormal];
    
}
- (void)dismisplayerView{
    
    [UIView animateWithDuration:0.5 animations:^{
    
        if (isFullScreen) {
            
            self.playerView.hidden = YES;
            
            isTap = !isTap;
            
        }
        
        
    }];
    

}
- (void)SingleTap:(UITapGestureRecognizer *)tap{

    isTap = !isTap;
    [UIView animateWithDuration:0.5 animations:^{
        if (isTap) {
           
            self.playerView.hidden = YES;
            
        }else{
            
        
            self.playerView.hidden = NO;
            if (isFullScreen) {
                
            
                [self.Timer invalidate];
              
                self.Timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(dismisplayerView) userInfo:nil repeats:NO];
                
            }
        }
        }];
}
-(void)dealloc
{
    if (self.alert) {
        [self.alert dismissWithClickedButtonIndex:-1 animated:NO];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_Timer invalidate];
//    streamRender.delegate = nil;
    [streamRender stopStream];
}

- (void)sliderTouchDown:(id)sender {
    

}

- (void)sliderTouchCancel:(id)sender {
   
    isSliderMoving = NO;
}
- (IBAction)sliderValueChanged:(id)sender {
    
     
     [streamRender moveRecordStreamToTimePoint:self.timeSlider.value];
    
    isPause = NO;
    //pause
    [self.playerBtn setImage:[UIImage imageNamed:@"full_pause_btn_hl"] forState:UIControlStateNormal];
	
    self.loadingIndicator.hidden = NO;
    [self.loadingIndicator startAnimating];
    
	isSliderMoving = NO;

}

- (IBAction)pauseBtnClicked:(id)sender {
    isPause = !isPause;
    
    if (isPause) {
        //play
        [self.playerBtn setImage:[UIImage imageNamed:@"full_play_btn_hl"] forState:UIControlStateNormal];
        [streamRender pauseRecordStream];
        
        
        self. fullScreenPlayBtn.hidden = NO;
        
    }else{
        //pause
        [self.playerBtn setImage:[UIImage imageNamed:@"full_pause_btn_hl"] forState:UIControlStateNormal];
        [streamRender resumeRecordStream];
        
        self.fullScreenPlayBtn.hidden = YES;

    }

}

- (IBAction)fullScreenBtnClicked:(id)sender {
    
    
    if (isFullScreen) {
    
        [[UIDevice currentDevice] setValue: [NSNumber numberWithInteger: UIDeviceOrientationPortrait] forKey:@"orientation"];
   
    }else{
    
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait] forKey:@"orientation"];//防止横屏进入此界面后点击全屏无效
        [[UIDevice currentDevice] setValue: [NSNumber numberWithInteger: UIDeviceOrientationLandscapeLeft] forKey:@"orientation"];
    }
}



/**
 * 让当前控制器对应的状态栏是白色
 */
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end



