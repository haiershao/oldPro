//
//  CameraViewController.m
//  HuaWo
//
//  Created by circlely on 1/20/16.
//  Copyright © 2016 circlely. All rights reserved.
//

#import "CameraViewController.h"
#import "ManualAddViewController.h"
#import "QRAddViewController.h"
#import "MemberData.h"
#import "CameraExpandMoreCell.h"
#import "ServerTableViewCell.h"
#import "MBProgressHUD.h"
#import "AHCServerCommunicator.h"
#import "AHCNetworkChangeDetector.h"
#import "CameraSettingsViewController.h"
#import "VideoViewController.h"
#import "ManageViewController.h"
#import "EditCameraViewController.h"
#import "MJRefresh.h"
#import "REMenu.h"
#import "LanAddViewController.h"
#import "HWImmediatelyShareController.h"
#import "HWBindUserInfoView.h"
#import "NSString+encrypto.h"
#import "NSString+Helper.h"
#import "HWIntergralConvertController.h"
#import "HWUnbindAlertView.h"
#import "CameraViewController.h"

#import "MBProgressHUD.h"
#import "HWBandInfoController.h"
#import "HWCameraRecorderViewController.h"
#import "SYRecordVideoController.h"
#import "HWBandInfoController.h"
#import "HWUserInstanceInfo.h"
#import "MBProgressHUD+MG.h"
#import "HWNetworkStauts.h"
#define kMenuItem_Title            @"MenuTitle"
#define kMenuItem_SubTitle         @"MenuSubTitle"
#define kMenuItem_Image            @"MenuImage"
#define kMenuItem_HighlightedImage @"MenuHighlightedImage"
#define kMenuItem_SeletorName      @"MenuSelectorName"

#define kCoverViewTag 1000
#define kDeleteCIDAlertViewTag  1001

#define kUid [[MemberData memberData] getMemberAccount]

#define k_Bind_Check @"bindcheck"
#define k_Integral_Check @"integralcheck"

@interface CameraViewController ()<UITableViewDataSource, UITableViewDataSource, UIAlertViewDelegate, ExpandMoreCellDelegate, AHCServerCommunicatorDelegate, AHCNetworkChangeDetectorDelegate, EditViewControllerDelegate, HWBindUserInfoViewDelegate, REMenuItemDelegate, HWUnbindAlertViewDelegate>


@property (weak, nonatomic) IBOutlet UITableView *serversTableView;
@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (nonatomic, strong) NSArray* SortedCIDList;
@property (nonatomic, copy)  NSString *currentExpandedCID;
@property (nonatomic, strong) REMenu *menu;
@property (weak, nonatomic) IBOutlet UILabel *addCameraTips;
@property (strong, nonatomic) NSString *currentSelectedCID;

@property (strong, nonatomic) UIView *popBindView;
@property (assign, nonatomic) float bindViewY;

@property (strong, nonatomic) UIView *popUnbindView;
@property (assign, nonatomic) float unbindViewY;

@property (weak, nonatomic) NSString *identityCardText;
@property (weak, nonatomic) NSString *userRealNameText;
@property (weak, nonatomic) NSString *phoneNumText;
@property (weak, nonatomic) NSString *plateNumberText;
@property (weak, nonatomic) NSString *emailAddressText;
@property (weak, nonatomic) NSString *zhifuAccountText;
@property (strong, nonatomic) MBProgressHUD *hud;
@property (strong, nonatomic) UIAlertView *alertBind;
@property (assign, nonatomic) AVAuthorizationStatus authStatus;
@property (strong, nonatomic) UIAlertView *alertBindQuery;
//@property (strong, nonatomic) UIAlertView *alertBindQuery;
@property (strong ,nonatomic)UIButton *bandBtn;
@end

@implementation CameraViewController
{
    BOOL  isExpanded;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        
        [[AHCServerCommunicator sharedAHCServerCommunicator] addObserver:self];
    }
    
    return self;
}
- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [[RDVTabBarController shareTabBar] setTabBarHidden:NO animated:NO];
    self.navigationController.navigationBarHidden = NO;
    
    //[self.serversTableView headerBeginRefreshing];
    
}

- (void)viewDidAppear:(BOOL)animated{
    
    [self.serversTableView headerEndRefreshing];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    if (self.menu.isOpen) {
        [self.menu close];
    }
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = kBackgroundColor;
    
    [self setUpLocalCameraView];
    
    [self setUpTableView];
    
    [self setUpNav];
    
    
    self.addCameraTips.text = NSLocalizedString(@"add_recorder", nil);
    
    [self createMenu];
    
    
    [[AHCNetworkChangeDetector sharedNetworkChangeDetector] setDelegate:self];
    if ([[AHCNetworkChangeDetector sharedNetworkChangeDetector] isNetworkConnected]) {
        
        self.serversTableView.tableHeaderView = nil;
        [self connectingToServer];
    }else{
        
        if(self.SortedCIDList.count){//CID列表不为0时且没有网络，显示headerview
            self.serversTableView.tableHeaderView = self.headerView;
            
        }
        
    }
    
    //[self createMenu];
    
    self.SortedCIDList = [[MemberData memberData] getMemberCIDList];
    
    //监听程序从后台拉起的通知，不管在哪个页面，都需要回到CID LIST界面重新连接
    [self notificationBackgroundObserver];
    
    __typeof(self) __weak safeSelf = self;
    [self.serversTableView addHeaderWithCallback:^{
        
        [safeSelf reconnectingToServer];
        
    }];
    
    //监听键盘
    [self notificationKeyBoard];
    
    [DZNotificationCenter addObserver:self selector:@selector(pushRecordUI) name:@"GORECORDVIDEOUI" object:nil];
    [DZNotificationCenter addObserver:self selector:@selector(PushBandUI) name:@"PushBandUI" object:nil];
}
- (void)pushRecordUI{
    SYRecordVideoController *land= [[SYRecordVideoController alloc] initWithNibName:NSStringFromClass([SYRecordVideoController class]) bundle:nil];
    //LandScapeViewController *land = [[LandScapeViewController alloc]init];
    [self presentViewController:land animated:YES completion:nil];
    
}
-(void)PushBandUI{
    HWBandInfoController *BandInfo =  [[HWBandInfoController alloc] initWithNibName:NSStringFromClass([HWBandInfoController class]) bundle:nil];
    [self presentViewController:BandInfo  animated:YES completion:nil];
}

