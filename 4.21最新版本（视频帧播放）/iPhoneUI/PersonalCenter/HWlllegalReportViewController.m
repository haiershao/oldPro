//
//  HWlllegalReportViewController.m
//  HuaWo
//
//  Created by hwawo on 16/6/7.
//  Copyright © 2016年 HW. All rights reserved.
//

#import "HWlllegalReportViewController.h"
#import "AHCNetworkChangeDetector.h"
#import "NSString+encrypto.h"
#import "HWlllegalReportCell.h"
#import <MJRefresh.h>
#import "HWUserInstanceInfo.h"
#import "HWlllegalReportModel.h"
#import <MediaPlayer/MediaPlayer.h>
@interface HWlllegalReportViewController ()<UITableViewDelegate, UITableViewDataSource , UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray * videoArray; // video数组
@property (strong, nonatomic) MPMoviePlayerViewController *playerVC;
@property (assign ,nonatomic)NSInteger page;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@end

@implementation HWlllegalReportViewController
- (NSMutableArray *)videoArray{
    
    if (!_videoArray) {
        _videoArray = [NSMutableArray array];
    }
    return _videoArray;
}
- (void)viewDidLoad {
    [super viewDidLoad];
  
    self.view.backgroundColor = kBackgroundColor;
        [self setUpTitle];
    
    [self setUpLeftNavigationItem];
    
    [self isConnectionAvailable];
    
    [self setUpActivityIndicatorView];
    [self setTableView];
    [self setUpfromation];
}
- (void)setTableView{
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([HWlllegalReportCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([HWlllegalReportCell class])];
    self.tableView .estimatedRowHeight = 250;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
     self.tableView.backgroundColor = kBackgroundColor;
    self.tableView.separatorColor = [UIColor blackColor];
    
}
- (void)setUpfromation {
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(requestNetData)];
    //self.tableView.mj_header.autoChangeAlpha = YES;
    [self.tableView.mj_header beginRefreshing];
    
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(requestUpData)];
    
}
- (void)requestNetData{
    self.page = 1;
    [self.tableView.mj_footer endRefreshing];
        HWUserInstanceInfo* InstanceInfo = [HWUserInstanceInfo shareUser];
    NSString *nowTime = [self timeOfNow];
    NSDictionary *dict = @{
                           @"starttime": @"2016-08-10",
                           @"edate":nowTime,
                           @"num": @"3",
                           @"pno": @"1",
                           @"order":@"desc",
                           @"option":@"1",
                           @"procstate":@"draft",
                           @"did":@""
                           };
    APIRequest *request = [[APIRequest alloc] initWithApiPath:@"/ControlCenter/v3/restapi/doaction" method:APIRequestMethodPost];
    request.urlQueryParameters = @{
                                   @"action":@"qry_reportlist",
                                   @"para":dict,
                                   @"token":InstanceInfo.token
                                   };
    NSLog(@"request---%@",request);
    [[APIRequestOperationManager sharedRequestOperationManager] requestAPI:request completion:^(id result, NSError *error) {
        
        NSMutableArray *videoSidList = [HWlllegalReportModel mj_objectArrayWithKeyValuesArray:result[@"data"][@"datalist"]];
       
        self.videoArray = videoSidList;
        [self.tableView reloadData];
        [self.tableView.mj_header endRefreshing];
        self.page = 1;
        
    }];
    

}
- (void)requestUpData{
    [self.tableView.mj_header endRefreshing];
    NSString *str = [NSString stringWithFormat:@"%ld",++self.page];
    HWUserInstanceInfo* InstanceInfo = [HWUserInstanceInfo shareUser];
    NSString *nowTime = [self timeOfNow];
    NSDictionary *dict = @{
                           @"starttime": @"2016-08-10",
                           @"edate":nowTime,
                           @"num": @"3",
                           @"pno": str,
                           @"order":@"desc",
                           @"option":@"1",
                           @"procstate":@"draft",
                           @"did":@""
                           };
    APIRequest *request = [[APIRequest alloc] initWithApiPath:@"/ControlCenter/v3/restapi/doaction" method:APIRequestMethodPost];
    request.urlQueryParameters = @{
                                   @"action":@"qry_reportlist",
                                   @"para":dict,
                                   @"token":InstanceInfo.token
                                   };
    NSLog(@"request---%@",request);
    [[APIRequestOperationManager sharedRequestOperationManager] requestAPI:request completion:^(id result, NSError *error) {
        
        NSMutableArray *videoSidList = [HWlllegalReportModel mj_objectArrayWithKeyValuesArray:result[@"data"][@"datalist"]];
        
        if (videoSidList.count > 0) {
            [self.videoArray addObjectsFromArray:videoSidList];
            [self.tableView reloadData];
        }else {
            // self.noMoreData = YES;
        }
        [self.tableView.mj_footer endRefreshing];
    }];

}
- (void)setUpTitle{

    CGFloat screenw = screenW;
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0.3*screenw, 12)];
    titleLabel.text = NSLocalizedString(@"violation_of_regulation_and_report", nil);
    titleLabel.font = [UIFont systemFontOfSize:15];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
}

