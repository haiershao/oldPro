//
//  AppDelegate.m
//  HuaWo
//
//  Created by circlely on 1/18/16.
//  Copyright © 2016 circlely. All rights reserved.
//

#import "AppDelegate.h"
#import "AHCServerCommunicator.h"
#import "AudioSessionManager.h"
#import "AlbumManager.h"

#import <ShareSDK/ShareSDK.h>
#import <ShareSDKConnector/ShareSDKConnector.h>
#import "UMFeedback.h"
#import "UMessage.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import "UMOpus.h"
#import "WXApi.h"
#import "WeiboSDK.h"

#import "RDVTabBarController.h"
#import "RDVTabBarItem.h"
#import "DiscoveryController.h"
#import "CameraViewController.h"
#import "PersonalCenterViewController.h"
#import "AlbumController.h"
#import <LBClearCacheTool/LBClearCacheTool.h>
#import "HWCameraRecorderView.h"
#import "HWCameraRecorderViewController.h"
#import "CameraViewController.h"
#include <sys/param.h>
#include <sys/mount.h>
#import "SYRecordVideoController.h"
#import "SYVideoListController.h"
#import "CusNavigationController.h"
#import "HWUserInstanceInfo.h"
#import "MBProgressHUD.h"
#define KCachesPath [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]
@interface AppDelegate ()<HWCameraRecorderViewControllerDelegate, CameraViewControllerDelegate>
{
    BOOL isSupportOrient;
    NSInteger _fileSize;
    BOOL _isCameraRecorder;
}

@property (copy, nonatomic) NSMutableString *localDataPath;
@property (copy, nonatomic) NSString *fileSizeStr;
@property (assign, getter=isDeleteDataSuccess,nonatomic) BOOL DeleteDataSuccess;
@property (strong, nonatomic) NSArray *documents;
@property (strong, nonatomic) NSArray *documents1;
@property (strong, nonatomic) HWCameraRecorderViewController *cameraVc;
@property (strong, nonatomic) CameraViewController *cameraViewVc;
@property (strong, nonatomic) UIAlertView *alertLeftSpace;
@property (strong, nonatomic) UIAlertView *alertWiFi;
@end

@implementation AppDelegate

//- (void)cameraRecorderView:(HWCameraRecorderView *)cameraRecorderView{
//
//    cameraRecorderView.hidden = YES;
//    _isCameraRecorder = NO;
//    isSupportOrient = NO;
//    [self exchangeScreen:cameraRecorderView];
//}

- (void)cameraViewController:(CameraViewController *)cameraViewController{
    UIViewController *vc = [self setupViewControllers];
    vc.view.hidden = YES;
    HWCameraRecorderViewController *cameraVc = [HWCameraRecorderViewController cameraRecorderViewController];
    self.window.rootViewController = cameraVc;
}

- (void)cameraRecorderViewController:(HWCameraRecorderViewController *)cameraRecorderViewController{
    _isCameraRecorder = NO;
    cameraRecorderViewController.view.hidden = YES;
    self.window.rootViewController = [self setupViewControllers];
    [self application:[UIApplication sharedApplication] supportedInterfaceOrientationsForWindow:self.window];
}

//- (void)exchangeScreen:(HWCameraRecorderView *)cameraRecorderView{
//
//    [self application:[UIApplication sharedApplication] supportedInterfaceOrientationsForWindow:self.window];
//}

- (id)init {
    self = [super init];
    if (self) {
        
        _isCameraRecorder = YES;
        isSupportOrient = NO;
        
        self.cameraViewVc = [CameraViewController cameraViewController];
        //        self.cameraViewVc.delegate = self;
        [DZNotificationCenter addObserver:self selector:@selector(exchangeVC:) name:@"cameraViewControllerIntoVc" object:nil];
        
        [DZNotificationCenter addObserver:self selector:@selector(exchangeRootVC:) name:@"HWCameraRecorderViewControllerToCameraVc" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(isSupportOrientionY) name:KUIControllerIsSupportOrientionY object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(isSupportOrientionN) name:KUIControllerIsSupportOrientionN object:nil];
    }
    
    return self;
}

