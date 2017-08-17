//
//  VideoViewController.m
//  HuaWo
//
//  Created by circlely on 1/22/16.
//  Copyright © 2016 circlely. All rights reserved.
//

#import "VideoViewController.h"
#import "StreamAVRender.h"
#import "AHCServerCommunicator.h"
#import "MBProgressHUD.h"
#import "AlbumManager.h"
#import "VideoItemCollectionViewCell.h"
#import "MemberData.h"
#import "AlbumController.h"
#import "SharePageViewController.h"
#import "HWImmediatelyShareController.h"
#import "CameraSettingsConfigData.h"

#define kLogoutWarningSheetTag       1000
#define kTunnelDisconnectedAlertTag  1001

@interface VideoViewController ()<UIAlertViewDelegate, AHCServerCommunicatorDelegate,UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, VideoItemCollectionViewCellDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *liveVideoView;
@property (weak, nonatomic) IBOutlet UIButton *voiceBtn;
@property (weak, nonatomic) IBOutlet UIButton *recordBtn;
@property (weak, nonatomic) IBOutlet UIButton *speakBtn;
@property (weak, nonatomic) IBOutlet UIImageView *waitingImage;
@property (weak, nonatomic) IBOutlet UILabel *waitingLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UICollectionView *VideoCollectionView;
@property (weak, nonatomic) IBOutlet UIButton *cutPicBtn;
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
@property (weak, nonatomic) IBOutlet UIButton *fullScreenButton;
@property (weak, nonatomic) IBOutlet UIView *recordVideoCollectionView;
@property (weak, nonatomic) IBOutlet UIView *actionView;
@property (weak, nonatomic) IBOutlet UIButton *fullScreenBackButton;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *livingVideoWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *livingVideoHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *livingVideoTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *actionViewHeightConstraint;//166

@property (nonatomic, strong) NSString *currentCIDNumber;
@property (nonatomic, strong) StreamAVRender *streamRender;
@property (nonatomic, strong) NSDate *TouchDownDate;
@property (nonatomic, strong) NSDate *TouchUpDate;
@property (nonatomic, strong) NSMutableArray *videoIconList;
@property (nonatomic, strong) NSTimer *recordVideoTimer;
@property (nonatomic, weak) SharePageViewController *shareVc;
@property (strong, nonatomic) CameraSettingsConfigData *configData;
@end