- (void)setUpLocalCameraView{
    
    UIView *view = [[UIView alloc] init];
    view.frame = CGRectMake(0, 0, screenW, 280);
    //    view.backgroundColor = [UIColor whiteColor];
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.image = [UIImage imageNamed:@"localCameraBg"];
    imageView.frame = view.bounds;
    imageView.userInteractionEnabled = YES;
    
    UIButton *button = [[UIButton alloc] init];
    button.width = 0.6*screenW;
    button.height = 30;
    button.x = (view.width - button.width)/2;
    button.y = view.height - 100;
    [button setBackgroundImage:[UIImage imageNamed:@"cameraBtn"] forState:UIControlStateNormal];
    [button setTitle:@"点击进入本地记录仪" forState:UIControlStateNormal];
    [button setFont:[UIFont systemFontOfSize:13]];
    [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(intoLocalCamera) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *View0 = [[UIView alloc] init];
    View0.backgroundColor = [UIColor colorWithRed:(155)/255.0 green:(155)/255.0 blue:(155)/255.0 alpha:0.5];
    
    View0.frame = CGRectMake(0, view.frame.size.height-40, screenW, 40);
    
    UIButton *setUpBtn = [[UIButton alloc] init];
    [setUpBtn setImage:[UIImage imageNamed:@"setUp1"] forState:UIControlStateNormal];
    [setUpBtn setImage:[UIImage imageNamed:@"setUp0"] forState:UIControlStateHighlighted];
    setUpBtn.frame = CGRectMake(0.3*screenW, 0, 0.35*screenW, 30);
    //    setUpBtn.backgroundColor = [UIColor blueColor];
    
    UIButton *driveCon = [[UIButton alloc] init];
    [driveCon setImage:[UIImage imageNamed:@"drivecon1"] forState:UIControlStateNormal];
    [driveCon setImage:[UIImage imageNamed:@"drivecon"] forState:UIControlStateHighlighted];
    driveCon.frame = CGRectMake(0.65*screenW, 0, 0.35*screenW, 30);
    //    driveCon.backgroundColor = [UIColor blackColor];
    [View0 addSubview:self.bandBtn];
    //    [View0 addSubview:setUpBtn];
    //    [View0 addSubview:driveCon];
    
    [imageView addSubview:button];
    [imageView addSubview:View0];
    //    [imageView bringSubviewToFront:subView];
    [view addSubview:imageView];
    
    
    [self.view addSubview:view];
    
    
}
- (UIButton *)bandBtn {
    if (!_bandBtn) {
        _bandBtn = [[UIButton alloc]init];
        
        [_bandBtn setImage:[UIImage imageNamed:@"绑定-1"] forState:UIControlStateNormal];
        [_bandBtn setImage:[UIImage imageNamed:@"绑定"] forState:UIControlStateHighlighted];
        [_bandBtn addTarget:self action:@selector(bindBtnClick) forControlEvents:UIControlEventTouchUpInside];
        _bandBtn.frame = CGRectMake(screenW*0.5-30, 5, 50, 30);
    }
    return _bandBtn;
}
- (void)bindBtnClick{
    if (![HWNetworkStauts sharedManager].isNetWork) {
        [MBProgressHUD showError:@"请检查网络设置"];
        return ;
    }
    
    [self examineReportState];
    
    //    [self checkDeviceBind:k_Bind_Check];
    //[self inquiryDeviceBind];
    
}
- (void)examineReportState {
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
        if (!result[@"data"]) {
            
            HWBandInfoController *BandInfo =  [[HWBandInfoController alloc] initWithNibName:NSStringFromClass([HWBandInfoController class]) bundle:nil];
            [self presentViewController:BandInfo  animated:YES completion:nil];
        }else {
            //[MBProgressHUD showSuccess:@"绑定"];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"是否解除绑定？" preferredStyle:UIAlertControllerStyleActionSheet];
            // 设置popover指向的item
            alert.popoverPresentationController.barButtonItem = self.navigationItem.leftBarButtonItem;
            
            // 添加按钮
            [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
                [self cancelBand];
                NSLog(@"点击了确定按钮");
            }]];
            [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                NSLog(@"点击了取消按钮");
            }]];
            
            [self presentViewController:alert animated:YES completion:nil];
            
        }
        
    }];
    
}
- (void)cancelBand{
    HWUserInstanceInfo *InstanceInfo = [HWUserInstanceInfo shareUser];
    NSDictionary *dict = @{
                           @"did":@"",
                           @"idno":@"1234"
                           };
    
    APIRequest *request = [[APIRequest alloc] initWithApiPath:@"/ControlCenter/v3/restapi/doaction" method:APIRequestMethodPost];
    request.urlQueryParameters = @{
                                   @"action":@"unbind_devuser",
                                   @"para":dict,
                                   @"token":InstanceInfo.token
                                   };
    NSLog(@"request---%@",request);
    [[APIRequestOperationManager sharedRequestOperationManager] requestAPI:request completion:^(id result, NSError *error) {
        
        [MBProgressHUD showSuccess:@"解除绑定"];
    }];
    
}
-(BOOL)shouldAutorotate{
    return YES;
}

//支持的方向 因为界面A我们只需要支持竖屏
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}
- (void)intoLocalCamera{
    SYRecordVideoController *land= [[SYRecordVideoController alloc] initWithNibName:NSStringFromClass([SYRecordVideoController class]) bundle:nil];
    //LandScapeViewController *land = [[LandScapeViewController alloc]init];
    [self presentViewController:land animated:YES completion:nil];
    //    self.hidesBottomBarWhenPushed = YES;
    //      [self.navigationController pushViewController:land animated:YES];
    // [DZNotificationCenter postNotificationName:@"cameraViewControllerIntoVc" object:self];
    
    
    //    if ([self.delegate respondsToSelector:@selector( HWCameraRecorderViewController:)]) {
    //
    //        [self.delegate cameraViewController:self];
    //
    //    }
}

- (void)setUpNav {
    
    self.navigationController.navigationBar.barTintColor = kNavigation7Color;
    //self.navigationItem.title = NSLocalizedString(@"connect_recorder_title", nil);
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 44)];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = NSLocalizedString(@"connect_recorder_title", nil);
    self.navigationItem.titleView = titleLabel;
}

- (void)setUpTableView{
    
    self.serversTableView.backgroundColor = nil;
    self.serversTableView.backgroundColor = kBackgroundColor;
    self.serversTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    //self.serversTableView.tableFooterView = self.footerView;
    self.serversTableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
}