- (void)exchangeVC:(NSNotification *)note{
    _isCameraRecorder = YES;
    SYRecordVideoController *land= [[SYRecordVideoController alloc] initWithNibName:NSStringFromClass([SYRecordVideoController class]) bundle:nil];
    //SYRecordVideoController *land = [[SYRecordVideoController alloc]init];
    self.window.rootViewController = land;
    [self application:[UIApplication sharedApplication] supportedInterfaceOrientationsForWindow:self.window];
}

- (void)exchangeRootVC:(NSNotification *)note{
    
    //    HWCameraRecorderViewController *cameraVc = [HWCameraRecorderViewController cameraRecorderViewController];
    self.window.rootViewController = [self setupViewControllers];
    [self application:[UIApplication sharedApplication] supportedInterfaceOrientationsForWindow:self.window];
}

- (void)isSupportOrientionY {
    isSupportOrient = YES;
    
    
}

- (void)isSupportOrientionN {
    isSupportOrient = YES;
    
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self UserRegisterToken];
    [self intoViewingTerminal:launchOptions];
    
    [self intoCameraRecorder];
    
    self.alertLeftSpace = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title", nil) message:@"" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    self.alertLeftSpace.message = [self freeDiskSpaceInBytes];
    
    return YES;
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    if (_allowRotation == YES) {
        return UIInterfaceOrientationMaskLandscapeRight|UIInterfaceOrientationMaskLandscapeLeft|UIInterfaceOrientationMaskPortrait;
    }else{
        return UIInterfaceOrientationMaskPortrait;
    }
}

- (void)dealloc{
    
    self.alertLeftSpace.hidden = YES;
}

- (NSString *) freeDiskSpaceInBytes{
    struct statfs buf;
    long long freespace = -1;
    if(statfs("/var", &buf) >= 0){
        freespace = (long long)(buf.f_bsize * buf.f_bfree);
    }
    
    return [NSString stringWithFormat:@"手机剩余存储空间为：%qi G" ,freespace/1024/1024/1024];
}

- (void)intoViewingTerminal:(NSDictionary *)launchOptions{
    
    //电话过程中进入后台 打开app 下移20像素问题
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector (layoutControllerSubViews)name: UIApplicationDidChangeStatusBarFrameNotification object:nil];
    [self startUmengSDKWithOptions:launchOptions];
    [self initBaseEnv];
    [self initUI];
    [self initBusiness];
    [self initShareSDK];
}

- (void)intoCameraRecorder{
    _isCameraRecorder = NO;
    
    //    [self initCameraUI];
}

- (void)initCameraUI{
    
    HWCameraRecorderViewController *cameraVc = [HWCameraRecorderViewController cameraRecorderViewController];
    cameraVc.delegate = self;
    self.cameraVc = cameraVc;
    cameraVc.view.frame = CGRectMake(0, 0, screenW, screenH);
    NSArray *windows = [UIApplication sharedApplication].windows;
    UIWindow *window = [windows objectAtIndex:0];
    window.rootViewController = cameraVc;
    
    //设置状态栏的字体颜色模式
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    //设置状态栏是否隐藏
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    //tabbarViewController *tabbarVC = [tabbarViewController shareTabbarController_iphone];
    //TabbarVC *tabbarVC = [[TabbarVC alloc] initWithNibName:@"TabbarVC" bundle:nil];
    
    //    self.window.backgroundColor = [UIColor whiteColor];
}

//- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
//
//    return [ShareSDK];
//}
//
//- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
//
//    return YES;
//}

- (void)applicationWillResignActive:(UIApplication *)application {
    
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [DZNotificationCenter postNotificationName:@"DidEnterBackgroundSTOP" object:nil];
    //    [self clearData];
    [self removeMobileVideoAlbumFile];
}
- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the app          lication was previously in the background, optionally refresh the user interface.
     [DZNotificationCenter postNotificationName:@"DidBecomeActiveSTART" object:nil];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    
}
- (void)removeMobileVideoAlbumFile{
    
    NSString *dirName = @"mobileAlbum";
    NSString *imageDir = [NSString stringWithFormat:@"%@/%@", KCachesPath, dirName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:imageDir error:nil];
}

