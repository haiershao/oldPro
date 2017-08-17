//
//  HWCameraRecorderViewController.m
//  HuaWo
//
//  Created by hwawo on 17/2/20.
//  Copyright © 2017年 HW. All rights reserved.
//

#import "HWCameraRecorderViewController.h"
#import "include/iosRecordSdk/RecordInterface.h"
#import <AWSS3/AWSS3.h>
#import <AWSCore/AWSCore.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <CustomPhotoAlbum/ALAssetsLibrary+CustomPhotoAlbum.h>
#import "MapAnnotation.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "MJExtension.h"
#import "Reachability.h"
#import "MBProgressHUD.h"

#define KCachesPath [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]

#define kBucketName @"huawo"
@interface HWCameraRecorderViewController () <RecordInterfaceDelegate, MKMapViewDelegate,CLLocationManagerDelegate> {

    DevicePosition _devicePosition;
    AVCaptureVideoPreviewLayer* _previewLayer;
    NSInteger _videoCount;
    BOOL _isSnap;
}
@property (weak, nonatomic) IBOutlet UIImageView *shuiyingImageView;
@property (weak, nonatomic) IBOutlet UIButton *shequBtn;
@property (weak, nonatomic) IBOutlet UIButton *luzhiBtn;
@property (weak, nonatomic) IBOutlet UIButton *snapBtn;
@property (weak, nonatomic) IBOutlet UIView *setView;
@property (weak, nonatomic) IBOutlet UIButton *reportBtn;
@property (weak, nonatomic) IBOutlet UILabel *qianmingLabel;
@property (weak, nonatomic) UIView *leftView;

@property (weak, nonatomic) IBOutlet UILabel *timeTipLabel;
@property (nonatomic,strong) NSMutableArray *groupArrays;
@property (nonatomic,strong) ALAssetsLibrary *assetLibrary;
@property (weak, nonatomic) IBOutlet UILabel *alertLabel;

@property (copy, nonatomic) NSString *currentDateStr;
@property (nonatomic,strong) CLLocation *userLocation;
@property(nonatomic,strong) CLLocationManager *mgr;
@property (nonatomic, strong) CLGeocoder *coder;
@property (weak, nonatomic) IBOutlet MKMapView *mkMapView;

@property (copy, nonatomic) NSString *videoKey;
@property (copy, nonatomic) NSString *imageKey;
@property (copy, nonatomic) NSString *uuidStr;
@property (copy, nonatomic) NSString *nickname;
@property (strong, nonatomic) UIAlertView *alertWiFi;
@property (strong, nonatomic) NSDictionary *codeDict;
@property (copy, nonatomic) NSString *fullPath;
@property (strong, nonatomic) MBProgressHUD *hud;
@property (copy, nonatomic) NSString *strVideoPath;
@property (copy, nonatomic) NSString *imagePath;
@end

@implementation HWCameraRecorderViewController

- (CLGeocoder *)coder{
    
    if (!_coder) {
        _coder = [[CLGeocoder alloc] init];
    }
    return _coder;
}

- (NSMutableArray *)groupArrays{
    
    if (!_groupArrays) {
        _groupArrays = [NSMutableArray array];
    }
    return _groupArrays;
}

- (ALAssetsLibrary *)assetLibrary{

    if (!_assetLibrary) {

        _assetLibrary = [[ALAssetsLibrary alloc] init];

    }
    return _assetLibrary;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _isSnap = NO;
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(getNowtime) userInfo:nil repeats:YES];
    
    self.mkMapView.hidden = YES;
    _devicePosition = DevicePositionBack;
    [self setUpRecorderView:_devicePosition];
    
    [self setUpLeftView];
    
    [self getDeviceNickName];
    
    [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(leftBattery) userInfo:nil repeats:YES];
}

- (void)leftBattery{

    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        self.leftView.transform = CGAffineTransformMakeTranslation(screenW, 0);
        
    } completion:nil];
}


- (void)getNowtime{

    self.timeTipLabel.text = [self timeOfNow];
    
}

