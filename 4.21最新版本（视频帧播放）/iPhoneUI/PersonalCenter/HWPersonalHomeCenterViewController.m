//
//  HWPersonalHomeCenterViewController.m
//  HuaWo
//
//  Created by hwawo on 16/12/20.
//  Copyright © 2016年 HW. All rights reserved.
//

#import "HWPersonalHomeCenterViewController.h"
#import "HWHWPersonalHomeCenterViewCell.h"
#import "PersonalInfoViewController.h"
//#import "FullViewController.h"
#import <MJRefresh.h>
#import "GetVideoDataTools.h"
#import "VideoSid.h"
#import "Video.h"
#import "HWUserInstanceInfo.h"
#import <MediaPlayer/MediaPlayer.h>
@interface HWPersonalHomeCenterViewController ()<UITableViewDelegate, UITableViewDataSource , UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *shareBtn;
@property (weak, nonatomic) IBOutlet UIButton *collectionBtn;
@property (weak, nonatomic) IBOutlet UIButton *commentBtn;

@property (nonatomic, strong) FullViewController *fullVc;
@property (nonatomic, strong) NSArray * videoSidArray; // videoSid数组
@property (nonatomic, strong) NSMutableArray * videoArray; // video数组

@property (nonatomic, strong) NSMutableArray * deleteData;
@property (nonatomic, strong) UIImage *userIconImage;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;

@property (copy, nonatomic) NSString *fullPath;

@property (weak, nonatomic) IBOutlet UILabel *nickName;
@property (nonatomic, strong) VideoSid * videoSid;
@property (nonatomic, strong) NSMutableArray * dataArr;
@property (nonatomic,strong) NSMutableArray *textPaths;
@property (strong, nonatomic) UIAlertView *alertReport;
@property (nonatomic, strong) FMGVideoPlayView * fmVideoPlayer;
@property (strong, nonatomic) MPMoviePlayerViewController *playerVC;
@property (assign ,nonatomic)NSInteger page;
//@property (nonatomic, assign) BOOL isLoading;
//@property (nonatomic, assign) BOOL noMoreData;
@end
@implementation HWPersonalHomeCenterViewController

- (NSMutableArray *)videoArray{
    
    if (!_videoArray) {
        _videoArray = [NSMutableArray array];
    }
    return _videoArray;
}
- (IBAction)bianjiBtnClick:(UIButton *)sender {
    
    [[RDVTabBarController shareTabBar] setTabBarHidden:YES animated:NO];
    
    PersonalInfoViewController *personInfo = [[PersonalInfoViewController alloc] initWithNibName:@"PersonalInfoViewController" bundle:nil];
    [self.navigationController pushViewController:personInfo animated:YES];
    
}
- (void)setIconImage{
    
    self.fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[NSString stringWithFormat:@"iconimage%@",identifierForVendor]];
    self.userIconImage = [UIImage imageWithContentsOfFile:_fullPath];
    if (self.userIconImage) {
        self.iconImageView.image = self.userIconImage;
    }else{
        self.iconImageView.image = [UIImage imageNamed:@"find_new_head_bg"];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
   // self.tableView.contentInset = UIEdgeInsetsMake(50, 0, 0, 0);
    self.navigationController.navigationBar.barTintColor = kNavigation7Color;
    self.tableView.backgroundColor = kBackgroundColor;
    self.nickName.text = [HWUserInstanceInfo shareUser].nickname;
    [self setTableView];
    [self setNavTitle];
    [self  requestNetData ];
    [self setUpfromation];
    [self setIconImage];
}

- (void)setUpfromation {
   
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(requestNetData)];
    self.tableView.mj_header.autoChangeAlpha = YES;
    [self.tableView.mj_header beginRefreshing];
    
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(requestUpData)];
    