- (void)notificationBackgroundObserver{
    
    [DZNotificationCenter addObserver:self selector:@selector(applicationWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    [DZNotificationCenter addObserver:self selector:@selector(reconnectingToServer) name:KLoginSucceed object:nil];
    [DZNotificationCenter addObserver:self selector:@selector(reconnectingToServer) name:KLoginOutMsg object:nil];
    
    [DZNotificationCenter addObserver:self selector:@selector(updateView) name:kUpdateCameraList object:nil];
}

- (void)notificationKeyBoard{
    
    //注册键盘出现的通知
    [DZNotificationCenter addObserver:self
     
                             selector:@selector(keyboardWasShown:)
     
                                 name:UIKeyboardWillShowNotification object:nil];
    
    //注册键盘消失的通知
    [DZNotificationCenter addObserver:self
     
                             selector:@selector(keyboardWillBeHidden:)
     
                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWasShown:(NSNotification *)note{
    
    CGRect keyBoardFrame = [[note.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    HWLog(@"--------show------------keyBoardFrame*%@*",NSStringFromCGRect(keyBoardFrame));
    CGFloat screenh = screenH;
    self.bindViewY = self.popBindView.y;
    self.popBindView.y = screenh - (keyBoardFrame.size.height + self.popBindView.height);
    
    self.unbindViewY = self.popUnbindView.y;
    self.popUnbindView.y = screenh - (keyBoardFrame.size.height + self.popUnbindView.height);
    HWLog(@"------------------------%f",self.popUnbindView.height);
}

- (void)keyboardWillBeHidden:(NSNotification *)note{
    CGRect keyBoardFrame = [[note.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    HWLog(@"------hide---------------keyBoardFrame*%@*",NSStringFromCGRect(keyBoardFrame));
    self.popBindView.y = self.bindViewY;
    
    self.popUnbindView.y = self.unbindViewY;
}

+ (instancetype)cameraViewController{
    
    return [[CameraViewController alloc] initWithNibName:@"CameraViewController" bundle:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


-(void)connectingToServer
{
    [self syncCidList];
}

- (void)reconnectingToServer{
    
    [self syncCidList];
}

- (void)syncCidList {
    
    [self addCoverView];
    
    
    //self.composeView.noNetworkTipsView = nil;
    //serversTableView.tableHeaderView = self.composeView;
    
    //未登陆不需要同步CID列表
    if([[MemberData memberData] isMemberLogin]){
        
    }
    else {
        
    }
}

- (void)connectAllStreamers{
    
    NSArray* cidArray = self.SortedCIDList;
    
    for (NSDictionary* item in cidArray) {
        NSNumber* CIDNumber   = [NSNumber numberWithLongLong:[[item objectForKey:kMemberCIDNumber] longLongValue]];
        NSString* CIDUsername = [item objectForKey:kMemberCIDUserName];
        NSString* CIDPassword = [item objectForKey:kMemberCIDPassword];
        
        NSDictionary* CIDInfo = @{kCIDInfoNumber: CIDNumber,
                                  kCIDInfoUsername: CIDUsername,
                                  kCIDInfoPassword: CIDPassword};
        
        [[AHCServerCommunicator sharedAHCServerCommunicator] resubscribeCID:CIDInfo];
    }
}


-(void)addCoverView
{
    //    if ([self.view viewWithTag:kCoverViewTag] == nil) {
    //        [self.navigationItem.rightBarButtonItem setEnabled:NO];
    //        //[self->slideViewController setSlidesOnPanGesture:NO];
    //
    //        UIView* coverView = [[UIView alloc] initWithFrame:self.serversTableView.frame];
    //
    //        [coverView setBackgroundColor:[UIColor blackColor]];
    //        coverView.alpha = 0.5;
    //        coverView.tag = kCoverViewTag;
    //        [self.view addSubview:coverView];
    
    //    }
}

-(void)removeCoverView
{
    [self.serversTableView headerEndRefreshing];
    [[self.view viewWithTag:kCoverViewTag] removeFromSuperview];
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
}

- (int)expandCellIndex:(NSString *)cid{
    
    if (cid) {
        NSArray *cidListArr = self.SortedCIDList;
        
        for (int i = 0 ; i < [cidListArr count]; i++) {
            
            NSDictionary *dic = [cidListArr objectAtIndex:i];
            if ([[dic objectForKey:kMemberCIDNumber] isEqualToString:cid]) {
                
                return i;
            }
        }
    }
    
    return -1;
}

- (void)updateCidListAndReloadTableView {
    
    self.SortedCIDList = [[MemberData memberData] getMemberCIDList];
    [self.serversTableView reloadData];
    
}

- (void)updateView {
    
    isExpanded = NO;
    [self updateCidListAndReloadTableView];
    
}
- (void)deleteCIDFromLocalAndService{
    
    MBProgressHUD* HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES configBlock:nil];
    __typeof(self) __weak safeSelf = self;
    void(^delCidSucBlk)() = ^{
        
        [MBProgressHUD hideHUDForView:safeSelf.view animated:YES];
        NSDictionary* CIDInfo = @{kCIDInfoNumber:safeSelf.currentExpandedCID};
        [[AHCServerCommunicator sharedAHCServerCommunicator] unsubscribeCID:CIDInfo];
        [safeSelf updateView];
    };
    
}

-(void)onRecieveSessionIDInvalidNotification:(NSNotification* )notify
{
    @synchronized (self)
    {
        if ([[notify object] isKindOfClass:[AHCNetworkChangeDetector class]]) {
            NSString* warnningMsg = [NSString stringWithFormat:NSLocalizedString(@"warnning_member_sessionid_invalid", nil), [[MemberData memberData] getMemberAccount]];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title", nil)
                                                            message:warnningMsg
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:NSLocalizedString(@"ok_btn", nil),nil];
            [alert show];
        }
    }
}

-(BOOL)loginValidationWithRowIndex:(NSInteger)rowIndex
{
    
    
    if (![[AHCNetworkChangeDetector sharedNetworkChangeDetector] isNetworkConnected])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title", nil)
                                                        message:NSLocalizedString(@"warnning_no_internet_connection", nil)
                                                       delegate:nil cancelButtonTitle:NSLocalizedString(@"ok_btn", nil) otherButtonTitles:nil];
        [alert show];
        
        return NO;
    }
    
    NSArray* cidArray = self.SortedCIDList ;
    
    
    if (cidArray.count >= rowIndex) {
        
        
        //cell展开状态，点击下一个cell角标多了1
        if ((isExpanded && rowIndex >  [self expandCellIndex:_currentExpandedCID])) {
            rowIndex = rowIndex - 1;
        }
        
        NSDictionary* CIDInfo = [cidArray objectAtIndex:rowIndex];
        NSString* CIDNumber   = [CIDInfo objectForKey:kMemberCIDNumber];
        self.currentSelectedCID = CIDNumber;
        NSInteger onlineState = [[MemberData memberData] getAvsStatusOfCID:CIDNumber];
        
        
        if (onlineState == PEER_STATUS_STATE_ERRUSERPWD) {
            
            [[RDVTabBarController shareTabBar] setTabBarHidden:YES animated:NO];
            EditCameraViewController *editViewController = [[EditCameraViewController alloc] initWithNibName:@"EditCameraViewController" bundle:nil];
            editViewController.CIDNumber = self.currentSelectedCID;
            editViewController.delegate = self;
            [self.navigationController pushViewController:editViewController animated:YES];
            
            //[[RDVTabBarController shareTabBar] setTabBarHidden:NO animated:NO];
            
            return NO;
        }
        
        if (onlineState != PEER_STATUS_STATE_ONLINE) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title", nil)
                                                            message:NSLocalizedString(@"warnning_streamer_offline", nil)
                                                           delegate:nil cancelButtonTitle:NSLocalizedString(@"ok_btn", nil) otherButtonTitles:nil];
            [alert show];
            
            return NO;
        }
    }
    return YES;
}

- (void)applicationWillEnterForeground {
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    [self reconnectingToServer];
}

-(void)deselect:(id)sender
{
    [self.serversTableView deselectRowAtIndexPath:[self.serversTableView indexPathForSelectedRow] animated:YES];
}
// 加号按钮监听事件
- (IBAction)addNewDeviceBtnPressed:(id)sender {
    
    if (self.menu.isOpen){
        return [self.menu close];
    }else{
        [self.menu showFromRect:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height) inView:self.view];
    }
}


-(void)createMenu
{
    NSInteger menuCount = 3;
    
    if (menuCount == 0) {
        return;
    }
    
    NSMutableArray* menuArray = [NSMutableArray array];
    
    for (NSInteger index = 0; index < menuCount; index++) {
        NSDictionary* menuDic = [self onCreateRightNavMenu:index];
        
        __typeof (self) __block safeSelf = self;
        
        REMenuItem *menuItem =
        [[REMenuItem alloc] initWithTitle:menuDic[kMenuItem_Title]
                                 subtitle:nil
                                    image:[UIImage imageNamed:menuDic[kMenuItem_Image]]
                         highlightedImage:nil
                                   action:^(REMenuItem *item) {
                                       
                                       //                                       [safeSelf onSideMenuPress];
                                       
                                       SEL currentSelector = NSSelectorFromString(menuDic[kMenuItem_SeletorName]);
                                       
                                       if ([safeSelf respondsToSelector:currentSelector]) {
                                           [safeSelf performSelector:currentSelector];
                                       }
                                   }];
        menuItem.tag = index;
        
        [menuArray addObject:menuItem];
        
    }
    
    self.menu = [[REMenu alloc] initWithItems:menuArray];
    self.menu.delegate = self;
    self.menu.backgroundColor = kBackgroundColor;
    //    self.menu.alpha = 0.8;
    self.menu.highlightedTextColor = [UIColor colorWithWhite:0.7 alpha:1.0];
    self.menu.highlightedBackgroundColor = kBackgroundColor;
    self.menu.font = HWCellFont;
    self.menu.imageOffset = CGSizeMake(5, -1);
    self.menu.waitUntilAnimationIsComplete = NO;
    self.menu.badgeLabelConfigurationBlock = ^(UILabel *badgeLabel, REMenuItem *item) {
        badgeLabel.backgroundColor = [UIColor colorWithRed:0 green:179/255.0 blue:134/255.0 alpha:1];
        badgeLabel.layer.borderColor = [UIColor colorWithRed:0.000 green:0.648 blue:0.507 alpha:1.000].CGColor;
    };
}

-(NSDictionary *)onCreateRightNavMenu:(NSInteger)menuIndex{
    
    switch (menuIndex) {
        case 0:
            return [NSDictionary dictionaryWithObjectsAndKeys:
                    NSLocalizedString(@"root_sidebar_add_cid_by_qrcode_label", nil), kMenuItem_Title,
                    @"add_camera_qrscan",kMenuItem_Image,
                    NSStringFromSelector(@selector(onQRCodeAddPressed)), kMenuItem_SeletorName, nil];
        case 1:
            return [NSDictionary dictionaryWithObjectsAndKeys:
                    NSLocalizedString(@"root_sidebar_add_cid_label", nil), kMenuItem_Title,
                    @"add_camera_hand",kMenuItem_Image,
                    NSStringFromSelector(@selector(onManualAddPressed)), kMenuItem_SeletorName, nil];
        case 2:
            return [NSDictionary dictionaryWithObjectsAndKeys:
                    NSLocalizedString(@"root_sidebar_add_cid_by_lansearch_label", nil), kMenuItem_Title,
                    @"add_camera_wifi",kMenuItem_Image,
                    NSStringFromSelector(@selector(onNetworkSearch)), kMenuItem_SeletorName, nil];
            
        default:
            break;
    }
    return nil;
    
}
//手动添加
- (void)onManualAddPressed {
    
    [[RDVTabBarController shareTabBar] setTabBarHidden:YES animated:NO];
    ManualAddViewController *addServerController = [[ManualAddViewController alloc] initWithNibName:@"ManualAddViewController" bundle:nil];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:addServerController];
    if (kiOS7) {
        navigationController.navigationBar.tintColor = [UIColor whiteColor];
        navigationController.navigationBar.barTintColor = kNavigation7Color;
        NSDictionary *textColorDictionary = @{UITextAttributeFont: CG_BOLD_FONT(20),UITextAttributeTextColor: [UIColor whiteColor]};
        navigationController.navigationBar.titleTextAttributes = textColorDictionary;
        navigationController.navigationBar.translucent = NO;
    }else{
        navigationController.navigationBar.tintColor = kNavigation7Color;
    }
    
    //[self presentViewController:navigationController animated:YES completion:^{}];
    [self.navigationController pushViewController:addServerController animated:YES];
    
    //[[RDVTabBarController shareTabBar] setTabBarHidden:NO animated:YES];
    
}
// 二维码添加
- (void)onQRCodeAddPressed {
    
    [[RDVTabBarController shareTabBar] setTabBarHidden:YES animated:NO];
    QRAddViewController *QRAddVC = [[QRAddViewController alloc] initWithNibName:@"QRAddViewController" bundle:nil];
    [self.navigationController pushViewController:QRAddVC animated:YES];
    
}
// 局域网搜索
- (void)onNetworkSearch {
    
    [[RDVTabBarController shareTabBar] setTabBarHidden:YES animated:NO];
    
    LanAddViewController *lanAddViewController = [[LanAddViewController alloc] initWithNibName:@"LanAddViewController" bundle:nil];
    [self.navigationController pushViewController:lanAddViewController animated:YES];
    //[[RDVTabBarController shareTabBar] setTabBarHidden:NO animated:YES];
}

#pragma mark -----TableViewDelegate-----

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (isExpanded && indexPath.row ==  [self expandCellIndex:_currentExpandedCID]+1) {
        
        return 60;
    }
    return 70;
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (isExpanded) {
        return self.SortedCIDList.count + 1;
    }
    return self.SortedCIDList.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int currentExpandedCIDIndex = [self expandCellIndex:_currentExpandedCID];
    
    if (isExpanded && indexPath.row ==  currentExpandedCIDIndex + 1) {
        
        
        
        CameraExpandMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CameraExpandMoreCell"];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"CameraExpandMoreCell" owner:self options:nil]firstObject];
            cell.delegate = self;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        }
        
        cell.cid        = _currentExpandedCID;
        return cell;
        
    }else{
        ServerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RootCell"];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"ServerTableViewCell" owner:self options:nil]firstObject];
            cell.delegate = self;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        }
        if (isExpanded && indexPath.row ==  currentExpandedCIDIndex) {
            cell.editImageView.image = [UIImage imageNamed:@"setting_server_button_background_image_up"];
        }else{
            
            cell.editImageView.image = [UIImage imageNamed:@"setting_server_button_background_image"];
        }
        
        NSDictionary* currentItem;
        if (isExpanded && (indexPath.row > currentExpandedCIDIndex)) {
            
            currentItem = [self.SortedCIDList objectAtIndex:indexPath.row-1];
            
        }else {
            currentItem = [self.SortedCIDList objectAtIndex:indexPath.row];
            
        }
        
        cell.cid        = [currentItem objectForKey:kMemberCIDNumber];
        //isOnline 由2部分组成 高16位代表cflag，低16位代表sub后的status值
        cell.isOnline   =  [[MemberData memberData] getAvsStatusOfCID:cell.cid];/* + ([[currentItem objectForKey:kMemberCIDFlag] intValue]<< 16);*/
        cell.isEnable   = YES;
        
        
        
        
        
        cell.serverName.text        = [[MemberData memberData] getAvsNameOfCID:cell.cid];
        //cell.tableView              = tableView;
        cell.accessoryType          = UITableViewCellAccessoryNone;
        
        return cell;
        
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    if(self.navigationController.topViewController != self){
        return;
        
    }
    
    [self performSelector:@selector(deselect:) withObject:nil afterDelay:0.5f];
    if ((!(isExpanded && indexPath.row ==  [self expandCellIndex:_currentExpandedCID]+1)) && [self loginValidationWithRowIndex:indexPath.row]) {
        
        NSInteger row = indexPath.row;
        
        
        //cell展开状态，点击下一个cell角标多了1
        if ((isExpanded && indexPath.row > [self expandCellIndex:_currentExpandedCID])) {
            
            row = row -1;
        }
        
        
        
        
        NSDictionary* currentItem = [self.SortedCIDList objectAtIndex:row];
        
        NSString* CIDNumber = [currentItem objectForKey:kMemberCIDNumber];
        
        [[AVSConfigData sharedAVSConfigData] configWithAVSConfigData:[[MemberData memberData] getDetailConfigInfoForCID:CIDNumber]];
        
        VideoViewController* videoViewController = [[VideoViewController alloc] initWithNibName:@"VideoViewController" CIDNumber:CIDNumber];
        
        [[RDVTabBarController shareTabBar] setTabBarHidden:YES animated:NO];
        [self.navigationController pushViewController:videoViewController animated:YES];
        
        //[[RDVTabBarController shareTabBar] setTabBarHidden:NO animated:YES];
    }
    
    
}