@implementation VideoViewController
{
    BOOL isRecievingAudio;
    BOOL isRecordingVideo;
    int _timerCount;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = NO;
    
    
    isRecievingAudio = NO;
    isRecordingVideo = NO;
//    self.timerLabel.hidden = YES;
    self.timerLabel.text = NSLocalizedString(@"snap_video_text", nil);
    self.view.backgroundColor = kBackgroundColor;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 44)];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = [[MemberData memberData] getAvsNameOfCID:self.currentCIDNumber];
    self.navigationItem.titleView = titleLabel;

    self.configData = [CameraSettingsConfigData shareConfigData];
    
    //监听APP切入后台的通知，用于资源清理，在下一次APP拉起时，界面会回到CID LIST 界面
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    self.streamRender = [self onCreateStreamRenderForCID:self.currentCIDNumber];
    [self.VideoCollectionView registerNib:[UINib nibWithNibName:@"VideoItemCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"collectioncell"];
    
    self.videoIconList = [self getVideoList];
    
    [self addLeftNavBarBtn];
    [self addRightNavBarBtn];
    if (kiPhone4) {
        
        self.actionViewHeightConstraint.constant = 166-88;
    }
    
    
}


- (NSMutableArray *)getVideoList {
    
    NSMutableArray *videoList = [[NSMutableArray alloc] initWithCapacity:42];
    
    NSMutableArray *videoListTmp = [AlbumManager shareAlbumManager].AlbumItemList;
    
    for (AlbumInfo *info in videoListTmp) {
        NSString *str = [[[[info.fileName componentsSeparatedByString:@"_"] lastObject] componentsSeparatedByString:@"."] firstObject];
        
        if (![info.iconPath isEqualToString:kNULL]  && [str isEqualToString:self.currentCIDNumber]) {
            
            [videoList addObject:info];
        }
        
    }
    
    
    return videoList;
    
    
}

- (void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    if (_streamRender) {
        
        self.voiceBtn.enabled  = NO;
        self.speakBtn.enabled  = NO;
        self.recordBtn.enabled = NO;
        self.cutPicBtn.enabled = NO;
        __typeof (self) __weak safeSelf = self;
        
        
        [_streamRender startStreamOnStreamChannelCreated:^{
            
            [safeSelf.streamRender activateVoice];
            
        } FirstVideoFrameShow:^{
            
            [safeSelf.streamRender setBackgroundColor:kColor(170, 170, 170, 1)];
 //           [safeSelf.streamRender startMute];
            [safeSelf setVoiceBtnStateIsReviving:isRecievingAudio];
            
            safeSelf.activityIndicator.hidden = YES;
            safeSelf.waitingImage.hidden = YES;
            safeSelf.waitingLabel.hidden = YES;
            safeSelf.voiceBtn.enabled  = YES;
            safeSelf.speakBtn.enabled  = YES;
            safeSelf.recordBtn.enabled = YES;
            safeSelf.cutPicBtn.enabled = YES;

            
        } PlayEnded:^(NSError *error) {
            
            if ([KErrorStreamParam isEqualToString:error.domain]) {
                
                safeSelf.activityIndicator.hidden = YES;
                safeSelf.waitingImage.hidden = YES;
                safeSelf.waitingLabel.hidden = YES;
                safeSelf.voiceBtn.enabled = YES;
                safeSelf.speakBtn.enabled = YES;
                safeSelf.cutPicBtn.enabled = YES;
                [safeSelf.streamRender setBackgroundColor:kColor(170, 170, 170, 1)];
                
            }
            
        }];
    }
    

    
}


- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
    //[[RDVTabBarController shareTabBar] setTabBarHidden:NO animated:NO];
//    [UIApplication sharedApplication].statusBarHidden = NO;
    
    self.fullScreenBackButton.hidden = YES;
    
    self.videoIconList = [self getVideoList];

    [self.VideoCollectionView reloadData];
    NSNotification	*note = [NSNotification notificationWithName:KUIControllerIsSupportOrientionY object:nil userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:note];
    
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    
    [_streamRender stopStream];
    
    [super viewWillDisappear:animated];
    
    NSNotification	*note = [NSNotification notificationWithName:KUIControllerIsSupportOrientionN object:nil userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:note];
    
    self.fullScreenBackButton.hidden = YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        
        self.navigationController.navigationBarHidden = YES;
        
        self.streamRender.isScreenRotating = YES;
        [self.streamRender setBackgroundColor:kColor(0, 0, 0, 1)];
        
        self.recordVideoCollectionView.hidden = YES;
        self.actionView.hidden = YES;
        self.cutPicBtn.hidden = YES;
        self.fullScreenBackButton.hidden = NO;
        self.fullScreenButton.hidden = YES;
        
        self.livingVideoHeightConstraint.constant = 320;
        self.livingVideoWidthConstraint.constant = 420;
        
        self.livingVideoTopConstraint.constant = 0;
        
    }else {
        
        self.navigationController.navigationBarHidden = NO;
        
        self.streamRender.isScreenRotating = NO;
        [self.streamRender setBackgroundColor:kColor(170, 170, 170, 1)];
        
        self.livingVideoHeightConstraint.constant = screenH;
        self.livingVideoWidthConstraint.constant = screenW;
        
        self.livingVideoTopConstraint.constant = 64;
        
        
        self.recordVideoCollectionView.hidden = NO;
        self.actionView.hidden = NO;
        self.fullScreenButton.hidden = NO;
        self.cutPicBtn.hidden = NO;
        
        self.fullScreenBackButton.hidden = YES;

        
    }
    
    
}


- (void)applicationDidEnterBackground {
    
    if (_streamRender.isStreamRecording) {
        
        __typeof(self) __weak safeSelf = self;
        
        [_streamRender saveRecordVideoToLocalWithCompletionBlock:^{
            
            safeSelf.videoIconList = [safeSelf getVideoList];
            
            [safeSelf.VideoCollectionView reloadData];
            
        } failureBlock:^(NSError *error) {
            
        }];
        
        
    }
    
    
    
    //停止RTSP通道
    [_streamRender stopStream];
    [[AHCServerCommunicator sharedAHCServerCommunicator] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)dealloc{
    
    [_streamRender stopStream];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}


- (id)initWithNibName:(NSString *)nibNameOrNil CIDNumber:(NSString *)CIDNumber{
    
    self = [super initWithNibName:nibNameOrNil bundle:nil];
    if (self) {
        self.currentCIDNumber = CIDNumber;
        [[AHCServerCommunicator sharedAHCServerCommunicator] addObserver:self forCID:CIDNumber];
        
    }
    
    return self;
    
}

-(void)addLeftNavBarBtn
{
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"title_back_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonItemAction)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
}

- (void)addRightNavBarBtn {
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"videorecord_icon_pic"] style:UIBarButtonItemStylePlain target:self action:@selector(onRightNavBarBtnPressed)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
}


