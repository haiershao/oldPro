//
//  DisCoveryDetailViewController.m
//  HuaWo
//
//  Created by circlely on 2/29/16.
//  Copyright © 2016 circlely. All rights reserved.
//

#import "DisCoveryDetailViewController.h"
#import "ASIHTTPRequest.h"
#import <AssetsLibrary/ALAsset.h>
#import <AssetsLibrary/ALAssetsGroup.h>
#import "MBProgressHUD.h"
#import "LoginViewController.h"
#import <CCString/CCString.h>
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>
#import <ShareSDKUI/SSUIShareActionSheetCustomItem.h>
#import <ShareSDK/ShareSDK+Base.h>
#import <ShareSDKExtension/ShareSDK+Extension.h>
#import "HWUserInstanceInfo.h"
#import <ShareSDKExtension/SSEShareHelper.h>
#import <ShareSDKUI/SSUIShareActionSheetStyle.h>

#import "NSString+encrypto.h"
#import "HWTextAlertView.h"
#import "NSString+encrypto.h"
#import "MemberData.h"
#import "NSString+Helper.h"
#import "HWCommentView.h"
#import "VideoModel.h"
#import <WMPlayer/WMPlayer.h>
#import "SidModel.h"
#import "MBProgressHUD.h"
#import "HWDiscoverCommentCell.h"
#import "HWCommentModel.h"
#import <MJRefresh.h>
#import "AppDelegate.h"
#define kUid [[MemberData memberData] getMemberAccount]
#define kNickName [[MemberData memberData] getMemberNickName]

typedef void (^CompletionBlock)(void);
typedef void (^FailureBlock)(NSError *error);


@interface DisCoveryDetailViewController ()<WMPlayerDelegate, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate>{
    WMPlayer  *wmPlayer;
    CGRect     playerFrame;
    BOOL isHiddenStatusBar;//记录状态的隐藏显示
    BOOL flag;
}
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSString *videoUrl;
@property (copy, nonatomic) NSString *deviceNickname;

/**
 *  面板
 */
@property (nonatomic, strong) UIView *panelView;
@property (nonatomic, strong) UIView *headerView;
/**
 *  加载视图
 */
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;

//@property (strong, nonatomic) MBProgressHUD *hud;
@property (nonatomic, strong) HWTextAlertView *textAlertView;
@property (nonatomic, copy) NSString *alarmId;
@property (strong, nonatomic) UIAlertController *alertCommentVc;
@property (strong, nonatomic) UIAlertView *alertBindQuery;
//@property (nonatomic, strong) HWCommentView *commentView;

@property (weak, nonatomic) UIButton *commentBtn;

@property (strong, nonatomic) UIButton *agreeBtn;
@property (strong, nonatomic) UIButton *shareBtn;
@property (strong, nonatomic) NSMutableArray *commentArr;
@property (weak, nonatomic) IBOutlet UIView *commentView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomSapce;
@property (weak, nonatomic) IBOutlet UITextField *commentFiledText;
@end

@implementation DisCoveryDetailViewController
- (NSMutableArray *)commentArr{
    
    if (!_commentArr) {
        _commentArr = [NSMutableArray array];
    }
    return _commentArr;
}

- (id)init{
    self = [super init];
    if (self) {
        self.enablePanGesture = YES;
    }
    return self;
}

- (void)addHud
{
    if (!_hud) {
        _hud=[MBProgressHUD showHUDAddedTo:self.view animated:YES configBlock:nil];
    }
}
- (void)addHudWithMessage:(NSString*)message
{
    if (!_hud)
    {
        _hud=[MBProgressHUD showHUDAddedTo:self.view animated:YES configBlock:nil];
        _hud.labelText=message;
    }
    
}
- (void)removeHud
{
    if (_hud) {
        [_hud removeFromSuperview];
        _hud=nil;
    }
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

//- (void)viewDidAppear:(BOOL)animated{
//
//    [super viewDidAppear:animated];
//    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
//        
//        //调用隐藏方法
//        [self prefersStatusBarHidden];
//        
//        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
//        
//    }
//}

-(BOOL)prefersStatusBarHidden{
    
    if (isHiddenStatusBar) {//隐藏
        return YES;
    }
    
    return YES;
}
//视图控制器实现的方法
-(BOOL)shouldAutorotate{
    
    //iOS6.0之后,要想让状态条可以旋转,必须设置视图不能自动旋转
    return NO;
}
// 支持哪些屏幕方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

// 默认的屏幕方向（当前ViewController必须是通过模态出来的UIViewController（模态带导航的无效）方式展现出来的，才会调用这个方法）
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}
///播放器事件
-(void)wmplayer:(WMPlayer *)wmplayer clickedCloseButton:(UIButton *)closeBtn{
    
    if (wmplayer.isFullscreen) {
        [self toOrientation:UIInterfaceOrientationPortrait];
        wmPlayer.isFullscreen = NO;
        self.enablePanGesture = YES;
        
    }else{
        [self releaseWMPlayer];
        [[RDVTabBarController shareTabBar] setTabBarHidden:YES animated:NO];
        [self.navigationController popViewControllerAnimated:YES];
        
    }
}
///播放暂停
-(void)wmplayer:(WMPlayer *)wmplayer clickedPlayOrPauseButton:(UIButton *)playOrPauseBtn{
    NSLog(@"clickedPlayOrPauseButton");
}
///全屏按钮
-(void)wmplayer:(WMPlayer *)wmplayer clickedFullScreenButton:(UIButton *)fullScreenBtn{
    
    if (wmPlayer.isFullscreen==YES) {//全屏
        [self toOrientation:UIInterfaceOrientationPortrait];
        wmPlayer.isFullscreen = NO;
        self.enablePanGesture = YES;
        
    }else{//非全屏
        [self toOrientation:UIInterfaceOrientationLandscapeRight];
        wmPlayer.isFullscreen = YES;
        self.enablePanGesture = NO;
    }
}
///单击播放器
-(void)wmplayer:(WMPlayer *)wmplayer singleTaped:(UITapGestureRecognizer *)singleTap{
    NSLog(@"didSingleTaped");
    //    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"测试" message:@"测试旋转屏" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    //    [alertView show];
    
    //    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"测试" message:@"测试旋转屏" preferredStyle:UIAlertControllerStyleAlert];
    //    [alertVC addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    //
    //    }]];
    //    [self presentViewController:alertVC animated:YES completion:^{
    //    }];
    
    
    
}
///双击播放器
-(void)wmplayer:(WMPlayer *)wmplayer doubleTaped:(UITapGestureRecognizer *)doubleTap{
    NSLog(@"didDoubleTaped");
}
///播放状态
-(void)wmplayerFailedPlay:(WMPlayer *)wmplayer WMPlayerStatus:(WMPlayerState)state{
    NSLog(@"wmplayerDidFailedPlay");
}
-(void)wmplayerReadyToPlay:(WMPlayer *)wmplayer WMPlayerStatus:(WMPlayerState)state{
    //    NSLog(@"wmplayerDidReadyToPlay");
}
-(void)wmplayerFinishedPlay:(WMPlayer *)wmplayer{
    NSLog(@"wmplayerDidFinishedPlay");
}
//操作栏隐藏或者显示都会调用此方法
-(void)wmplayer:(WMPlayer *)wmplayer isHiddenTopAndBottomView:(BOOL)isHidden{
    isHiddenStatusBar = isHidden;
    [self setNeedsStatusBarAppearanceUpdate];
}
/**
 *  旋转屏幕通知
 */