#pragma mark ----ServerCellDelegate----
- (void) expandMoreMessage:(NSString *)cidStr{
    
    
    int cidStrIndex = [self expandCellIndex:cidStr];
    
    if (isExpanded){
        
        if([cidStr isEqualToString:_currentExpandedCID]){
            
            isExpanded = NO;
            self.currentExpandedCID = cidStr;
            
            NSIndexPath *deleteIndexPath = [NSIndexPath indexPathForRow:cidStrIndex + 1 inSection:0];
            NSArray *deleteArray = [NSArray arrayWithObjects:deleteIndexPath, nil];
            
            
            [self.serversTableView beginUpdates];
            [self.serversTableView deleteRowsAtIndexPaths:deleteArray withRowAnimation:UITableViewRowAnimationFade];
            [self.serversTableView endUpdates];
            
            if([[self.serversTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:cidStrIndex inSection:0]]isKindOfClass:[ServerTableViewCell class]]){
                
                ServerTableViewCell *cell = (ServerTableViewCell *)[self.serversTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:cidStrIndex inSection:0]];
                cell.editImageView.image = [UIImage imageNamed:@"setting_server_button_background_image"];
            }
        }
        else {
            
            int preExpandRow = (int)[self expandCellIndex:_currentExpandedCID];
            
            if(cidStrIndex < [self expandCellIndex:_currentExpandedCID]) {
                
                self.currentExpandedCID = cidStr;
                
                NSIndexPath *deleteIndexPath = [NSIndexPath indexPathForRow: preExpandRow + 1 inSection:0];
                NSArray * deleteArray = [NSArray arrayWithObjects:deleteIndexPath, nil];
                
                NSIndexPath *addIndexPath = [NSIndexPath indexPathForRow:cidStrIndex + 1 inSection:0];
                NSArray *addArray = [NSArray arrayWithObjects:addIndexPath, nil];
                
                
                [self.serversTableView beginUpdates];
                [self.serversTableView deleteRowsAtIndexPaths:deleteArray withRowAnimation:UITableViewRowAnimationFade];
                [self.serversTableView insertRowsAtIndexPaths:addArray withRowAnimation:UITableViewRowAnimationFade];
                [self.serversTableView endUpdates];
                
                if([[self.serversTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:preExpandRow + 1 inSection:0]]isKindOfClass:[ServerTableViewCell class]]){
                    
                    ServerTableViewCell *closeCell = (ServerTableViewCell *)[self.serversTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:preExpandRow + 1 inSection:0]];
                    closeCell.editImageView.image = [UIImage imageNamed:@"setting_server_button_background_image"];
                }
                
                if([[self.serversTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:cidStrIndex inSection:0]]isKindOfClass:[ServerTableViewCell class]]){
                    
                    ServerTableViewCell *openCell = (ServerTableViewCell *)[self.serversTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:cidStrIndex inSection:0]];
                    openCell.editImageView.image = [UIImage imageNamed:@"setting_server_button_background_image_up"];
                }
            }
            else {
                
                self.currentExpandedCID = cidStr;
                
                NSIndexPath *deleteIndexPath = [NSIndexPath indexPathForRow: preExpandRow + 1 inSection:0];
                NSArray * deleteArray = [NSArray arrayWithObjects:deleteIndexPath, nil];
                
                NSIndexPath *addIndexPath = [NSIndexPath indexPathForRow:cidStrIndex + 1 inSection:0];
                NSArray *addArray = [NSArray arrayWithObjects:addIndexPath, nil];
                
                
                [self.serversTableView beginUpdates];
                [self.serversTableView deleteRowsAtIndexPaths:deleteArray withRowAnimation:UITableViewRowAnimationFade];
                [self.serversTableView insertRowsAtIndexPaths:addArray withRowAnimation:UITableViewRowAnimationFade];
                [self.serversTableView endUpdates];
                
                
                if([[self.serversTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:preExpandRow inSection:0]]isKindOfClass:[ServerTableViewCell class]]){
                    ServerTableViewCell *closeCell = (ServerTableViewCell *)[self.serversTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:preExpandRow inSection:0]];
                    closeCell.editImageView.image = [UIImage imageNamed:@"setting_server_button_background_image"];
                }
                
                if([[self.serversTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:cidStrIndex inSection:0]]isKindOfClass:[ServerTableViewCell class]]){
                    ServerTableViewCell *openCell = (ServerTableViewCell *)[self.serversTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:cidStrIndex inSection:0]];
                    openCell.editImageView.image = [UIImage imageNamed:@"setting_server_button_background_image_up"];
                }
                
            }
        }
        
    }
    else {
        
        isExpanded = YES;
        self.currentExpandedCID = cidStr;
        
        NSIndexPath *addIndexPath = [NSIndexPath indexPathForRow:cidStrIndex + 1 inSection:0];
        NSArray *addArray = [NSArray arrayWithObjects:addIndexPath, nil];
        
        [self.serversTableView beginUpdates];
        [self.serversTableView insertRowsAtIndexPaths:addArray withRowAnimation:UITableViewRowAnimationFade];
        [self.serversTableView endUpdates];
        
        if([[self.serversTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:cidStrIndex inSection:0]]isKindOfClass:[ServerTableViewCell class]]){
            
            ServerTableViewCell *cell = (ServerTableViewCell *)[self.serversTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:cidStrIndex inSection:0]];
            cell.editImageView.image = [UIImage imageNamed:@"setting_server_button_background_image_up"];
            
        }
    }
    
}