- (void)onRightNavBarBtnPressed {
    
    [[RDVTabBarController shareTabBar] setTabBarHidden:YES animated:NO];
    AlbumController *album = [[AlbumController alloc] initWithNibName:@"AlbumController" bundle:nil];
    [self.navigationController pushViewController:album animated:YES];

}


- (void)leftBarButtonItemAction {
    
    [self logoutServer];
    
}

- (void)logoutServer{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title", nil)
                                                    message:NSLocalizedString(@"warnning_quit_connection", nil)
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"cancel_btn", nil)
                                          otherButtonTitles:NSLocalizedString(@"ok_btn", nil), nil];

    
    alert.tag = kLogoutWarningSheetTag;
    [alert show];

}


- (IBAction)fullScreenBackButtonPressed:(id)sender {
    
    self.navigationController.navigationBarHidden = NO;
    
    self.streamRender.isScreenRotating = NO;
    [self.streamRender setBackgroundColor:kColor(170, 170, 170, 1)];
    
    self.livingVideoHeightConstraint.constant = 240;
    self.livingVideoWidthConstraint.constant = 320;
    
    self.livingVideoTopConstraint.constant = 64;
    
    
    self.recordVideoCollectionView.hidden = NO;
    self.actionView.hidden = NO;
    self.fullScreenButton.hidden = NO;
    self.cutPicBtn.hidden = NO;
    
    self.fullScreenBackButton.hidden = YES;
    
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait] forKey:@"orientation"];
    
    
    
}

- (IBAction)fullScreenPressed:(id)sender {

    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait] forKey:@"orientation"];//防止横屏进入此界面后点击全屏无效
    
    [[UIDevice currentDevice] setValue: [NSNumber numberWithInteger: UIDeviceOrientationLandscapeLeft] forKey:@"orientation"];
    
    
    self.navigationController.navigationBarHidden = YES;

    self.streamRender.isScreenRotating = YES;
    [self.streamRender setBackgroundColor:kColor(0, 0, 0, 1)];
   
    self.recordVideoCollectionView.hidden = YES;
    self.actionView.hidden = YES;
    self.cutPicBtn.hidden = YES;
    self.fullScreenBackButton.hidden = NO;
    self.fullScreenButton.hidden = YES;
     
    self.livingVideoHeightConstraint.constant = 320;
    self.livingVideoWidthConstraint.constant = 420;
    
    self.livingVideoTopConstraint.constant = 0;
    
    self.liveVideoView.frame = self.view.bounds;
    NSLog(@"self.liveVideoView.frame:%@",NSStringFromCGRect(self.liveVideoView.frame));

}

- (void)actionLogout{

    if (_streamRender.isStreamRecording) {
        
        __typeof(self) __weak safeSelf = self;
        
        [_streamRender saveRecordVideoToLocalWithCompletionBlock:^{
            
            safeSelf.videoIconList = [safeSelf getVideoList];
            
            [safeSelf.VideoCollectionView reloadData];
            
        } failureBlock:^(NSError *error) {
            
        }];
        
        
    }

    
    //退出的时候需要将所有连接断掉
    [[AHCServerCommunicator sharedAHCServerCommunicator] removeObserver:self];
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}

- (void)checkPressedButtonTime{
    
    NSTimeInterval time = [_TouchDownDate timeIntervalSinceDate:_TouchUpDate];
    
    if (fabs((double)time) < clippingTime) {
        MBProgressHUD* HUD = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow
                                                  animated:YES configBlock:^(MBProgressHUD *HUD) {
                                                      HUD.mode = MBProgressHUDModeCustomView;
                                                      HUD.detailsLabelText = NSLocalizedString(@"warning_hold_to_talk_period_too_short", nil);
                                                      HUD.removeFromSuperViewOnHide = YES;
                                                      UIImage *image = [UIImage imageNamed:@"warning.png"];
                                                      HUD.customView = [[UIImageView alloc] initWithImage:image];
                                                  }];
        
        [HUD hide:YES afterDelay:1.0];
        
    }
    
    self.TouchDownDate = nil;
    self.TouchUpDate   = nil;
 
}