- (void)onDeviceOrientationChange:(NSNotification *)notification{
    if (wmPlayer==nil||wmPlayer.superview==nil){
        return;
    }
    
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)orientation;
    switch (interfaceOrientation) {
        case UIInterfaceOrientationPortraitUpsideDown:{
            NSLog(@"第3个旋转方向---电池栏在下");
            wmPlayer.isFullscreen = NO;
            self.enablePanGesture = NO;
        }
            break;
        case UIInterfaceOrientationPortrait:{
            NSLog(@"第0个旋转方向---电池栏在上");
            [UIApplication sharedApplication].statusBarHidden = YES;
            [self toOrientation:UIInterfaceOrientationPortrait];
            [UIApplication sharedApplication].statusBarHidden = YES;
            wmPlayer.isFullscreen = YES;
            self.enablePanGesture = YES;
            
        }
            break;
        case UIInterfaceOrientationLandscapeLeft:{
            NSLog(@"第2个旋转方向---电池栏在左");
            [self toOrientation:UIInterfaceOrientationLandscapeLeft];
            wmPlayer.isFullscreen = YES;
            self.enablePanGesture = NO;
            
        }
            break;
        case UIInterfaceOrientationLandscapeRight:{
            NSLog(@"第1个旋转方向---电池栏在右");
            [self toOrientation:UIInterfaceOrientationLandscapeRight];
            wmPlayer.isFullscreen = YES;
            self.enablePanGesture = NO;
        }
            break;
        default:
            break;
    }
}

//点击进入,退出全屏,或者监测到屏幕旋转去调用的方法
-(void)toOrientation:(UIInterfaceOrientation)orientation{
    //获取到当前状态条的方向
    UIInterfaceOrientation currentOrientation = [UIApplication sharedApplication].statusBarOrientation;
    //判断如果当前方向和要旋转的方向一致,那么不做任何操作
    
    //根据要旋转的方向,使用Masonry重新修改限制
    if (orientation ==UIInterfaceOrientationPortrait) {//
        [wmPlayer mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).with.offset(0);
            make.left.equalTo(self.view).with.offset(0);
            make.right.equalTo(self.view).with.offset(0);
            make.height.equalTo(@(playerFrame.size.height));
        }];
    }else{
        //这个地方加判断是为了从全屏的一侧,直接到全屏的另一侧不用修改限制,否则会出错;
        if (currentOrientation ==UIInterfaceOrientationPortrait) {
            [wmPlayer mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(@([UIScreen mainScreen].bounds.size.height));
                make.height.equalTo(@([UIScreen mainScreen].bounds.size.width));
                make.center.equalTo(wmPlayer.superview);
                
            }];
        }
    }
    //iOS6.0之后,设置状态条的方法能使用的前提是shouldAutorotate为NO,也就是说这个视图控制器内,旋转要关掉;
    //也就是说在实现这个方法的时候-(BOOL)shouldAutorotate返回值要为NO
    [[UIApplication sharedApplication] setStatusBarOrientation:orientation animated:NO];
    //获取旋转状态条需要的时间:
    [UIView beginAnimations:nil context:nil];
    //更改了状态条的方向,但是设备方向UIInterfaceOrientation还是正方向的,这就要设置给你播放视频的视图的方向设置旋转
    //给你的播放视频的view视图设置旋转
    wmPlayer.transform = CGAffineTransformIdentity;
    //    wmPlayer.transform = [WMPlayer getCurrentDeviceOrientation];
    
    if (wmPlayer.isFullscreen) {
        
        [wmPlayer mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).with.offset(0);
            make.left.equalTo(self.view).with.offset(0);
            make.right.equalTo(self.view).with.offset(0);
            make.height.equalTo(@(playerFrame.size.height));
        }];
        wmPlayer.transform = [WMPlayer GetCurrentDeviceOrientation:UIInterfaceOrientationPortrait];
        wmPlayer.isFullscreen = NO;
    }else{
        
        [wmPlayer mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@([UIScreen mainScreen].bounds.size.height));
            make.height.equalTo(@([UIScreen mainScreen].bounds.size.width));
            make.center.equalTo(wmPlayer.superview);
            wmPlayer.isFullscreen = YES;
            
        }];
        wmPlayer.transform = [WMPlayer GetCurrentDeviceOrientation:UIInterfaceOrientationLandscapeRight];
        wmPlayer.isFullscreen = YES;
    }
    
    [UIView setAnimationDuration:2.0];
    //开始旋转
    [UIView commitAnimations];
}