//自动注册
- (void)getDeviceNickName{
    self.alertWiFi = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title", nil) message:@"" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    if (![self isConnectionAvailable]) {
        
        self.alertWiFi.title = @"❌";
        self.alertWiFi.message = @"当前无网络...";
        self.alertLabel.text = @"当前无网络...";
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.alertLabel.hidden = YES;
        });
        
        //        [self.alertWiFi show];
        return ;
    }
    //    NSString *identifierForVendor = [[UIDevice currentDevice].identifierForVendor UUIDString];
    //http://112.124.22.101:38080/illegalreport/restapi/cidbinduser
    //    NSString *identityno = self.identityCardText;
    //    NSString *name = self.userRealNameText;
    //    NSString *phonenumber = self.plateNumberText;
    //    NSString *licenseno = self.emailAddressText;
    //    NSString *email = self.zhifuAccountText;
    
    NSString *urlStr = [NSString stringWithFormat:@"http://112.124.22.101:8190/user/registerDeviceInfo?deviceid=%@",identifierForVendor];
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    // 2. 请求
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:1 timeoutInterval:2.0f];
    
    // 3. 连接
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        if (!connectionError) {
            // 反序列化
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            
            NSLog(@"result---%@--%@", result,result[@"desc"]);
            NSString *str0 = [NSString stringWithFormat:@"%@",result[@"desc"]];
            if ([str0 isEqualToString:@"success"]) {
                
                self.nickname = result[@"nickname"];
            }else {
                
                HWLog(@"===================");
            }
        }
        
    }];
}

-(BOOL)isConnectionAvailable{
    
    BOOL isExistenceNetwork = YES;
    Reachability *reach = [Reachability reachabilityWithHostname:@"www.apple.com"];
    switch ([reach currentReachabilityStatus]) {
        case NotReachable:
            isExistenceNetwork = NO;
            //HWLog(@"notReachable");
            break;
        case ReachableViaWiFi:
            isExistenceNetwork = YES;
            //HWLog(@"WIFI");
            break;
        case ReachableViaWWAN:
            isExistenceNetwork = NO;
            //HWLog(@"3G");
            break;
    }
    
    if (!isExistenceNetwork) {
        //<span style="font-family: Arial, Helvetica, sans-serif;">MBProgressHUD为第三方库，不需要可以省略或使用AlertView</span>
        //        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES configBlock:nil];
        //        hud.removeFromSuperViewOnHide =YES;
        //        hud.mode = MBProgressHUDModeText;
        //        hud.labelText = @"当前网络不可用，请检查网络连接";  //提示的内容
        //        hud.minSize = CGSizeMake(132.f, 108.0f);
        //        [hud hide:YES afterDelay:3];
        return NO;
    }
    
    return isExistenceNetwork;
}

- (void)setUpLeftView{
    
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(-screenH, 0, screenH, screenW)];
    leftView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:leftView];
    [self.view bringSubviewToFront:leftView];
    self.leftView = leftView;
    
    [leftView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(leftDian)]];
    
}

- (void)leftDian{
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        self.leftView.transform = CGAffineTransformIdentity;
        
    } completion:nil];
}


+ (instancetype)cameraRecorderViewController{
    
    return [[HWCameraRecorderViewController alloc] initWithNibName:@"HWCameraRecorderViewController" bundle:nil];
}

- (NSUInteger)supportedInterfaceOrientations

{
    
    return UIInterfaceOrientationMaskLandscapeRight;
    
}

- (BOOL)shouldAutorotate

{
    
    return YES;
    
}

- (void)setUpRecorderView:(DevicePosition)devicePosition{

    [[RecordInterface instance] initSDK];
    [RecordInterface instance].delegate = self;
    [RecordInterface instance].advanceTime = 1;
    [RecordInterface instance].fileTime = 15;
    [RecordInterface instance].normalFileTime = 60;
    [RecordInterface instance].memorySize = 500;// MB
    [RecordInterface instance].sessionPreset = AVCaptureSessionPreset640x480;
    [RecordInterface instance].quickAlbumName = @"行车秀秀";
    
    __weak typeof(self) weakself = self;
    [[RecordInterface instance]startPreview:nil devicePosition:devicePosition completeHandler:^(AVCaptureSession* avcapturess){
        
        // block外不要修改 AVCaptureSession
        //
        _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:avcapturess];
        _previewLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        _previewLayer.frame = CGRectMake(0, 0, 0.8*screenH, screenW);
        
        _previewLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
        [_previewLayer setAffineTransform:CGAffineTransformMakeScale(1.6,1.7)];
        [weakself.view.layer addSublayer:_previewLayer];
        
        [weakself.view bringSubviewToFront:weakself.shuiyingImageView];
        [weakself.view bringSubviewToFront:weakself.shequBtn];
        [weakself.view bringSubviewToFront:weakself.luzhiBtn];
        [weakself.view bringSubviewToFront:weakself.snapBtn];
        [weakself.view bringSubviewToFront:weakself.setView];
        [weakself.view bringSubviewToFront:weakself.timeTipLabel];
        [weakself.view bringSubviewToFront:weakself.qianmingLabel];
        [weakself.view bringSubviewToFront:weakself.mkMapView];
        [weakself.view bringSubviewToFront:weakself.alertLabel];
        [weakself.view bringSubviewToFront:weakself.reportBtn];
        
        [weakself location];
    }];
}
- (IBAction)shequBtnClick:(UIButton *)sender {
    [DZNotificationCenter postNotificationName:@"HWCameraRecorderViewControllerToCameraVc" object:self];
}
- (IBAction)recordingBtnClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    
    if (sender.selected) {
        NSLog(@"recordingBtnClick startRecord");
        [[RecordInterface instance] startRecord];
    }else{
    
        [[RecordInterface instance] stopRecord];
        NSLog(@"recordingBtnClick stopRecord");
    }

}