- (void)unbindAlertView:(HWUnbindAlertView *)bindAlertView idCardNum:(NSString *)idCardNum{
    
    [self unbindDevice:idCardNum];
}

#pragma mark --- HWBindUserInfoViewDelegate ---
- (void)bindUserInfoView:(HWBindUserInfoView *)bindUserInfoView IDCardText:(NSString *)IDCardText realNameText:(NSString *)realNameText phoneNumText:(NSString *)phoneNumText plateNumText:(NSString *)plateNumText emailText:(NSString *)emailText zhifuAccountText:(NSString *)zhifuAccountText{
    
    self.identityCardText = IDCardText;
    self.userRealNameText = realNameText;
    self.phoneNumText = phoneNumText;
    self.plateNumberText = plateNumText;
    self.emailAddressText = emailText;
    self.zhifuAccountText = zhifuAccountText;
    
    HWLog(@"self.identityCardTextField.text*%@*",self.identityCardText);
    HWLog(@"self.identityCardTextField.text*%@*",self.userRealNameText);
    HWLog(@"self.identityCardTextField.text*%@*",self.phoneNumText);
    HWLog(@"self.identityCardTextField.text*%@*",self.plateNumberText);
    HWLog(@"self.identityCardTextField.text*%@*",self.emailAddressText);
    HWLog(@"self.identityCardTextField.text*%@*",self.zhifuAccountText);
    
    //    [self deviceBind];
    
    [self selfDeviceBind];
    
}

//- (void)selfDeviceBind{
//
////    NSString *identifierForVendor = [[UIDevice currentDevice].identifierForVendor UUIDString];
//    //http://112.124.22.101:38080/illegalreport/restapi/cidbinduser
////    NSString *identityno = self.identityCardText;
////    NSString *name = self.userRealNameText;
////    NSString *phonenumber = self.phoneNumText;
////    NSString *licenseno = self.plateNumberText;
////    NSString *email = self.emailAddressText;
//
//    NSString *identityno = @"012345678912345678";
//    NSString *name = @"李四";
//    NSString *phonenumber = @"13490123459";
//    NSString *licenseno = @"沪BBCCDD";
//    NSString *email = @"1485114219@qq.com";
//
//
//    NSString *str = identifierForVendor;
//    //http://192.168.0.29:8080
////    NSString *urlStr = [NSString stringWithFormat:@"http://112.124.22.101:38080/illegalreport/restapi/cidbinduser?cid=%@&identityno=%@&name=%@&phonenumber=%@&licenseno=%@&email=%@",identifierForVendor,identityno,name,phonenumber,licenseno,email];
//    NSString *path = @"http://192.168.0.29:8080/illegalreport/restapi/cidbinduser?";
//    NSString *param = [NSString stringWithFormat:@"cid=%@&identityno=%@&name=%@&phonenumber=%@&licenseno=%@&email=%@",identifierForVendor,identityno,name,phonenumber,licenseno,email];
//    NSString *urlStr = [NSString stringWithFormat:@"%@%@",path,param];
//    urlStr = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)urlStr, nil, nil, kCFStringEncodingUTF8));
////    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//
//    NSURL *url = [NSURL URLWithString:urlStr];
//    HWLog(@"============selfDeviceBind %@",url);
//    // 2. 请求
//    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:1 timeoutInterval:2.0f];
//
//    // 3. 连接
//    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
//
//        // 反序列化
//        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
//        self.alertBindQuery = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title", nil) message:@"" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
//        NSLog(@"result---%@--%@", result,result[@"bindresult"]);
////        NSString *str0 = [NSString stringWithFormat:@"%@",result[@"bindresult"]];
//        NSString *str1 = [NSString stringWithFormat:@"%@",result[@"result"]];
//
//        if (str1) {
//            if ([str1 isEqualToString:@"0"]) {
//                HWLog(@"-------已绑定...------------");
//                self.alertBindQuery.message = @"已绑定...";
//                [self.alertBindQuery show];
//            }else if([str1 isEqualToString:@"1"]){
//                HWLog(@"=========绑定失败...==========");
//                self.alertBindQuery.message = @"绑定失败...";
//                [self.alertBindQuery show];
//            }else if ([str1 isEqualToString:@"2"]){
//                HWLog(@"========绑定成功...===========");
//                self.alertBindQuery.message = @"绑定成功...";
//                [self.alertBindQuery show];
//            }else{
//
//                HWLog(@"=======信息不全...============");
//                self.alertBindQuery.message = @"信息不全...";
//                [self.alertBindQuery show];
//            }
//        }else {
//
//            HWLog(@"====================result＝为空");
//        }
//
//    }];
//
//
//
//
//
//}

