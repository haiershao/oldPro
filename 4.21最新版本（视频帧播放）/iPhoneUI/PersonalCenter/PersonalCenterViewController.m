//
//  PersonalCenterViewController.m
//  HuaWo
//
//  Created by circlely on 1/20/16.
//  Copyright © 2016 circlely. All rights reserved.
//

#import "PersonalCenterViewController.h"
#import "PersonalCenterCell.h"
#import "MemberData.h"
#import "LoginViewController.h"
#import "PersonalInfoViewController.h"
#import "AlbumController.h"
#import "UMFeedback.h"
//#import "CommonSettingViewController.h"
#import "HWMyStoreViewController.h"
#import "HWGuideViewController.h"
#import "HWServiceCloudViewController.h"
#import "HWMyCollectionViewController.h"
#import "HWlllegalReportViewController.h"
#import "NSString+encrypto.h"
#import "NSString+Helper.h"
#import "MBProgressHUD.h"
#import "Reachability.h"
#import "HWFourBtnCell.h"
#import <LBClearCacheTool/LBClearCacheTool.h>
#import "AlbumManager.h"
#import "PersonalCenterCell.h"
#import "HWPersonalHomeCenterViewController.h"
#import "HWFansViewController.h"
#import "HWXingCheBiViewController.h"
#import "HWFcousOnViewController.h"
#import "HWSharesViewController.h"
#import "LHCleanCache.h"
#import "HWUserInstanceInfo.h"
#import "MBProgressHUD+MG.h"

#define kMenuTitle @"menuTitle"
#define kMenuSelector @"menuSelector"
#define kMenuImageName @"imagename"
#define kUid [[MemberData memberData] getMemberAccount]
#define isLogin [[MemberData memberData] isMemberLogin]
#define iconImageName [NSString stringWithFormat:@"%@.png",kUid]

#define KCachesPath [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]
@interface PersonalCenterViewController ()<UITableViewDataSource, UITableViewDelegate, PersonalInfoViewControllerDelegate, PersonalCenterCellDelegate, HWFourBtnCellDelegate>
@property (weak, nonatomic)   IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *sections;
@property (strong, nonatomic) NSMutableArray *FirstSecCells;
@property (strong, nonatomic) NSMutableArray *SecondSecCells;
@property (strong, nonatomic) NSMutableArray *ThirdSecCells;
@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UILabel *versionNumLabel;
@property (strong, nonatomic) NSMutableArray *ForthSecCells;
@property (strong, nonatomic) NSMutableArray *ForthSecCells0;
@property (strong, nonatomic) NSMutableArray *FiveSecCells;
@property (strong, nonatomic) MBProgressHUD *hud;
@property (strong, nonatomic) UIAlertView *alertBindQuery;
@property (weak, nonatomic) PersonalCenterCell *iconCell;
@property (strong, nonatomic) UIImage *iconImage;
@property (copy, nonatomic) NSString *nickname;
@property (strong, nonatomic) UIAlertView *alertWiFi;

@property (strong, nonatomic) NSMutableArray *FourSecCells;


@property (strong, nonatomic) UIImageView *iconImageView;
@property (copy, nonatomic) NSString *pictureName;
@property (copy, nonatomic) NSString *filePath;
@property (copy, nonatomic) NSString *fileKey;
@property (strong, nonatomic) UIImage *userIconImage;
@property (copy, nonatomic) NSString *fullPath;
@property (copy, nonatomic) NSMutableString *localDataPath;
@property (copy, nonatomic) NSString *fileSizeStr;
@property (copy, nonatomic) NSString *fileSizeStr0;
@property (strong, nonatomic) NSArray *documents;
@property (strong, nonatomic) NSArray *documents1;
@property (assign, getter=isDeleteDataSuccess,nonatomic) BOOL DeleteDataSuccess;
@property (strong, nonatomic) UIAlertView *alertPersionInfo;
@property (copy, nonatomic) NSString *deviceNickname;
@end

@implementation PersonalCenterViewController{
    
    NSInteger _fileSize;
    
}

