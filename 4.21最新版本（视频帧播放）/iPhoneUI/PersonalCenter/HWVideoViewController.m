//
//  HWVideoViewController.m
//  HuaWo
//
//  Created by hwawo on 16/12/23.
//  Copyright © 2016年 HW. All rights reserved.
//

#import "HWVideoViewController.h"
#import "Video.h"
#import "VideoSid.h"
#define kRandomColor [UIColor colorWithRed:arc4random_uniform(256) / 255.0 green:arc4random_uniform(256) / 255.0 blue:arc4random_uniform(256) / 255.0 alpha:1]
@interface HWVideoViewController () <FMGVideoPlayViewDelegate>
/* 全屏控制器 */
@property (nonatomic, strong) FullViewController *fullVc;

@property (nonatomic, assign) BOOL isShowDanmak;

@end

@implementation HWVideoViewController

+ (instancetype)shareVideoController
{
    static HWVideoViewController
    * video = nil;
    static dispatch_once_t token;
    if (video == nil) {
        dispatch_once(&token, ^{
            video = [[HWVideoViewController alloc] init];
        });
    }
    return video;
}

- (void)viewWillAppear:(BOOL)animated
{
//    if (self.playView.urlString != _video.alarm_info.video_url) {
//        [_playView setUrlString:_video.alarm_info.video_url];
        [_playView.player play];
        _playView.playOrPauseBtn.selected = YES;
 //   }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self p_play];
    self.navigationItem.title = _video.title;
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:self action:@selector(leftBarButtonAction:)];
}

/**
 *  播放器
 */
- (void)p_play{
    self.playView = [FMGVideoPlayView videoPlayView];
    self.playView.delegate = self;
    _playView.index = 0;
    // 视频资源路径
   // [_playView setUrlString:_video.alarm_info.video_url];
    // 播放器显示位置（竖屏时）
    _playView.frame = CGRectMake(0, 70, screenW, screenW/2);
    // 添加到当前控制器的view上
    [self.view addSubview:_playView];
    [_playView.player play];
    _playView.playOrPauseBtn.selected = YES;
    // 指定一个作为播放的控制器
    _playView.contrainerViewController = self;
    
}

#pragma mark - 懒加载代码
- (FullViewController *)fullVc
{
    if (_fullVc == nil) {
        _fullVc = [[FullViewController alloc] init];
    }
    return _fullVc;
}

- (void)leftBarButtonAction:(UIBarButtonItem *)sender{
    [_playView.player pause];
    [_playView.player setRate:0];
    _playView.playOrPauseBtn.selected = NO;
    //    [_playView.currentItem removeObserver:_playView forKeyPath:@"status"];
    //    [_playView.player replaceCurrentItemWithPlayerItem:nil];
    //    _playView.currentItem = nil;
    //    _playView.player = nil;
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - 视频代理方法

- (void)videoplayViewSwitchOrientation:(BOOL)isFull
{
    if (isFull) {
        [self.navigationController presentViewController:self.fullVc animated:NO completion:^{
            [self.fullVc.view addSubview:self.playView];
            _playView.center = self.fullVc.view.center;
            
            [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionLayoutSubviews animations:^{
                _playView.frame = self.fullVc.view.bounds;
                
            } completion:nil];
        }];
    } else {
        [self.fullVc dismissViewControllerAnimated:NO completion:^{
            [self.view addSubview:_playView];
            _playView.frame = CGRectMake(0,  70 , screenW, (screenW-20)/2);
        }];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