- (void)s3ConfigParams{
    
    AWSStaticCredentialsProvider *credentialsProvider = [[AWSStaticCredentialsProvider alloc] initWithAccessKey:@"AKIAOVUGNAXFVVE5IALQ" secretKey:@"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"];
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionCNNorth1 credentialsProvider:credentialsProvider];
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
}

- (IBAction)snapBtnClick:(UIButton *)sender {
    _isSnap = YES;
    self.snapBtn.selected = YES;
    self.reportBtn.userInteractionEnabled = NO;
    self.snapBtn.userInteractionEnabled = YES;
    HWLog(@"snapBtnClick");
//    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES configBlock:^(MBProgressHUD *HUD) {
//        HUD.removeFromSuperViewOnHide = YES;
//    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"%@", [NSDate date]);
        [[RecordInterface instance] quickRecord];
    });

}

- (void)fileWillAddToAlbum:(NSString *)filePath{
    HWLog(@"－－－－fileWillAddToAlbum%@",filePath);
    __weak __typeof(self)weakSelf = self;
    
    [self.assetLibrary loadAssetsForProperty:@"ALAssetPropertyAssetURL" fromAlbum:@"行车秀秀" completion:^(NSMutableArray *array, NSError *error) {
        HWLog(@"----------------来了------------------");
        if (error) {
            HWLog(@"视频地址获取失败%@",error);
        }else{
            
            HWLog(@"视频地址获取:%@",array);
            
            
            UIImage *image = [weakSelf.assetLibrary thumbnailImageForVideo:[array lastObject] atTime:0];
            HWLog(@"image--%@",image);
            

            [self saveSnapeVideoImage:image];
            [self uploadVideo:filePath imagePath:self.imagePath];
//            self.imagePath = imagePath;
//            NSURL *path = [array lastObject];
//            [self videoWithUrl:path withFileName:[NSString stringWithFormat:@"%@",[self uuidStr]]];
            
//            [self upLoadImage:imagePath];
        }
    }];
    
}

- (NSString *)createSnapVideoImagePath{

    NSString *dirName = @"snapImage";
    NSString *snapImagePath = [NSString stringWithFormat:@"%@/Documents/%@", NSHomeDirectory(), dirName];
    
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:snapImagePath isDirectory:&isDir];
    if (!(isDir == YES && existed == YES) )
    {
        [fileManager createDirectoryAtPath:snapImagePath withIntermediateDirectories:YES attributes:nil error:nil];
    }else{
    
        HWLog(@"-----------创建的文件夹已存在-----------");
    }
    
    return snapImagePath;
}

- (void)saveSnapeVideoImage:(UIImage *)image{
    
    HWLog(@"-------------saveUserIconImage------------%@",image);
    
    
    
    NSData *imageData2 = UIImagePNGRepresentation(image);
//    //    NSLog(@"--imageData---%u",[imageData2 length]/1024);
//    //    NSString *imageName = [NSString stringWithFormat:@"%@.png",kUid];
//    // 获取沙盒目录
//    NSDate *currentDate = [NSDate date];
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
//    NSString *currentDateStr = [dateFormatter stringFromDate:currentDate];
//    HWLog(@"====================== %@",currentDateStr);
////    NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[NSString stringWithFormat:@"reportVideo%@.png",[self timeOfNowQuhuaxian]]];
//    //    NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:iconImageName];
//    //    self.userIconImage = [UIImage imageWithContentsOfFile:ullPath];
//    self.fullPath = fullPath;
    // 将图片写入文件
    self.imagePath = [[self createSnapVideoImagePath] stringByAppendingFormat:@"reportVideo%@.png",[self timeOfNowQuhuaxian]];
    if ([imageData2 writeToFile:self.imagePath atomically:NO]) {
        
        HWLog(@"--------------写入OK");
    }else{
        
        HWLog(@"--------------写入失败");
    }
//    NSString *ullPath =[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[NSString stringWithFormat:@"reportVideo%@.png",currentDateStr]];
//    UIImage *image0 = [UIImage imageWithContentsOfFile:ullPath];

}

