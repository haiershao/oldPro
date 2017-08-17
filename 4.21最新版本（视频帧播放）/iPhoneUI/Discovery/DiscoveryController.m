//
//  DiscoveryController.m
//  HuaWo
//
//  Created by circlely on 1/20/16.
//  Copyright © 2016 circlely. All rights reserved.
//

#import "DiscoveryController.h"
#import "DisCoveryDetailViewController.h"
#import "MemberData.h"
#import <CCString/CCString.h>
#import "LoginViewController.h"
#import "NSString+encrypto.h"
#import "NSString+Helper.h"
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>
#import <ShareSDKUI/SSUIShareActionSheetCustomItem.h>
#import <ShareSDK/ShareSDK+Base.h>
#import <ShareSDKExtension/ShareSDK+Extension.h>
#import "HWTopDianViewController.h"
#import "HWZuiXinTableViewController.h"
#import "UIView+Extension.h"
#define isLogin [[MemberData memberData] isMemberLogin]
#define kUid [[MemberData memberData] getMemberAccount]
#define kNickName [[MemberData memberData] getMemberNickName]
@interface DiscoveryController()<UIWebViewDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate, UINavigationBarDelegate>
@property (nonatomic, weak) UIView *titlesView;
@property (nonatomic, weak) UIView *indicatorView;
@property (nonatomic, weak) UIButton *selectedButton;
@property (nonatomic, weak) UIScrollView *contentView;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeGestureRecognizerUp;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeGestureRecognizerDown;
@end

@implementation DiscoveryController


- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewWillAppear:(BOOL)animated{
    
    //    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
//    [UIApplication sharedApplication].statusBarHidden = NO;
}

- (void)viewDidDisappear:(BOOL)animated{
    
    //    [super viewDidDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];
//    [UIApplication sharedApplication].statusBarHidden = NO;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.navigationController.delegate = self;
    //    self.view.backgroundColor = kBackgroundColor;
    //    self.navigationController.navigationBar.backgroundColor = kNavigation7Color;
    
    [self setupChildVces];
    
    [self setUpTitleView];
    
    [self setUpContentView];
    
    //    [self addGesture];
}



- (void)addGesture{
    
    for (UITableViewController *vc in self.childViewControllers) {
        
        _swipeGestureRecognizerUp = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeUp:)];
        [_swipeGestureRecognizerUp  setDirection:UISwipeGestureRecognizerDirectionUp];
        [vc.view addGestureRecognizer:_swipeGestureRecognizerUp];
        
        
        _swipeGestureRecognizerDown = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeDown:)];
        [_swipeGestureRecognizerDown  setDirection:UISwipeGestureRecognizerDirectionDown];
        [vc.view addGestureRecognizer:_swipeGestureRecognizerDown];
    }
    
    
}

- (void)handleSwipeUp:(id)sender
{
    NSLog(@"handleSwipeUp");
    //do something ...
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)handleSwipeDown:(id)sender
{
    NSLog(@"handleSwipeDown");
    //do something ...
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)setupChildVces{
    
    HWTopDianViewController *topVc = [[HWTopDianViewController alloc] init];
    [self addChildViewController:topVc];
    
    HWZuiXinTableViewController *zuiXinVc = [[HWZuiXinTableViewController alloc] init];
    [self addChildViewController:zuiXinVc];
    
}

