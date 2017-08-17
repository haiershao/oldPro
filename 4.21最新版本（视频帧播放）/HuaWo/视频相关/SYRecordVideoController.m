//
//  SYRecordVideoController.m
//  SYRecordVideoDemo
//
//  Created by leju_esf on 17/3/15.
//  Copyright © 2017年 yjc. All rights reserved.
//

#import "SYRecordVideoController.h"
#import "WCLRecordEngine.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <MediaPlayer/MediaPlayer.h>
#import "SYVideoModel.h"
#import <Photos/Photos.h>
#import "CDPVideoEditor.h"
#import "SYShareVideoModel.h"
#import "SYVideoMergeManager.h"
#import "MBProgressHUD.h"
#import "HWUserInstanceInfo.h"
#import "HWBandInfoController.h"
#import <CoreLocation/CoreLocation.h>
#import "CityInfo.h"

#import "MBProgressHUD+MG.h"
#import "AppDelegate.h"
@interface SYRecordVideoController ()<WCLRecordEngineDelegate,MBProgressHUDDelegate,CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *startBtn;
@property (weak, nonatomic) IBOutlet UISwitch *soundSwitch;
@property (strong, nonatomic) WCLRecordEngine *recordEngine;
@property (weak, nonatomic) IBOutlet UIView *shadowView;
@property (weak, nonatomic) IBOutlet UIButton *PlusBtn;

@property (weak, nonatomic) IBOutlet UIImageView *focusCursor;
@property (atomic, assign) CGFloat startRecordTime;
@property (atomic, assign) CGFloat endRecordTime;
@property (nonatomic, strong) NSMutableArray *sharePoints;
@property (nonatomic, strong) NSMutableArray *videoList;

@property(nonatomic,strong) CLLocationManager *locationManager;

@property (nonatomic,strong) CityInfo *cityModel;
@property (weak, nonatomic) IBOutlet UILabel *currentTimeLbl;
@property (nonatomic ,strong)NSTimer *timeNow;
@property (nonatomic ,assign)NSInteger count;
@property (nonatomic ,strong)NSArray *arr;
@property (weak, nonatomic) IBOutlet UILabel *advertiseLabel;
@property (weak, nonatomic) IBOutlet UIButton *reportBtn;

@end

@implementation SYRecordVideoController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self addGenstureRecognizer];
    [self.locationManager startUpdatingLocation];
    
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.locationManager startUpdatingLocation];
    AppDelegate * appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.allowRotation = NO;
    [MBProgressHUD showMessage:@"停止录制"];
    [MBProgressHUD hideHUD];
    [_timeNow invalidate];
    _timeNow = nil;
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.recordEngine shutdown];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // 开始录制
    [self.recordEngine startUp];
    [self.recordEngine startCapture];
    //设置横屏
    AppDelegate * appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.allowRotation = YES;
    [MBProgressHUD showMessage:@"开始录制"];
    [MBProgressHUD hideHUD];
    [self currentTimess];
    [self advertise];
    [self test2];
    [DZNotificationCenter addObserver:self selector:@selector(stopUploadVideo) name:@"DidEnterBackgroundSTOP"  object:nil];
    [DZNotificationCenter addObserver:self selector:@selector(startRecordVideo) name:@"DidBecomeActiveSTART"  object:nil];
   
}
- (void)advertise {
    HWUserInstanceInfo *InstanceInfo = [HWUserInstanceInfo shareUser];
    APIRequest *request = [[APIRequest alloc] initWithApiPath:@"/ControlCenter/v3/restapi/doaction" method:APIRequestMethodPost];
    request.urlQueryParameters = @{
                                   @"action":@"advertise_query",
                                   @"token":InstanceInfo.token
                                   };
    NSLog(@"request---%@",request);
    [[APIRequestOperationManager sharedRequestOperationManager] requestAPI:request completion:^(id result, NSError *error) {
        
        if (!error) {
            self.arr = result[@"data"];
        }else{
            [MBProgressHUD showError:@"获取广告语失败"];
        }
      
    }];
}

