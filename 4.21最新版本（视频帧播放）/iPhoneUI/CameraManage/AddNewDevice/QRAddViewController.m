//
//  QRAddViewController.m
//  HuaWo
//
//  Created by circlely on 1/21/16.
//  Copyright © 2016 circlely. All rights reserved.
//

#import "QRAddViewController.h"
#import "MBProgressHUD.h"
#import "AHCServerCommunicator.h"
#import "MemberData.h"

#define kQRCode_CID      @"cid"
#define kQRCode_DeviceID @"deviceid"
#define kQRCode_Username @"username"
#define kQRCode_Password @"password"

static const CGFloat kPadding = 40;

@interface QRAddViewController ()<AVCaptureMetadataOutputObjectsDelegate>

@property (strong, nonatomic) AVCaptureSession *session;

@property (strong, nonatomic) UIView *backgroundView;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIImageView *lightLineView;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UILabel *topTipsLabel;
@property (weak, nonatomic) IBOutlet UILabel *buttomTipsLabel;
@property (nonatomic, assign) BOOL isAnimating;
@end

@implementation QRAddViewController
{
    CGRect cropRect;
    CGFloat screenHeight;
    CGFloat screenWidth;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    
    CGFloat rectSize = self.view.frame.size.width - kPadding * 2;
    cropRect = CGRectMake(kPadding, (self.view.frame.size.height - rectSize) / 2, rectSize, rectSize);
    screenHeight = self.view.frame.size.height;
    screenWidth = self.view.frame.size.width;
    self.isAnimating = YES;
    
    [self setUpNav];
    
    
    
    self.topTipsLabel.text = NSLocalizedString(@"warnning_scan_qrcode_instruction1", nil);
    self.buttomTipsLabel.text = NSLocalizedString(@"warnning_scan_qrcode_instruction", nil);
    
    self.cancelButton.hidden = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    //判断相机权限
    [self isCameraAuth];
    
    [self addGrid];
    [self addBackgroundImageView];
    
}

- (void)setUpNav{

    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"title_back_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonItemAction)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 44)];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = NSLocalizedString(@"root_sidebar_add_cid_by_qrcode_label", nil);
    self.navigationItem.titleView = titleLabel;
}

- (void)isCameraAuth {
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    self.session = [[AVCaptureSession alloc] init];
    
    [self.session setSessionPreset:AVCaptureSessionPresetHigh];
    
    [self.session addInput:input];
    [self.session addOutput:output];

    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    self.session = [[AVCaptureSession alloc] init];
    
    [self.session setSessionPreset:AVCaptureSessionPresetHigh];
    
    [self.session addInput:input];
    [self.session addOutput:output];
    
    
    _backgroundView = [[UIView alloc] initWithFrame:self.view.frame];
    _backgroundView.backgroundColor = [UIColor blackColor];
    _backgroundView.alpha = 0.8f;
    [self.view addSubview:_backgroundView];
    
    output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
    
    AVCaptureVideoPreviewLayer *layer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    layer.frame = self.view.layer.bounds;
    
    [self.view.layer insertSublayer:layer atIndex:0];
}

- (void)viewDidAppear:(BOOL)animated{
    
    [_backgroundView removeFromSuperview];
    
    [self.session startRunning];
    
    [self startAnimat];
}

- (void)viewDidDisappear:(BOOL)animated {
    
    [self.session stopRunning];
    
    self.isAnimating = NO;
}

- (void)leftBarButtonItemAction {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)addGrid{
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(cropRect.origin.x, cropRect.origin.y, cropRect.size.width, 0)];
    self.imageView.image = [UIImage imageNamed:@"grid_image"];
    self.imageView.contentMode = UIViewContentModeTop;
    self.imageView.clipsToBounds = YES;
    self.imageView.hidden = NO;
    [self.view addSubview:self.imageView];
    
    self.lightLineView = [[UIImageView alloc] initWithFrame:CGRectMake(cropRect.origin.x, cropRect.origin.y, cropRect.size.width, 2)];
    self.lightLineView.image = [UIImage imageNamed:@"lightline_image"];
    self.lightLineView.contentMode = UIViewContentModeScaleToFill;
    self.lightLineView.clipsToBounds = YES;
    self.lightLineView.hidden = NO;
    [self.view addSubview:self.lightLineView];
}