- (void)upLoadImage:(NSString *)imagePath{
    
    [self s3ConfigParams];
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *currentDateStr = [dateFormatter stringFromDate:currentDate];
    HWLog(@"====================== %@",currentDateStr);
    
    NSString *uuidString = [HWCameraRecorderViewController uuidString];
    uuidString = [uuidString stringByReplacingOccurrencesOfString:@"-" withString:@""];
    self.uuidStr = uuidString;
    
    self.imageKey = [NSString stringWithFormat:@"illegal_video/thumb/%@/%@.png",currentDateStr,uuidString];
    
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    
    //设置uploadrequest
    AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
    uploadRequest.bucket = kBucketName;
    uploadRequest.key = self.imageKey;
    NSURL *url = [NSURL fileURLWithPath:self.imagePath];
    
    uploadRequest.body = url;
    
    [[transferManager upload:uploadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor] withBlock:^id(AWSTask*task) {
        if (task.error) {
            HWLog(@"*****************************Error: %@", task.error);
        }
        else {
            // The file uploaded successfully.
            HWLog(@"------image------OK");
            
            if (_isSnap) {
            
                [self writeToSnapServer];
            }else{

                [self writeToReportServer];

            }
            
        }
        
        return nil;
    }];
}



- (void)uploadVideo:(NSString *)videoPath imagePath:(NSString *)imagePath{
    
//    self.alertKeyShare = [[UIAlertView alloc] initWithTitle:@"" message:@"" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    
    //配置亚马逊参数
    [self s3ConfigParams];
    
    //拼接imagekey
    //    NSString *videoKey1 = [[self.videoPath componentsSeparatedByString:@"/"] lastObject];//20160419165643.mp4
    //    NSString *videoKey2 = [videoKey1 substringToIndex:[videoKey1 length] - 4];//20160419165643
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *currentDateStr = [dateFormatter stringFromDate:currentDate];
    self.currentDateStr = currentDateStr;
    HWLog(@"====================== %@",currentDateStr);
    
    NSString *uuidString = [HWCameraRecorderViewController uuidString];
    uuidString = [uuidString stringByReplacingOccurrencesOfString:@"-" withString:@""];
    self.uuidStr = uuidString;
    //    self.videoKey = [NSString stringWithFormat:@"share_pic/mp4/%@/%@%@%@.mp4",self.dateStr,videoKey2,currentDateStr,uuidString];//share_pic/20160419165629_70002611.mp4
    self.videoKey = [NSString stringWithFormat:@"illegal_video/thumb/mp4/%@/%@.mp4",currentDateStr,uuidString];//share_pic/20160419165629_70002611.mp4
    
    //    HWLog(@"-----------------------%@",self.videoKey);
    
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
    uploadRequest.bucket = kBucketName;
    uploadRequest.key = self.videoKey;
    
    //    dispatch_group_t group=dispatch_group_create();
    //    dispatch_group_async(group, global_queue, ^{
//    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
//                                                          NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:[NSString stringWithFormat:@"reportVideo%@.mp4",_tempUrl]];
//    NSURL *url  = [NSURL fileURLWithPath:videoPath];
    
    //  [_captureMovieFileOutput startRecordingToOutputFileURL:url recordingDelegate:self];
    
    uploadRequest.body = [NSURL fileURLWithPath:videoPath];
    
    __typeof(self) __weak safeSelf = self;
    [[transferManager upload:uploadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor] withBlock:^id(AWSTask*task) {
        if (task.error) {
            [self.hud hide:YES];
            HWLog(@"=====================Error: %@", task.error);
        }
        else {
            [self.hud hide:YES];
            // The file uploaded successfully.
            HWLog(@"video upload------------OK");
            [self upLoadImage:imagePath];
            
            //            [safeSelf sharePicture];
            
        }
        
        return nil;
    }];
    
    
    
    //NSURL *url = [NSURL fileURLWithPath:[self videoWithUrl:_assetWriter.outputURL withFileName:[NSString stringWithFormat:@"reportVideo%@",currentDateStr]]];
    
    //    uploadRequest.body = url;
    //
    //    __typeof(self) __weak safeSelf = self;
    //    [[transferManager upload:uploadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor] withBlock:^id(AWSTask*task) {
    //        if (task.error) {
    //            [self.hud hide:YES];
    //            HWLog(@"=====================Error: %@", task.error);
    //        }
    //        else {
    //            [self.hud hide:YES];
    //            // The file uploaded successfully.
    //            HWLog(@"video upload------------OK");
    //            if (_isSnap) {
    //
    //                [self writeToSnapServer];
    //            }else{
    //
    //                [self writeToReportServer];
    //
    //            }
    //            //            [safeSelf sharePicture];
    //
    //        }
    //
    //        return nil;
    //    }];
}

