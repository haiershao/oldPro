//
//  HWZuiXinTableViewController.m
//  HuaWo
//
//  Created by hwawo on 17/3/14.
//  Copyright © 2017年 HW. All rights reserved.
//

#import "HWZuiXinTableViewController.h"
#import "SidModel.h"
#import "VideoModel.h"
#import "DisCoveryDetailViewController.h"
#import "AppDelegate.h"
#import <MJRefresh.h>
#import <WMPlayer/Masonry.h>
#import "DataManager.h"
#import <WMPlayer/WMPlayer.h>
#import "MBProgressHUD.h"
#import "HWZuiXinCell.h"
#import "HWCommentView.h"
#import "HWMyShowViewController.h"
#import "HWPushViewController.h"
#import "HWAccidentViewController.h"
#import "HWBeautifulViewController.h"
#import "HWUserInstanceInfo.h"
@interface HWZuiXinTableViewController ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,WMPlayerDelegate, zuiXinCellDelegate>{
    NSMutableArray *dataSource;
    WMPlayer *wmPlayer;
    NSIndexPath *currentIndexPath;
    BOOL isSmallScreen;
    NSInteger index;
}
@property(nonatomic,retain)HWZuiXinCell *currentCell;
@property (nonatomic,retain) MBProgressHUD* hud;
@property (nonatomic, strong) HWCommentView *commentView;
@property (nonatomic, copy) NSString *alarmId;

@end

@implementation HWZuiXinTableViewController

- (void)zuiXinCellCommentBtnClick:(HWZuiXinCell *)zuiXinCell videoModel:(VideoModel *)model{
    [[RDVTabBarController shareTabBar] setTabBarHidden:YES animated:NO];
    DisCoveryDetailViewController *detailVc = [DisCoveryDetailViewController disCoveryDetailViewController];
    detailVc.model = model;
    detailVc.statusBarHidden = YES;
    [self.navigationController pushViewController:detailVc animated:YES];
    HWLog(@"zuiXinCellCommentBtnClick");
}

- (void)zuiXinCellAgreeBtnClick:(HWZuiXinCell *)zuiXinCell videoModel:(VideoModel *)model{
//    [[RDVTabBarController shareTabBar] setTabBarHidden:YES animated:NO];
//    
//    DisCoveryDetailViewController *detailVc = [DisCoveryDetailViewController disCoveryDetailViewController];
//    detailVc.model = model;
//    detailVc.statusBarHidden = YES;
//    [self.navigationController pushViewController:detailVc animated:YES];
    [self agree:model cell:zuiXinCell];
    
    HWLog(@"zuiXinCellAgreeBtnClick");
}

- (void)zuiXinCellShareBtnClick:(HWZuiXinCell *)zuiXinCell videoModel:(VideoModel *)model{

    DisCoveryDetailViewController *detailVc = [DisCoveryDetailViewController disCoveryDetailViewController];

    detailVc.statusBarHidden = NO;
    [detailVc share:model];
    
    
    HWLog(@"zuiXinCellShareBtnClick");
}

- (void)agree:(VideoModel *)model cell:(HWZuiXinCell *)zuiXinCell{

    HWUserInstanceInfo * instanceInfo = [HWUserInstanceInfo shareUser];
    self.alarmId = model.videoid;
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
                        
                        model.goodtimes =  [NSString stringWithFormat:@"%ld",[model.goodtimes integerValue] + 1];
                        
                        [zuiXinCell.agreeBtn setTitle:model.goodtimes forState:UIControlStateNormal];
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
            }
        }];
    }
    else
    {
        HWLog(@"数据有误");
    }
}

- (instancetype)init{
    self = [super init];
    if (self) {
        dataSource = [NSMutableArray array];
        isSmallScreen = NO;
    }
    return self;
}
-(BOOL)prefersStatusBarHidden{
    if (wmPlayer) {
        if (wmPlayer.isFullscreen) {
            return YES;
        }else{
            return NO;
        }
    }else{
        return NO;
    }
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    self.navigationController.navigationBarHidden = YES;
    //旋转屏幕通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onDeviceOrientationChange)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil
     ];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [[RDVTabBarController shareTabBar] setTabBarHidden:NO animated:NO];
//    [UIApplication sharedApplication].statusBarHidden = NO;
}
/**
 *  旋转屏幕通知
 */