- (void)viewWillAppear:(BOOL)animated{
    AppDelegate * appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.allowRotation = YES;
    wmPlayer.isFullscreen = NO;
    [super viewWillAppear:animated];
    //获取设备旋转方向的通知,即使关闭了自动旋转,一样可以监测到设备的旋转方向
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    //旋转屏幕通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onDeviceOrientationChange:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil
     ];
//    [[UIApplication sharedApplication] setStatusBarHidden:YES];
//    [self.navigationController setNavigationBarHidden:YES animated:YES];
//    [[RDVTabBarController shareTabBar] setTabBarHidden:YES animated:NO];
    
}
-(void)viewDidDisappear:(BOOL)animated{
    
    [super viewDidAppear:animated];
//    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self releaseWMPlayer];

    
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [UIApplication sharedApplication].statusBarHidden = NO;//不隐藏／
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    wmPlayer.isFullscreen = NO;
    
    self.navigationController.delegate = self;
//    [self.navigationController setNavigationBarHidden:YES animated:YES];
    if (_statusBarHidden) {
     [UIApplication sharedApplication].statusBarHidden = YES;//不隐藏／   
    }
    
    
    [self shouldAutorotate];
    
//    [[HWGetUserInfo alloc] getDeviceNickname];
//    [DZNotificationCenter addObserver:self selector:@selector(getUserNickName:) name:@"getUserInfoToNickname" object:nil];
    
    
    flag = NO;
    self.view.backgroundColor = kBackgroundColor;
    self.tableView.backgroundColor = kBackgroundColor;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.contentInset = UIEdgeInsetsMake(-64, 0, 0, 0);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableHeaderView.tintColor = [UIColor whiteColor];
    [self setUpNav];
    
    [self setUpHeaderView];
    
    [self setUpPlayer];
    
    [self getCommentList];
//    [self.tableView.mj_header beginRefreshing];
    
    [SSUIShareActionSheetStyle setShareActionSheetStyle:ShareActionSheetStyleSimple];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    // 判断要显示的控制器是否是自己
    
//    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
}

- (void)getUserNickName:(NSNotification *)note{
    
    self.deviceNickname = (NSString *)note.object;
    [self.tableView reloadData];
    
}

- (void)keyboardWillChangeFrame:(NSNotification *)note{
    flag = !flag;
    CGRect frame = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.bottomSapce.constant = screenH - frame.origin.y;
    [self.view layoutIfNeeded];
    CGFloat duration = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    [UIView animateWithDuration:duration animations:^{
        [self.view layoutIfNeeded];
    }];
    
}
- (IBAction)cancelBtnClick:(UIButton *)sender {
    [self.view endEditing:YES];
    self.commentBtn.selected = NO;
}

- (IBAction)postBtnClick:(UIButton *)sender {
    HWLog(@"postBtnClick%@",self.commentFiledText.text);
    [self.view endEditing:YES];
    [self composeContent:self.commentFiledText.text];
    self.commentFiledText.text = nil;
    self.commentBtn.selected = NO;
    
}
- (void)getCommentList{
    self.alarmId = _model.videoid;
    __weak __typeof(&*self)weakSelf = self;
    __unsafe_unretained UITableView *tableView = weakSelf.tableView;
    // 下拉刷新
    tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
//        [weakSelf addHudWithMessage:@"加载中..."];
        
        NSURL *url = [NSURL URLWithString:@"http://find.hwawo.com:9090/ControlCenter/v3/restapi/doaction"];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        request.HTTPMethod = @"POST";
        
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        HWLog(@"self.alarmId  %@",self.alarmId);
        NSDictionary *para = @{
                               @"videoid":self.alarmId,
                               @"order":@"desc"
                               };
        
        NSDictionary *dict = @{
                               @"action":@"qry_remarklist",
                               @"token":@"public001",
                               @"para":para
                               };
        HWLog(@"dict == %@",dict);
        if ([NSJSONSerialization isValidJSONObject:dict])
        {
            
            NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
            request.HTTPBody = data;
            
            __typeof(self) __weak safeSelf = self;
            [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                
                if (!connectionError) {
                    
                    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                    HWLog(@"getCommentList dict == %@",dict);
                    HWLog(@"getCommentList code == %@",[dict objectForKey:@"data"]);
                    NSDictionary *dataList = [dict objectForKey:@"data"];
                    HWLog(@"getCommentList datalist == %@",dataList[@"datalist"]);
                    
                    NSArray *dictArr = dataList[@"datalist"];
                    [self.commentArr removeAllObjects];
                    for (NSInteger i = 0; i < dictArr.count; i++){
                        HWCommentModel * v= [[HWCommentModel alloc] init];
                        [v setValuesForKeysWithDictionary:dictArr[i]];
                        [self.commentArr addObject:v];
                        NSLog(@"v.nickname %@",v.nickname);
                        
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                            
                        _model.comtimes =  [NSString stringWithFormat:@"%ld",[_model.comtimes integerValue] + 1];
                        
                        [self.commentBtn setTitle:_model.comtimes forState:UIControlStateNormal];
                        
                        [weakSelf removeHud];
                        [tableView reloadData];
                        [tableView.mj_header endRefreshing];
                    });
                    HWLog(@"self.commentArr %@",self.commentArr);
                }
                else{
                    HWLog(@"error:%@",connectionError);
                    [weakSelf removeHud];
                }
            }];
        }
        else
        {
            HWLog(@"数据有误");
        }
        
    }];
    
    
}