- (void)HWFourBtnCell:(HWFourBtnCell *)fourCell fourBtn:(UIButton *)btn{
    
    if (btn.tag == 1) {
        HWLog(@"============%ld==============",(long)btn.tag);
        [[RDVTabBarController shareTabBar] setTabBarHidden:YES animated:NO];
        HWSharesViewController *shareVc = [HWSharesViewController sharesViewController];
        [self.navigationController pushViewController:shareVc animated:YES];
    }else if (btn.tag == 2){
        HWLog(@"============%ld==============",(long)btn.tag);
        [[RDVTabBarController shareTabBar] setTabBarHidden:YES animated:NO];
        HWXingCheBiViewController *xingcheVc = [HWXingCheBiViewController xingCheBiViewController];
        [self.navigationController pushViewController:xingcheVc animated:YES];
        
    }else if (btn.tag == 3){
        HWLog(@"============%ld==============",(long)btn.tag);
        [[RDVTabBarController shareTabBar] setTabBarHidden:YES animated:NO];
        HWFcousOnViewController *focusVc = [HWFcousOnViewController fcousOnViewController];
        [self.navigationController pushViewController:focusVc animated:YES];
        
    }else if (btn.tag == 4){
        HWLog(@"============%ld==============",(long)btn.tag);
        [[RDVTabBarController shareTabBar] setTabBarHidden:YES animated:NO];
        HWFansViewController *fansVc = [HWFansViewController fansViewController];
        [self.navigationController pushViewController:fansVc animated:YES];
        
    }
}

- (void)personalCenterCell:(PersonalCenterCell *)personalCenterCell{
    [[RDVTabBarController shareTabBar] setTabBarHidden:YES animated:NO];
    //HWPersonalHomeCenterViewController *personalHome = [HWPersonalHomeCenterViewController personalHomeCenterViewController];
    // [self.navigationController pushViewController:personalHome animated:YES];
    
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    
    [viewController viewDidAppear:animated];
}

- (void)viewDidAppear: (BOOL)animated{
    //    [super viewDidAppear:YES];
    //加载头像
    [self setIconImage];
}

- (void)resetIconImage{
    
    self.iconCell.accountIconImageView.image = [UIImage imageNamed:@"find_new_head_bg"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.view.backgroundColor = kBackgroundColor;
    [self setUpNav];
    
    [self setUpTableView];
    
    //    [self onClearAllCache];
    
    [self onAllCache];
    
    [DZNotificationCenter addObserver:self selector:@selector(updateView) name:KLoginSucceed object:nil];
    [DZNotificationCenter addObserver:self selector:@selector(updateView) name:KLoginOutMsg object:nil];
    [DZNotificationCenter addObserver:self selector:@selector(getIconImage:) name:@"iconImageName" object:nil];
    [self initSectionArray];
    
    PersonalInfoViewController *pInfoVc = [[PersonalInfoViewController alloc] init];
    pInfoVc.delegate = self;
    
    [DZNotificationCenter addObserver:self selector:@selector(updatePCenterView) name:KLoginOutMsg object:nil];
    [DZNotificationCenter addObserver:self selector:@selector(updatePCenterView) name:KLoginOutMsg object:nil];
    HWLog(@"-------------kUid-----88----------%@",kUid);
    
    //    if (!isLogin) {
    //        self.iconCell.accountIconImageView.image = [UIImage imageNamed:@"find_new_head_bg"];
    //        HWLog(@"---------------------==============-----------------------------");
    //    }
    if (![self isConnectionAvailable]) {
        self.iconCell.accountIconImageView.image = [UIImage imageNamed:@"find_new_head_bg"];
        HWLog(@"---------------------==============-----------------------------");
    }
    
    [DZNotificationCenter postNotificationName:@"iconImageToPersonalHomeVc" object:self.nickname];
    
    
    
    [self.tableView reloadData];
}

//- (void)didPresentAlertView:(UIAlertView *)alertView
//{
//    [UIView beginAnimations:@"" context:nil];
//    [UIView setAnimationDuration:0.1];
//    alertView.transform = CGAffineTransformRotate(alertView.transform, M_PI / 2);
//    [UIView commitAnimations];
//}


- (void)onAllCache{
    
    _documents = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    
    for (_localDataPath in _documents) {
        
        NSInteger fileSize = [LBClearCacheTool getCacheSizeWithFilePath:_localDataPath];
        _fileSize = fileSize;
        HWLog(@"---------------fileSize:[%ld]",(long)(fileSize+=fileSize));
        
        if (fileSize > 1000 * 1000)
        {
            _fileSizeStr0 = [NSString stringWithFormat:@"%.1fM数据",fileSize / 1000.0f /1000.0f];
        }else if (fileSize > 1000)
        {
            _fileSizeStr0 = [NSString stringWithFormat:@"%.1fKB数据",fileSize / 1000.0f ];
            
        }else
        {
            _fileSizeStr0 = [NSString stringWithFormat:@"%.1fB数据",fileSize / 1.0f];
        }
        
    }
    
    _documents1 = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    for (_localDataPath in _documents1) {
        
        NSInteger fileSize1 = [LBClearCacheTool getCacheSizeWithFilePath:_localDataPath];
        
        HWLog(@"---------------fileSize:[%ld]",(long)(fileSize1 = fileSize1 + _fileSize));
        
        if (fileSize1 > 1000 * 1000)
        {
            _fileSizeStr0 = [NSString stringWithFormat:@"%.1fM",fileSize1 / 1000.0f /1000.0f];
        }else if (fileSize1 > 1000)
        {
            _fileSizeStr0 = [NSString stringWithFormat:@"%.1fKB",fileSize1 / 1000.0f ];
            
        }else
        {
            _fileSizeStr0 = [NSString stringWithFormat:@"%.1fB",fileSize1 / 1.0f];
        }
        
    }
    [self removeMobileVideoAlbumFile];
}

- (void)removeMobileVideoAlbumFile{
    
    NSString *dirName = @"mobileAlbum";
    NSString *imageDir = [NSString stringWithFormat:@"%@/%@", KCachesPath, dirName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:imageDir error:nil];
}

//自动注册
- (void)getDeviceNickName{
    self.alertWiFi = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title", nil) message:@"" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    if (![self isConnectionAvailable]) {
        
        self.alertWiFi.title = @"❌";
        self.alertWiFi.message = @"当前无网络...";
        [self.alertWiFi show];
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
    NSURL *url = [NSURL URLWithString:urlStr];
    
    // 2. 请求
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:1 timeoutInterval:2.0f];
    
    // 3. 连接
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        // 反序列化
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
        
        NSLog(@"result---%@--%@", result,result[@"desc"]);
        NSString *str0 = [NSString stringWithFormat:@"%@",result[@"desc"]];
        if ([str0 isEqualToString:@"success"]) {
            self.nickname = result[@"nickname"];
            
        }else{
            HWLog(@"===================");
        }
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
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES configBlock:nil];
        hud.removeFromSuperViewOnHide =YES;
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"当前网络不可用，请检查网络连接";  //提示的内容
        hud.minSize = CGSizeMake(132.f, 108.0f);
        [hud hide:YES afterDelay:3];
        return NO;
    }
    
    return isExistenceNetwork;
}