- (void)selfDeviceBind{
    
    //    NSString *identifierForVendor = [[UIDevice currentDevice].identifierForVendor UUIDString];
    //http://112.124.22.101:38080/illegalreport/restapi/cidbinduser
    //    NSString *identityno = self.identityCardText;
    //    NSString *name = self.userRealNameText;
    //    NSString *phonenumber = self.phoneNumText;
    //    NSString *licenseno = self.plateNumberText;
    //    NSString *email = self.emailAddressText;
    
    NSString *identityno = @"012345678912345678";
    NSString *name = @"李四";
    NSString *phonenumber = @"13490123459";
    NSString *licenseno = @"BBCCDD";
    NSString *email = @"1485114219@qq.com";
    
    
    NSString *str = identifierForVendor;
    //http://192.168.0.29:8080
    //    NSString *urlStr = [NSString stringWithFormat:@"http://112.124.22.101:38080/illegalreport/restapi/cidbinduser?cid=%@&identityno=%@&name=%@&phonenumber=%@&licenseno=%@&email=%@",identifierForVendor,identityno,name,phonenumber,licenseno,email];
    NSString *path = @"http://192.168.0.29:8080/illegalreport/restapi/cidbinduser?";
    NSString *param = [NSString stringWithFormat:@"cid=%@&identityno=%@&name=%@&phonenumber=%@&licenseno=%@&email=%@",identifierForVendor,identityno,name,phonenumber,licenseno,email];
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",path,param];
    //    urlStr = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)urlStr, nil, nil, kCFStringEncodingUTF8));
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //    urlStr = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSURL *url = [NSURL URLWithString:urlStr];
    HWLog(@"============selfDeviceBind %@",url);
    // 2. 请求
    //    AFHTTPRequestOperationManager *mgr=[AFHTTPRequestOperationManager manager];
    //    mgr.requestSerializer = [AFJSONRequestSerializer serializer];
    //    mgr.responseSerializer = [AFHTTPResponseSerializer serializer];
    //    AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
    //    [requestSerializer setValue:@"application/x-www-form-urlencoded;charset=utf8" forHTTPHeaderField:@"Content-Type"];
    //    NSMutableDictionary *dict=[NSMutableDictionary dictionary];
    //    [mgr GET:urlStr parameters:dict success:^(AFHTTPRequestOperation * operation, id responseObject) {
    //
    //        if (dict[@"error"]) {
    //            NSLog(@"%@",dict[@"error"]);
    //        } else {
    //            NSLog(@"ok");
    //        }
    //
    //    } failure:^(AFHTTPRequestOperation * operation, NSError * error) {
    //
    //
    //    }];
    //
    //
    
    
    
}

- (NSString*)encodeURL:(NSString*)dString{
    NSString* escapedUrlString= (NSString*) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)dString, NULL,(CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8 )); 　　escapedUrlString = [escapedUrlString stringByAddingPercentEscapesUsingEncoding:kCFStringEncodingUTF8];
    　　return escapedUrlString;
}

- (void)unbindDevice:(NSString *)idCardNum{
    //    idCardNum = @"012345678912345678";
    NSString *urlStr = [NSString stringWithFormat:@"http://112.124.22.101:38080/illegalreport/restapi/cidunbinduser?cid=%@&identityno=%@",identifierForVendor,idCardNum];
    
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    // 2. 请求
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:1 timeoutInterval:2.0f];
    
    // 3. 连接
    self.alertBindQuery = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title", nil) message:@"" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (!connectionError) {
            // 反序列化
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            
            NSLog(@"解绑result---%@--%@", result,result[@"bindresult"]);
            //        NSString *str0 = [NSString stringWithFormat:@"%@",result[@"bindresult"]];
            NSString *str1 = [NSString stringWithFormat:@"%@",result[@"result"]];
            
            if (str1) {
                if ([str1 isEqualToString:@"0"]) {
                    HWLog(@"-------绑定解除失败，未绑定------------");
                    self.alertBindQuery.message = @"绑定解除失败，未绑定";
                    [self.alertBindQuery show];
                }else if([str1 isEqualToString:@"1"]){
                    HWLog(@"=========绑定解除失败，不能解除其他用户的绑定==========");
                    self.alertBindQuery.message = @"绑定解除失败，不能解除其他用户的绑定";
                    [self.alertBindQuery show];
                }else if ([str1 isEqualToString:@"2"]){
                    HWLog(@"========绑定成功...===========");
                    self.alertBindQuery.message = @"绑定成功...";
                    [self.alertBindQuery show];
                }else if ([str1 isEqualToString:@"3"]){
                    
                    HWLog(@"=======绑定解除失败，数据库操作故障============");
                    self.alertBindQuery.message = @"绑定解除失败，数据库操作故障";
                    [self.alertBindQuery show];
                }else if ([str1 isEqualToString:@"4"]){
                    
                    HWLog(@"=======绑定解除成功============");
                    self.alertBindQuery.message = @"绑定解除成功";
                    [self.alertBindQuery show];
                }
            }else {
                
                HWLog(@"====================result＝为空");
            }
        }
        
        
    }];
    
    
    //    NSString *strUid = kUid;
    //    NSString *upSecretUid = [[strUid sha1] uppercaseString];
    //    HWLog(@"secretUid:*%@*",upSecretUid);
    //
    //    NSURL *url = [NSURL URLWithString:kStreamerUnbindUrl];
    //    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    //    request.HTTPMethod = @"POST";
    //
    //    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    //
    //    //    NSDictionary *dict = @{
    //    //                           @"cid" : self.currentExpandedCID,
    //    //                           @"uid":upSecretUid,
    //    //                           @"identityno": @"012345678912345678"
    //    //                           };
    //
    //    NSDictionary *dict = @{
    //                           @"cid" : self.currentExpandedCID,
    //                           @"uid":upSecretUid,
    //                           @"identityno": idCardNum
    //                           };
    //
    //    if ([NSJSONSerialization isValidJSONObject:dict])
    //    {
    //
    //        NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    //        NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    //        HWLog(@"------------加密前的data转为字符串dataStr---------%@",dataStr);
    //
    //        NSData *secretData = [NSString EncryptRequestString:dataStr];
    //        HWLog(@"-------NSData加密后secretData---------------%@",secretData);
    //
    //        NSData *dataJ = [NSString DecryptData:secretData];
    //        NSString *dataStrJ = [[NSString alloc] initWithData:dataJ encoding:NSUTF8StringEncoding];
    //        HWLog(@"-------------dataStrJ--------------%@",dataStrJ);
    //        request.HTTPBody = secretData;
    //
    //        self.alertBindQuery = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title", nil) message:@"" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    //
    //        self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES configBlock:^(MBProgressHUD *HUD) {
    //            HUD.removeFromSuperViewOnHide = YES;
    //        }];
    //
    //        __typeof(self) __weak safeSelf = self;
    //        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
    //
    //            if (!connectionError) {
    //                NSData *dataDe = [NSString DecryptData:data];
    //                HWLog(@"datalength:%lu",(unsigned long)data.length);
    //
    //                HWLog(@"dataDe:%@",dataDe);
    //
    //                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:dataDe options:NSJSONReadingMutableContainers error:nil];
    //                HWLog(@"dict[%@]",dict);
    //
    //                HWLog(@"result[%@]",dict[@"result"]);
    //
    //                dispatch_async(dispatch_get_main_queue(), ^{
    //
    //                    [safeSelf.hud hide:YES];
    //
    //                    if ([dict[@"result"] isEqualToString:@"0"]) {
    //
    //                        //                        safeSelf.alertBindQuery.message = @"未绑定";
    //                        HWLog(@"---------解绑失败，未绑定--------");
    //
    //                        [self bindInfoView];
    //
    //
    //                    }else if ([dict[@"result"] isEqualToString:@"1"]){
    //
    //                        safeSelf.alertBindQuery.message = @"解绑失败，不能解除其他用户的绑定";
    //                        HWLog(@"---------解绑失败，不能解除其他用户的绑定--------");
    //                        [safeSelf.alertBindQuery show];
    //                    }else if ([dict[@"result"] isEqualToString:@"3"]){
    //
    //                        HWLog(@"---------解绑失败，数据库操作故障--------");
    //                        safeSelf.alertBindQuery.message = @"解绑失败，数据库操作故障";
    //                        [safeSelf.alertBindQuery show];
    //                    }else if ([dict[@"result"] isEqualToString:@"4"]){
    //
    //                        HWLog(@"---------绑定解除成功--------");
    //                        safeSelf.alertBindQuery.message = @"绑定解除成功";
    //                        [safeSelf.alertBindQuery show];
    //                    }
    //                    else{
    //
    //                        //                        safeSelf.alertBindQuery.message = @"已被其他账号绑定";
    //                    }
    //
    //
    //                });
    //
    //
    //            }
    //            else{
    //                safeSelf.alertBindQuery.title = @"❌";
    //                safeSelf.alertBindQuery.message = @"解绑失败";
    //                HWLog(@"error:%@",connectionError);
    //            }
    //        }];
    //    }
    //    else
    //    {
    //        HWLog(@"数据有误");
    //    }
}