-(void)writeToReportServer{
    
    //    NSString *identifierForVendor = [[UIDevice currentDevice].identifierForVendor UUIDString];
    //http://112.124.22.101:38080/illegalreport/restapi/cidbinduser
    CLLocationDegrees longitude = self.userLocation.coordinate.longitude;
    CLLocationDegrees latitude = self.userLocation.coordinate.latitude;
    self.currentDateStr = [self timeOfNow];
    NSString *occurtime = self.currentDateStr;
    NSString *video_id = [NSString stringWithFormat:@"%@_%@",self.currentDateStr,identifierForVendor];
    
    NSString *store_loc = @"0";
    NSDictionary *store_param = @{
                                  @"bucketname":kBucketName,
                                  @"mp4key":self.videoKey,
                                  @"imagekey":self.imageKey
                                  };
//    NSString *store_param = [NSString stringWithFormat:@"bucketname=%@;mp4key=%@;imagekey=%@",kBucketName,self.videoKey,self.imageKey];
    
    NSString *urlStr = [NSString stringWithFormat:@"http://112.124.22.101:38080/illegalreport/restapi/cidonekeyreport?cid=%@&longitude=%f&latitude=%f&occurtime=%@&occuraddr=%@&video_id=%@&store_loc=%@&store_param=%@",identifierForVendor,longitude,latitude,occurtime,video_id,store_loc,store_param];
//    NSString *urlStr = [NSString stringWithFormat:@"http://192.168.0.29:8080/illegalreport/restapi/cidonekeyreport?cid=%@&longitude=%f&latitude=%f&occurtime=%@&occuraddr=%@&video_id=%@&store_loc=%@&store_param=%@",identifierForVendor,longitude,latitude,occurtime,occuraddr,video_id,store_loc,store_param];
    HWLog(@"writeToReportServer == %@",urlStr);
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//   NSString *urlStr =  (NSString *)
//    
//    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
//                                                              
//                                                              (CFStringRef)urlStr0,
//                                                              
//                                                              (CFStringRef)@"!$&'()*+,-./:;=?@_~%#[]",
//                                                              
//                                                              NULL,
//                                                              
//                                                              kCFStringEncodingUTF8));
    NSURL *url = [NSURL URLWithString:urlStr];
    
    // 2. 请求
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:1 timeoutInterval:2.0f];
    
//    self.alertReport = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title", nil) message:@"" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    
    // 3. 连接
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        self.snapBtn.userInteractionEnabled = YES;
        self.reportBtn.userInteractionEnabled = YES;
        // 反序列化
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
        
        NSLog(@"result---%@--%@", result,result[@"desc"]);
        NSString *str0 = [NSString stringWithFormat:@"%@",result[@"result"]];
        if ([str0 isEqualToString:@"success"]) {
            self.nickname = result[@"nickname"];
            
//            self.alertReport.title = @"✅";
//            self.alertReport.message = @"举报成功";
            self.alertLabel.text = @"您已成功举报";
            self.alertLabel.hidden = NO;
            self.reportBtn.selected = NO;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.alertLabel.hidden = YES;
            });
            
            HWLog(@"===============您已举报成功!!!=============");
            //            [self.alertReport show];
        }else if([str0 isEqualToString:@"1003"]){
            HWLog(@"===================");
//            self.alertReport.title = @"❌";
//            self.alertReport.message = @"举报失败";
            
            self.alertLabel.text = @"未绑定";
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.alertLabel.hidden = YES;
            });
            //            [self.alertReport show];
        }
    }];
}