#pragma mark VideoViewTabBar

//是否静音
- (IBAction)onVoiceBtnClicked:(id)sender {
    
    isRecievingAudio = !isRecievingAudio;
    [self setVoiceBtnStateIsReviving:isRecievingAudio];
    
}

- (void)setVoiceBtnStateIsReviving:(BOOL)isReciving{
    
    NSString *btnImageName = isReciving ? @"videorecord_icon_speaker" : @"videorecord_icon_mute";
    NSString *btnPressedImageName = isReciving ? @"videorecord_icon_speaker_press":@"videorecord_icon_mute_press";
    [self.voiceBtn setImage:[UIImage imageNamed:btnImageName] forState:UIControlStateNormal];
    
    [self.voiceBtn setImage:[UIImage imageNamed:btnPressedImageName] forState:UIControlStateHighlighted];
    
    
    if (isReciving) {
        [_streamRender stopMute];
    }else{
        [_streamRender startMute];
    }
}

//是否录制
- (IBAction)onRecordBtnClicked:(id)sender {
#warning  继续进行定位
/*
 
 采集端返回的指令：
 String context = "{\"msgname\":\"getLocationRsp\",\"requestId\":\""+requestId+"\",\"param\":{\"address\":\""+address+"\"}}";
 
 String context = "{\"msgname\":\"getLocationReq\",\"requestId\":\""
 + requestId + "\"}";
 
 */
    
    HWLog(@"---------------------------------------------------");
    
    isRecordingVideo = !isRecordingVideo;
    
    if (!isRecordingVideo) {
        return;
    }

    NSString *filePath = [[AlbumManager shareAlbumManager] createRecordLocationPathForVideo:YES];
    if ([_streamRender startRecordToLocalAlbum:filePath]) {
        
        [_streamRender forceIFrame];
        
    }
    
    
        
    [self timerFire];
    
    //获取定位信息
    [self getUserLocation:filePath];
}

- (void)getUserLocation:(NSString *)filePath{
    
    NSString *recordDir = [filePath componentsSeparatedByString:@"/"].lastObject;

    recordDir = [NSString stringWithFormat:@"%@_%@.text",recordDir,self.currentCIDNumber];
    filePath = [filePath stringByAppendingPathComponent:recordDir];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES configBlock:^(MBProgressHUD *HUD) {
        
    }];
    
    
}

- (void)timerFire {
    
    _timerCount = 15;
    
    self.timerLabel.hidden = NO;
    
    self.recordBtn.enabled = NO;
    
    self.timerLabel.text = [NSString stringWithFormat:@"%i", _timerCount];
    
    self.recordVideoTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerCallBack) userInfo:nil repeats:YES];
    
}

- (void)timerCallBack {
    
    _timerCount--;
    
    self.timerLabel.text = [NSString stringWithFormat:@"%i", _timerCount];
    
    if (_timerCount < 12) {
       
        self.recordBtn.enabled = YES;
    }
    
    if (!isRecordingVideo || _timerCount < 0) {
        
        //self.timerLabel.hidden = YES;
        self.timerLabel.text = NSLocalizedString(@"snap_video_text", nil);
        
        self.recordBtn.enabled = YES;
        
        isRecordingVideo = NO;
        
        [self.recordVideoTimer invalidate];
        self.recordVideoTimer = nil;
        
        __typeof(self) __weak safeSelf = self;
        
        [_streamRender saveRecordVideoToLocalWithCompletionBlock:^{
            
            safeSelf.videoIconList = [safeSelf getVideoList];
            
            [safeSelf.VideoCollectionView reloadData];
            
        } failureBlock:^(NSError *error) {
            
            APP_LOG_ERR(@"save record video error[%@]",error);
            
        }];

    }
}

//是否对讲
- (IBAction)onMicphoneTouchDown:(id)sender {// 按下
    
    [self setMicphoneBtnStateIsSending:YES];
    self.TouchDownDate = [NSDate date];
    
}
- (IBAction)onMicphoneTouchUp:(id)sender {// 弹起
    
    self.TouchUpDate = [NSDate date];
    
    [self checkPressedButtonTime];
    [self setMicphoneBtnStateIsSending:NO];
    
}