- (void)getIconImage:(NSNotification *)note{
    
    UIImage *iconImage = (UIImage *)note.object;
    self.iconImage = iconImage;
}

- (void)setUpNav{
    
    self.navigationController.navigationBar.barTintColor = kNavigation7Color;
    //self.navigationItem.title = NSLocalizedString(@"tabbar_me_label", nil);
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 44)];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = NSLocalizedString(@"tabbar_me_label", nil);
    self.navigationItem.titleView = titleLabel;
}

- (void)setUpTableView{
    
    self.tableView.separatorColor = kBackgroundColor;
    self.footerView.backgroundColor = kBackgroundColor;
    self.tableView.tableFooterView = self.footerView;
    
    NSString *versionNum = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    self.versionNumLabel.text = [NSString stringWithFormat:NSLocalizedString(@"about_controller_version_num", nil),versionNum];
}

- (void)updatePCenterView{
    
    self.iconCell.accountIconImageView.image = [UIImage imageNamed:@"find_new_head_bg"];
    HWLog(@"---------------------===============-----------------------------");
}

- (void)setIconImage{
    
    //加载首先访问本地沙盒是否存在相关图片
    
    NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[NSString stringWithFormat:@"iconimage%@",identifierForVendor]];
    UIImage *savedImage = [UIImage imageWithContentsOfFile:fullPath];
    
    self.iconImage = savedImage;
    if (!self.iconImage) {
        PersonalInfoViewController *pInfoVc = [[PersonalInfoViewController alloc] init];
        self.iconImage = [pInfoVc downLoadIconImage];
        
        if (!self.iconImage) {
            //默认头像
            self.iconCell.accountIconImageView.image = [UIImage imageNamed:@"find_new_head_bg"];
        }
        self.iconCell.accountIconImageView.image = self.iconImage;
    }else {
        
        self.iconCell.accountIconImageView.image = self.iconImage;
        HWLog(@"----%@----PersonalCenterViewController-----savedImage---------%@--%@",fullPath,savedImage,self.iconImage);
    }
    
    //    if (!savedImage)
    //    {
    //
    //        //默认头像
    //        self.iconCell.accountIconImageView.image = [UIImage imageNamed:@"find_new_head_bg"];
    //    }
    //    else
    //    {
    ////        if (!isLogin) {
    ////            return;
    ////        }else{
    ////
    ////            if (!savedImage) {
    ////                PersonalInfoViewController *pInfoVc = [[PersonalInfoViewController alloc] init];
    ////                self.iconImage = [pInfoVc downLoadIconImage];
    ////                self.iconCell.accountIconImageView.image = self.iconImage;
    ////            }else{
    ////
    ////                self.iconCell.accountIconImageView.image = savedImage;
    ////                HWLog(@"----%@----PersonalCenterViewController-----savedImage---------%@--%d--%@",fullPath,savedImage,isLogin,kUid);
    ////            }
    ////
    ////        }
    //        if (![self isConnectionAvailable]) {
    //            return;
    //        }else{
    //
    //            if (!savedImage) {
    //                PersonalInfoViewController *pInfoVc = [[PersonalInfoViewController alloc] init];
    //                self.iconImage = [pInfoVc downLoadIconImage];
    //                self.iconCell.accountIconImageView.image = self.iconImage;
    //            }else{
    //
    //                self.iconCell.accountIconImageView.image = savedImage;
    //                HWLog(@"----%@----PersonalCenterViewController-----savedImage---------%@--%d--%@",fullPath,savedImage,isLogin,kUid);
    //            }
    //
    //        }
    //
    //
    //    }
    //    self.iconCell.accountIconImageView.layer.cornerRadius = 32;
    //    self.iconCell.accountIconImageView.layer.masksToBounds = YES;
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [[RDVTabBarController shareTabBar] setTabBarHidden:NO animated:NO];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)viewDidLayoutSubviews {
    
    //设置tableview.separatorLine 左边顶到头
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        
        self.tableView.separatorInset = UIEdgeInsetsZero;
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutManager:)]) {
        
        self.tableView.layoutMargins = UIEdgeInsetsZero;
    }
    
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    HWLog(@"PersonalCenterViewController dealloc!!!");
}