- (void)onDeviceOrientationChange{
    if (wmPlayer==nil||wmPlayer.superview==nil){
        return;
    }
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)orientation;
    switch (interfaceOrientation) {
        case UIInterfaceOrientationPortraitUpsideDown:{
            NSLog(@"第3个旋转方向---电池栏在下");
        }
            break;
        case UIInterfaceOrientationPortrait:{
            NSLog(@"第0个旋转方向---电池栏在上");
            if (wmPlayer.isFullscreen) {
                if (isSmallScreen) {
                    //放widow上,小屏显示
                    [self toSmallScreen];
                }else{
                    [self toCell];
                }
            }
        }
            break;
        case UIInterfaceOrientationLandscapeLeft:{
            NSLog(@"第2个旋转方向---电池栏在左");
            wmPlayer.isFullscreen = YES;
            [self setNeedsStatusBarAppearanceUpdate];
            [self toFullScreenWithInterfaceOrientation:interfaceOrientation];
        }
            break;
        case UIInterfaceOrientationLandscapeRight:{
            NSLog(@"第1个旋转方向---电池栏在右");
            wmPlayer.isFullscreen = YES;
            [self setNeedsStatusBarAppearanceUpdate];
            [self toFullScreenWithInterfaceOrientation:interfaceOrientation];
        }
            break;
        default:
            break;
    }
}
///把播放器wmPlayer对象放到cell上，同时更新约束
-(void)toCell{
    wmPlayer.dragEnable = NO;
    HWZuiXinCell *currentCell = (HWZuiXinCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentIndexPath.row inSection:0]];
    [wmPlayer removeFromSuperview];
    [UIView animateWithDuration:0.7f animations:^{
        wmPlayer.transform = CGAffineTransformIdentity;
        wmPlayer.frame = currentCell.backgroundIV.bounds;
        wmPlayer.playerLayer.frame =  wmPlayer.bounds;
        [currentCell.backgroundIV addSubview:wmPlayer];
        [currentCell.backgroundIV bringSubviewToFront:wmPlayer];
        [wmPlayer.contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
            
            make.edges.equalTo(wmPlayer).with.offset(0);
            make.width.mas_equalTo([UIScreen mainScreen].bounds.size.width);
            make.height.mas_equalTo(wmPlayer.frame.size.height);
            
        }];
        if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
            wmPlayer.effectView.frame = CGRectMake([UIScreen mainScreen].bounds.size.width/2-155/2, [UIScreen mainScreen].bounds.size.height/2-155/2, 155, 155);
        }else{
            //            wmPlayer.lightView.frame = CGRectMake(kScreenWidth/2-155/2, kScreenHeight/2-155/2, 155, 155);
        }
        
        [wmPlayer.FF_View  mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(CGPointMake([UIScreen mainScreen].bounds.size.width/2-180, wmPlayer.frame.size.height/2-144));
            make.height.mas_equalTo(60);
            make.width.mas_equalTo(120);
            
        }];
        
        [wmPlayer.bottomView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(wmPlayer).with.offset(0);
            make.right.equalTo(wmPlayer).with.offset(0);
            make.height.mas_equalTo(50);
            make.bottom.equalTo(wmPlayer).with.offset(0);
        }];
        [wmPlayer.topView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(wmPlayer).with.offset(0);
            make.right.equalTo(wmPlayer).with.offset(0);
            make.height.mas_equalTo(70);
            make.top.equalTo(wmPlayer).with.offset(0);
        }];
        [wmPlayer.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(wmPlayer.topView).with.offset(45);
            make.right.equalTo(wmPlayer.topView).with.offset(-45);
            make.center.equalTo(wmPlayer.topView);
            make.top.equalTo(wmPlayer.topView).with.offset(0);
        }];
        [wmPlayer.closeBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(wmPlayer).with.offset(5);
            make.height.mas_equalTo(30);
            make.width.mas_equalTo(30);
            make.top.equalTo(wmPlayer).with.offset(20);
        }];
        [wmPlayer.loadFailedLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(wmPlayer);
            make.width.equalTo(wmPlayer);
            make.height.equalTo(@30);
        }];
    }completion:^(BOOL finished) {
        wmPlayer.isFullscreen = NO;
        [self setNeedsStatusBarAppearanceUpdate];
        isSmallScreen = NO;
        wmPlayer.fullScreenBtn.selected = NO;
        wmPlayer.FF_View.hidden = YES;
    }];
    
}