//- (void)unbindDevice:(NSString *)idCardNum{
//
//    NSString *strUid = kUid;
//    NSString *upSecretUid = [[strUid sha1] uppercaseString];
//    HWLog(@"secretUid:*%@*",upSecretUid);
//
//    NSURL *url = [NSURL URLWithString:kStreamerUnbindUrl];
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
//    request.HTTPMethod = @"POST";
//
//    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//
////    NSDictionary *dict = @{
////                           @"cid" : self.currentExpandedCID,
////                           @"uid":upSecretUid,
////                           @"identityno": @"012345678912345678"
////                           };
//
//    NSDictionary *dict = @{
//                           @"cid" : self.currentExpandedCID,
//                           @"uid":upSecretUid,
//                           @"identityno": idCardNum
//                           };
//
//    if ([NSJSONSerialization isValidJSONObject:dict])
//    {
//
//        NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
//        NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//        HWLog(@"------------加密前的data转为字符串dataStr---------%@",dataStr);
//
//        NSData *secretData = [NSString EncryptRequestString:dataStr];
//        HWLog(@"-------NSData加密后secretData---------------%@",secretData);
//
//        NSData *dataJ = [NSString DecryptData:secretData];
//        NSString *dataStrJ = [[NSString alloc] initWithData:dataJ encoding:NSUTF8StringEncoding];
//        HWLog(@"-------------dataStrJ--------------%@",dataStrJ);
//        request.HTTPBody = secretData;
//
//        self.alertBindQuery = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title", nil) message:@"" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
//
//        self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES configBlock:^(MBProgressHUD *HUD) {
//            HUD.removeFromSuperViewOnHide = YES;
//        }];
//
//        __typeof(self) __weak safeSelf = self;
//        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
//
//            if (!connectionError) {
//                NSData *dataDe = [NSString DecryptData:data];
//                HWLog(@"datalength:%lu",(unsigned long)data.length);
//
//                HWLog(@"dataDe:%@",dataDe);
//
//                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:dataDe options:NSJSONReadingMutableContainers error:nil];
//                HWLog(@"dict[%@]",dict);
//
//                HWLog(@"result[%@]",dict[@"result"]);
//
//                dispatch_async(dispatch_get_main_queue(), ^{
//
//                    [safeSelf.hud hide:YES];
//
//                    if ([dict[@"result"] isEqualToString:@"0"]) {
//
//                        //                        safeSelf.alertBindQuery.message = @"未绑定";
//                        HWLog(@"---------解绑失败，未绑定--------");
//
//                        [self bindInfoView];
//
//
//                    }else if ([dict[@"result"] isEqualToString:@"1"]){
//
//                        safeSelf.alertBindQuery.message = @"解绑失败，不能解除其他用户的绑定";
//                        HWLog(@"---------解绑失败，不能解除其他用户的绑定--------");
//                        [safeSelf.alertBindQuery show];
//                    }else if ([dict[@"result"] isEqualToString:@"3"]){
//
//                        HWLog(@"---------解绑失败，数据库操作故障--------");
//                        safeSelf.alertBindQuery.message = @"解绑失败，数据库操作故障";
//                        [safeSelf.alertBindQuery show];
//                    }else if ([dict[@"result"] isEqualToString:@"4"]){
//
//                        HWLog(@"---------绑定解除成功--------");
//                        safeSelf.alertBindQuery.message = @"绑定解除成功";
//                        [safeSelf.alertBindQuery show];
//                    }
//                    else{
//
////                        safeSelf.alertBindQuery.message = @"已被其他账号绑定";
//                    }
//
//
//                });
//
//
//            }
//            else{
//                safeSelf.alertBindQuery.title = @"❌";
//                safeSelf.alertBindQuery.message = @"解绑失败";
//                HWLog(@"error:%@",connectionError);
//            }
//        }];
//    }
//    else
//    {
//        HWLog(@"数据有误");
//    }
//}

- (void)checkDeviceBind:(NSString *)check_Key{
    
    HWLog(@"---------checkDeviceBind-----------------");
    
    NSString *strUid = kUid;
    NSString *upSecretUid = [[strUid sha1] uppercaseString];
    HWLog(@"secretUid:*%@*",upSecretUid);
    
    NSURL *url = [NSURL URLWithString:kStreamerBindQueryUrl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSDictionary *dict = @{
                           @"cid" : identifierForVendor
                           
                           };
    
    
    if ([NSJSONSerialization isValidJSONObject:dict])
    {
        
        NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
        
        request.HTTPBody = data;
        
        self.alertBindQuery = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title", nil) message:@"" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        
        self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES configBlock:^(MBProgressHUD *HUD) {
            HUD.removeFromSuperViewOnHide = YES;
        }];
        
        __typeof(self) __weak safeSelf = self;
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            
            if (!connectionError) {
                
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                HWLog(@"dict[%@]",dict);
                
                HWLog(@"bindresult[%@]",dict[@"bindresult"]);
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [safeSelf.hud hide:YES];
                    
                    if ([dict[@"bindresult"] isEqualToString:@"0"]) {
                        
                        HWLog(@"---------未绑定--------");
                        if ([check_Key isEqualToString:k_Bind_Check]) {
                            
                            [self bindInfoView];
                        }else if ([check_Key isEqualToString:k_Integral_Check]){
                            
                            safeSelf.alertBindQuery.message = @"未绑定";
                            [safeSelf.alertBindQuery show];
                        }
                        
                        
                    }else if ([dict[@"bindresult"] isEqualToString:@"1"]){
                        
                        HWLog(@"---------已与该帐号绑定--------");
                        if ([check_Key isEqualToString:k_Bind_Check]) {
                            
                            [self unbindView];
                        }else if ([check_Key isEqualToString:k_Integral_Check]){
                            
                            [self pushIntegralConvertController];
                        }
                        
                    }else{
                        NSString *str = [NSString stringWithFormat:@"已被%@账号绑定",dict[@"memo"]];
                        safeSelf.alertBindQuery.message = str;
                        [safeSelf.alertBindQuery show];
                    }
                    
                    
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


- (void)unbindView{
    
    HWUnbindAlertView *unbindAlertView = [HWUnbindAlertView unbindAlertView];
    self.popUnbindView = unbindAlertView.popUnbindView;
    unbindAlertView.delegate = self;
    CGFloat screenw = screenW;
    CGFloat screenh = screenH;
    unbindAlertView.frame = CGRectMake(0, 0, screenw, screenh);
    [self.view addSubview:unbindAlertView];
}


#pragma mark --- ExpanCellDelegate ---

- (void)bindButtonAction:(NSString *)cid{
    HWLog(@"-------bindButtonAction---------------------");
    
    NSInteger onlineState = [[MemberData memberData] getAvsStatusOfCID:cid];
    
    
    if (onlineState == PEER_STATUS_STATE_ERRUSERPWD) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title", nil)
                                                        message:NSLocalizedString(@"member_cid_status_wrong_password", nil)
                                                       delegate:nil cancelButtonTitle:NSLocalizedString(@"ok_btn", nil) otherButtonTitles:nil];
        [alert show];
        
        return;
    }
    
    if (onlineState != PEER_STATUS_STATE_ONLINE) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title", nil)
                                                        message:NSLocalizedString(@"warnning_streamer_offline", nil)
                                                       delegate:nil cancelButtonTitle:NSLocalizedString(@"ok_btn", nil) otherButtonTitles:nil];
        [alert show];
        
        return;
    }
    
    [self checkDeviceBind:k_Bind_Check];
    
}