- (void)addBackgroundImageView{
    UIImageView *leftView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, (screenWidth-cropRect.size.width)/2, screenHeight)];
    leftView.backgroundColor = [UIColor blackColor];
    leftView.alpha = 0.5;
    [self.view addSubview:leftView];
    
    UIImageView *rightView = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth-kPadding, 0, kPadding, screenHeight)];
    rightView.backgroundColor = [UIColor blackColor];
    rightView.alpha = 0.5;
    [self.view addSubview:rightView];
    
    UIImageView *topView = [[UIImageView alloc] initWithFrame:CGRectMake(kPadding, 0, cropRect.size.width, cropRect.origin.y)];
    topView.backgroundColor = [UIColor blackColor];
    topView.alpha = 0.5;
    [self.view addSubview:topView];
    
    UIImageView *bottomView = [[UIImageView alloc] initWithFrame:CGRectMake(kPadding, cropRect.origin.y+cropRect.size.height, cropRect.size.width, screenHeight-cropRect.origin.y-cropRect.size.height)];
    bottomView.backgroundColor = [UIColor blackColor];
    bottomView.alpha = 0.5;
    [self.view addSubview:bottomView];
    
    UIImageView *rectView = [[UIImageView alloc] initWithFrame:cropRect];
    rectView.image = [UIImage imageNamed:@"scanbox_image"];
    rectView.contentMode = UIViewContentModeScaleAspectFill;
    rectView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:rectView];
    
}

- (void)startAnimat{
    
    __typeof(self) __block safeSelf = self;
    [UIView animateWithDuration:1.2 delay:0.5 options:UIViewAnimationOptionTransitionCrossDissolve  animations:^{
        safeSelf.imageView.frame = cropRect;
        
        if (kiPhone4) {
            safeSelf.lightLineView.frame = CGRectMake(cropRect.origin.x, cropRect.size.height+112, cropRect.size.width, 8);
        }else{
            safeSelf.lightLineView.frame = CGRectMake(cropRect.origin.x, cropRect.size.height+155, cropRect.size.width, 8);
        }
        
        
        
        
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 animations:^{
            safeSelf.imageView.alpha = 0;
            safeSelf.lightLineView.alpha = 0;
        } completion:^(BOOL finished) {
            safeSelf.lightLineView.frame = CGRectMake(cropRect.origin.x, cropRect.origin.y, cropRect.size.width, 2);
            safeSelf.imageView.frame = CGRectMake(cropRect.origin.x, cropRect.origin.y, cropRect.size.width, 0);
            safeSelf.imageView.alpha = 1;
            safeSelf.lightLineView.alpha = 1;
            if (_isAnimating) {
                [safeSelf startAnimat];
            }
            
        }];
    }];
}


- (void)applicationDidEnterBackground {
    
    //程序进入后台時，將彈出的界面dismiss掉
    [self dismissViewControllerAnimated:NO completion:^{}];
}

- (void)dealloc {
    
    [self.session stopRunning];
    [[NSNotificationCenter defaultCenter] removeObserver:self];;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)cancelBtnClicked:(id)sender {
    
    
    //[self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)parseQRCodeString:(NSString *)result withCompletion:(void(^)(NSDictionary* result))aCompletionBlock failedCompletion:(void(^)())aFailedBlock{
    HWLog(@"QR--result*%@*",result);
    NSArray *array = [result componentsSeparatedByString:@"&"];
    HWLog(@"QR--array*%@*",array);
    
    if ([array count] == 4) {
        
        NSString *cid       = nil;
        
        NSString *userName  = nil;
        NSString *password  = nil;
        NSString *deviceID  = nil;
        NSInteger QRCodeFlag = 0;
        
        
            
        if ([[array objectAtIndex:3] hasPrefix:@"flag="]) {
            
            QRCodeFlag = [[[[array objectAtIndex:3] componentsSeparatedByString:@"flag="] objectAtIndex:1] intValue];
            
        }
        else if ([[array objectAtIndex:3] hasPrefix:@"flag"]) //兼容flag1 flag4 类
        {
            QRCodeFlag = [[[[array objectAtIndex:3] componentsSeparatedByString:@"flag"] objectAtIndex:1] intValue];
        }
        
        if ([[array objectAtIndex:0] hasPrefix:@"cid="]) {
            cid = [[[array objectAtIndex:0] componentsSeparatedByString:@"cid="] objectAtIndex:1];
            HWLog(@"%@",cid);
        }
        
        if ([[array objectAtIndex:1] hasPrefix:@"username="])
        {
            userName = [[[array objectAtIndex:1] componentsSeparatedByString:@"username="] objectAtIndex:1];
            HWLog(@"%@",userName);
        }
        
        if ([[array objectAtIndex:2] hasPrefix:@"password="])
        {
            password = [[[array objectAtIndex:2] componentsSeparatedByString:@"password="] objectAtIndex:1];
            HWLog(@"%@",password);
        }
        
        if ([cid length] == 0 || [userName length] == 0 || [password length] == 0 || ![self validateCID:cid]) {
            aFailedBlock();
            return;
        }
        
        aCompletionBlock(@{kQRCode_CID:cid, kQRCode_Username:userName, kQRCode_Password:password});
        return;
        
    }
    
    
    
    
    aFailedBlock();
}