-(void)toFullScreenWithInterfaceOrientation:(UIInterfaceOrientation )interfaceOrientation{
    [wmPlayer removeFromSuperview];
    wmPlayer.dragEnable = NO;
    wmPlayer.transform = CGAffineTransformIdentity;
    if (interfaceOrientation==UIInterfaceOrientationLandscapeLeft) {
        wmPlayer.transform = CGAffineTransformMakeRotation(-M_PI_2);
    }else if(interfaceOrientation==UIInterfaceOrientationLandscapeRight){
        wmPlayer.transform = CGAffineTransformMakeRotation(M_PI_2);
    }
    wmPlayer.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    wmPlayer.playerLayer.frame =  CGRectMake(0,0, [UIScreen mainScreen].bounds.size.height,[UIScreen mainScreen].bounds.size.width);
    
    [wmPlayer.contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo([UIScreen mainScreen].bounds.size.height);
        make.height.mas_equalTo([UIScreen mainScreen].bounds.size.width);
        make.left.equalTo(wmPlayer).with.offset(0);
        make.top.equalTo(wmPlayer).with.offset(0);
    }];
    if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
        wmPlayer.effectView.frame = CGRectMake([UIScreen mainScreen].bounds.size.height/2-155/2, [UIScreen mainScreen].bounds.size.width/2-155/2, 155, 155);
    }else{
        //        wmPlayer.lightView.frame = CGRectMake(kScreenHeight/2-155/2, kScreenWidth/2-155/2, 155, 155);
    }
    [wmPlayer.FF_View  mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wmPlayer).with.offset([UIScreen mainScreen].bounds.size.height/2-120/2);
        make.top.equalTo(wmPlayer).with.offset([UIScreen mainScreen].bounds.size.width/2-60/2);
        make.height.mas_equalTo(60);
        make.width.mas_equalTo(120);
    }];
    [wmPlayer.bottomView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(50);
        make.width.mas_equalTo([UIScreen mainScreen].bounds.size.height);
        make.bottom.equalTo(wmPlayer.contentView).with.offset(0);
    }];
    
    [wmPlayer.topView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(70);
        make.left.equalTo(wmPlayer).with.offset(0);
        make.width.mas_equalTo([UIScreen mainScreen].bounds.size.height);
    }];
    
    [wmPlayer.closeBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wmPlayer.topView).with.offset(5);
        make.height.mas_equalTo(30);
        make.width.mas_equalTo(30);
        make.top.equalTo(wmPlayer).with.offset(20);
        
    }];
    
    [wmPlayer.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wmPlayer.topView).with.offset(45);
        make.right.equalTo(wmPlayer.topView).with.offset(-45);
        make.center.equalTo(wmPlayer.topView);
        make.top.equalTo(wmPlayer.topView).with.offset(0);
    }];
    
    [wmPlayer.loadFailedLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wmPlayer).with.offset(0);
        make.top.equalTo(wmPlayer).with.offset([UIScreen mainScreen].bounds.size.width/2-30/2);
        make.height.equalTo(@30);
        make.width.mas_equalTo([UIScreen mainScreen].bounds.size.height);
    }];
    
    [wmPlayer.loadingView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wmPlayer).with.offset([UIScreen mainScreen].bounds.size.height/2-22/2);
        make.top.equalTo(wmPlayer).with.offset([UIScreen mainScreen].bounds.size.width/2-22/2);
        make.height.mas_equalTo(22);
        make.width.mas_equalTo(22);
    }];
    
    [self.view addSubview:wmPlayer];
    [[UIApplication sharedApplication].keyWindow addSubview:wmPlayer];
    wmPlayer.fullScreenBtn.selected = YES;
    wmPlayer.isFullscreen = YES;
    wmPlayer.FF_View.hidden = YES;
}
-(void)toSmallScreen{
    //放widow上
    wmPlayer.dragEnable = YES;
    [wmPlayer removeFromSuperview];
    [UIView animateWithDuration:0.7f animations:^{
        wmPlayer.transform = CGAffineTransformIdentity;
        wmPlayer.frame = CGRectMake([UIScreen mainScreen].bounds.size.width/2,[UIScreen mainScreen].bounds.size.height-49-([UIScreen mainScreen].bounds.size.width/2)*0.75, [UIScreen mainScreen].bounds.size.width/2, ([UIScreen mainScreen].bounds.size.width/2)*0.75);
        wmPlayer.freeRect = CGRectMake(0,64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-64-49);
        wmPlayer.playerLayer.frame =  wmPlayer.bounds;
        [[UIApplication sharedApplication].keyWindow addSubview:wmPlayer];
        
        [wmPlayer.contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo([UIScreen mainScreen].bounds.size.width/2);
            make.height.mas_equalTo(([UIScreen mainScreen].bounds.size.width/2)*0.75);
            make.left.equalTo(wmPlayer).with.offset(0);
            make.top.equalTo(wmPlayer).with.offset(0);
        }];
        [wmPlayer.bottomView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(wmPlayer).with.offset(0);
            make.right.equalTo(wmPlayer).with.offset(0);
            make.height.mas_equalTo(40);
            make.bottom.equalTo(wmPlayer).with.offset(0);
        }];
        [wmPlayer.topView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(wmPlayer).with.offset(0);
            make.right.equalTo(wmPlayer).with.offset(0);
            make.height.mas_equalTo(40);
            make.top.equalTo(wmPlayer).with.offset(0);
        }];
        [wmPlayer.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(wmPlayer.topView).with.offset(45);
            make.right.equalTo(wmPlayer.topView).with.offset(-45);
            make.center.equalTo(wmPlayer.topView);
            make.top.equalTo(wmPlayer.topView).with.offset(0);
        }];
        [wmPlayer.closeBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(wmPlayer).with.offset(5);
            make.height.mas_equalTo(30);
            make.width.mas_equalTo(30);
            make.top.equalTo(wmPlayer).with.offset(5);
            
        }];
        [wmPlayer.loadFailedLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(wmPlayer);
            make.width.equalTo(wmPlayer);
            make.height.equalTo(@30);
        }];
        
    }completion:^(BOOL finished) {
        wmPlayer.isFullscreen = NO;
        [self setNeedsStatusBarAppearanceUpdate];
        wmPlayer.fullScreenBtn.selected = NO;
        isSmallScreen = YES;
        wmPlayer.FF_View.hidden = YES;
        [[UIApplication sharedApplication].keyWindow bringSubviewToFront:wmPlayer];
    }];
    
}