- (void)writeToSnapServer{
    NSString *titleStr = @"啥也不想说，先看视频吧！！！";
    NSString *video_id = [NSString stringWithFormat:@"%@%ld_%@",self.currentDateStr,(long)_videoCount,identifierForVendor];
    
    
    NSURL *url = [NSURL URLWithString:kKeyShareUrl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    //    NSDictionary *dict = @{
    //                          @"alarm_type" : @"04",
    //                          @"alarm_info":@{@"video_url": videoStr,
    //                                          @"image_url": imageStr,
    //                                          @"nickname":  strNickName
    //                                          },
    //                          @"location":@"上海张江",
    //                          @"title":contentStr,
    //                          @"cid":self.cidNum,
    //                          @"uid":upSecretUid,
    //                          @"videoChecked":self.titleStr
    //                          };
    //@"image_url": imageStr,
    HWLog(@"--%@--",titleStr);
    HWLog(@"--%@--",video_id);
    HWLog(@"--%@--",self.nickname);
    HWLog(@"--%@--",kBucketName);
    HWLog(@"--%@--",self.videoKey);
    HWLog(@"--%@--",self.imageKey);
    HWLog(@"--%@--",titleStr);
    HWLog(@"--%@--",identifierForVendor);
    NSDictionary *dict = @{
                           @"alarm_type" : @04,
                           @"video_id": video_id,
                           @"store_loc":@"0",
                           @"nickname": self.nickname,
                           @"store_param":@{
                                   @"bucketname":kBucketName,
                                   @"mp4key":self.videoKey,
                                   @"imgkey":self.imageKey
                                   },
                           @"location":@"上海浦东新区张江",
                           @"title":titleStr,
                           @"cid":identifierForVendor,
                           @"uid":identifierForVendor
                           };
    
    HWLog(@"---dict*%@*",dict);
    
    if ([NSJSONSerialization isValidJSONObject:dict])
    {
        
        NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
        request.HTTPBody = data;
        
//        self.alertSnap = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title", nil) message:@"" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        
        __typeof(self) __weak safeSelf = self;
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            self.reportBtn.userInteractionEnabled = YES;
            if (!connectionError) {
                HWLog(@"datalength:%lu",(unsigned long)data.length);
                HWLog(@"data:%@",data);
                
                
                self.codeDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                HWLog(@"dict[%@]",self.codeDict);
                
                HWLog(@"code-----%@",self.codeDict[@"code"]);
                HWLog(@"code-----%@",self.codeDict[@"desc"]);
                dispatch_async(dispatch_get_main_queue(), ^{
//                    if ([self.codeDict[@"code"] isEqualToString:@"9999"]) {
//                        [safeSelf.hud hide:YES];
//                        self.alertSnap.title = @"❌";
//                        self.alertSnap.message = @"9999";
//                        [self.alertSnap show];
//                        return ;
//                    }
        
                    self.alertLabel.text = @"您已成功一键分享";
                    self.alertLabel.hidden = NO;
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        self.alertLabel.hidden = YES;
                        self.snapBtn.selected = NO;
//                        if (_isWiFi0) {
//                            if (videoCount == self.videoPaths.count) {
//                                [self deleteFile];
//                            }else{
//                                
//                                [self deleteFile];
//                            }
//                        }
                        
                    });
                    //                    [self.alertSnap show];
                });
                
                
            }
            else{
                HWLog(@"error:%@",connectionError);
//                self.alertSnap.title = @"❌";
//                self.alertSnap.message = @"分享失败";
                self.alertLabel.text = @"分享失败";
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    self.alertLabel.hidden = YES;
                });
            }
        }];
    }
    else
    {
        HWLog(@"数据有误");
    }
}



- (IBAction)reportBtnClick:(UIButton *)sender {
    _isSnap = NO;
    self.snapBtn.userInteractionEnabled = NO;
    self.reportBtn.userInteractionEnabled = NO;
    self.reportBtn.selected = YES;
//    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES configBlock:^(MBProgressHUD *HUD) {
//        HUD.removeFromSuperViewOnHide = YES;
//    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"%@", [NSDate date]);
        [[RecordInterface instance] quickRecord];
    });
    
}

- (void) fileWillAddToDirectory:(NSString *)filePath {
    NSLog(@"fileWillAddToDirectory add file filePath%@", filePath);
    
}

- (void) fileWillDelFromDirectory:(NSString *)filePath {
    NSLog(@"fileWillDelFromDirectory del file filePath%@", filePath);
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    [fileManager removeItemAtPath:filePath error:&error];
    if (error) {
        NSLog(@"fileWillDelFromDirectory error:%@",error);
    }

}

- (IBAction)exchangeCameraBtnClick:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    [[RecordInterface instance] stopPreview];
    if (sender.selected) {
        
        HWLog(@"－－－－－－－－－DevicePositionFront%d",DevicePositionFront);
        [self setUpRecorderView:DevicePositionFront];
    }else{
        
        HWLog(@"－－－－－－－DevicePositionBack%d",DevicePositionBack);
        [self setUpRecorderView:DevicePositionBack];
    }
}

- (IBAction)cutBtnClick:(UIButton *)sender {
    
}

- (IBAction)maikeBtnClick:(UIButton *)sender {
    
}