//检测用户注册
- (void)UserRegisterToken {
    __weak typeof(self) weakself = self;
    NSDictionary *dict = @{
                           @"did":identifierForVendor,
                           @"stype":@"111",
                           @"license":@"1"
                           };
    
    APIRequest *request = [[APIRequest alloc] initWithApiPath:@"/ControlCenter/v3/restapi/doaction" method:APIRequestMethodPost];
    request.urlQueryParameters = @{
                                   @"action":@"dev_register",
                                   @"para":dict
                                   };
    NSLog(@"request---%@",request);
    [[APIRequestOperationManager sharedRequestOperationManager] requestAPI:request completion:^(id result, NSError *error) {
        NSDictionary *dict = result[@"token"];
        NSString *str1 = [NSString stringWithFormat:@"%@",dict];
        
        
        [weakself UserNickNameRegisterGetToken:str1];
        NSLog(@"------接口结果%@-----%@",result,error);
    }];
}
- (void)UserNickNameRegisterGetToken:(NSString *)token {
    
    APIRequest *request = [[APIRequest alloc] initWithApiPath:@"/ControlCenter/v3/restapi/doaction" method:APIRequestMethodPost];
    request.urlQueryParameters = @{
                                   @"action":@"dev_getstatus",
                                   @"token":token
                                   };
    NSLog(@"request---%@",request);
    [[APIRequestOperationManager sharedRequestOperationManager] requestAPI:request completion:^(id result, NSError *error) {
        // NSDictionary *dict = result[@"data"][@"nickname"];
        HWUserInstanceInfo *account = [HWUserInstanceInfo accountWithDict:result];
        NSLog(@"------接口结果%@-----%@",result,error);
    }];      
    
}

- (void)clearData{
    
    HWLog(@"-----------------------onClearAllCache");
    
    _documents = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    
    for (_localDataPath in _documents) {
        
        NSInteger fileSize = [LBClearCacheTool getCacheSizeWithFilePath:_localDataPath];
        _fileSize = fileSize;
        HWLog(@"---------------fileSize:[%ld]",(long)(fileSize+=fileSize));
        
        if (fileSize > 1000 * 1000)
        {
            _fileSizeStr = [NSString stringWithFormat:@"确定要删除%.1fM数据",fileSize / 1000.0f /1000.0f];
        }else if (fileSize > 1000)
        {
            _fileSizeStr = [NSString stringWithFormat:@"确定要删除%.1fKB数据",fileSize / 1000.0f ];
            
        }else
        {
            _fileSizeStr = [NSString stringWithFormat:@"确定要删除%.1fB数据",fileSize / 1.0f];
        }
        
    }
    
    _documents1 = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    for (_localDataPath in _documents1) {
        
        NSInteger fileSize1 = [LBClearCacheTool getCacheSizeWithFilePath:_localDataPath];
        
        HWLog(@"---------------fileSize:[%ld]",(long)(fileSize1 = fileSize1 + _fileSize));
        
        if (fileSize1 > 1000 * 1000)
        {
            _fileSizeStr = [NSString stringWithFormat:@"确定要删除%.1fM数据",fileSize1 / 1000.0f /1000.0f];
        }else if (fileSize1 > 1000)
        {
            _fileSizeStr = [NSString stringWithFormat:@"确定要删除%.1fKB数据",fileSize1 / 1000.0f ];
            
        }else
        {
            _fileSizeStr = [NSString stringWithFormat:@"确定要删除%.1fB数据",fileSize1 / 1.0f];
        }
        
    }
    
    for (NSString *path in _documents) {
        _DeleteDataSuccess = [LBClearCacheTool clearCacheWithFilePath:path];
    }
    
    for (NSString *path in _documents1) {
        _DeleteDataSuccess = [LBClearCacheTool clearCacheWithFilePath:path];
    }
    HWLog(@"applicationWillTerminate clearData==%@",_fileSizeStr);
}