///播放器事件
-(void)wmplayer:(WMPlayer *)wmplayer clickedCloseButton:(UIButton *)closeBtn{
    NSLog(@"didClickedCloseButton");
    HWZuiXinCell *currentCell = (HWZuiXinCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentIndexPath.row inSection:0]];
    [currentCell.playBtn.superview bringSubviewToFront:currentCell.playBtn];
    [self releaseWMPlayer];
    [self setNeedsStatusBarAppearanceUpdate];
    
}
-(void)wmplayer:(WMPlayer *)wmplayer clickedFullScreenButton:(UIButton *)fullScreenBtn{
    if (fullScreenBtn.isSelected) {//全屏显示
        wmPlayer.isFullscreen = YES;
        [self setNeedsStatusBarAppearanceUpdate];
        [self toFullScreenWithInterfaceOrientation:UIInterfaceOrientationLandscapeLeft];
    }else{
        if (isSmallScreen) {
            //放widow上,小屏显示
            [self toSmallScreen];
        }else{
            [self toCell];
        }
    }
}
-(void)wmplayer:(WMPlayer *)wmplayer singleTaped:(UITapGestureRecognizer *)singleTap{
    NSLog(@"didSingleTaped");
}
-(void)wmplayer:(WMPlayer *)wmplayer doubleTaped:(UITapGestureRecognizer *)doubleTap{
    NSLog(@"didDoubleTaped");
}

///播放状态
-(void)wmplayerFailedPlay:(WMPlayer *)wmplayer WMPlayerStatus:(WMPlayerState)state{
    NSLog(@"wmplayerDidFailedPlay");
}
-(void)wmplayerReadyToPlay:(WMPlayer *)wmplayer WMPlayerStatus:(WMPlayerState)state{
    NSLog(@"wmplayerDidReadyToPlay");
}
-(void)wmplayerFinishedPlay:(WMPlayer *)wmplayer{
    NSLog(@"wmplayerDidFinishedPlay");
    HWZuiXinCell *currentCell = (HWZuiXinCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentIndexPath.row inSection:0]];
    [currentCell.playBtn.superview bringSubviewToFront:currentCell.playBtn];
    [self releaseWMPlayer];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)viewDidDisappear:(BOOL)animated{

    [super viewDidDisappear:animated];
//    [UIApplication sharedApplication].statusBarHidden = NO;
    [self releaseWMPlayer];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    index = 1;
    self.navigationController.navigationBarHidden = YES;
    
    self.tableView.backgroundColor = kBackgroundColor;
    self.navigationController.navigationBarHidden = YES;
    self.tableView.separatorStyle = UITableViewCellAccessoryNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"HWZuiXinCell" bundle:nil] forCellReuseIdentifier:@"HWZuiXinCell"];
    
    __weak __typeof(&*self)weakSelf = self;
    __unsafe_unretained UITableView *tableView = weakSelf.tableView;
    
    [self addMJRefresh];
    
    [tableView.mj_header beginRefreshing];
    
    [self setUpHeaderView];
  
    
}

- (void)setUpHeaderView{

    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenW, 200)];
    headerView.backgroundColor = DZColor(30, 30, 34);