- (IBAction)leftBatteryClick:(UIButton *)sender {
    
//    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
//        
//        self.leftView.transform = CGAffineTransformMakeTranslation(screenW, 0);
//        
//    } completion:nil];
}

- (void)location{
    
    self.mgr = [[CLLocationManager alloc] init];
    self.mgr.delegate = self;
    self.mgr.desiredAccuracy=kCLLocationAccuracyBest;
    self.mgr.distanceFilter
    = 1000.0f;
    
    //判断是否授权
    if([self.mgr respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        
        [self.mgr requestWhenInUseAuthorization];
    }
    
    //定位功能开启的情况下进行定位
    if([CLLocationManager locationServicesEnabled]){
        self.mgr.distanceFilter = kCLDistanceFilterNone;
        //跟踪用户
        self.mkMapView.userTrackingMode = MKUserTrackingModeFollow;
        [self.mgr startUpdatingLocation];
        
    }else {
        
        //初始化提示框；
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"请在设置中打开定位" preferredStyle:  UIAlertControllerStyleAlert];
        
        //弹出提示框；
        [self presentViewController:alert animated:true completion:nil];
    }
}

+ (NSString *)uuidString
{
    CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
    CFStringRef uuid_string_ref= CFUUIDCreateString(NULL, uuid_ref);
    NSString *uuid = [NSString stringWithString:(__bridge NSString *)uuid_string_ref];
    CFRelease(uuid_ref);
    CFRelease(uuid_string_ref);
    return [uuid  lowercaseString];
}

-(NSString *)timeOfNowQuhuaxian{
    NSDate *currentDate = [NSDate date];//获取当前时间，日期
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYYMMddhhmmss"];
    NSString *dateString = [dateFormatter stringFromDate:currentDate];
    return dateString;
}

-(NSString *)timeOfNow{
    NSDate *currentDate = [NSDate date];//获取当前时间，日期
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd hh:mm:ss"];
    NSString *dateString = [dateFormatter stringFromDate:currentDate];
    return dateString;
}

+ (BOOL)shouldAutorotate{

    return YES;
}