- (void)layoutControllerSubViews{
    
    self.window.frame = CGRectMake(0, 0, self.window.frame.size.width, self.window.frame.size.height);
}

- (void)startUmengSDKWithOptions:(NSDictionary *)launchOptions {
    
    [UMFeedback setAppkey:kUmengAppkey];
    [UMFeedback setLogEnabled:NO];
    [UMOpus setAudioEnable:YES];
    [UMessage startWithAppkey:kUmengAppkey launchOptions:launchOptions];
    [UMessage setLogEnabled:NO];
}

- (void)initUI {
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    //    self.window.backgroundColor = [UIColor whiteColor];
    
    //设置状态栏的字体颜色模式
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    //设置状态栏是否隐藏
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    //tabbarViewController *tabbarVC = [tabbarViewController shareTabbarController_iphone];
    //TabbarVC *tabbarVC = [[TabbarVC alloc] initWithNibName:@"TabbarVC" bundle:nil];
    
    
    
    self.window.rootViewController = [self setupViewControllers];
    [self.window makeKeyAndVisible];
    [self customizeInterface];
    
    
}

- (void)initBaseEnv {
    
    [[AHCServerCommunicator sharedAHCServerCommunicator] start];
    
    //启动声音session管理
    [[AudioSessionManager defaultAudioSessionManager] start];
    
}

- (void)initBusiness{
    
    [AlbumManager shareAlbumManager];
    
    //[StreamerAlbumManager shareStreamerAlbumManager];
    
}

- (void)initShareSDK {
    
    [ShareSDK registerApp:kShareSDKAppkey activePlatforms:@[
                                                            @(SSDKPlatformTypeSinaWeibo),
                                                            @(SSDKPlatformTypeWechat),
                                                            @(SSDKPlatformTypeQQ)]
                 onImport:^(SSDKPlatformType platformType) {
                     switch (platformType)
                     {
                         case SSDKPlatformTypeWechat:
                             [ShareSDKConnector connectWeChat:[WXApi class]];
                             break;
                         case SSDKPlatformTypeQQ:
                             [ShareSDKConnector connectQQ:[QQApiInterface class] tencentOAuthClass:[TencentOAuth class]];
                             break;
                         case SSDKPlatformTypeSinaWeibo:
                             [ShareSDKConnector connectWeibo:[WeiboSDK class]];
                             break;
                         default:
                             break;
                     }
                 } onConfiguration:^(SSDKPlatformType platformType, NSMutableDictionary *appInfo) {
                     
                     switch (platformType)
                     {
                         case SSDKPlatformTypeSinaWeibo:
                             //设置新浪微博应用信息,其中authType设置为使用SSO＋Web形式授权
                             [appInfo SSDKSetupSinaWeiboByAppKey:KSinaWeiboAppKey_ssdk
                                                       appSecret:KSinaWeiboAppSecret_ssdk
                                                     redirectUri:@"http://www.sharesdk.cn"
                                                        authType:SSDKAuthTypeBoth];
                             break;
                         case SSDKPlatformTypeWechat:
                             [appInfo SSDKSetupWeChatByAppId:kWeiXinAppId
                                                   appSecret:kWeiXinAppSecret];
                             break;
                         case SSDKPlatformTypeQQ:
                             [appInfo SSDKSetupQQByAppId:kQQAppId
                                                  appKey:kQQAppKey
                                                authType:SSDKAuthTypeBoth];
                             break;
                         default:
                             break;
                     }
                     
                 }];
    
}

#pragma mark - Methods