//    headerView.backgroundColor = [UIColor orangeColor];
    self.tableView.tableHeaderView = headerView;
    
    CGFloat margin = 5;
    UIView *view0 = [[UIView alloc] init];
    view0.backgroundColor = [UIColor orangeColor];
    view0.width = (screenW - 3*margin)*0.5;
    view0.height = (headerView.height - 3*margin)*0.5;
    view0.x = margin;
    view0.y = margin;
    [headerView addSubview:view0];
    UIButton *btn0 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn0.backgroundColor = [UIColor grayColor];
    btn0.frame = view0.bounds;
    [btn0 addTarget:self action:@selector(btn0Click:) forControlEvents:UIControlEventTouchUpInside];
    [view0 addSubview:btn0];
    UIImageView *imgView0 = [[UIImageView alloc] init];
    imgView0.frame = btn0.bounds;
    [imgView0 setImage:[UIImage imageNamed:@"find_new_bg1"]];
    [view0 addSubview:imgView0];
    UIView *view00 = [[UIView alloc] init];
    view00.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    view00.x = 0;
    view00.y = 0;
    view00.width = view0.width - 40;
    view00.height = 40;
    [view0 addSubview:view00];
    UIImageView *imgView00 = [[UIImageView alloc] init];
    imgView00.image = [UIImage imageNamed:@"find_new_icon1"];
    [view00 bringSubviewToFront:imgView00];
    imgView00.x = 4;
    imgView00.y = 4;
    imgView00.width = view00.height - 8;
    imgView00.height = view00.height - 8;
    [view00 addSubview:imgView00];
    UILabel *topLabel0 = [[UILabel alloc] init];
    topLabel0.x = imgView00.width + 5;
    topLabel0.y = 5;
    topLabel0.width = 100;
    topLabel0.height = 20;
    topLabel0.text = @"我行我秀";
    topLabel0.textColor = [UIColor whiteColor];
    topLabel0.font = [UIFont systemFontOfSize:14];
    [view00 addSubview:topLabel0];
    UILabel *bottomLabel0 = [[UILabel alloc] init];
    bottomLabel0.x = topLabel0.x;
    bottomLabel0.y = topLabel0.height;
    bottomLabel0.width = 100;
    bottomLabel0.height = 20;
    bottomLabel0.text = @"16分钟前跟新";
    bottomLabel0.textColor = [UIColor whiteColor];
    bottomLabel0.font = [UIFont systemFontOfSize:11];
    [view00 addSubview:bottomLabel0];
    
    
    
    
    
    UIView *view1 = [[UIView alloc] init];
    view1.backgroundColor = [UIColor orangeColor];
    view1.width = (screenW - 3*margin)*0.5;
    view1.height = (headerView.height - 3*margin)*0.5;
    view1.x = 2*margin + view0.width;
    view1.y = margin;
    [headerView addSubview:view1];
    UIButton *btn1 = [[UIButton alloc] init];
    btn1.backgroundColor = [UIColor grayColor];
    btn1.frame = view1.bounds;
    [btn1 addTarget:self action:@selector(btn1Click:) forControlEvents:UIControlEventTouchUpInside];
    [view1 addSubview:btn1];
    UIImageView *imgView1 = [[UIImageView alloc] init];
    imgView1.frame = btn1.bounds;
    [imgView1 setImage:[UIImage imageNamed:@"find_new_bg2"]];
    [view1 addSubview:imgView1];
    UIView *view01 = [[UIView alloc] init];
    view01.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    view01.x = 0;
    view01.y = 0;
    view01.width = view0.width - 40;
    view01.height = 40;
    [view1 addSubview:view01];
    UIImageView *imgView01 = [[UIImageView alloc] init];
    imgView01.image = [UIImage imageNamed:@"find_new_icon2"];;
    imgView01.x = 4;
    imgView01.y = 4;
    imgView01.width = view00.height - 8;
    imgView01.height = view00.height - 8;
    [view01 addSubview:imgView01];
    UILabel *topLabel1 = [[UILabel alloc] init];
    topLabel1.x = imgView01.width + 5;
    topLabel1.y = 5;
    topLabel1.width = 100;
    topLabel1.height = 20;
    topLabel1.text = @"曝光台";
    topLabel1.textColor = [UIColor whiteColor];
    topLabel1.font = [UIFont systemFontOfSize:14];
    [view01 addSubview:topLabel1];
    UILabel *bottomLabel1 = [[UILabel alloc] init];
    bottomLabel1.x = topLabel1.x;
    bottomLabel1.y = topLabel1.height;
    bottomLabel1.width = 100;
    bottomLabel1.height = 20;
    bottomLabel1.text = @"9分钟前跟新";
    bottomLabel1.textColor = [UIColor whiteColor];
    bottomLabel1.font = [UIFont systemFontOfSize:11];
    [view01 addSubview:bottomLabel1];
    
    
    UIView *view2 = [[UIView alloc] init];
    view2.backgroundColor = [UIColor orangeColor];
    view2.width = (screenW - 3*margin)*0.5;
    view2.height = (headerView.height - 3*margin)*0.5;
    view2.x = margin;
    view2.y = 2*margin + view0.height;
    [headerView addSubview:view2];
    UIButton *btn2 = [[UIButton alloc] init];
    btn2.backgroundColor = [UIColor grayColor];
    btn2.frame = view2.bounds;
    [btn2 addTarget:self action:@selector(btn2Click:) forControlEvents:UIControlEventTouchUpInside];
    [view2 addSubview:btn2];
    UIImageView *imgView2 = [[UIImageView alloc] init];
    imgView2.frame = btn2.bounds;
    [imgView2 setImage:[UIImage imageNamed:@"find_new_bg3"]];
    [view2 addSubview:imgView2];
    UIView *view02 = [[UIView alloc] init];
    view02.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    view02.x = 0;
    view02.y = 0;
    view02.width = view0.width - 40;
    view02.height = 40;
    [view2 addSubview:view02];
    UIImageView *imgView02 = [[UIImageView alloc] init];
    imgView02.image = [UIImage imageNamed:@"find_new_icon3"];;
    imgView02.x = 4;
    imgView02.y = 4;
    imgView02.width = view00.height - 8;
    imgView02.height = view00.height - 8;
    [view02 addSubview:imgView02];
    UILabel *topLabel2 = [[UILabel alloc] init];
    topLabel2.x = imgView02.width + 5;
    topLabel2.y = 5;
    topLabel2.width = 100;
    topLabel2.height = 20;
    topLabel2.text = @"事故爆料";
    topLabel2.textColor = [UIColor whiteColor];
    topLabel2.font = [UIFont systemFontOfSize:14];
    [view02 addSubview:topLabel2];
    UILabel *bottomLabel2 = [[UILabel alloc] init];
    bottomLabel2.x = topLabel2.x;
    bottomLabel2.y = topLabel2.height;
    bottomLabel2.width = 100;
    bottomLabel2.height = 20;
    bottomLabel2.text = @"1分钟前跟新";
    bottomLabel2.textColor = [UIColor whiteColor];
    bottomLabel2.font = [UIFont systemFontOfSize:11];
    [view02 addSubview:bottomLabel2];
    
    
    UIView *view3 = [[UIView alloc] init];
    view3.backgroundColor = [UIColor orangeColor];
    view3.width = (screenW - 3*margin)*0.5;
    view3.height = (headerView.height - 3*margin)*0.5;
    view3.x = 2*margin + view0.width;
    view3.y = 2*margin + view0.height;
    [headerView addSubview:view3];
    UIButton *btn3 = [[UIButton alloc] init];
    btn3.backgroundColor = [UIColor grayColor];
    btn3.frame = view3.bounds;
    [btn3 addTarget:self action:@selector(btn3Click:) forControlEvents:UIControlEventTouchUpInside];
    [view3 addSubview:btn3];
    UIImageView *imgView3 = [[UIImageView alloc] init];
    imgView3.frame = btn3.bounds;
    [imgView3 setImage:[UIImage imageNamed:@"find_new_bg4"]];
    
    [view3 addSubview:imgView3];
    UIView *view03 = [[UIView alloc] init];
    view03.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    view03.x = 0;
    view03.y = 0;
    view03.width = view0.width - 40;
    view03.height = 40;
    [view3 addSubview:view03];
    UIImageView *imgView03 = [[UIImageView alloc] init];
    imgView03.image = [UIImage imageNamed:@"find_new_icon4"];;
    imgView03.x = 4;
    imgView03.y = 4;
    imgView03.width = view00.height - 8;
    imgView03.height = view00.height - 8;
    [view03 addSubview:imgView03];
    UILabel *topLabel3 = [[UILabel alloc] init];
    topLabel3.x = imgView03.width + 5;
    topLabel3.y = 5;
    topLabel3.width = 100;
    topLabel3.height = 20;
    topLabel3.text = @"美丽风景";
    topLabel3.textColor = [UIColor whiteColor];
    topLabel3.font = [UIFont systemFontOfSize:14];
    [view03 addSubview:topLabel3];
    UILabel *bottomLabel3 = [[UILabel alloc] init];
    bottomLabel3.x = topLabel3.x;
    bottomLabel3.y = topLabel3.height;
    bottomLabel3.width = 100;
    bottomLabel3.height = 20;
    bottomLabel3.text = @"21分钟前跟新";
    bottomLabel3.textColor = [UIColor whiteColor];
    bottomLabel3.font = [UIFont systemFontOfSize:11];
    [view03 addSubview:bottomLabel3];
    
}