- (void)setUpHeaderView{
    
    UIView *bgView = [[UIView alloc] init];
    
    bgView.x = 0;
    bgView.y = 100;
    bgView.width = screenW;
    bgView.height = 0.56*screenW + 28;
    
    UIView *headerView = [[UIView alloc] init];
    //    headerView.backgroundColor = [UIColor redColor];
    headerView.x = 0;
    headerView.y = 0;
    headerView.width = screenW;
    headerView.height = 0.56*screenW;
    [bgView addSubview:headerView];
    self.tableView.tableHeaderView = bgView;
    self.headerView = bgView;
    //    [self.view addSubview:bgView];
    
    NSArray *images = @[@"find_common", @"find_agree", @"find_share"];
    NSArray *images_h = @[@"find_common_h", @"find_agree_h", @"find_share_h"];
    CGFloat width = screenW/3;
    for (NSInteger i = 0; i < images.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        //        btn.backgroundColor = [UIColor redColor];
        btn.x = i*width;
        btn.y = CGRectGetMaxY(headerView.frame);
        btn.width = width;
        btn.height = bgView.height - headerView.height - 2;
        [btn setImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:images_h[i]] forState:UIControlStateHighlighted];
        [bgView addSubview:btn];
        
        if (i == 0) {
            self.commentBtn = btn;
            [self.commentBtn setTitle:[NSString stringWithFormat:@"%@",_model.comtimes] forState:UIControlStateNormal];
            self.commentBtn.titleLabel.font = [UIFont systemFontOfSize:14];
            [self.commentBtn addTarget:self action:@selector(commentBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            [btn setImage:[UIImage imageNamed:images_h[i]] forState:UIControlStateSelected];
        }else if (i == 1){
            
            self.agreeBtn = btn;
            [self.agreeBtn setTitle:[NSString stringWithFormat:@"%@",_model.goodtimes]
             
                           forState:UIControlStateNormal];
            self.agreeBtn.titleLabel.font = [UIFont systemFontOfSize:14];
            [self.agreeBtn addTarget:self action:@selector(agreeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        }else if (i == 2){
            self.shareBtn = btn;
            [self.shareBtn addTarget:self action:@selector(shareBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    
    UILabel *label = [[UILabel alloc] init];
    label.backgroundColor = [UIColor blackColor];
    label.x = 0;
    label.y = CGRectGetMaxY(headerView.frame) + bgView.height - headerView.height - 2;
    label.width = screenW;
    label.height = 2;
    [bgView addSubview:label];
    
    
    
}

- (void)commentBtnClick:(UIButton *)btn{

    btn.selected = !btn.selected;
    self.commentBtn.selected = btn.selected;
    if (btn.selected) {
        [self.commentFiledText becomeFirstResponder];
    }else{
    
        [self.view endEditing:YES];
    }
}

- (void)shareBtnClick:(UIButton *)btn{

    wmPlayer.isFullscreen = NO;
    [self share:self.model];
}

- (void)agreeBtnClick:(UIButton *)btn{
    
    //    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES configBlock:^(MBProgressHUD *HUD) {
    //        HUD.removeFromSuperViewOnHide = YES;
    //    }];
    HWUserInstanceInfo * instanceInfo = [HWUserInstanceInfo shareUser];
    self.alarmId = _model.videoid;
    NSString *nickname = instanceInfo.nickname;
    NSString *uid = identifierForVendor;
    NSString *alarm_id = self.alarmId;
    
    
    
    NSURL *url = [NSURL URLWithString:@"http://find.hwawo.com:9090/ControlCenter/v3/restapi/doaction"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    if (!nickname) {
        return;
    }
    NSDictionary *para = @{
                           @"videoid":self.alarmId
                           };
    
    NSDictionary *dict = @{
                           @"action":@"add_onegood",
                           @"token":@"public001",
                           @"para":para
                           };
    
//    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:UIAlertControllerStyleAlert];
//    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
//        
//    }];
//    self.alertCommentVc = alertVc;
//    HWLog(@"agreeBtnClick%@",alertVc);
//    [self.alertCommentVc addAction:cancelAction];
    
    if ([NSJSONSerialization isValidJSONObject:dict])
    {
        
        NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
        request.HTTPBody = data;
        
        
        //        [self.alertCommentVc addAction:cancelAction];
        __typeof(self) __weak safeSelf = self;
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            
            if (!connectionError) {
                
                
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                HWLog(@"dict[%@]",dict);
                
                HWLog(@"data[%@]",[dict objectForKey:@"data"]);
                NSDictionary *dataDict = [dict objectForKey:@"data"];
                HWLog(@"data[%@]",dataDict[@"code"]);
                
                if ([[dataDict objectForKey:@"code"] isEqualToString:@"1000"]) {
//                    [safeSelf.hud hide:YES];
                    
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                      
                        _model.goodtimes =  [NSString stringWithFormat:@"%ld",[_model.goodtimes integerValue] + 1];
                        
                        [self.agreeBtn setTitle:_model.goodtimes forState:UIControlStateNormal];
                    });
                    
                    
                    //                    safeSelf.alertCommentVc.title = @"✅";
//                    safeSelf.alertCommentVc.message = @"点赞";
                    [safeSelf.view endEditing:YES];
//                    [safeSelf presentViewController:self.alertCommentVc animated:YES completion:nil];
//                    [self.tableView.mj_header beginRefreshing];
//                    [self.tableView reloadData];
                }
                
                
            }
            else{
                HWLog(@"error:%@",connectionError);
                //                safeSelf.alertCommentVc.title = @"❌";
//                safeSelf.alertCommentVc.message = @"点赞失败";
                [safeSelf presentViewController:safeSelf.alertCommentVc animated:YES completion:nil];
            }
        }];
    }
    else
    {
        HWLog(@"数据有误");
    }
}

- (void)setModel:(VideoModel *)model{
    
    _model = model;
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    return @"最新评论";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    HWLog(@"_commentArr.count%lu",(unsigned long)_commentArr.count);
    return self.commentArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *detailCellID = @"detailCellID";
    HWDiscoverCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:detailCellID];
    if (!cell) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"HWDiscoverCommentCell" owner:self options:nil].firstObject;
    }
    
    cell.model = _commentArr[indexPath.row];
    
    [self.commentBtn setTitle:[NSString stringWithFormat:@"%@",_model.comtimes] forState:UIControlStateNormal];
    [self.agreeBtn setTitle:[NSString stringWithFormat:@"%@",_model.goodtimes] forState:UIControlStateNormal];
    
    return cell;
}

- (void)setUpPlayer{
    
    playerFrame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, ([UIScreen mainScreen].bounds.size.width)* 9 / 16);
    
    wmPlayer = [[WMPlayer alloc]init];
    //    wmPlayer = [[WMPlayer alloc]initWithFrame:playerFrame];
    
    wmPlayer.delegate = self;
    wmPlayer.URLString = _model.videoinfo.video_url;
    
    wmPlayer.titleLabel.text = @"";
    wmPlayer.closeBtn.hidden = NO;
    wmPlayer.dragEnable = NO;
    [self.view addSubview:wmPlayer];
    [wmPlayer play];
    
    [wmPlayer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(0);
        make.left.equalTo(self.view).with.offset(0);
        make.right.equalTo(self.view).with.offset(0);
        make.height.equalTo(@(playerFrame.size.height));
    }];
}