- (void)setMicphoneBtnStateIsSending:(BOOL)isSending {

    if (isSending) {
        [_streamRender startTalk];
    
        [_streamRender startMute];
        [self setVoiceBtnStateIsReviving:NO];
        
    }else{
        [_streamRender stopTalk];
        
        [self setVoiceBtnStateIsReviving:isRecievingAudio];
    }
    
}

//截图
- (IBAction)cutPictureBtnClicked:(id)sender {
    
    NSString *filePath = [[AlbumManager shareAlbumManager] createRecordLocationPathForVideo:NO];
    UIImage *cutImage = [_streamRender caputreVideoImage];
    
    [_streamRender saveImage:cutImage ToLocal:filePath WithCompletionBlock:^{
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES configBlock:^(MBProgressHUD *HUD) {
            HUD.mode = MBProgressHUDModeText;
            HUD.removeFromSuperViewOnHide = YES;
            HUD.detailsLabelText = NSLocalizedString(@"warnning_save_successfully", nil);
            [HUD hide:YES afterDelay:2];
        }];

    } failureBlock:^(NSError *error) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES configBlock:^(MBProgressHUD *HUD) {
            HUD.mode = MBProgressHUDModeText;
            HUD.removeFromSuperViewOnHide = YES;
            HUD.detailsLabelText = NSLocalizedString(@"warnning_save_photo_failed", nil);
            [HUD hide:YES afterDelay:2];
        }];

    }];
    
}

-(StreamAVRender*)onCreateStreamRenderForCID:(NSString*)CIDNumber
{
    return [[StreamAVRender alloc] initRealTimeStreamWithCID:[CIDNumber longLongValue] CameraIndex:0 StreamIndex:0 TargetView:self.liveVideoView];
}

#pragma mark - AHCServerCommunicatorDelegate
//-(void) onRecieveStreamerStateChanged:(NSString*)peerCID withState:(STREAMER_CONN_STATE)state {
//    
//    
//    if ([peerCID isEqualToString:_currentCIDNumber] && state != STREAMER_CONN_STATE_CONNECTED) {
//        
//        [[AHCServerCommunicator sharedAHCServerCommunicator] removeObserver:self];
//        
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title", nil)
//                                                        message:[NSString stringWithFormat:NSLocalizedString(@"warnning_tunnel_disconnected", nil), state]
//                                                       delegate:self
//                                              cancelButtonTitle:nil
//                                              otherButtonTitles:NSLocalizedString(@"ok_btn", nil), nil];
//        alert.tag = kTunnelDisconnectedAlertTag;
//        
//        [alert show];
//
//    }
//    
//}

#pragma mark UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag == kLogoutWarningSheetTag){
        if (buttonIndex == 1){
            
            [self actionLogout];
            
        }
    }
    
//    if (alertView.tag == kTunnelDisconnectedAlertTag) {
//        if (buttonIndex == 0) {
//            
//            [self actionLogout];
//        }
//    }

    
}

#pragma mark CollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    if (self.videoIconList.count < 8) {
        return self.videoIconList.count;
    }
    
    return 8;
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    
    VideoItemCollectionViewCell *cell =[collectionView dequeueReusableCellWithReuseIdentifier:@"collectioncell" forIndexPath:indexPath];
      
    
    AlbumInfo *itemInfo = self.videoIconList[indexPath.row];
    
    cell.videoItemImageView.image = [UIImage imageWithContentsOfFile:itemInfo.iconPath];
    //20160315152714
    
    cell.dateLabel.text = [NSString stringWithFormat:@"%@-%@-%@ %@:%@:%@",
                           [itemInfo.fileName substringWithRange:NSMakeRange(0, 4)],
                           [itemInfo.fileName substringWithRange:NSMakeRange(4, 2)],
                           [itemInfo.fileName substringWithRange:NSMakeRange(6, 2)],
                           [itemInfo.fileName substringWithRange:NSMakeRange(8, 2)],
                           [itemInfo.fileName substringWithRange:NSMakeRange(10, 2)],
                           [itemInfo.fileName substringWithRange:NSMakeRange(12, 2)]];
    
    //
    cell.imagePath = itemInfo.iconPath;
    cell.videoPath = itemInfo.fullPath;
    cell.locationPath = cell.videoPath;
    cell.cidNum = self.currentCIDNumber;
    return cell;
    
    
}

/**
 * 让当前控制器对应的状态栏是白色
 */
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
@end