- (BOOL)validateCID:(NSString *)CID
{
    if ([CID hasPrefix:@"0"]) {
        return NO;
    }
    
    NSString *CIDRegex = @"^[0-9]{8}$";
    NSPredicate *CIDTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CIDRegex];
    return [CIDTest evaluateWithObject:CID];
}

- (void)addNewServerWithDeviceID:(NSString*)deviceID
                       username:(NSString*)username
                       password:(NSString*)password
{
   
    
    
    
    
    
    MBProgressHUD* HUD = [MBProgressHUD showHUDAddedTo:self.view
                                              animated:YES
                                           configBlock:nil];
    
    __typeof(self) __block safeMyself = self;
    

}

- (void)addNewServerWithCID:(NSString*)CID
                  username:(NSString*)username
                  password:(NSString*)password
{
    MBProgressHUD* HUD = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow
                                              animated:YES
                                           configBlock:nil];
    
    
    __typeof(self) __block  safeMyself = self;
    void(^addCidSucBlk)() = ^{
        
        NSDictionary* CIDInfo = @{ kCIDInfoNumber:   CID,
                                   kCIDInfoUsername: username,
                                   kCIDInfoPassword: password};
        
        [[AHCServerCommunicator sharedAHCServerCommunicator] subscribeCID:CIDInfo];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateCameraList object:nil];
        
        HUD.detailsLabelText =  NSLocalizedString(@"warnning_cid_add_success", nil);
        HUD.labelFont = CG_BOLD_FONT(15);
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.removeFromSuperViewOnHide = YES;
        HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Checkmark.png"]];
        [HUD hide:YES afterDelay:1.0];
        
    };
    
    if ([[MemberData memberData] isMemberLogin]) {
        
       
        
    }
    else {
        
        
        [[MemberData memberData] addOneLocalCID:CID UserName:username Pwd:password];
        addCidSucBlk();
        
        
    }
    
}

#pragma mark AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    
    AVMetadataMachineReadableCodeObject *metadataObject = [metadataObjects objectAtIndex:0];
    
    __typeof(self) __weak safeSelf = self;
    
    UIWindow *window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:window animated:YES configBlock:^(MBProgressHUD *HUD) {
        
        HUD.removeFromSuperViewOnHide = YES;
    }];
    
    [self parseQRCodeString:metadataObject.stringValue withCompletion:^(NSDictionary *result) {
        
        hud.hidden = YES;
        
        if ([result count] > 0) {
            
            if ([[result allKeys] containsObject:@"deviceid"]) {
                
                [safeSelf addNewServerWithDeviceID:[result objectForKey:kQRCode_DeviceID]
                                          username:[result objectForKey:kQRCode_Username]
                                          password:[result objectForKey:kQRCode_Password]];
            }else{
                
                [safeSelf addNewServerWithCID:[result objectForKey:kQRCode_CID]
                                     username:[result objectForKey:kQRCode_Username]
                                     password:[result objectForKey:kQRCode_Password]];
                
            }
        }
        
        
        
    } failedCompletion:^{
        
        hud.detailsLabelText = NSLocalizedString(@"无效二维码", nil);
        [hud hide:YES afterDelay:1];
        
    }];
    
    [self.session stopRunning];
    
    
    //[self dismissViewControllerAnimated:YES completion:^{}];
    [self.navigationController popToRootViewControllerAnimated:YES];
    
    
}

/**
 * 让当前控制器对应的状态栏是白色
 */
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
@end