- (void)releaseWMPlayer
{
    //堵塞主线程
    //    [wmPlayer.player.currentItem cancelPendingSeeks];
    //    [wmPlayer.player.currentItem.asset cancelLoading];
    [wmPlayer pause];
    [wmPlayer removeFromSuperview];
    [wmPlayer.playerLayer removeFromSuperlayer];
    [wmPlayer.player replaceCurrentItemWithPlayerItem:nil];
    wmPlayer.player = nil;
    wmPlayer.currentItem = nil;
    //释放定时器，否侧不会调用WMPlayer中的dealloc方法
    [wmPlayer.autoDismissTimer invalidate];
    wmPlayer.autoDismissTimer = nil;
    wmPlayer.playOrPauseBtn = nil;
    wmPlayer.playerLayer = nil;
    wmPlayer = nil;
}

- (void)dealloc
{
    [self releaseWMPlayer];
    [DZNotificationCenter removeObserver:self];
    
    NSLog(@"DetailViewController deallco");
}

+ (instancetype)disCoveryDetailViewController{
    
    return [[self alloc] initWithNibName:@"DisCoveryDetailViewController" bundle:nil];
}


- (void)setUpNav{
//    [self.navigationController setNavigationBarHidden:YES animated:YES];
//    self.navigationController.navigationBar.barTintColor = kNavigation7Color;
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"title_back_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonItemAction)];
//    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    
    //注册键盘出现的通知
    [DZNotificationCenter addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    
    //注册键盘消失的通知
    [DZNotificationCenter addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWasShown:(NSNotification *)note {
    
    CGRect frame = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat screenh = screenH;
    self.commentView.y = screenh - (self.commentView.frame.size.height + frame.size.height);
    
    CGFloat duration = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    [UIView animateWithDuration:duration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardWillBeHidden:(NSNotification *)note{
    
    CGFloat screenh = screenH;
    self.commentView.y = screenh + self.commentView.frame.size.height;
    
    CGFloat duration = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    [UIView animateWithDuration:duration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)leftBarButtonItemAction {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)addRightBarButton {
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"title_more"] style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonItemPressed)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    
}

- (void)rightBarButtonItemPressed {
    
    [self.webView stringByEvaluatingJavaScriptFromString:@"callRightMenu()"];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"quit_btn", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"collection_lable", nil),NSLocalizedString(@"save_btn", nil),NSLocalizedString(@"remove_btn", nil), nil];
    
    [actionSheet showInView:self.view];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    HWLog(@"requestUrl[%@]",request.URL);
    
    return [self AnalysisURL:request.URL];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 44)];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:14];
    titleLabel.text = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    self.navigationItem.titleView = titleLabel;
}

