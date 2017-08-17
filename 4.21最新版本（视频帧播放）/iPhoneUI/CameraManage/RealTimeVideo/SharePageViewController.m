 //
//  SharePageViewController.m
//  HuaWo
//
//  Created by Sun on 16/4/14.
//  Copyright © 2016年 circlely. All rights reserved.
//

#import "SharePageViewController.h"
#import <AWSS3/AWSS3.h>
#import <AWSCore/AWSCore.h>
//#import "FMGVideoPlayView.h"
//#import "FullViewController.h"

#import "MemberData.h"
#import "NSString+encrypto.h"
#import <CommonCrypto/CommonDigest.h>
#import "MBProgressHUD.h"
#import "CameraViewController.h"
#import <TextView/TextView.h>
#import "Reachability.h"
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>
#import <ShareSDKUI/SSUIShareActionSheetCustomItem.h>
#import <ShareSDK/ShareSDK+Base.h>
#import <ShareSDKExtension/ShareSDK+Extension.h>

#import <ShareSDKExtension/SSEShareHelper.h>
#import <ShareSDKUI/SSUIShareActionSheetStyle.h>


#define kBucketName @"huawo"
#define kVideoKey
#define kImageKey
#define kUid [[MemberData memberData] getMemberAccount]
#define kNickName [[MemberData memberData] getMemberNickName]

@interface SharePageViewController ()<UITextViewDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *recordText;
@property (weak, nonatomic) IBOutlet UIView *videoView;
@property (weak, nonatomic) IBOutlet UIView *navView;
@property (weak, nonatomic) IBOutlet UIButton *picketBtn;
@property (weak, nonatomic) IBOutlet UIButton *lighthouseBtn;
@property (weak, nonatomic) IBOutlet UIButton *accidentBtn;
@property (weak, nonatomic) IBOutlet UIButton *sceneryBtn;
@property (weak, nonatomic) IBOutlet UIButton *circleOfFriendsBtn;
@property (weak, nonatomic) IBOutlet UIButton *qzoneBtn;
@property (weak, nonatomic) IBOutlet UIButton *weiboBtn;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;

@property (strong, nonatomic) NSURL *videoUrl;
@property (strong, nonatomic) NSURL *imageUrl;
@property (copy, nonatomic) NSString *videoKey;
@property (copy, nonatomic) NSString *imageKey;

@property (assign, nonatomic) UIButton *coverViewBtn;
@property (copy, nonatomic) NSString *titleStr;
@property (strong, nonatomic) MBProgressHUD *hud;
@property (strong, nonatomic) TextView *textview;
@property (copy, nonatomic) NSString *uuidStr;
@property (strong, nonatomic) NSDictionary *codeDict;

/**
 *  面板
 */
@property (nonatomic, strong) UIView *panelView;
/**
 *  加载视图
 */
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;
@property (weak, nonatomic) IBOutlet UIButton *shareBtn;

@property (strong, nonatomic) UIAlertView *alertKeyShare;
@property (copy, nonatomic) NSString *dateStr;

@property (strong, nonatomic) FMGVideoPlayView *playView;
@property (strong, nonatomic) UIAlertView *alertWiFi;
@property (copy, nonatomic) NSString *nickname;
@end

@implementation SharePageViewController