//- (void)getLocalVideoList
//{
//    
//    __weak HWCameraRecorderViewController *weakSelf = self;
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        ALAssetsLibraryGroupsEnumerationResultsBlock listGroupBlock = ^(ALAssetsGroup *group, BOOL *stop) {
//            if (group != nil) {
//                
//                [weakSelf.groupArrays addObject:group];
//                
//            } else {
//                
//                [weakSelf.groupArrays enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//                    HWLog(@"---weakSelf.groupArrays--%@",weakSelf.groupArrays);
//                    [obj enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
//                        if ([result thumbnail] != nil) {
//                            // 照片
//                            if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]){
//                                NSDate *date = [result valueForProperty:ALAssetPropertyDate];
//                                UIImage *image = [UIImage imageWithCGImage:[result thumbnail]];
//                                NSString *fileName = [[result defaultRepresentation] filename];
//                                NSURL *url = [[result defaultRepresentation] url];
//                                int64_t fileSize = [[result defaultRepresentation] size];
//                                NSLog(@"date = %@",date);
//                                NSLog(@"fileName = %@",fileName);
//                                
//                                NSLog(@"url = %@",url);
//                                NSLog(@"fileSize = %lld",fileSize);
//                                // UI的更新记得放在主线程,要不然等子线程排队过来都不知道什么年代了,会很慢的
//                                dispatch_async(dispatch_get_main_queue(), ^{
//                                    
//                                    
//                                    
//                                });
//                            }
//                            
//                            //视频
//                            else if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo] ){
//                                // 和图片方法类似
//                                NSDate *date= [result valueForProperty:ALAssetPropertyDate];
//                                UIImage *image = [UIImage imageWithCGImage:[result thumbnail]];
//                                NSString *fileName = [[result defaultRepresentation] filename];
//                                NSURL *url = [[result defaultRepresentation] url];
//                                int64_t fileSize = [[result defaultRepresentation] size];
//                                //                                NSLog(@"date = %@",date);
//                                //                                NSLog(@"fileName = %@",fileName);
//                                //                                NSLog(@"url = %@",url);
//                                //                                NSLog(@"fileSize = %lld",fileSize);
//                                
//                                // UI的更新记得放在主线程,要不然等子线程排队过来都不知道什么年代了,会很慢的
//                                //                                dispatch_async(dispatch_get_main_queue(), ^{
//                                //
//                                //                                    [self.fileNames addObject:fileName];
//                                //                                    [self.litImages addObject:image];
//                                //                                    if (self.fileNames.count&&self.litImages.count&&self.videoArrays.count&&self.groupArrays&&self.iconPaths) {
//                                //                                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                                //                                            [self.tableView reloadData];
//                                //                                        });
//                                //
//                                //                                    }
//                                //                                    HWLog(@"--==--%@",self.fileNames);
//                                //
//                                //                                });
//                                
//                                //                                if ([fileName containsString:@".mp4"] ||[fileName containsString:@".mov"] ) {
//                                
//                                //                                [self videoWithUrl:url withFileName:fileName];
//                                //                                }
//                                
//                                
//                                
//                            }
//                            
//                        }
//                        
//                    }];
//                    
//                }];
//                
//            }
//        };
//        
//        ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error)
//        {
//            HWLog(@"--------%@",error);
//            NSString *errorMessage = nil;
//            switch ([error code]) {
//                    
//                case ALAssetsLibraryAccessUserDeniedError:
//                    
//                case ALAssetsLibraryAccessGloballyDeniedError:
//                    errorMessage = @"用户拒绝访问相册,请在<隐私>中开启";
//                    break;
//                    
//                default:
//                    
//                    errorMessage = @"Reason unknown.";
//                    
//                    break;
//                    
//            }
//            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                
//                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"错误,无法访问!"
//                                                                   message:errorMessage
//                                                                  delegate:self
//                                                         cancelButtonTitle:@"确定"
//                                          
//                                                         otherButtonTitles:nil, nil];
//                
//                [alertView show];
//                
//            });
//            
//        };
//        
//        ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc]  init];
//        
//        [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll
//         
//                                     usingBlock:listGroupBlock failureBlock:failureBlock];
//        
//    });
//    
//}

//// 将原始视频的URL转化为NSData数据,写入沙盒
//- (void)videoWithUrl:(NSURL *)url withFileName:(NSString *)fileName
//{
//    // 解析一下,为什么视频不像图片一样一次性开辟本身大小的内存写入?
//    // 想想,如果1个视频有1G多,难道直接开辟1G多的空间大小来写?
//    ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc] init];
//
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//
//        if (url) {
//
//            [assetLibrary assetForURL:url resultBlock:^(ALAsset *asset) {
//
//                ALAssetRepresentation *rep = [asset defaultRepresentation];
//
//                NSString *videoPath = [KCachesPath stringByAppendingPathComponent:fileName];
//
//                //                self.videoPath = videoPath;
//                //                for (int i = 0; i<self.groupArrays.count; i++) {
//
////                [self.videoArrays addObject:videoPath];
//                HWLog(@"-------videoPath==%@",videoPath);
//                NSString *strVideoPath = videoPath;
//                self.strVideoPath = videoPath;
//                //                }
//
////                HWLog(@"self.videoArrays = %@",self.videoArrays);
//
////                self.fileName = fileName;
//                videoPath = [videoPath stringByReplacingOccurrencesOfString:@".mp4" withString:@""];
////                videoPath = [videoPath stringByReplacingOccurrencesOfString:@".MP4" withString:@""];
////                videoPath = [videoPath stringByReplacingOccurrencesOfString:@".mov" withString:@""];
////                videoPath = [videoPath stringByReplacingOccurrencesOfString:@".MOV" withString:@""];
////                NSString *iconPath = [videoPath stringByAppendingPathExtension:@"png"];
//
////                [self.iconPaths addObject:iconPath];
////                HWLog(@"-------iconPath==%@",iconPath);
//
//                char const *cvideoPath = [strVideoPath UTF8String];
//
//                FILE *file = fopen(cvideoPath, "a+");
//
//                if (file) {
//
//                    const int bufferSize = 1024 * 1024;
//
//                    // 初始化一个1M的buffer
//                    Byte *buffer = (Byte*)malloc(bufferSize);
//
//                    NSUInteger read = 0, offset = 0, written = 0;
//
//                    NSError* err = nil;
//
//                    if (rep.size != 0)
//                    {
//
//                        do {
//
//                            read = [rep getBytes:buffer fromOffset:offset length:bufferSize error:&err];
//
//                            written = fwrite(buffer, sizeof(char), read, file);
//
//                            offset += read;
//
//                        } while (read != 0 && !err);//没到结尾，没出错，ok继续
//
//                    }
//                    
//                    // 释放缓冲区，关闭文件
//                    free(buffer);
//                    
//                    buffer = NULL;
//                    
//                    fclose(file);
//                    
//                    file = NULL;
//                [self uploadVideo:self.strVideoPath imagePath:self.imagePath];
//                }
//                
//            } failureBlock:nil];
//            
//        }
//        
//    });
//    
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