- (void)updateView {
    
    [self initSectionArray];
    [self.tableView reloadData];
}

- (void)initSectionArray {
    
    //    self.FirstSecCells = [[NSMutableArray alloc] initWithObjects:
    //                          @{kMenuTitle:NSLocalizedString(@"tabbar_camera_label", nil),kMenuSelector:NSStringFromSelector(@selector(onMemberLogin))},
    //                          @{kMenuTitle:NSLocalizedString(@"tabbar_camera_label", nil),kMenuSelector:NSStringFromSelector(@selector(onFourBtnClick))}, nil];
    self.FirstSecCells = [[NSMutableArray alloc] initWithObjects:
                          @{kMenuTitle:NSLocalizedString(@"tabbar_camera_label", nil),kMenuSelector:NSStringFromSelector(@selector(onMemberLogin))},
                          nil];
    
    self.SecondSecCells = [[NSMutableArray alloc] initWithObjects:
                           @{kMenuTitle:NSLocalizedString(@"my_photo_album", nil),
                             kMenuImageName:@"list_icon_album",
                             kMenuSelector:NSStringFromSelector(@selector(onAlbumPressed))},
                           nil];
    
    
    //    NSArray *loginCells = [NSArray arrayWithObjects:@{kMenuTitle:NSLocalizedString(@"my_shared_lable", nil),
    //                                                      kMenuImageName:@"list_icon_share",
    //                                                      kMenuSelector:NSStringFromSelector(@selector(onMySharePressed))},
    //                           @{
    //                             kMenuTitle:NSLocalizedString(@"my_collection_lable", nil),
    //                             kMenuImageName:@"list_icon_save",
    //                             kMenuSelector:NSStringFromSelector(@selector(onCollectPressed))},
    //                           @{
    //                             kMenuTitle:NSLocalizedString(@"common_settings", nil),
    //                             kMenuImageName:@"list_icon_setting",
    //                             kMenuSelector:NSStringFromSelector(@selector(onCommonSettingsPressed))},
    //                           nil];
    //
#warning 隐藏不用的cell
    //    if ([[MemberData memberData] isMemberLogin]) {
    //
    //        [self.SecondSecCells addObjectsFromArray:loginCells];
    //    }
    
#warning 隐藏不用的cell
    //    self.ThirdSecCells = [[NSMutableArray alloc] initWithObjects:
    //                          @{
    //                            kMenuTitle:NSLocalizedString(@"root_sidebar_store_label", nil),
    //                            kMenuImageName:@"list_icon_sale",
    //                            kMenuSelector:NSStringFromSelector(@selector(myStore))},
    //                          @{
    //                            kMenuTitle:NSLocalizedString(@"cloud_service_label", nil),
    //                            kMenuImageName:@"list_icon_cloud",
    //                            kMenuSelector:NSStringFromSelector(@selector(onMyCloudPressed))},nil];
    
    
    
    self.ThirdSecCells = [[NSMutableArray alloc] initWithObjects:
                          @{
                                          kMenuTitle:NSLocalizedString(@"violation_of_regulation_and_report", nil),
                                          kMenuImageName:@"wei_zhang_ju_bao",
                                          kMenuSelector:NSStringFromSelector(@selector(onLllegalReport))},
                          
                          @{
                            kMenuTitle:NSLocalizedString(@"root_sidebar_store_label", nil),
                            kMenuImageName:@"list_icon_sale",
                            kMenuSelector:NSStringFromSelector(@selector(myStore))},nil];
    //加举报
//    - (void)dd{
//            @{
//              kMenuTitle:NSLocalizedString(@"violation_of_regulation_and_report", nil),
//              kMenuImageName:@"wei_zhang_ju_bao",
//              kMenuSelector:NSStringFromSelector(@selector(onLllegalReport))}
//        }
#warning 加上意见反馈打开这个
    //    self.ForthSecCells = [[NSMutableArray alloc] initWithObjects:
    //                          @{
    //                            kMenuTitle:NSLocalizedString(@"root_sidebar_help_btn", nil),
    //                            kMenuImageName:@"list_icon_guide",
    //                            kMenuSelector:NSStringFromSelector(@selector(onGuidePressed))},
    //                          @{
    //                            kMenuTitle:NSLocalizedString(@"root_sidebar_rating_app_label", nil),
    //                            kMenuImageName:@"list_icon_score",
    //                            kMenuSelector:NSStringFromSelector(@selector(onRatingPressed))},
    //                          @{
    //                            kMenuTitle:NSLocalizedString(@"clear_all_cache", nil),
    //                            kMenuImageName:@"clear0",
    //                            kMenuSelector:NSStringFromSelector(@selector(onClearAllCache))},
    //                          @{
    //                            kMenuTitle:NSLocalizedString(@"more_controller_app_feedback_cell_label", nil),
    //                            kMenuImageName:@"list_icon_suggest",
    //                            kMenuSelector:NSStringFromSelector(@selector(onFeedbackPressed))},
    //                          nil];
    
    self.ForthSecCells = [[NSMutableArray alloc] initWithObjects:
                          @{
                            kMenuTitle:NSLocalizedString(@"root_sidebar_help_btn", nil),
                            kMenuImageName:@"list_icon_guide",
                            kMenuSelector:NSStringFromSelector(@selector(onGuidePressed))},
                          @{
                            kMenuTitle:NSLocalizedString(@"root_sidebar_rating_app_label", nil),
                            kMenuImageName:@"list_icon_score",
                            kMenuSelector:NSStringFromSelector(@selector(onRatingPressed))},
                          @{
                            kMenuTitle:NSLocalizedString(@"clear_all_cache", nil),
                            kMenuImageName:@"clear0",
                            kMenuSelector:NSStringFromSelector(@selector(onClearAllCache))},nil];
    
    //    self.FiveSecCells = [[NSMutableArray alloc] initWithObjects:
    //                          @{
    //                            kMenuTitle:NSLocalizedString(@"streamer_bind_check", nil),
    //                            kMenuImageName:@"camera_icon_delete_press",
    //                            kMenuSelector:NSStringFromSelector(@selector(onBindQuery))},nil];
    //
    self.sections = [[NSMutableArray alloc] initWithObjects:self.FirstSecCells, self.ThirdSecCells,self.ForthSecCells,  nil];
}