//    self.tableView.sy_headerRefresh = ^(){
//        [weakSelf  requestNetData ];
//    };
}
- (void)setTableView{
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([HWHWPersonalHomeCenterViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([HWHWPersonalHomeCenterViewCell class])];
    self.tableView .estimatedRowHeight = 200;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.separatorColor = [UIColor blackColor];
    
}
- (void)setNavTitle{
    self.title = @"个人主页";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"title_back_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonItemAction)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont systemFontOfSize:20]}];
}
-(void)leftBarButtonItemAction{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)requestNetData{
    self.page = 1;
    [self.tableView.mj_footer endRefreshing];
   // self.noMoreData = NO;
//    if (self.isLoading == YES) {
//        return;
//    }else {
//        self.isLoading = YES;
//    }
    
    HWUserInstanceInfo* InstanceInfo = [HWUserInstanceInfo shareUser];
    NSString *nowTime = [self timeOfNow];
    NSDictionary *dict = @{
                           @"sdate": @"2015-08-10",
                           @"edate":nowTime,
                           @"num": @"3",
                           @"pno": @"1",
                           @"uid":@"-1",
                           @"vtype":@"1",
                           @"orderby":@"gentime",
                           @"order":@"desc",
                           @"option":@"1"
                           };
    APIRequest *request = [[APIRequest alloc] initWithApiPath:@"/ControlCenter/v3/restapi/doaction" method:APIRequestMethodPost];
    request.urlQueryParameters = @{
                                   @"action":@"qry_videolist",
                                   @"para":dict,
                                   @"token":InstanceInfo.token
                                   };
    NSLog(@"request---%@",request);
    [[APIRequestOperationManager sharedRequestOperationManager] requestAPI:request completion:^(id result, NSError *error) {
        NSMutableArray *videoSidList = [Video mj_objectArrayWithKeyValuesArray:result[@"data"][@"datalist"]];
//        NSDictionary *dic = result[@"data"][@"total"];
//        NSString *str = [NSString stringWithFormat:@"%@",dic];
        self.videoArray = videoSidList;
        [self.tableView reloadData];
        [self.tableView.mj_header endRefreshing];
        self.page = 1;
       // self.isLoading = NO;
    }];
    
    
}
- (void)requestUpData{
     [self.tableView.mj_header endRefreshing];
    NSString *str = [NSString stringWithFormat:@"%ld",++self.page];
    HWUserInstanceInfo* InstanceInfo = [HWUserInstanceInfo shareUser];
    NSString *nowTime = [self timeOfNow];
    NSDictionary *dict = @{
                           @"sdate": @"2015-08-10",
                           @"edate":nowTime,
                           @"num": @"3",
                           @"pno": str,
                           @"uid":@"-1",
                           @"vtype":@"1",
                           @"orderby":@"gentime",
                           @"order":@"desc",
                           @"option":@"1"
                           };
    APIRequest *request = [[APIRequest alloc] initWithApiPath:@"/ControlCenter/v3/restapi/doaction" method:APIRequestMethodPost];
    request.urlQueryParameters = @{
                                   @"action":@"qry_videolist",
                                   @"para":dict,
                                   @"token":InstanceInfo.token
                                   };
    NSLog(@"request---%@",request);
    [[APIRequestOperationManager sharedRequestOperationManager] requestAPI:request completion:^(id result, NSError *error) {
        
        NSMutableArray *videoSidList = [Video mj_objectArrayWithKeyValuesArray:result[@"data"][@"datalist"]];
        
        if (videoSidList.count > 0) {
            [self.videoArray addObjectsFromArray:videoSidList];
            [self.tableView reloadData];
        }else {
           // self.noMoreData = YES;
        }
        [self.tableView.mj_footer endRefreshing];
    }];
}
//- (void)tableView:(UITableView *)tableView willDisplayCell:(nonnull UITableViewCell *)cell forRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
//    if (indexPath.row == self.videoArray.count-1&&self.noMoreData != YES) {
//        
//        [self requestUpData];
//    }
//}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.videoArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    __weak typeof(self) weakSelf = self;
    HWHWPersonalHomeCenterViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HWHWPersonalHomeCenterViewCell class])];
    if (cell == nil) {
        cell = [[HWHWPersonalHomeCenterViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([HWHWPersonalHomeCenterViewCell class])];
    }
    Video *video = self.videoArray[indexPath.row];
    cell.video = video;
    cell.block = ^{
        [weakSelf deleteVideo:video row:indexPath.row];
        
    };
    
    
    return cell;
}

- (void)deleteVideo:(Video *)video row:(NSInteger)row {
    HWUserInstanceInfo *InstanceInfo = [HWUserInstanceInfo shareUser];
    
    NSString *alarmId = [NSString stringWithFormat:@"%@",video.videoid];
    
    NSDictionary *dict = @{
                           @"id":@[alarmId]
                           
                           };
    
    APIRequest *request = [[APIRequest alloc] initWithApiPath:@"/ControlCenter/v3/restapi/doaction" method:APIRequestMethodPost];
    request.urlQueryParameters = @{
                                   @"action":@"del_sharevideo",
                                   @"para":dict,
                                   @"token":InstanceInfo.token
                                   };
    NSLog(@"request---%@",request);
    [[APIRequestOperationManager sharedRequestOperationManager] requestAPI:request completion:^(id result, NSError *error) {
        
        if (!result[@"data"]) {
            [self.videoArray removeObjectAtIndex:row];
            [self.tableView reloadData];
        }else{
            HWLog(@"删除失败");
        }
        
    }];
    
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (alertView.tag == 1) {
        //[self refresh];
        [self.tableView reloadData];
    }
    
    
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == _fmVideoPlayer.index) {
        [_fmVideoPlayer.player pause];
        _fmVideoPlayer.hidden = YES;
    }
    
}
//当点击Done按键或者播放完毕时调用此函数
- (void) playVideoFinished:(NSNotification *)theNotification {
    MPMoviePlayerController *player = [theNotification object];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:player];
    [player stop];
    [self.playerVC dismissMoviePlayerViewControllerAnimated];
    self.playerVC = nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Video * video = _videoArray[indexPath.row];
    
    self.playerVC = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:video.videoinfo.video_url]];
    [[self.playerVC moviePlayer] prepareToPlay];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playVideoFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:[self.playerVC moviePlayer]];
    [self presentMoviePlayerViewControllerAnimated:self.playerVC];
    [[self.playerVC moviePlayer] play];
    
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 200;
}

-(NSString *)timeOfNow{
    NSDate *currentDate = [NSDate date];//获取当前时间，日期
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd"];
    NSString *dateString = [dateFormatter stringFromDate:currentDate];
    return dateString;
}

@end