+ (instancetype)sharePageViewController{

    return [[SharePageViewController alloc] initWithNibName:@"SharePageViewController" bundle:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self.imagePath isEqualToString:@"123456"]) {
        self.shareBtn.hidden = YES;
    }else{
    
        self.shareBtn.hidden = NO;
        
        self.imageUrl = [NSURL fileURLWithPath:self.imagePath];
        //    self.videoUrl = [NSURL URLWithString:@"file:///var/mobile/Containers/Data/Application/C6BAE209-11AA-4D14-8DDC-C87EFBF3617D/Documents/reportVideo20161207152319.mp4"];
        //    self.imageUrl = [NSURL URLWithString:@"file:///var/mobile/Containers/Data/Application/C6BAE209-11AA-4D14-8DDC-C87EFBF3617D/Documents/reportVideo20161207152319.png"];;
        HWLog(@"---sharePageViewController--%@--%@",self.videoUrl, self.imageUrl);
    }
    
    [self setUpTitleLabel];
    
    self.videoUrl = [NSURL fileURLWithPath:self.videoPath];
    
    //添加播放器
    [self setUpVideoPlayer];
    
    [self addNotification];
    
    self.sceneryBtn.selected = YES;
    self.circleOfFriendsBtn.selected = YES;
    
    
    //添加placeholderLabel
    [self addPlaceholderLabel];
    
    [self setUpLeftNavigationItem];
    
    self.titleStr = @"04";
    
    [self setUpCurrentDate];
    
    [self getLocation];
    
    [self getDeviceNickName];
    
    [DZNotificationCenter addObserver:self selector:@selector(OrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
}

- (void)OrientationDidChange:(NSNotification *)note{
    HWLog(@"===%@",note);
}

- (void)setUpTitleLabel{

    CGFloat screenw = screenW;
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0.3*screenw, 12)];
    titleLabel.text = @"分享到广场";
    titleLabel.font = [UIFont systemFontOfSize:18];
    titleLabel.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = titleLabel;
}

- (void)getLocation{
    
    HWLog(@"self.videoPath%@",self.videoPath);
    NSString *filePath = [self.videoPath stringByReplacingOccurrencesOfString:@".mp4" withString:@".text"];
    HWLog(@"---fenxiang-filePath----%@",filePath);
    NSError *error = nil;
    NSString *locationStr = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        HWLog(@"---读取失败-----%@",error);
    }else{
        self.locationLabel.text = locationStr;
        HWLog(@"----读取成功----");
    }
}

- (void)addNotification{

    [DZNotificationCenter addObserver:self selector:@selector(playerView:) name:@"playerView" object:nil];
    [DZNotificationCenter addObserver:self selector:@selector(playerViewFrame:) name:@"playerViewFrame" object:nil];
}

- (void)setUpCurrentDate{

    NSString *str = [NSString stringWithFormat:@"%@",[NSDate date]];
    str = [str stringByReplacingOccurrencesOfString:@"-" withString:@""];
    str = [str substringToIndex:8]; 
    self.dateStr = str;
}

- (void)setUpLeftNavigationItem{
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"title_back_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonItemAction)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
}