- (void)onClearAllCache{
    
    HWLog(@"-----------------------onClearAllCache");
    //输出缓存大小 m
    NSLog(@"%.2fm",[LHCleanCache folderSizeAtPath]);
    
    //清楚缓存
    [LHCleanCache cleanCache:^{
        NSLog(@"清除成功");
        [MBProgressHUD showMessage:@"清理完成"];
        [MBProgressHUD hideHUD];
        [self.tableView reloadData];
        
    }];
    
    
}

- (void)allCacheSize{
    
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
}

#pragma mark - AlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == 1011){
        
        if (buttonIndex == 1) {
            
            for (NSString *path in _documents) {
                _DeleteDataSuccess = [LBClearCacheTool clearCacheWithFilePath:path];
            }
            
            for (NSString *path in _documents1) {
                _DeleteDataSuccess = [LBClearCacheTool clearCacheWithFilePath:path];
            }
            
            if (_DeleteDataSuccess) {
                
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES configBlock:nil];
                hud.removeFromSuperViewOnHide =YES;
                hud.mode = MBProgressHUDModeText;
                hud.labelText = @"✅";
                [hud hide:YES afterDelay:3];
                HWLog(@"%@",NSStringFromCGRect(hud.bounds));
                [self onAllCache];
                [self.tableView reloadData];
            }else{
                
                _hud.labelText = @"❌";  //提示的内容
            }
        }
        
    }
    
}