- (void)test2{
    [ [ UIApplication sharedApplication] setIdleTimerDisabled:YES ] ;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.shadowView.hidden = YES;
    self.PlusBtn.hidden = NO;
    
}
- (void)currentTimess {
    _timeNow = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(timerFunc) userInfo:nil repeats:YES];
    //获取系统时间
   // [self timerFunc];
    NSDate * senddate=[NSDate date];
    
    NSDateFormatter *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"HH:mm"];
    
    NSString * locationString=[dateformatter stringFromDate:senddate];
    
    NSLog(@"-------%@",locationString);
    
    //获取系统时间
    
    NSCalendar * cal=[NSCalendar currentCalendar];
    
    NSUInteger unitFlags=NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear;
    
    NSDateComponents * conponent= [cal components:unitFlags fromDate:senddate];
    
    NSInteger year=[conponent year];
    
    NSInteger month=[conponent month];
    
    NSInteger day=[conponent day];
    
    NSString * nsDateString= [NSString stringWithFormat:@"%4ld年%2ld月%2ld日",(long)year,(long)month,(long)day];
    
    NSLog(@"+++++++++++++%@",nsDateString);
   
}
- (void)timerFunc
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *timestamp = [formatter stringFromDate:[NSDate date]];
    [self.currentTimeLbl setText:timestamp];//时间在变化的语句
    NSLog(@"%@",timestamp);
    
        if (self.arr.count > 0) {
            //表示有广告
            if (_count%5 == 0) {
                NSInteger index = _count/5;
                NSString *adString = self.arr[index%self.arr.count];
                self.advertiseLabel.text = adString;
                NSLog(@"这就是要播的广告---%@",adString);
            }
            _count ++;
        }
}

// 两分钟保存一个视频
- (void)recordProgress:(CGFloat)progress {
    if (progress >= 1) {
        [self cutOutRecord];
        
    }
}
// 切换摄像头
- (IBAction)changeVido:(UIButton *)sender {
    sender.selected = !sender.selected;
    [self.recordEngine switchCamera];
}
// 切换声音
- (IBAction)switchVoice:(UIButton *)sender {
    sender.selected = !sender.selected;
    NSLog(@"当前录制时间-----%f",self.recordEngine.currentRecordTime);
    self.recordEngine.isSoundOff = !self.recordEngine.isSoundOff;
}
//截图
- (IBAction)screenshot:(UIButton *)sender {
    sender.selected = !sender.selected;
    [UIView animateWithDuration:1 animations:^{
        
    } completion:^(BOOL finished) {
        UIImage *image =  [self fetchScreenshot];
        UIImageWriteToSavedPhotosAlbum(image, self, nil, nil);
    }];
    
    
}

- (UIImage *)fetchScreenshot {
    UIImage *image = nil;
    if (self.view.layer) {
        CGSize imageSize = self.view.layer.bounds.size;
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, 1.0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        [self.view.layer renderInContext:context];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    return image;
}

- (IBAction)PlusBtn:(id)sender {
    
    self.shadowView.hidden = NO;
    self.PlusBtn.hidden = YES;
}


- (IBAction)backAction {
    
    __weak typeof(self) weakSelf = self;
    if (self.recordEngine.isCapturing) {
        [self.recordEngine stopCaptureHandler:^(CGFloat totalTime) {
            
            [weakSelf saveVideoWithTotalTime:totalTime];
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.recordEngine shutdown];
                [weakSelf dismissViewControllerAnimated:YES completion:nil];
            });
        }];
    }else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