- (BOOL)AnalysisURL:(NSURL*)url {
    
    NSString *categoryUrl = @"category.html";
    NSString *requestUrl = [NSString stringWithFormat:@"%@",url];
    requestUrl = [requestUrl decodeFromPercentEscapeString:requestUrl];
    NSRange foundObject = [requestUrl rangeOfString:categoryUrl];
    
    if (foundObject.location == NSNotFound) {
        
        [self addRightBarButton];
    }
    
    NSString* info = url.absoluteString;
    HWLog(@"url[%@]",url);
    HWLog(@"info[%@]",info);
    
    APP_LOG_INF(@"start Analysis url [%@]", info);
    
#define K_READY_GET_INFO @"iosgetinfo:"
#define K_IOSALERT @"iosalert:"
#define K_IOS_SHARE @"iosshare:"
#define K_IOS_NOLOGIN @"iosnologin:"
#define K_IOS_COMMENT @"ioscomment:"
    NSArray* schemes = [NSArray arrayWithObjects:K_READY_GET_INFO, K_IOSALERT, K_IOS_SHARE,K_IOS_NOLOGIN, K_IOS_COMMENT,nil];
    
    //解码
    NSString* packageinfo = [info stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    HWLog(@"-------------packageinfo------------------%@",packageinfo);
    NSString* curScheme = nil;
    
    for (NSString* scheme in schemes) {
        HWLog(@"---substring---%@",[packageinfo substringToIndex:scheme.length]);
        if (packageinfo.length >= scheme.length && [[packageinfo substringToIndex:scheme.length] isEqualToString:scheme]) {
            
            curScheme = scheme;
            break;
        }
    }
    
    
    if (!curScheme) {
        
        return YES;
    }
    
    NSError *error = nil;
    
    id infoobj = [NSJSONSerialization JSONObjectWithData:[[packageinfo substringFromIndex:curScheme.length] dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
    HWLog(@"----------infoobj-----------%@",infoobj);
    HWLog(@"----------infoobj[@""]-----------%@",infoobj[@"alarmId"]);
    self.alarmId = infoobj[@"alarmId"];
    if (error) {
        
        return YES;
    }
    
    
    if([curScheme isEqualToString:K_READY_GET_INFO]){
        
        self.videoUrl = [infoobj objectForKey:@"videoUrl"];
        
        return NO;
    }
    //    else if ([curScheme isEqualToString:K_IOS_NOLOGIN]){
    //
    //        [self noLoginAlert];
    //        return NO;
    //    }
    else if([curScheme isEqualToString:K_IOS_SHARE]){
        
        [self share:infoobj[@"href"]];
        return NO;
    }
    
    else if ([curScheme isEqualToString:K_IOSALERT]) {
        
        if ([[infoobj objectForKey:@"result"] isEqualToString:@"success"]) {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES configBlock:^(MBProgressHUD *HUD) {
                
                HUD.removeFromSuperViewOnHide = YES;
                HUD.mode = MBProgressHUDModeText;
                HUD.detailsLabelText = @"操作成功";
                [HUD hide:YES afterDelay:2];
            }];
        }else{
            
            
            [MBProgressHUD showHUDAddedTo:self.view animated:YES configBlock:^(MBProgressHUD *HUD) {
                
                HUD.removeFromSuperViewOnHide = YES;
                HUD.mode = MBProgressHUDModeText;
                HUD.detailsLabelText = @"操作失败";
                [HUD hide:YES afterDelay:2];
            }];
            
        }
        
        return NO;
    }else if ([curScheme isEqualToString:K_IOS_COMMENT]){
        
        HWLog(@"--------------comment-------------------------------------");
        
    }
    
    return YES;
    
}

- (void)commentView:(HWCommentView *)commentView commentText:(UITextField *)commentTextField{
    
    HWLog(@"---%@",commentTextField.text);
    [self composeContent:commentTextField.text];
}

- (void)alertViewBtnClick{
    HWLog(@"----------------------------------");
    HWLog(@"-----%@",self.textAlertView.textview.text);
    [self.textAlertView.commentTextField endEditing:YES];
}

- (void)composeContent:(NSString *)comment{
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES configBlock:^(MBProgressHUD *HUD) {
        HUD.removeFromSuperViewOnHide = YES;
    }];
    
    //    [self.textAlertView.commentTextField endEditing:YES];
    //    [self.textAlertView closeTextAlertView];
    self.alarmId = _model.videoid;
    //    NSString *alarm_type = @"04";
    HWUserInstanceInfo *InstanceInfo = [HWUserInstanceInfo shareUser];
    NSString *nickname = InstanceInfo.nickname;
    //    NSString *location = @"上海张江";
    //    NSString *title = @"美丽风景";
    NSString *uid = identifierForVendor;
    NSString *alarm_id = self.alarmId;
    NSString *commentStr = comment;
    
    
    
    NSURL *url = [NSURL URLWithString:@"http://find.hwawo.com:9090/ControlCenter/v3/restapi/doaction"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    if (!nickname) {
        return;
    }
    
    NSDictionary *para = @{
                           @"content":commentStr,
                           @"nickname":nickname,
                           @"videoid":self.alarmId
                           };
    
    NSDictionary *dict = @{
                           @"action" :@"add_remark",
                           @"para": para,
                           @"token":InstanceInfo.token
                           };
    
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
    self.alertCommentVc = alertVc;
    HWLog(@"%@",alertVc);
    [self.alertCommentVc addAction:cancelAction];
    
    HWLog(@"composeContent dict %@",dict);
    
    if ([NSJSONSerialization isValidJSONObject:dict])
    {
        
        NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
        request.HTTPBody = data;
        
        
        //        [self.alertCommentVc addAction:cancelAction];
        __typeof(self) __weak safeSelf = self;
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            
            if (!connectionError) {
                
                NSData *dataDe = [NSString DecryptData:data];
                HWLog(@"datalength:%lu",(unsigned long)data.length);
                
                HWLog(@"dataDe:%@",dataDe);
                
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                HWLog(@"dict[%@]",dict);
                
                HWLog(@"code[%@]",[dict objectForKey:@"result"]);
                
                if ([[NSString stringWithFormat:@"%@",[dict objectForKey:@"result"]] isEqualToString:@"1"]) {
                    [safeSelf.hud hide:YES];
                    
                    //                    safeSelf.alertCommentVc.title = @"✅";
                    safeSelf.alertCommentVc.message = @"评论成功";
                    [safeSelf.view endEditing:YES];
                    [safeSelf presentViewController:self.alertCommentVc animated:YES completion:nil];
                    [self.tableView.mj_header beginRefreshing];
                    [self.tableView reloadData];
                }
                
                
            }
            else{
                HWLog(@"error:%@",connectionError);
                //                safeSelf.alertCommentVc.title = @"❌";
                safeSelf.alertCommentVc.message = @"发表失败";
                [safeSelf presentViewController:safeSelf.alertCommentVc animated:YES completion:nil];
            }
        }];
    }
    else
    {
        HWLog(@"数据有误");
    }
    
    
    //    NSString *urlStr = [NSString stringWithFormat:@"http://112.124.22.101:28080/alarm/v2/restapi/postComment?cid=%@&alarm_type=%@&nickname=%@&location=%@&title=%@&uid=%@&alarm_id=%@&comment=%@",identifierForVendor,alarm_type,nickname,location,title,uid,alarm_id,commentStr];
    //
    //    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //    NSURL *url = [NSURL URLWithString:urlStr];
    //
    //    // 2. 请求
    //    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:1 timeoutInterval:2.0f];
    //
    //    // 3. 连接
    //    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"XX" message:@"XX" preferredStyle:UIAlertControllerStyleAlert];
    //    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    //
    //    }];
    //    self.alertCommentVc = alertVc;
    //    HWLog(@"%@",alertVc);
    //    [self.alertCommentVc addAction:cancelAction];
    //    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
    //
    //        // 反序列化
    //        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
    //
    //
    //
    //        //        NSString *str0 = [NSString stringWithFormat:@"%@",result[@"bindresult"]];
    //        NSString *str1 = [NSString stringWithFormat:@"%@",result[@"desc"]];
    //
    //        if (str1) {
    //            if ([str1 isEqualToString:@"success"]) {
    //                HWLog(@"-------已绑定...------------");
    //                self.hud.hidden = YES;
    //                self.alertCommentVc.title = @"✅";
    //                self.alertCommentVc.message = @"评论成功";
    //
    //                [self.view endEditing:YES];
    //                [self presentViewController:self.alertCommentVc animated:YES completion:nil];
    //
    //            }else{
    //                self.hud.hidden = YES;
    //                self.alertCommentVc.title = @"❌";
    //                self.alertCommentVc.message = @"发表失败";
    //                [self presentViewController:self.alertCommentVc animated:YES completion:nil];
    //            }
    //        }else {
    //            
    //            HWLog(@"====================result＝为空");
    //        }
    //        
    //    }];
    
    
    
    HWLog(@"----composeContent------%@--%@",self.textAlertView.textview.text,self.alarmId);
}