- (void)bindInfoView{
    
    HWLog(@"-------bindInfoView---------------------");
    
    HWBindUserInfoView *bindView = [HWBindUserInfoView bindUserInfoView];
    self.popBindView = bindView.popBindView;
    bindView.delegate = self;
    
    CGFloat screenw = screenW;
    CGFloat screenh = screenH;
    bindView.frame = CGRectMake(0, 0, screenw, screenh);
    NSArray* windows = [UIApplication sharedApplication].windows;
    UIWindow *window = [windows objectAtIndex:0];
    [window addSubview:bindView];
}

- (void)intgralConvertButtonAction:(NSString *)cid{
    
    NSInteger onlineState = [[MemberData memberData] getAvsStatusOfCID:cid];
    
    
    if (onlineState == PEER_STATUS_STATE_ERRUSERPWD) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title", nil)
                                                        message:NSLocalizedString(@"member_cid_status_wrong_password", nil)
                                                       delegate:nil cancelButtonTitle:NSLocalizedString(@"ok_btn", nil) otherButtonTitles:nil];
        [alert show];
        
        return;
    }
    
    if (onlineState != PEER_STATUS_STATE_ONLINE) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title", nil)
                                                        message:NSLocalizedString(@"warnning_streamer_offline", nil)
                                                       delegate:nil cancelButtonTitle:NSLocalizedString(@"ok_btn", nil) otherButtonTitles:nil];
        [alert show];
        
        return;
    }
    
    [self checkDeviceBind:k_Integral_Check];
}

- (void)pushIntegralConvertController{
    
    HWIntergralConvertController *intergralVc = [HWIntergralConvertController intergralConvertController];
    intergralVc.cidNum = self.currentExpandedCID;
    [self.navigationController pushViewController:intergralVc animated:YES];
}

- (void)deleteButtonAction:(NSString *)cid{
    
    UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"warnning_be_sure_to_del_cid", nil) message:NSLocalizedString(@"warnning_prompt_delete_server", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"cancel_btn", nil) otherButtonTitles:NSLocalizedString(@"remove_btn", nil), nil];
    
    alerView.tag = kDeleteCIDAlertViewTag;
    [alerView show];
    
    
}

- (void)settingButtonAction:(NSString *)cid {
    
    NSInteger onlineState = [[MemberData memberData] getAvsStatusOfCID:cid];
    if (onlineState == PEER_STATUS_STATE_ERRUSERPWD) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title", nil)
                                                        message:NSLocalizedString(@"member_cid_status_wrong_password", nil)
                                                       delegate:nil cancelButtonTitle:NSLocalizedString(@"ok_btn", nil) otherButtonTitles:nil];
        [alert show];
        
        return;
    }
    
    
    if (onlineState != PEER_STATUS_STATE_ONLINE) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title", nil)
                                                        message:NSLocalizedString(@"warnning_streamer_offline", nil)
                                                       delegate:nil cancelButtonTitle:NSLocalizedString(@"ok_btn", nil) otherButtonTitles:nil];
        [alert show];
        
        return;
    }
    
    
    
    CameraSettingsViewController *settingsVC = [[CameraSettingsViewController alloc] initWithNibName:@"CameraSettingsViewController" bundle:nil];
    
    settingsVC.cidNumber = cid;
    [[RDVTabBarController shareTabBar] setTabBarHidden:YES animated:NO];
    
    [self.navigationController pushViewController:settingsVC animated:YES];
    //[[RDVTabBarController shareTabBar] setTabBarHidden:NO animated:YES];
}

- (void)manageButtonAction:(NSString *)cid {
    
    //    NSInteger onlineState = [[MemberData memberData] getAvsStatusOfCID:cid];
    //
    //
    //    if (onlineState == PEER_STATUS_STATE_ERRUSERPWD) {
    //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title", nil)
    //                                                        message:NSLocalizedString(@"member_cid_status_wrong_password", nil)
    //                                                       delegate:nil cancelButtonTitle:NSLocalizedString(@"ok_btn", nil) otherButtonTitles:nil];
    //        [alert show];
    //
    //        return;
    //    }
    //
    //    if (onlineState != PEER_STATUS_STATE_ONLINE) {
    //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title", nil)
    //                                                        message:NSLocalizedString(@"warnning_streamer_offline", nil)
    //                                                       delegate:nil cancelButtonTitle:NSLocalizedString(@"ok_btn", nil) otherButtonTitles:nil];
    //        [alert show];
    //
    //        return;
    //    }
    
    
    
    [[RDVTabBarController shareTabBar] setTabBarHidden:YES animated:NO];
    ManageViewController *manage = [[ManageViewController alloc] initWithNibName:@"ManageViewController" bundle:nil];
    manage.CIDNumber = cid;
    [self.navigationController pushViewController:manage animated:YES];
    //[[RDVTabBarController shareTabBar] setTabBarHidden:NO animated:YES];
}

#pragma mark EditViewControllerDelegate

- (void)onEditCIDDone {
    
    [self delayTableVIewReload];
}

#pragma mark ----AHCServerCommunicatorDelegate----
-(void) onRecieveConnectServerStatusChanged:(SERVER_CONNECT_STATUS) status
{
    [self delayTableVIewReload];
}

-(void) onRecievePeerStatusChanged:(NSString*)peerCID withStatus:(NSDictionary*)statusInfo
{
    [self delayTableVIewReload];
}


-(void) onCfgGetSuc:(NSString*)peerCID {
    
    [self delayTableVIewReload];
}

- (void)delayTableVIewReload {
    
    [self updateCidListAndReloadTableView];
}

#pragma mark ---AHCNetworkChangeDetectorDelegate---
-(void) onNeedReconnect
{
    [self.navigationController popToRootViewControllerAnimated:YES];
    [self reconnectingToServer];
}


- (void)notifyNetworkChange:(AHCNetworkChangeDetector*) detector {
    
    
    if ([detector isNetworkConnected]) {
        
        self.serversTableView.tableHeaderView = nil;
        
        [self removeCoverView];
    }
    else {
        
        self.serversTableView.tableHeaderView = self.headerView;
        
        [self removeCoverView];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == kDeleteCIDAlertViewTag) {
        if (buttonIndex == 1) {
            [self deleteCIDFromLocalAndService];
        }
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