#pragma mark --- onCellPressed---
-(void)onMemberLogin{
    
    [[RDVTabBarController shareTabBar] setTabBarHidden:YES animated:NO];
    HWPersonalHomeCenterViewController *personalHome = [[HWPersonalHomeCenterViewController alloc]init];
    [self.navigationController pushViewController:personalHome animated:YES];
    
    //    [[RDVTabBarController shareTabBar] setTabBarHidden:YES animated:NO];
    ////    if ([[MemberData memberData] isMemberLogin]) {
    //
    //        PersonalInfoViewController *personInfo = [[PersonalInfoViewController alloc] initWithNibName:@"PersonalInfoViewController" bundle:nil];
    //        [self.navigationController pushViewController:personInfo animated:YES];
    //[[RDVTabBarController shareTabBar] setTabBarHidden:NO animated:YES];
    
    //        if ([self.delegate respondsToSelector:@selector(loadLocalIconImage)]) {
    //            [self.delegate loadLocalIconImage];
    //        }
    
    //    }else{
    //
    //        LoginViewController *loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    //        [self.navigationController pushViewController:loginViewController animated:YES];
    //
    //        //[[RDVTabBarController shareTabBar] setTabBarHidden:NO animated:YES];
    //    }
    
}

- (void)onFourBtnClick{
    
    
}

- (void)onRatingPressed{
    HWLog(@"onRatingUs pressed");
    
    NSString* appLink = kRatingAddress_IOS7;
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appLink]];
    
    
}

- (void)onAlbumPressed{
    
    [[RDVTabBarController shareTabBar] setTabBarHidden:YES animated:NO];
    AlbumController *albumController = [AlbumController albumController];
    [self.navigationController pushViewController:albumController animated:YES];
    //[[RDVTabBarController shareTabBar] setTabBarHidden:NO animated:YES];
    
}

- (void)onFeedbackPressed {
    
    [self presentViewController:[UMFeedback feedbackModalViewController] animated:YES completion:nil];
    
}

//- (void)onCommonSettingsPressed {
//
//    CommonSettingViewController *settingViewController = [[CommonSettingViewController alloc] initWithNibName:@"CommonSettingViewController" bundle:nil];
//    [[RDVTabBarController shareTabBar] setTabBarHidden:YES animated:NO];
//    [self.navigationController pushViewController:settingViewController animated:YES];
//    //[[RDVTabBarController shareTabBar] setTabBarHidden:NO animated:YES];
//
//}

- (void)onMySharePressed{
    HWLog(@"--------------------------");
}

- (void)onLllegalReport{
    
    HWLog(@"--------违章举报------------------");
    //    if (isLogin) {
    
    HWlllegalReportViewController *serviceCloudVc = [HWlllegalReportViewController lllegalReportViewController];
    [[RDVTabBarController shareTabBar] setTabBarHidden:YES animated:NO];
    [self.navigationController pushViewController:serviceCloudVc animated:YES];
    //    }else{
    //
    //        [[RDVTabBarController shareTabBar] setTabBarHidden:YES animated:NO];
    //        LoginViewController *loginVc = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    //
    //        [self.navigationController pushViewController:loginVc animated:YES];
    //    }
    
}

- (void)onMyCloudPressed{
    
    HWLog(@"--------------------------");
    HWServiceCloudViewController *serviceCloudVc = [HWServiceCloudViewController serviceCloudViewController];
    [[RDVTabBarController shareTabBar] setTabBarHidden:YES animated:NO];
    [self.navigationController pushViewController:serviceCloudVc animated:YES];
    
}