//- (void)composeContent:(NSString *)comment{
//
////    [self.textAlertView.commentTextField endEditing:YES];
////    [self.textAlertView closeTextAlertView];
//
//    NSString *strUid = kUid;
//    NSString *secretUid = [strUid sha1];
//    NSString *strNickName = kNickName;
//
//    NSURL *url = [NSURL URLWithString:kCommentUrl];
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
//    request.HTTPMethod = @"POST";
//
//    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//
//    NSDictionary *dict = @{
//                           @"alarm_type" : @"04",
//                           @"nickname": deviceNickName,
//                           @"location":@"上海张江",
//                           @"title":@"美丽风景",
//                           @"uid":identifierForVendor,
//                           @"alarm_id":self.alarmId,
//                           @"comment":comment
//                           };
//
//    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"XX" message:@"XX" preferredStyle:UIAlertControllerStyleAlert];
//    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
//
//    }];
//    self.alertCommentVc = alertVc;
//    HWLog(@"%@",alertVc);
//    [self.alertCommentVc addAction:cancelAction];
//
//    if ([NSJSONSerialization isValidJSONObject:dict])
//    {
//
//        NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
//        request.HTTPBody = data;
//
//
////        [self.alertCommentVc addAction:cancelAction];
//        __typeof(self) __weak safeSelf = self;
//        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
//
//            if (!connectionError) {
//
//                NSData *dataDe = [NSString DecryptData:data];
//                HWLog(@"datalength:%lu",(unsigned long)data.length);
//
//                HWLog(@"dataDe:%@",dataDe);
//
//                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:dataDe options:NSJSONReadingMutableContainers error:nil];
//                HWLog(@"dict[%@]",dict);
//
//                HWLog(@"code[%@]",[dict objectForKey:@"code"]);
//
//                [safeSelf.hud hide:YES];
//
//                safeSelf.alertCommentVc.title = @"✅";
//                safeSelf.alertCommentVc.message = @"评论成功";
//                [safeSelf.view endEditing:YES];
//                [safeSelf presentViewController:self.alertCommentVc animated:YES completion:nil];
//
//                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:safeSelf.requestUrl];
//
//                [self.webView loadRequest:request];
//            }
//            else{
//                HWLog(@"error:%@",connectionError);
//                safeSelf.alertCommentVc.title = @"❌";
//                safeSelf.alertCommentVc.message = @"发表失败";
//                [safeSelf presentViewController:safeSelf.alertCommentVc animated:YES completion:nil];
//            }
//        }];
//    }
//    else
//    {
//        HWLog(@"数据有误");
//    }
//    HWLog(@"----composeContent------%@--%@",self.textAlertView.textview.text,self.alarmId);
//}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    HWLog(@"----%ld",(long)buttonIndex);
}

- (void)cancelBtnClick {
    
    [self.textAlertView.commentTextField endEditing:YES];
}

// 3.18 add start --- by mj
- (void)share:(VideoModel *)model{

    HWLog(@"%@",[NSURL URLWithString:model.videoinfo.video_url]);
    NSURL *url = [NSURL URLWithString:model.videoinfo.video_url];
    HWUserInstanceInfo *instanceInfo = [HWUserInstanceInfo shareUser];
    NSString *nickName = instanceInfo.nickname;
    HWLog(@"_model.videoinfo.nickname==%@",model.videoinfo.nickname);
    
    /**
     * 在简单分享中，只要设置共有分享参数即可分享到任意的社交平台
     **/
    __weak DisCoveryDetailViewController *theController = self;
    
    //1、创建分享参数（必要）
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    NSArray* imageArray = @[[UIImage imageNamed:@"AppIcon120.png"]];
    [shareParams SSDKSetupShareParamsByText:_model.title
                                     images:imageArray
                                        url:url
                                      title:model.videoinfo.nickname
                                       type:SSDKContentTypeAuto];
    
    HWLog(@"--------------------%@",[NSURL URLWithString:model.videoinfo.video_url]);
    //1.2、自定义分享平台（非必要）
    NSMutableArray *activePlatforms = [NSMutableArray arrayWithArray:[ShareSDK activePlatforms]];
    //添加一个自定义的平台（非必要）
    SSUIShareActionSheetCustomItem *item = [SSUIShareActionSheetCustomItem itemWithIcon:[UIImage imageNamed:@"Icon.png"]
                                                                                  label:@"自定义"
                                                                                onClick:^{
                                                                                    
                                                                                    //自定义item被点击的处理逻辑
                                                                                    HWLog(@"=== 自定义item被点击 ===");
                                                                                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"自定义item被点击"
                                                                                                                                        message:nil
                                                                                                                                       delegate:nil
                                                                                                                              cancelButtonTitle:@"确定"
                                                                                                                              otherButtonTitles:nil];
                                                                                    [alertView show];
                                                                                }];
    [activePlatforms addObject:item];
    
    //2、分享
    [ShareSDK showShareActionSheet:self.view
                             items:nil
                       shareParams:shareParams
               onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
                   
                   switch (state) {
                           
                       case SSDKResponseStateBegin:
                       {
                           [theController showLoadingView:YES];
                           break;
                       }
                       case SSDKResponseStateSuccess:
                       {
                           //Facebook Messenger、WhatsApp等平台捕获不到分享成功或失败的状态，最合适的方式就是对这些平台区别对待
                           if (platformType == SSDKPlatformTypeFacebookMessenger)
                           {
                               break;
                           }
                           
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
                           if (platformType == SSDKPlatformTypeSMS && [error code] == 201)
                           {
                               UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享失败"
                                                                               message:@"失败原因可能是：1、短信应用没有设置帐号；2、设备不支持短信应用；3、短信应用在iOS 7以上才能发送带附件的短信。"
                                                                              delegate:nil
                                                                     cancelButtonTitle:@"OK"
                                                                     otherButtonTitles:nil, nil];
                               [alert show];
                               break;
                           }
                           else if(platformType == SSDKPlatformTypeMail && [error code] == 201)
                           {
                               UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享失败"
                                                                               message:@"失败原因可能是：1、邮件应用没有设置帐号；2、设备不支持邮件应用；"
                                                                              delegate:nil
                                                                     cancelButtonTitle:@"OK"
                                                                     otherButtonTitles:nil, nil];
                               [alert show];
                               break;
                           }
                           else
                           {
                               UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享失败"
                                                                               message:[NSString stringWithFormat:@"%@",error]
                                                                              delegate:nil
                                                                     cancelButtonTitle:@"OK"
                                                                     otherButtonTitles:nil, nil];
                               [alert show];
                               break;
                           }
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
                   
                   if (state != SSDKResponseStateBegin)
                   {
                       [theController showLoadingView:NO];
                       
                   }
                   
               }];
    
}