- (void)stopUploadVideo {
    __weak typeof(self) weakSelf = self;
    if (self.recordEngine.isCapturing) {
        [self.recordEngine stopCaptureHandler:^(CGFloat totalTime) {
            
            [weakSelf saveVideoWithTotalTime:totalTime];
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.recordEngine shutdown];
                //[weakSelf dismissViewControllerAnimated:YES completion:nil];
            });
        }];
    }else {
       // [self dismissViewControllerAnimated:YES completion:nil];
    }

    HWLog(@"停止录制视频");
}
- (void)startRecordVideo{
    // 开始录制
    [self.recordEngine startUp];
    [self.recordEngine startCapture];
}
//抢拍分享
- (IBAction)startRecord:(UIButton *)sender {
    
    BOOL isShare = sender.tag == 1;
    
    if (!isShare) {
        self.reportBtn.selected = YES;
       
        [self examineReportState];
    }else{
        [MBProgressHUD showSuccess:@"开始分享"];
    }
    HWLog(@"%f",self.recordEngine.currentRecordTime);
    if (self.recordEngine.currentRecordTime < 7) {
        if (self.videoList.count > 0) {
            SYVideoModel *model = self.videoList.lastObject;
            SYShareVideoModel *shareModel = [[SYShareVideoModel alloc] init];
            shareModel.pointTime = self.recordEngine.currentRecordTime;
            shareModel.path1 = model.path;
            shareModel.path2 = self.recordEngine.videoPath;
            shareModel.isTowVideo = YES;
            shareModel.isShare = isShare;
            [self.sharePoints addObject:shareModel];
        }else {
            SYShareVideoModel *shareModel = [[SYShareVideoModel alloc] init];
            shareModel.pointTime = 0;
            shareModel.path1 = self.recordEngine.videoPath;
            shareModel.isTowVideo = NO;
            shareModel.isShare = isShare;
            [self.sharePoints addObject:shareModel];
        }
    }else if (self.recordEngine.currentRecordTime > 112){
        SYShareVideoModel *shareModel = [[SYShareVideoModel alloc] init];
        shareModel.pointTime = self.recordEngine.currentRecordTime;
        shareModel.path1 = self.recordEngine.videoPath;
        shareModel.path2 = nil;
        shareModel.isTowVideo = YES;
        shareModel.isShare = isShare;
        [self.sharePoints addObject:shareModel];
    }else {
        SYShareVideoModel *shareModel = [[SYShareVideoModel alloc] init];
        shareModel.pointTime = self.recordEngine.currentRecordTime;
        shareModel.path1 = self.recordEngine.videoPath;
        shareModel.isTowVideo = NO;
        shareModel.isShare = isShare;
        [self.sharePoints addObject:shareModel];
    }
    
    __block int timeout=8; //倒计时时间
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        if(timeout<=0){ //倒计时结束，关闭
            
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                if (!isShare){
                    sender.imageView.image = [UIImage imageNamed:@"举报"];
                }else{
                    sender.userInteractionEnabled = YES;
                    sender.alpha=1.0;
                }
               
                //sender.selected = NO;
                
                
            });
        }else{

            dispatch_async(dispatch_get_main_queue(), ^{
                //让按钮变为不可点击的灰色
                if (!isShare){
                    sender.imageView.image = [UIImage imageNamed:@"举报-"];
                }else{
                    sender.userInteractionEnabled = NO;
                    sender.alpha=0.4;
                }
               
                
                //设置界面的按钮显示 根据自己需求设置
                [UIView beginAnimations:nil context:nil];
                [UIView setAnimationDuration:1];
                
                [UIView commitAnimations];
            });
            timeout--;
        }
    });
    dispatch_resume(_timer);
    
}
- (void)examineReportState {
    __weak typeof(self) weakSelf = self;
    HWUserInstanceInfo *InstanceInfo = [HWUserInstanceInfo shareUser];
    NSDictionary *dict = @{
                           @"did":@""
                           };
    
    APIRequest *request = [[APIRequest alloc] initWithApiPath:@"/ControlCenter/v3/restapi/doaction" method:APIRequestMethodPost];
    request.urlQueryParameters = @{
                                   @"action":@"qry_devbind",
                                   @"para":dict,
                                   @"token":InstanceInfo.token
                                   };
    NSLog(@"request---%@",request);
    [[APIRequestOperationManager sharedRequestOperationManager] requestAPI:request completion:^(id result, NSError *error) {
        
        if (!result[@"data"]&&[result[@"result"]isEqualToString:@"1"])  {
            [MBProgressHUD showSuccess:@"请先绑定"];
            if (self.recordEngine.isCapturing) {
                [self.recordEngine stopCaptureHandler:^(CGFloat totalTime) {
                    
                    [weakSelf saveVideoWithTotalTime:totalTime];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.recordEngine shutdown];
                        [weakSelf dismissViewControllerAnimated:YES completion:nil];
                        [DZNotificationCenter postNotificationName:@"PushBandUI" object:nil];
                    });
                }];
            }else {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
            
        }
        
    }];
    
}

- (void)cutOutRecord {
    if (_recordEngine.videoPath.length > 0) {
        //self.startBtn.selected = NO;
        __weak typeof(self) weakSelf = self;
        [self.recordEngine stopCaptureHandler:^(CGFloat totalTime) {
            [weakSelf saveVideoWithTotalTime:totalTime];
            [weakSelf.recordEngine startUp];
            [weakSelf.recordEngine startCapture];
            NSLog(@"保存成功一条视频");
        }];
    }else {
        NSLog(@"请先录制视频~");
    }
}