- (void)onGuidePressed{
    HWLog(@"--------------------------");
    HWGuideViewController *guideVc = [HWGuideViewController guideViewController];
    [[RDVTabBarController shareTabBar] setTabBarHidden:YES animated:NO];
    [self.navigationController pushViewController:guideVc animated:YES];
}

- (void)onCollectPressed{
    HWLog(@"--------------------------");
    HWMyCollectionViewController *myCollectionVc = [HWMyCollectionViewController myCollectionViewController];
    [[RDVTabBarController shareTabBar] setTabBarHidden:YES animated:NO];
    [self.navigationController pushViewController:myCollectionVc animated:YES];
}

- (void)myStore{
    HWLog(@"--------------------------");
    //    if (isLogin) {
    
    HWMyStoreViewController *myStoreVc = [HWMyStoreViewController myStoreViewController];
    [[RDVTabBarController shareTabBar] setTabBarHidden:YES animated:NO];
    [self.navigationController pushViewController:myStoreVc animated:YES];
    //    }else{
    //
    //        [[RDVTabBarController shareTabBar] setTabBarHidden:YES animated:NO];
    //        LoginViewController *loginVc = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    //
    //        [self.navigationController pushViewController:loginVc animated:YES];
    //    }
    
    
}

- (void)onBindQuery{
    
    HWLog(@"--------------------------");
    
    NSString *strUid = kUid;
    NSString *upSecretUid = [[strUid sha1] uppercaseString];
    HWLog(@"secretUid:*%@*",upSecretUid);
    
    NSURL *url = [NSURL URLWithString:kStreamerBindQueryUrl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSDictionary *dict = @{
                           @"cid" : @"70002620",
                           @"uid":upSecretUid,
                           };
    
    
    
    if ([NSJSONSerialization isValidJSONObject:dict])
    {
        
        NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
        NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        HWLog(@"------------加密前的data转为字符串dataStr---------%@",dataStr);
        
        NSData *secretData = [NSString EncryptRequestString:dataStr];
        HWLog(@"-------NSData加密后secretData---------------%@",secretData);
        
        NSData *dataJ = [NSString DecryptData:secretData];
        NSString *dataStrJ = [[NSString alloc] initWithData:dataJ encoding:NSUTF8StringEncoding];
        HWLog(@"-------------dataStrJ--------------%@",dataStrJ);
        request.HTTPBody = secretData;
        
        self.alertBindQuery = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title", nil) message:@"" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        
        self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES configBlock:^(MBProgressHUD *HUD) {
            HUD.removeFromSuperViewOnHide = YES;
        }];
        
        __typeof(self) __weak safeSelf = self;
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            
            if (!connectionError) {
                NSData *dataDe = [NSString DecryptData:data];
                HWLog(@"datalength:%lu",(unsigned long)data.length);
                
                HWLog(@"dataDe:%@",dataDe);
                
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:dataDe options:NSJSONReadingMutableContainers error:nil];
                HWLog(@"dict[%@]",dict);
                
                HWLog(@"bindresult[%@]",dict[@"bindresult"]);
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [safeSelf.hud hide:YES];
                    
                    if ([dict[@"bindresult"] isEqualToString:@"0"]) {
                        
                        safeSelf.alertBindQuery.message = @"未绑定";
                    }else if ([dict[@"bindresult"] isEqualToString:@"1"]){
                        
                        safeSelf.alertBindQuery.message = @"已与该帐号绑定";
                    }else{
                        
                        safeSelf.alertBindQuery.message = @"已被其他账号绑定";
                    }
                    
                    [safeSelf.alertBindQuery show];
                });
                
                
            }
            else{
                safeSelf.alertBindQuery.title = @"❌";
                safeSelf.alertBindQuery.message = @"查询失败";
                HWLog(@"error:%@",connectionError);
            }
        }];
    }
    else
    {
        HWLog(@"数据有误");
    }
}

- (void)onSettingPressed{
    
}