- (void)setUpActivityIndicatorView{
    CGFloat screenw = screenW;
    CGFloat screenh = screenH;
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.45*screenw, 0.45*screenh, 50, 50)];
    self.activityIndicator.layer.cornerRadius = 5;
    self.activityIndicator.layer.masksToBounds = YES;
    self.activityIndicator.backgroundColor = [UIColor lightGrayColor];
    [self.activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
    [self.view addSubview:self.activityIndicator];
}
- (void)isConnectionAvailable{

    if (![[AHCNetworkChangeDetector sharedNetworkChangeDetector] isNetworkConnected]) {
        
        UILabel *labelTip = [[UILabel alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 30)];
        labelTip.text = NSLocalizedString(@"root_controller_network_error_label", nil);
        labelTip.textColor = [UIColor whiteColor];
        labelTip.backgroundColor = [UIColor lightGrayColor];
        labelTip.font = [UIFont systemFontOfSize:12];
        [self.view addSubview:labelTip];
        return ;
    }
    
   
}
- (void)setUpLeftNavigationItem{
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"title_back_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonItemAction)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
}

- (void)leftBarButtonItemAction{
    
    [self.navigationController popViewControllerAnimated:YES];
}

+ (instancetype)lllegalReportViewController {

    return [[HWlllegalReportViewController alloc] initWithNibName:@"HWlllegalReportViewController" bundle:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.videoArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    __weak typeof(self) weakSelf = self;
    HWlllegalReportCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HWlllegalReportCell class])];
    if (cell == nil) {
        cell = [[HWlllegalReportCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([HWlllegalReportCell class])];
    }
    HWlllegalReportModel *video = self.videoArray[indexPath.row];
    cell.model = video;
    cell.deblock = ^{
        [weakSelf deleteVideo:video row:indexPath.row];
        
    };
    return cell;
}
- (void)deleteVideo:(HWlllegalReportModel *)video row:(NSInteger)row{
    HWUserInstanceInfo *InstanceInfo = [HWUserInstanceInfo shareUser];
    
    NSString *alarmId = [NSString stringWithFormat:@"%@",video.pkid];
    
    NSDictionary *dict = @{
                           @"pkid":alarmId
                           };
    
    APIRequest *request = [[APIRequest alloc] initWithApiPath:@"/ControlCenter/v3/restapi/doaction" method:APIRequestMethodPost];
    request.urlQueryParameters = @{
                                   @"action":@"del_onereport",
                                   @"para":dict,
                                   @"token":InstanceInfo.token
                                   };
    NSLog(@"request---%@",request);
    [[APIRequestOperationManager sharedRequestOperationManager] requestAPI:request completion:^(id result, NSError *error) {
        
        if ([result[@"data"] isEqual:@"success"]) {
            [self.videoArray removeObjectAtIndex:row];
            [self.tableView reloadData];
        }else{
            HWLog(@"删除失败");
        }
        
    }];
    

    
    
    
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
    HWlllegalReportModel * model = _videoArray[indexPath.row];
    
    self.playerVC = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:model.video_url]];
    [[self.playerVC moviePlayer] prepareToPlay];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playVideoFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:[self.playerVC moviePlayer]];
    [self presentMoviePlayerViewControllerAnimated:self.playerVC];
    [[self.playerVC moviePlayer] play];
    
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 250;
}

-(NSString *)timeOfNow{
    NSDate *currentDate = [NSDate date];//获取当前时间，日期
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd"];
    NSString *dateString = [dateFormatter stringFromDate:currentDate];
    return dateString;
}


/**
 * 让当前控制器对应的状态栏是白色
 */
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