- (void)btn0Click:(UIButton *)btn{

    [[RDVTabBarController shareTabBar] setTabBarHidden:YES animated:NO];
    HWMyShowViewController *myShowVc = [HWMyShowViewController myShowViewController];
    [self.navigationController pushViewController:myShowVc animated:YES];
}

- (void)btn1Click:(UIButton *)btn{
    
    [[RDVTabBarController shareTabBar] setTabBarHidden:YES animated:NO];
    HWPushViewController *pushVc = [HWPushViewController pushViewController];
    [self.navigationController pushViewController:pushVc animated:YES];
}

- (void)btn2Click:(UIButton *)btn{
    
    [[RDVTabBarController shareTabBar] setTabBarHidden:YES animated:NO];
    HWAccidentViewController *accidentVc = [HWAccidentViewController accidentViewController];
    [self.navigationController pushViewController:accidentVc animated:YES];
}

- (void)btn3Click:(UIButton *)btn{
    
    [[RDVTabBarController shareTabBar] setTabBarHidden:YES animated:NO];
    HWBeautifulViewController *beautifulVc = [HWBeautifulViewController beautifulViewController];
    [self.navigationController pushViewController:beautifulVc animated:YES];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //    [self performSelector:@selector(loadData) withObject:nil afterDelay:1.0];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}
    
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
     [self.navigationController setNavigationBarHidden:YES animated:NO];
//    [UIApplication sharedApplication].statusBarHidden = NO;
    
}

