//
//  HWImmediatelyShareController.m
//  HuaWo
//
//  Created by hwawo on 16/5/24.
//  Copyright © 2016年 HW. All rights reserved.
//

#import "HWImmediatelyShareController.h"
//#import "FMGVideoPlayView.h"
//#import "FullViewController.h"
#import <AWSS3/AWSS3.h>
#import <AWSCore/AWSCore.h>
#import "MBProgressHUD.h"
#import <TextView/TextView.h>
#import "MemberData.h"
#import "NSString+encrypto.h"
#import "SharePageViewController.h"
#import "HWServiceCloudViewController.h"

#define kBucketName @"huawo"
#define kVideoKey
#define kImageKey
#define kUid [[MemberData memberData] getMemberAccount]
#define kNickName [[MemberData memberData] getMemberNickName]

@interface HWImmediatelyShareController ()<UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UIView *videoView;
@property (weak, nonatomic) IBOutlet UIButton *shareBtn;
@property (strong, nonatomic) NSURL *videoUrl;
@property (strong, nonatomic) NSURL *imageUrl;
@property (copy, nonatomic) NSString *videoKey;
@property (copy, nonatomic) NSString *imageKey;
@property (strong, nonatomic) MBProgressHUD *hud;
@property (weak, nonatomic) TextView *textview;
@property (strong, nonatomic) UIAlertView *alert;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) FMGVideoPlayView *playView;
@end

@implementation HWImmediatelyShareController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = kBackgroundColor;
    self.shareBtn.layer.cornerRadius = 5;
    self.shareBtn.layer.masksToBounds = YES;
    
    self.videoUrl = [NSURL fileURLWithPath:self.videoPath];
    self.imageUrl = [NSURL fileURLWithPath:self.imageIconPath];

    [self setUpTitle];
    
    [self setUpLeftNavigationItem];
    
//    [self setUpRightNavigationItem];
    
    [self addNotification];
    
    //添加播放器
    [self setUpVideoPlayer];

    HWLog(@"--------cid---------%@",[[MemberData memberData] getMemberCIDList]);
}

- (void)addNotification{

    [DZNotificationCenter addObserver:self selector:@selector(playerView:) name:@"playerView" object:nil];
    [DZNotificationCenter addObserver:self selector:@selector(playerViewFrame:) name:@"playerViewFrame" object:nil];
    
    [DZNotificationCenter addObserver:self selector:@selector(OrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];

}

- (void)OrientationDidChange:(NSNotification *)note{
    
    NSDictionary *dict = note.userInfo;
    NSString *str = [NSString stringWithFormat:@"%@",dict[@"UIDeviceOrientationRotateAnimatedUserInfoKey"]];
    HWLog(@"===%@-%@",note.userInfo,dict[@"UIDeviceOrientationRotateAnimatedUserInfoKey"]);
    if ([str isEqualToString:@"1"]) {
        HWLog(@"===%@--%@",NSStringFromCGRect(self.playView.frame),NSStringFromCGRect(self.videoView.frame));
//        [self.videoView addSubview:self.playView];
    
    }else{
    
    }
}

- (void)setUpRightNavigationItem{

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"title_more"] style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonItemAction)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
}

- (void)rightBarButtonItemAction{

    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"quit_btn", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"收藏", nil), NSLocalizedString(@"保存", nil), NSLocalizedString(@"删除", nil), nil];
    [actionSheet showInView:self.view];
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet{

    for (UIView *subView in actionSheet.subviews) {
        if ([subView isKindOfClass:[UIButton class]]) {
        
            UIButton *button = (UIButton *)subView;
            button.backgroundColor = kTableViewCellColor;
            [button.titleLabel setFont:[UIFont systemFontOfSize:14]];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            if ([button.titleLabel.text isEqual: @"删除"]) {
               [button setTitleColor:DZColor(232, 111, 40) forState:UIControlStateNormal];
            }
        }
    }
}

- (void)setUpTitle{

    NSString *str = [[self.videoPath componentsSeparatedByString:@"/"] lastObject];
    NSString *titleStr =  [str substringToIndex:str.length - 4];
    CGFloat screenw = screenW;
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0.3*screenw, 12)];
    titleLabel.text = titleStr;
    titleLabel.font = [UIFont systemFontOfSize:12];
    titleLabel.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = titleLabel;
}

- (void)setUpVideoPlayer{
    
    FMGVideoPlayView *playView = [FMGVideoPlayView videoPlayView];
    // 视频资源路径
//    [playView setVideoUrl:self.videoUrl];
    [playView setUrlString:self.videoPath];
    // 播放器显示位置（竖屏时）
    CGFloat screenw = screenW;
    playView.frame = CGRectMake(0, 0, screenw, self.videoView.frame.size.height);
    // 添加到当前控制器的view上
    [self.videoView addSubview:playView];

    // 指定一个作为播放的控制器
    playView.contrainerViewController = self;
    playView.contrainerViewController.view.frame = CGRectMake(0, 0, screenw, self.videoView.frame.size.height - 85);
    self.playView = playView;
}

- (void)playerView:(NSNotification *)note{
    
    [self.videoView addSubview:note.object];
}

- (void)playerViewFrame:(NSNotification *)note{
    UIView *view = (UIView *)note.object;
    [UIView animateWithDuration:5 animations:^{
        view.frame = self.videoView.bounds;
    }];
    
}

- (void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (instancetype)immediatelyShareController{

    return [[HWImmediatelyShareController alloc] initWithNibName:@"HWImmediatelyShareController" bundle:nil];
}

- (void)setUpLeftNavigationItem{
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"title_back_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonItemAction)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
}

- (void)leftBarButtonItemAction{
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)shareBtnClick:(UIButton *)sender {
    HWLog(@"----------------self.cidNum-----------------------------%@",self.cidNum);
    SharePageViewController *shareVc = [SharePageViewController sharePageViewController];
    shareVc.videoPath = self.videoPath;
    shareVc.imagePath = self.imageIconPath;
    shareVc.cidNum = self.cidNum;
    [self.navigationController pushViewController:shareVc animated:YES];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 * 让当前控制器对应的状态栏是白色
 */
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