- (void)saveVideoWithTotalTime:(CGFloat)totalTime {
    SYVideoModel *model = [[SYVideoModel alloc] init];
    model.path = _recordEngine.videoPath;
    model.totalTime = totalTime;
    model.type = SYVideoTypeNormal;
    [SYVideoModel saveVideo:model];
    [self.videoList addObject:model];
    _recordEngine.videoPath = nil;
    NSMutableArray *tempArray = [NSMutableArray array];
    for (SYShareVideoModel *sharemodel in self.sharePoints) {
        if (sharemodel.isTowVideo == NO || (sharemodel.isTowVideo == YES && sharemodel.path2 != nil)) {
            [[SYVideoMergeManager sharedManager] detailModel:sharemodel];
        }else {
            
            if (sharemodel.path2 == nil && sharemodel.path1 != model.path) {
                sharemodel.path2 = model.path;
                [[SYVideoMergeManager sharedManager] detailModel:sharemodel];
            }else {
                [tempArray addObject:sharemodel];
            }
        }
    }
    self.sharePoints = tempArray;
}

- (WCLRecordEngine *)recordEngine {
    if (_recordEngine == nil) {
        _recordEngine = [[WCLRecordEngine alloc] init];
        _recordEngine.delegate = self;
        _recordEngine.previewLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
        
        _recordEngine.previewLayer.frame = CGRectMake(0, 0, screenH, screenW);
        [self.view.layer insertSublayer:_recordEngine.previewLayer atIndex:0];
    }
    return _recordEngine;
}
/**
 *  添加点按手势，点按时聚焦
 */
-(void)addGenstureRecognizer{
    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapScreen1:)];
    [self.view addGestureRecognizer:tapGesture];
}
-(void)tapScreen1:(UITapGestureRecognizer *)tapGesture{
    CGPoint point= [tapGesture locationInView:self.view];
    //将UI坐标转化为摄像头坐标
    //CGPoint cameraPoint= [self.recordEngine.previewLayer captureDevicePointOfInterestForPoint:point];
    [self setFocusCursorWithPoint:point];
    [self.recordEngine setFocusCursorWithPoint:point];
    
}
-(void)setFocusCursorWithPoint:(CGPoint)point{
    self.focusCursor.center=point;
    self.focusCursor.transform=CGAffineTransformMakeScale(1.5, 1.5);
    self.focusCursor.alpha=1.0;
    [UIView animateWithDuration:1.0 animations:^{
        self.focusCursor.transform=CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        self.focusCursor.alpha=0;
        
    }];
}
-(BOOL)shouldAutorotate{
    return YES;
}
//支持的方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscapeRight;
}

- (NSMutableArray *)sharePoints {
    if (_sharePoints == nil) {
        _sharePoints = [[NSMutableArray alloc] init];
    }
    return _sharePoints;
}

- (NSMutableArray *)videoList {
    if (_videoList == nil) {
        _videoList = [[NSMutableArray alloc] init];
    }
    return _videoList;
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *currentLocation = [locations lastObject];
    HWLog(@"%f,%f",currentLocation.coordinate.latitude,currentLocation.coordinate.longitude);
    CLLocationDegrees ss = currentLocation.coordinate.latitude;
    
    //    self.latitudes =currentLocation.coordinate.latitude;
    CLLocationDegrees dd = currentLocation.coordinate.longitude;
    HWUserInstanceInfo *location = [HWUserInstanceInfo shareUser];
    location.longitude = dd;
    location.coordinate = ss;
    CLGeocoder *geocoder = [CLGeocoder new];
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        if (placemarks.count > 0) {
            CLPlacemark *placemark = placemarks[0];
            if (!placemark.locality) {
                HWLog(@"无法定位当前城市");
            }
            HWLog(@"-----------------%@",placemark.addressDictionary);
            CityInfo *ciyt = [CityInfo cityInfoDict:placemark.addressDictionary];
        }
        
    }];
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if ([error code] == kCLErrorDenied) {
        //无法定位
    } else if ([error code] == kCLErrorLocationUnknown) {
        //无法定位
    }
}

- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [CLLocationManager new];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.distanceFilter = 10;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.f) {
            [_locationManager requestWhenInUseAuthorization];
        }else {
        }
    }
    return _locationManager;
}
@end