- (UIViewController *)setupViewControllers {
    _isCameraRecorder = NO;
    UIViewController *firstViewController = [[DiscoveryController alloc] initWithNibName:@"DiscoveryController" bundle:nil];
    UIViewController *firstNavigationController = [[UINavigationController alloc]
                                                   initWithRootViewController:firstViewController];
    
    UIViewController *secondViewController = [[CameraViewController alloc] initWithNibName:@"CameraViewController" bundle:nil];
    UIViewController *secondNavigationController = [[UINavigationController alloc]
                                                    initWithRootViewController:secondViewController];
    
    UIViewController *thirdViewController = [[SYVideoListController alloc] initWithNibName:NSStringFromClass([SYVideoListController class]) bundle:nil];
    //CusNavViewController *nav = [[CusNavViewController alloc]initWithRootViewController:vc];
    
    
    UIViewController *thirdNavigationController = [[UINavigationController alloc]
                                                   initWithRootViewController:thirdViewController];
    [self.window addSubview:thirdViewController.view];
    UIViewController *fourViewController = [[PersonalCenterViewController alloc] initWithNibName:@"PersonalCenterViewController" bundle:nil];
    UIViewController *fourNavigationController = [[UINavigationController alloc]
                                                  initWithRootViewController:fourViewController];
    
    
    RDVTabBarController *tabBarController = [RDVTabBarController shareTabBar];
    [tabBarController setViewControllers:@[firstNavigationController, secondNavigationController,
                                           thirdNavigationController, fourNavigationController]];
    //self.viewController = tabBarController;
    
    [self customizeTabBarForController:tabBarController];
    
    return tabBarController;
}


- (void)customizeTabBarForController:(RDVTabBarController *)tabBarController {
    UIImage *finishedImage = [UIImage imageNamed:@"tabbar_selected_background"];
    UIImage *unfinishedImage = [UIImage imageNamed:@"tabbar_selected_background"];
    NSArray *selectedImages = @[@"tab_find_focus", @"tab_camera_focus",@"tabbar_icon_album", @"tab_my_focus"];
    NSArray *unselectedImages = @[@"tab_find",@"tab_camera",@"list_icon_album_un",@"tab_my"];
    
    NSArray *itemTitles = @[NSLocalizedString(@"tabbar_cloud_storage_label", nil),NSLocalizedString(@"tabbar_my_camera_label", nil),NSLocalizedString(@"tabbar_album", nil),NSLocalizedString(@"tabbar_me_label", nil)];
    
    NSInteger index = 0;
    for (RDVTabBarItem *item in [[tabBarController tabBar] items]) {
        
        item.title = [itemTitles objectAtIndex:index];
        
        item.unselectedTitleAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
        item.selectedTitleAttributes = @{NSForegroundColorAttributeName: kHuaWoTintColor};
        [item setBackgroundSelectedImage:finishedImage withUnselectedImage:unfinishedImage];
        UIImage *selectedimage = [UIImage imageNamed:[selectedImages objectAtIndex:index]];
        UIImage *unselectedimage = [UIImage imageNamed:[unselectedImages objectAtIndex:index]];
        [item setFinishedSelectedImage:selectedimage withFinishedUnselectedImage:unselectedimage];
        
        index++;
    }
}

- (void)customizeInterface {
    UINavigationBar *navigationBarAppearance = [UINavigationBar appearance];
    
    UIImage *backgroundImage = nil;
    NSDictionary *textAttributes = nil;
    
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        backgroundImage = [UIImage imageNamed:@"navigationbar_background_tall"];
        
        textAttributes = @{
                           NSFontAttributeName: [UIFont boldSystemFontOfSize:18],
                           NSForegroundColorAttributeName: [UIColor blackColor],
                           };
    } else {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
        backgroundImage = [UIImage imageNamed:@"navigationbar_background"];
        
        textAttributes = @{
                           UITextAttributeFont: [UIFont boldSystemFontOfSize:18],
                           UITextAttributeTextColor: [UIColor blackColor],
                           UITextAttributeTextShadowColor: [UIColor clearColor],
                           UITextAttributeTextShadowOffset: [NSValue valueWithUIOffset:UIOffsetZero],
                           };
#endif
    }
    
    [navigationBarAppearance setBackgroundImage:backgroundImage
                                  forBarMetrics:UIBarMetricsDefault];
    [navigationBarAppearance setTitleTextAttributes:textAttributes];
}
@end