/**
 *  显示加载动画
 *
 *  @param flag YES 显示，NO 不显示
 */
- (void)showLoadingView:(BOOL)flag{
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

//3.18 add end --- by mj
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        
        [self.webView stringByEvaluatingJavaScriptFromString:@"addFavorite()"];
    }
    
    else if (buttonIndex == 1) {
        
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES configBlock:^(MBProgressHUD *HUD) {
            HUD.mode = MBProgressHUDModeCustomView;
            HUD.removeFromSuperViewOnHide = YES;
            //HUD.customView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            //[((UIActivityIndicatorView *)HUD.customView) startAnimating];
            HUD.customView = self.progressView;
            
        }];
        
        [self saveToLocalAlbumWithCompletionBlock:^{
            hud.mode = MBProgressHUDModeCustomView;
            hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Checkmark"]];
            hud.detailsLabelText = NSLocalizedString(@"warnning_save_successfully", nil);
            [hud hide:YES afterDelay:2];
            
        } failureBlock:^(NSError *error) {
            
            hud.mode = MBProgressHUDModeCustomView;
            hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"warning"]];
            hud.detailsLabelText = NSLocalizedString(@"warnning_save_photo_failed", nil);
            [hud hide:YES afterDelay:2];
            
        }];
        
        
        
    }
    
    else if (buttonIndex == 2) {
        
        [self.webView stringByEvaluatingJavaScriptFromString:@"deleteFavorite()"];
    }
    
}

- (void)saveToLocalAlbumWithCompletionBlock:(CompletionBlock)aCompletionBlock
                               failureBlock:(FailureBlock)aFailureBlock{
    
    NSString *videoUrl = self.videoUrl;
    
    NSString *moviePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[videoUrl lastPathComponent]];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:videoUrl]];
    [request setDownloadDestinationPath:moviePath];
    
    [request startAsynchronous];
    [request setDownloadProgressDelegate:self.progressView];
    [request setFailedBlock:^{
        
        if (aFailureBlock) {
            aFailureBlock(nil);
        }
        
    }];
    
    [request setCompletionBlock:^{
        
        //        __block NSString *tempAlbumName = @"HuaWoVideo";
        
        ALAssetsLibrary* assetLib = [[ALAssetsLibrary alloc] init];
        
        [assetLib writeVideoAtPathToSavedPhotosAlbum:[NSURL fileURLWithPath:moviePath] completionBlock:^(NSURL *assetURL, NSError *error) {
            
            if (error) {
                
                
                HWLog(@"writeVideoAtPathToSavedPhotosAlbum error[%@]", [error description]);
                
                if (aFailureBlock) {
                    aFailureBlock(error);
                }
                
                return;
            }
            
            __block BOOL isAthomeGroupFound = NO;
            
            
            //遍历所有分组
            [assetLib enumerateGroupsWithTypes:ALAssetsGroupAlbum usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                
                //找到tempAlbumName
                if ([[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:@"HuaWoVideo0"]) {
                    
                    
                    isAthomeGroupFound = YES;
                    *stop = YES;
                    
                    
                    [assetLib assetForURL:assetURL resultBlock:^(ALAsset *asset) {
                        
                        [group addAsset:asset];
                        
                        //dispatch_async(dispatch_get_main_queue(), ^{
                        
                        if (aCompletionBlock) {
                            
                            aCompletionBlock();
                        }
                        
                        
                        // });
                        
                        
                        
                    }
                             failureBlock:^(NSError *error) {
                                 
                                 //dispatch_async(dispatch_get_main_queue(), ^{
                                 
                                 if (aFailureBlock) {
                                     aFailureBlock(error);
                                 }
                                 
                                 //});
                                 
                                 
                             }];
                    
                    return;
                    
                }
                
                
                //如果没有找到tempAlbumName,就需要先创建tempAlbumName
                if (!group && !isAthomeGroupFound){
                    
                    [assetLib addAssetsGroupAlbumWithName:@"HuaWoVideo0" resultBlock:^(ALAssetsGroup *group) {
                        
                        
                        [assetLib assetForURL:assetURL resultBlock:^(ALAsset *asset) {
                            
                            [group addAsset:asset];
                            
                            //dispatch_async(dispatch_get_main_queue(), ^{
                            
                            if (aCompletionBlock) {
                                
                                aCompletionBlock();
                            }
                            
                            
                            //});
                            
                        }
                                 failureBlock:^(NSError *error) {
                                     //dispatch_async(dispatch_get_main_queue(), ^{
                                     
                                     if (aFailureBlock) {
                                         aFailureBlock(error);
                                     }
                                     
                                     //});
                                 }];
                        
                    }
                                             failureBlock:^(NSError *error) {
                                                 
                                                 //dispatch_async(dispatch_get_main_queue(), ^{
                                                 
                                                 if (aFailureBlock) {
                                                     aFailureBlock(error);
                                                 }
                                                 
                                                 //});
                                                 
                                             }];
                }
                
                
            }
                                  failureBlock:^(NSError *error) {
                                      //dispatch_async(dispatch_get_main_queue(), ^{
                                      
                                      if (aFailureBlock) {
                                          aFailureBlock(error);
                                      }
                                      
                                      //});
                                  }];
        }];
        
    }];
    
}
@end