- (void)leftBarButtonItemAction{
    
    
    [DZNotificationCenter addObserver:self selector:@selector(dismissPlayer:) name:@"AVPlayer" object:nil];
//    [self.playView removeNotification];
    self.videoView = nil;
    self.playView = nil;
    [self.navigationController popViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)dismissPlayer:(NSNotification *)note{

    AVPlayer *player = (AVPlayer *)note.object;
    player = nil;
}

- (void)setUpVideoPlayer {

    FMGVideoPlayView *playView = [FMGVideoPlayView videoPlayView];
    self.playView = playView;
    // 视频资源路径
//    [playView setVideoUrl:self.videoUrl];
    [playView setUrlString:self.videoPath];
    // 播放器显示位置（竖屏时）
    CGFloat screew = screenW;
    playView.frame = CGRectMake(0, 0, screew, self.videoView.frame.size.height - 85);
    // 添加到当前控制器的view上
    [self.videoView addSubview:playView];
    
    // 指定一个作为播放的控制器
    playView.contrainerViewController = self;
    playView.contrainerViewController.view.frame = CGRectMake(0, 0, screew, self.videoView.height - 85);
}

- (void)addPlaceholderLabel{

    self.textview = [[TextView alloc] init];
    self.textview.textColor = [UIColor whiteColor];
    self.textview.delegate = self;
    self.textview.font = [UIFont systemFontOfSize:11];
    self.textview.frame = self.recordText.bounds;
    self.textview.backgroundColor = [UIColor clearColor];
    self.textview.placeholder = @"啥也不想说，先看视频吧！！！";
//    textview.text = @"啥也不想说，先看视频吧！！！";
//    self.textview = textview;
    [self.recordText addSubview:self.textview];
    
}

- (void)setCover{

    UIButton *coverViewBtn = [[UIButton alloc] init];
    [self.view addSubview:coverViewBtn];
    self.coverViewBtn = coverViewBtn;
    coverViewBtn.backgroundColor = [UIColor whiteColor];
    coverViewBtn.alpha = 0.2;
    CGFloat w = screenW;
    CGFloat h = screenH;
    CGFloat x = 0;
    CGFloat y = self.recordText.frame.size.height + self.navView.frame.size.height;
    coverViewBtn.frame = CGRectMake(x, y, w, h);
    
    [coverViewBtn addTarget:self action:@selector(quitKeyboard) forControlEvents:UIControlEventTouchUpInside];
}


- (void)textViewDidBeginEditing:(UITextView *)textView{

    [self setCover];
}

- (void)textViewDidEndEditing:(UITextView *)textView{

    self.coverViewBtn.hidden = YES;
}

- (void)quitKeyboard{

    [self.recordText endEditing:YES];
}

- (void)playerView:(NSNotification *)note{
    
    [self.videoView addSubview:note.object];
}

- (void)playerViewFrame:(NSNotification *)note{
    UIView *view = (UIView *)note.object;
    view.frame = self.videoView.bounds;
}

- (void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    if ([text isEqualToString:@"\n"]) {
        
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clickBack {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

//1-4依次为纠察台，曝光台，事故爆料，美丽风景
- (IBAction)picketBtnClick:(UIButton *)sender {
    self.picketBtn.selected = !self.picketBtn.selected;
    self.lighthouseBtn.selected = NO;
    self.accidentBtn.selected = NO;
    self.sceneryBtn.selected = NO;
    self.titleStr = @"01";
    HWLog(@"--------------------%@",self.titleStr);
}

- (IBAction)lighthouseBtnClick:(UIButton *)sender {
    
    self.picketBtn.selected = NO;
    self.lighthouseBtn.selected = !self.lighthouseBtn.selected;
    self.accidentBtn.selected = NO;
    self.sceneryBtn.selected = NO;
    self.titleStr = @"02";
    HWLog(@"--------------------%@",self.titleStr);
}


- (IBAction)accidentBtnClick:(UIButton *)sender {
    self.picketBtn.selected = NO;
    self.lighthouseBtn.selected = NO;
    self.accidentBtn.selected = !self.accidentBtn.selected;
    self.sceneryBtn.selected = NO;
    self.titleStr = @"03";
    HWLog(@"--------------------%@",self.titleStr);
}

- (IBAction)sceneryBtnClick:(UIButton *)sender {
    self.picketBtn.selected = NO;
    self.lighthouseBtn.selected = NO;
    self.accidentBtn.selected = NO;
    self.sceneryBtn.selected = !self.sceneryBtn.selected;
    self.titleStr = @"04";
    HWLog(@"--------------------%@",self.titleStr);
}

- (IBAction)circleOfFriendsBtnClick:(UIButton *)sender {
    
    self.circleOfFriendsBtn.selected = !self.circleOfFriendsBtn.selected;
    self.qzoneBtn.selected = NO;
    self.weiboBtn.selected = NO;
}

- (IBAction)qzoneBtnClick:(UIButton *)sender {
    self.circleOfFriendsBtn.selected = NO;
    self.qzoneBtn.selected = !self.qzoneBtn.selected;
    self.weiboBtn.selected = NO;
}

- (IBAction)weiboBtnClick:(UIButton *)sender {
    self.circleOfFriendsBtn.selected = NO;
    self.qzoneBtn.selected = NO;
    self.weiboBtn.selected = !self.weiboBtn.selected;
}

- (void)s3ConfigParams{
    
    AWSStaticCredentialsProvider *credentialsProvider = [[AWSStaticCredentialsProvider alloc] initWithAccessKey:@"AKIAOVUGNAXFVVE5IALQ" secretKey:@"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"];
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionCNNorth1 credentialsProvider:credentialsProvider];
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
}

- (IBAction)clickShare {

    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES configBlock:^(MBProgressHUD *HUD) {
        HUD.removeFromSuperViewOnHide = YES;
    }];
    
    self.alertKeyShare = [[UIAlertView alloc] initWithTitle:@"" message:@"" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    
    //配置亚马逊参数
    [self s3ConfigParams];
    
    //拼接imagekey
    NSString *videoKey1 = [[self.videoPath componentsSeparatedByString:@"/"] lastObject];//20160419165643.mp4
    NSString *videoKey2 = [videoKey1 substringToIndex:[videoKey1 length] - 4];//20160419165643
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *currentDateStr = [dateFormatter stringFromDate:currentDate];
    HWLog(@"====================== %@",currentDateStr);

    NSString *uuidString = [SharePageViewController uuidString];
    uuidString = [uuidString stringByReplacingOccurrencesOfString:@"-" withString:@""];
    self.uuidStr = uuidString;
//    self.videoKey = [NSString stringWithFormat:@"share_pic/mp4/%@/%@%@%@.mp4",self.dateStr,videoKey2,currentDateStr,uuidString];//share_pic/20160419165629_70002611.mp4
    self.videoKey = [NSString stringWithFormat:@"share_pic/mp4/%@/%@.mp4",self.dateStr,uuidString];//share_pic/20160419165629_70002611.mp4

    HWLog(@"-----------------------%@",self.videoKey);
    
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
    uploadRequest.bucket = kBucketName;
    uploadRequest.key = self.videoKey;
    uploadRequest.body = self.videoUrl;
    
    __typeof(self) __weak safeSelf = self;
    [[transferManager upload:uploadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor] withBlock:^id(AWSTask*task) {
        
        if (task.error) {
            HWLog(@"Error: %@", task.error);
        }
        else {
            
            // The file uploaded successfully.
            HWLog(@"video upload------------OK");
            [safeSelf sharePicture];

        }
        
        return nil;
    }];

}

+ (NSString *)uuidString
 {
    CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
    CFStringRef uuid_string_ref= CFUUIDCreateString(NULL, uuid_ref);
    NSString *uuid = [NSString stringWithString:(__bridge NSString *)uuid_string_ref];
    CFRelease(uuid_ref);
    CFRelease(uuid_string_ref);
    return [uuid lowercaseString];
}

-(void)sharePicture{
    
    //配置亚马逊参数
    [self s3ConfigParams];
    
    //拼接imagekey
    NSString *imageKey1 = [[self.videoPath componentsSeparatedByString:@"/"] lastObject];//20160419165643.mp4
    NSString *imageKey2 = [imageKey1 substringToIndex:[imageKey1 length] - 4];//20160419165643
//    self.imageKey = [NSString stringWithFormat:@"share_pic/thumb/%@/%@.png",self.dateStr,imageKey2];
    self.imageKey = [NSString stringWithFormat:@"share_pic/thumb/%@/%@.png",self.dateStr,self.uuidStr];
    
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
    uploadRequest.bucket = kBucketName;
    uploadRequest.key = self.imageKey;
    uploadRequest.body = self.imageUrl;

    __typeof(self) __weak safeSelf = self;
    [[transferManager upload:uploadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor] withBlock:^id(AWSTask*task) {
        if (task.error) {
            HWLog(@"Error: %@", task.error);
        }
        else {
            
            // The file uploaded successfully.
            HWLog(@"image upload------------OK");
            [safeSelf writeToDiscoveryServer];

        }
        
        return nil;
    }];
}

-(BOOL) isConnectionAvailable{
    
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
            isExistenceNetwork = YES;
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


//自动注册
- (void)getDeviceNickName{
    self.alertWiFi = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title", nil) message:@"" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    if (![self isConnectionAvailable]) {
        
        self.alertWiFi.title = @"❌";
        self.alertWiFi.message = @"当前无网络...";
//        self.alertLabel.text = @"当前无网络...";
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            self.alertLabel.hidden = YES;
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

-(void)writeToDiscoveryServer{
    
    NSString *videoStr = [[self.videoKey componentsSeparatedByString:@"/"] lastObject];
    videoStr = [videoStr stringByReplacingOccurrencesOfString:@".mp4" withString:@""];
//    NSString *imageStr = [[self.imageKey componentsSeparatedByString:@"/"] lastObject];
    
    HWLog(@"self.videoPath%@",self.videoPath);
    NSString *filePath = [self.videoPath stringByReplacingOccurrencesOfString:@".mp4" withString:@".text"];
    HWLog(@"---fenxiang-filePath----%@",filePath);
    NSError *error = nil;
    NSString *locationStr = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        HWLog(@"---读取失败-----%@",error);
        locationStr = @"上海浦东新区";
    }else{
        HWLog(@"----读取成功----");
    }
    
    NSString *bucketName = kBucketName;
    
    NSString *str = kUid;
    NSString *secretUid = [str sha1];
    NSString *upSecretUid = [secretUid uppercaseString];
    HWLog(@"secretUid:*%@*",upSecretUid);

    NSString *strNickName = self.nickname;
    
    HWLog(@"writeToDiscoveryServer:*%@*",self.titleStr);
    
    NSString *contentStr = nil;
    if (![self.textview.text isEqualToString:@""]) {
        HWLog(@"------%@",self.textview.text);
        
        contentStr = self.textview.text;
    }else{
        contentStr = self.textview.placeholder;
    }
    
    HWLog(@"contentStr*%@*",contentStr);
    if (!self.cidNum) {
        self.cidNum = @"70002611";
    }
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
    HWLog(@"--%@--",self.titleStr);
    HWLog(@"--%@--",self.uuidStr);
    HWLog(@"--%@--",self.nickname);
    HWLog(@"--%@--",bucketName);
    HWLog(@"--%@--",self.videoKey);
    HWLog(@"--%@--",self.imageKey);
    HWLog(@"--%@--",locationStr);
    HWLog(@"--%@--",contentStr);
    HWLog(@"--%@--",self.cidNum);
    HWLog(@"--%@--",upSecretUid);
    
    NSDictionary *dict = @{
                           @"alarm_type" : self.titleStr,
                           @"video_id": self.uuidStr,
                           @"store_loc":@"0",
                           @"nickname": strNickName,
                           @"store_param":@{
                                   @"bucketname":bucketName,
                                   @"mp4key":self.videoKey,
                                   @"imgkey":self.imageKey
                                   },
                           @"location":locationStr,
                           @"title":contentStr,
                           @"cid":self.cidNum,
                           @"uid":upSecretUid
                           };
    
    HWLog(@"---dict*%@*",dict);
    
    if ([NSJSONSerialization isValidJSONObject:dict])
    {
        
        NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
        request.HTTPBody = data;
        
        __typeof(self) __weak safeSelf = self;
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            
            if (!connectionError) {
                HWLog(@"datalength:%lu",(unsigned long)data.length);
                HWLog(@"data:%@",data);
                
                
                self.codeDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                HWLog(@"dict[%@]",self.codeDict);
                
                HWLog(@"code-----%@",self.codeDict[@"code"]);
                HWLog(@"code-----%@",self.codeDict[@"desc"]);
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([self.codeDict[@"code"] isEqualToString:@"9999"]) {
                        [safeSelf.hud hide:YES];
                        safeSelf.alertKeyShare.title = @"❌";
                        safeSelf.alertKeyShare.message = @"9999";
                        [safeSelf.alertKeyShare show];
                        return ;
                    }
                    [safeSelf.hud hide:YES];
                    safeSelf.alertKeyShare.title = @"✅";
                    safeSelf.alertKeyShare.message = @"分享成功";
                    [safeSelf.alertKeyShare show];
                });
                
               
            }
            else{
                HWLog(@"error:%@",connectionError);
                safeSelf.alertKeyShare.title = @"❌";
                safeSelf.alertKeyShare.message = @"分享失败";
            }
        }];
    }
    else
    {
        HWLog(@"数据有误");
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{

    if (buttonIndex == 0) {
    
        HWLog(@"----------buttonIndex-----------%ld",(long)buttonIndex);
        
        if (self.circleOfFriendsBtn.selected) {
            HWLog(@"----------circleOfFriendsBtn---------------");
            //SSDKPlatformSubTypeWechatTimeline
            //http://112.124.22.101:28080/find/details.html?alarmId=
            [self simplyShare:SSDKPlatformSubTypeWechatTimeline];
        }else if (self.qzoneBtn.selected){
            HWLog(@"----------qzoneBtn---------------");
            [self simplyShare:SSDKPlatformSubTypeQZone];
        }else if (self.weiboBtn.selected){
            HWLog(@"----------weiboBtn---------------");
            [self simplyShare:SSDKPlatformTypeSinaWeibo];
        }else{
            HWLog(@"----------------------------------");
        }
    }
}

- (void)simplyShare:(SSDKPlatformType)platformType{
    NSString *nickName = kNickName;
    
    NSString *contentStr = nil;
    if (![self.textview.text isEqualToString:@""]) {
        HWLog(@"------%@",self.textview.text);
        
        contentStr = self.textview.text;
    }else{
        contentStr = self.textview.placeholder;
    }
    
    /**
     * 在简单分享中，只要设置共有分享参数即可分享到任意的社交平台
     **/
    __weak SharePageViewController *theController = self;
    [theController showLoadingView:YES];
    
    //创建分享参数
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    [shareParams SSDKEnableUseClientShare];
    NSArray* imageArray = @[[UIImage imageNamed:@"AppIcon120"]];
    
    if (imageArray) {
        NSString *urlStr = [NSString stringWithFormat:@"%@:28080/find/details.html?alarmId=%@",kUrlHead,self.codeDict[@"alarmid"]];
        HWLog(@"-----------%@",urlStr);
        [shareParams SSDKSetupShareParamsByText:contentStr
                                         images:imageArray
                                            url:[NSURL URLWithString:urlStr]
                                          title:nickName
                                           type:SSDKContentTypeAuto];
        
        
        //进行分享
        [ShareSDK share:platformType
             parameters:shareParams
         onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
             
             [theController showLoadingView:NO];
             
             switch (state) {
                 case SSDKResponseStateSuccess:
                 {
                     UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享成功"
                                                                         message:nil
                                                                        delegate:nil
                                                               cancelButtonTitle:@"确定"
                                                               otherButtonTitles:nil];
                     [alertView show];
                     break;
                 }
                 case SSDKResponseStateFail:
                 {
                     UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享失败"
                                                                         message:[NSString stringWithFormat:@"%@", error]
                                                                        delegate:nil
                                                               cancelButtonTitle:@"确定"
                                                               otherButtonTitles:nil];
                     [alertView show];
                     break;
                 }
                 case SSDKResponseStateCancel:
                 {
                     UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享已取消"
                                                                         message:nil
                                                                        delegate:nil
                                                               cancelButtonTitle:@"确定"
                                                               otherButtonTitles:nil];
                     [alertView show];
                     break;
                 }
                 default:
                     break;
             }
         }];
    }
}

/**
 *  显示加载动画
 *
 *  @param flag YES 显示，NO 不显示
 */
- (void)showLoadingView:(BOOL)flag
{
    if (flag)
    {
        [self.view addSubview:self.panelView];
        [self.loadingView startAnimating];
    }
    else
    {
        [self.panelView removeFromSuperview];
    }
}



@end