#pragma mark --- TableViewDelegate--
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    if (section == 1) {
        return 0;
    }else{
        
        return 1;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0) {
        if (indexPath.row == 1) {
            return 40;
        }
        return 99.f;
    }
    return 40.f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [self.sections[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellid = @"Cell";
    
    if (indexPath.section == 0) {
        
        if (indexPath.row == 1) {
            
            HWFourBtnCell *cell = [tableView dequeueReusableCellWithIdentifier:@"fourBtnCell"];
            if (cell == nil) {
                cell = [[[NSBundle mainBundle] loadNibNamed:@"HWFourBtnCell" owner:self options:nil] firstObject];
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            cell.delegate = self;
            cell.backgroundColor = kBackgroundColor;
            return cell;
        }else if(indexPath.row == 0){
            
            self.iconCell = [tableView dequeueReusableCellWithIdentifier:@"CellHeader"];
            if (!self.iconCell) {
                self.iconCell = [[[NSBundle mainBundle] loadNibNamed:@"PersonalCenterCell" owner:self options:nil] firstObject];
                self.iconCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                self.iconCell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            //            self.iconCell.loginStatusLabel.text = NSLocalizedString(@"personal_setting_login_register_label", nil);
            //            self.iconCell.clickTipslabel.text = NSLocalizedString(@"personal_setting_header_detail_label", nil);
            //            self.iconCell.accountLabel.text = [[MemberData memberData] getMemberNickName];
            self.iconCell.delegate = self;
            self.iconCell.accountLabel.text = [HWUserInstanceInfo shareUser].nickname;
            //            self.iconCell.loginStatusLabel.hidden = YES;
            NSString *drivingNum = @"";
            //            self.iconCell.clickTipslabel.text = [NSString stringWithFormat:@"行车号：%@",drivingNum];
            self.iconCell.clickTipslabel.text = @"";
            self.iconCell.loginStatusLabel.hidden = YES;
            if (self.iconImage) {
                self.iconCell.accountIconImageView.image = self.iconImage;
            }else{
                self.iconCell.accountIconImageView.image = [UIImage imageNamed:@"find_new_head_bg"];
            }
            
            
            HWLog(@"====%@",self.deviceNickname);
            //            self.iconCell.accountLabel.font = HWCellFont;
            //            if ([[MemberData memberData] isMemberLogin]) {
            //                self.iconCell.loginStatusLabel.hidden = YES;
            //                self.iconCell.clickTipslabel.hidden = YES;
            //                self.iconCell.accountLabel.hidden = NO;
            //            }else{
            //                self.iconCell.loginStatusLabel.hidden = NO;
            //                self.iconCell.clickTipslabel.hidden = NO;
            //                self.iconCell.accountLabel.hidden = YES;
            //            }
            
            
            
            //            self.iconCell.loginStatusLabel.text = NSLocalizedString(@"personal_setting_login_register_label", nil);
            //            self.iconCell.clickTipslabel.text = NSLocalizedString(@"personal_setting_header_detail_label", nil);
            ////            self.iconCell.accountLabel.text = [[MemberData memberData] getMemberNickName];
            //            self.iconCell.delegate = self;
            //            self.iconCell.accountLabel.text = deviceNickName;
            //            self.iconCell.loginStatusLabel.hidden = YES;
            //            NSString *drivingNum = @"";
            //            self.iconCell.clickTipslabel.text = [NSString stringWithFormat:@"行车号：%@",drivingNum];
            //
            //            HWLog(@"====%@",deviceNickName);
            //            self.iconCell.accountLabel.font = HWCellFont;
            //            if ([[MemberData memberData] isMemberLogin]) {
            //                self.iconCell.loginStatusLabel.hidden = YES;
            //                self.iconCell.clickTipslabel.hidden = YES;
            //                self.iconCell.accountLabel.hidden = NO;
            //            }else{
            //                self.iconCell.loginStatusLabel.hidden = NO;
            //                self.iconCell.clickTipslabel.hidden = NO;
            //                self.iconCell.accountLabel.hidden = YES;
            //            }
            
            return self.iconCell;
            
        }
        
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellid];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (indexPath.section == 2) {
        if (indexPath.row == 2) {
            //输出缓存大小 m
            [LHCleanCache folderSizeAtPath];
            //            cell.detailTextLabel.text = _fileSizeStr0;
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2fM",[LHCleanCache folderSizeAtPath]];;
            cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
        }
    }
    
    NSDictionary* currentItem = [self.sections[indexPath.section] objectAtIndex:indexPath.row];
    cell.imageView.image = [UIImage imageNamed:[currentItem objectForKey:kMenuImageName]];
    cell.backgroundColor = kTableViewCellColor;
    cell.textLabel.text = [currentItem objectForKey:kMenuTitle];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = HWCellFont;
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *currentItem = [_sections[indexPath.section] objectAtIndex:indexPath.row];
    SEL currentSelector = NSSelectorFromString([currentItem objectForKey:kMenuSelector]);
    [self performSelector:currentSelector];
    
}

/**
 * 让当前控制器对应的状态栏是白色
 */
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
@end