- (void)setUpTitleView{
    
    
    
    UIView *titleView = [[UIView alloc] init];
    titleView.backgroundColor = kNavigation7Color;
    titleView.width = screenW;
    titleView.height = 30;
    titleView.x = 0;
    titleView.y = 35;
    
    self.titlesView = titleView;
    
    UIView *coverView = [[UIView alloc] init];
    coverView.backgroundColor = kNavigation7Color;
    coverView.width = screenW;
    coverView.height = 64;
    coverView.x = 0;
    coverView.y = 0;
    [coverView addSubview:titleView];
    [self.view addSubview:coverView];
    
    UIView *indicatorView = [[UIView alloc] init];
    indicatorView.backgroundColor = DZColor(16, 207, 234);
    indicatorView.height = 2;
    indicatorView.tag = -1;
    indicatorView.y = self.titlesView.height - self.indicatorView.height - 2;
    [self.titlesView addSubview:indicatorView];
    self.indicatorView = indicatorView;
    
    NSArray *titles = @[@"热点",@"最新"];
    CGFloat width = self.titlesView.width/titles.count;
    CGFloat height = self.titlesView.height;
    
    for (NSInteger i = 0; i < titles.count; i++) {
        UIButton *btn = [[UIButton alloc] init];
        btn.tag = i;
        HWLog(@"setUpTitleView %ld",(long)btn.tag);
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        btn.width = width;
        btn.height = height;
        btn.x = i*btn.width;
        
        
        [btn setTitle:titles[i] forState:UIControlStateNormal];
        [btn setTitleColor:DZColor(16, 207, 234) forState:UIControlStateDisabled];
        [btn addTarget:self action:@selector(titleClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.titlesView addSubview:btn];
        
        
        if (i == 0) {
            btn.enabled = NO;
            self.selectedButton = btn;
            //            btn.backgroundColor = [UIColor redColor];
            [btn.titleLabel sizeToFit];
            btn.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -0.2*screenW);
            btn.titleLabel.textAlignment = NSTextAlignmentRight;
            
            self.indicatorView.width = btn.titleLabel.width + 20;
            self.indicatorView.centerX = btn.centerX + 0.1*screenW;
        }else{
            
            [btn.titleLabel sizeToFit];
            btn.contentEdgeInsets = UIEdgeInsetsMake(0, -0.2*screenW, 0, 0);
            btn.titleLabel.textAlignment = NSTextAlignmentRight;
            self.indicatorView.width = btn.titleLabel.width + 20;
        }
        if (kiPhone5) {
            btn.titleLabel.font = [UIFont systemFontOfSize:17];
        }
    }
    
    
}

- (void)titleClick:(UIButton *)btn{
    
    self.selectedButton.enabled = YES;
    btn.enabled = NO;
    self.selectedButton = btn;
    
    [UIView animateWithDuration:0.25 animations:^{
//        HWLog(@"self.indicatorView.width%f--%f",self.indicatorView.width, btn.titleLabel.width);
        //        self.indicatorView.width = btn.titleLabel.width;
        if (btn.tag == 1) {
            self.indicatorView.centerX = btn.centerX - 0.1*screenW;
        }else{
            
            self.indicatorView.centerX = btn.centerX + 0.1*screenW;
        }
        
    }];
    
    CGPoint offset = self.contentView.contentOffset;
    offset.x = btn.tag * self.contentView.width;
    HWLog(@"titleClick  %f",offset.x);
    [self.contentView setContentOffset:offset animated:YES];
}

- (void)setUpContentView{
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    UIScrollView *contentView = [[UIScrollView alloc] init];
    contentView.backgroundColor = kBackgroundColor;
    contentView.frame = self.view.frame;
    contentView.delegate = self;
    contentView.pagingEnabled = YES;
    [self.view insertSubview:contentView atIndex:0];
    contentView.contentSize = CGSizeMake(contentView.width * self.childViewControllers.count, 0);
    self.contentView = contentView;
    
    [self scrollViewDidEndScrollingAnimation:contentView];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    
    NSInteger index = scrollView.contentOffset.x / scrollView.width;
    
    UITableViewController *vc = self.childViewControllers[index];
    vc.view.x = scrollView.contentOffset.x;
    vc.view.y = 0;
    vc.view.height = scrollView.height;
    
    CGFloat bottom = self.tabBarController.tabBar.height;
    CGFloat top = CGRectGetMaxY(self.titlesView.frame);
    vc.tableView.contentInset = UIEdgeInsetsMake(top, 0, bottom, 0);
    
    vc.tableView.scrollIndicatorInsets = vc.tableView.contentInset;
    [scrollView addSubview:vc.view];
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self scrollViewDidEndScrollingAnimation:scrollView];
    
    // 点击按钮
    NSInteger index = scrollView.contentOffset.x / scrollView.width;
    HWLog(@"scrollViewDidEndDecelerating  %ld--%ld--%@",(long)index,(long)self.titlesView.subviews[index].tag,(UIButton *)self.titlesView.subviews);
    [self titleClick:self.titlesView.subviews[index+1]];
}
    
- (void)dealloc{

    HWLog(@"----DiscoveryController---dealloc----");
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}
@end
