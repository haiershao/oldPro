//
//  HWTopDianViewController.m
//  HuaWo
//
//  Created by hwawo on 17/3/14.
//  Copyright © 2017年 HW. All rights reserved.
//

#import "HWTopDianViewController.h"
#import "SidModel.h"
#import "HWTopDianCell.h"
#import "VideoModel.h"
#import "DisCoveryDetailViewController.h"
#import "AppDelegate.h"
#import <MJRefresh.h>
#import <WMPlayer/Masonry.h>
#import "DataManager.h"
#import <WMPlayer/WMPlayer.h>
#import "MBProgressHUD.h"
#import "HWTopDianCell.h"
@interface HWTopDianViewController ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,WMPlayerDelegate>{
    NSMutableArray *dataSource;
    WMPlayer *wmPlayer;
    NSIndexPath *currentIndexPath;
    BOOL isSmallScreen;
    NSInteger index;
}
@property(nonatomic,retain)HWTopDianCell *currentCell;
@property (nonatomic,retain) MBProgressHUD* hud;
@end

@implementation HWTopDianViewController
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
    self.navigationController.navigationBarHidden = NO;
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
    
- (void)viewDidDisappear:(BOOL)animated{
    
    [super viewDidDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
//    [UIApplication sharedApplication].statusBarHidden = NO;
    [self releaseWMPlayer];
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
    HWTopDianCell *currentCell = (HWTopDianCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentIndexPath.row inSection:0]];
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
    HWTopDianCell *currentCell = (HWTopDianCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentIndexPath.row inSection:0]];
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
    HWTopDianCell *currentCell = (HWTopDianCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentIndexPath.row inSection:0]];
    [currentCell.playBtn.superview bringSubviewToFront:currentCell.playBtn];
    [self releaseWMPlayer];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    index = 1;
    self.tableView.backgroundColor = kBackgroundColor;
    self.navigationController.navigationBarHidden = YES;
    self.tableView.separatorStyle = UITableViewCellAccessoryNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"HWTopDianCell" bundle:nil] forCellReuseIdentifier:@"HWTopDianCell"];
    
    __weak __typeof(&*self)weakSelf = self;
    __unsafe_unretained UITableView *tableView = weakSelf.tableView;

    [self addMJRefresh];
    
    [tableView.mj_header beginRefreshing];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
//    [self performSelector:@selector(loadData) withObject:nil afterDelay:1.0];
}
//-(void)loadData{
//    [dataSource addObjectsFromArray:[AppDelegate shareAppDelegate].videoArray];
//    [self.tableView reloadData];
//    
//}
-(void)addMJRefresh{
    __weak __typeof(&*self)weakSelf = self;
    __unsafe_unretained UITableView *tableView = weakSelf.tableView;
    // 下拉刷新
    NSArray *para = @[@"qry_videolist", @"recommend desc, viewtimes", @""];
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
    return 225;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"HWTopDianCell";
    HWTopDianCell *cell = (HWTopDianCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    cell.model = [dataSource objectAtIndex:indexPath.row];
    [cell.playBtn addTarget:self action:@selector(startPlayVideo:) forControlEvents:UIControlEventTouchUpInside];
    cell.playBtn.tag = indexPath.row;
    
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
    
    HWLog(@"cellForRowAtIndexPath: %@",wmPlayer.delegate);
    return cell;
}
-(void)startPlayVideo:(UIButton *)sender{
    currentIndexPath = [NSIndexPath indexPathForRow:sender.tag inSection:0];
    NSLog(@"HWTopDianCell currentIndexPath.row = %ld",currentIndexPath.row);
    
    UIView *cellView = [sender superview];
    while (![cellView isKindOfClass:[UITableViewCell class]])
    {
        cellView =  [cellView superview];
    }
    self.currentCell = (HWTopDianCell *)cellView;
    
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
        [wmPlayer play];
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
    HWLog(@"didSelectRowAtIndexPath: 当前选中了cell");
    VideoModel *   model = [dataSource objectAtIndex:indexPath.row];
    [[RDVTabBarController shareTabBar] setTabBarHidden:YES animated:NO];
    DisCoveryDetailViewController *detailVc = [DisCoveryDetailViewController disCoveryDetailViewController];
    detailVc.model = model;
    detailVc.statusBarHidden = YES;
    detailVc.flag = @"HWTopDianViewController";
    
//    HWDetailViewController *detailVc = [HWDetailViewController detailViewController];
//    detailVc.model = model;
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

//-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
//
//    if(scrollView.contentOffset.y < 0){
//        NSLog(@"top*****");
//        [self.navigationController setNavigationBarHidden:NO animated:YES];
//        
//        
//    }else if(scrollView.contentOffset.y > 0){
//        NSLog(@"bottom*****");
//        
//        [self.navigationController setNavigationBarHidden:YES animated:YES];
//    }
//}

@end