-(void)addMJRefresh{
    __weak __typeof(&*self)weakSelf = self;
    __unsafe_unretained UITableView *tableView = weakSelf.tableView;
    NSArray *para = @[@"qry_videolist", @"gentime", @""];
    // 下拉刷新
    tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
//        [weakSelf addHudWithMessage:@"加载中..."];
        
        [[DataManager shareManager] getVideoListWithURLString:@"http://find.hwawo.com:9090/ControlCenter/v3/restapi/doaction" para:para ListID:@"1" success:^(NSArray *sidArray, NSArray *videoArray) {
            dataSource =[NSMutableArray arrayWithArray:sidArray];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (currentIndexPath.row>dataSource.count) {
                    [weakSelf releaseWMPlayer];
                }
                [weakSelf removeHud];
                [tableView reloadData];
                [tableView.mj_header endRefreshing];
            });
        } failed:^(NSError *error) {
            [weakSelf removeHud];
        }];
        
    }];
    
    
    // 设置自动切换透明度(在导航栏下面自动隐藏)
    tableView.mj_header.automaticallyChangeAlpha = YES;
    // 上拉刷新
    tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
       NSString *ID = [NSString stringWithFormat:@"%ld",(long)++index];
//        [weakSelf addHudWithMessage:@"加载中..."];
        
        [[DataManager shareManager] getVideoListWithURLString:@"http://find.hwawo.com:9090/ControlCenter/v3/restapi/doaction" para:para ListID:ID success:^(NSArray *sidArray, NSArray *videoArray) {
            [dataSource addObjectsFromArray:sidArray];
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf removeHud];
                [tableView reloadData];
                [tableView.mj_header endRefreshing];
            });
        } failed:^(NSError *error) {
            [weakSelf removeHud];
        }];
        // 结束刷新
        [tableView.mj_footer endRefreshing];
    }];
    
    
}
#warning -------------------------------------------
- (void)addHudWithMessage:(NSString*)message
{
    if (!_hud)
    {
        //        _hud=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
        _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES configBlock:nil];
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

+(AppDelegate *)shareAppDelegate{
    return (AppDelegate *) [UIApplication sharedApplication].delegate;
}

-(NSInteger )numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return dataSource.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 260;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"HWZuiXinCell";
    HWZuiXinCell *cell = (HWZuiXinCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    cell.model = [dataSource objectAtIndex:indexPath.row];
    [cell.playBtn addTarget:self action:@selector(startPlayVideo:) forControlEvents:UIControlEventTouchUpInside];
    cell.playBtn.tag = indexPath.row;
    
    cell.delegate = self;
    if (wmPlayer&&wmPlayer.superview) {
        if (indexPath.row==currentIndexPath.row) {
            [cell.playBtn.superview sendSubviewToBack:cell.playBtn];
        }else{
            [cell.playBtn.superview bringSubviewToFront:cell.playBtn];
        }
        NSArray *indexpaths = [tableView indexPathsForVisibleRows];
        if (![indexpaths containsObject:currentIndexPath]&&currentIndexPath!=nil) {//复用
            
            if ([[UIApplication sharedApplication].keyWindow.subviews containsObject:wmPlayer]) {
                wmPlayer.hidden = NO;
            }else{
                wmPlayer.hidden = YES;
                [cell.playBtn.superview bringSubviewToFront:cell.playBtn];
            }
        }else{
            if ([cell.backgroundIV.subviews containsObject:wmPlayer]) {
                [cell.backgroundIV addSubview:wmPlayer];
                
                [wmPlayer play];
                wmPlayer.hidden = NO;
            }
            
        }
    }
    
    
    return cell;
}
-(void)startPlayVideo:(UIButton *)sender{
    currentIndexPath = [NSIndexPath indexPathForRow:sender.tag inSection:0];
    NSLog(@"currentIndexPath.row = %ld",currentIndexPath.row);
    
    UIView *cellView = [sender superview];
    while (![cellView isKindOfClass:[UITableViewCell class]])
    {
        cellView =  [cellView superview];
    }
    self.currentCell = (HWZuiXinCell *)cellView;
    
    VideoModel *model = [dataSource objectAtIndex:sender.tag];
    
    if (isSmallScreen) {
        [self releaseWMPlayer];
        isSmallScreen = NO;
    }
    if (wmPlayer) {
        [self releaseWMPlayer];
        wmPlayer = [[WMPlayer alloc]initWithFrame:self.currentCell.backgroundIV.bounds];
        wmPlayer.delegate = self;
        //关闭音量调节的手势
        wmPlayer.enableVolumeGesture = NO;
        wmPlayer.closeBtnStyle = CloseBtnStyleClose;
        wmPlayer.URLString = model.videoinfo.video_url;
        wmPlayer.titleLabel.text = @"";
        //        [wmPlayer play];
    }else{
        wmPlayer = [[WMPlayer alloc]initWithFrame:self.currentCell.backgroundIV.bounds];
        wmPlayer.delegate = self;
        wmPlayer.closeBtnStyle = CloseBtnStyleClose;
        //关闭音量调节的手势
        wmPlayer.enableVolumeGesture = NO;
        wmPlayer.titleLabel.text = @"";
        wmPlayer.URLString = model.videoinfo.video_url;
    }
    wmPlayer.dragEnable = NO;
    
    [self.currentCell.backgroundIV addSubview:wmPlayer];
    [self.currentCell.backgroundIV bringSubviewToFront:wmPlayer];
    [self.currentCell.playBtn.superview sendSubviewToBack:self.currentCell.playBtn];
    [self.tableView reloadData];
    
}
#pragma mark scrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(scrollView ==self.tableView){
        if (wmPlayer==nil) {
            return;
        }
        
        if (wmPlayer.superview) {
            CGRect rectInTableView = [self.tableView rectForRowAtIndexPath:currentIndexPath];
            CGRect rectInSuperview = [self.tableView convertRect:rectInTableView toView:[self.tableView superview]];
            if (rectInSuperview.origin.y<-self.currentCell.backgroundIV.frame.size.height||rectInSuperview.origin.y>[UIScreen mainScreen].bounds.size.height-64-49) {//往上拖动
                
                if ([[UIApplication sharedApplication].keyWindow.subviews containsObject:wmPlayer]&&isSmallScreen) {
                    isSmallScreen = YES;
                }else{
                    //放widow上,小屏显示
                    [self toSmallScreen];
                }
                
            }else{
                if ([self.currentCell.backgroundIV.subviews containsObject:wmPlayer]) {
                    
                }else{
                    [self toCell];
                }
            }
        }
        
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    VideoModel *model = [dataSource objectAtIndex:indexPath.row];
    [[RDVTabBarController shareTabBar] setTabBarHidden:YES animated:NO];
    DisCoveryDetailViewController *detailVc = [DisCoveryDetailViewController disCoveryDetailViewController];
    detailVc.model = model;
    detailVc.statusBarHidden = YES;
    detailVc.flag = @"HWZuiXinTableViewController";
    [self.navigationController pushViewController:detailVc animated:YES];

    
}
/**
 *  释放WMPlayer
 */
-(void)releaseWMPlayer{
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
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}
-(void)dealloc{
    NSLog(@"%@ dealloc",[self class]);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self releaseWMPlayer];
}


@end
