//
//  HWMyStoreViewController.m
//  HuaWo
//
//  Created by hwawo on 16/5/20.
//  Copyright © 2016年 HW. All rights reserved.
//

#import "HWMyStoreViewController.h"
#import "AHCNetworkChangeDetector.h"
#import "MemberData.h"
#import "NSString+encrypto.h"

#define kUid [[MemberData memberData] getMemberAccount]
@interface HWMyStoreViewController ()<UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *storeWebView;
@property (strong, nonatomic) NSString *request;
@property (assign, nonatomic) NSInteger allDataLength;
@property (strong, nonatomic) NSMutableData *webData;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@end

@implementation HWMyStoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = kBackgroundColor;
    self.storeWebView.backgroundColor = kBackgroundColor;
    self.storeWebView.scalesPageToFit = YES;
    self.storeWebView.delegate = self;
    self.storeWebView.opaque = NO;
    
    [self isConnectionAvailable];
    
    [self setUpLeftNavigationItem];
    
    [self setUpActivityIndicatorView];
    
}

+ (instancetype)myStoreViewController{

    return [[HWMyStoreViewController alloc] initWithNibName:@"HWMyStoreViewController" bundle:nil];
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
    
    [self loadWebPage];
}

- (void)loadWebPage{

//    NSString *uidStr = kUid;
//    uidStr = [uidStr sha1];
//    NSString *urlStr = [NSString stringWithFormat:@"%@?uid=%@",kMyStoreUrl,uidStr];
    NSMutableURLRequest *requestUrl = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kMyStoreUrl]];
    [self.storeWebView loadRequest:requestUrl];
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

- (void)webViewDidStartLoad:(UIWebView *)webView {
    
    [self.activityIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.activityIndicator stopAnimating];
    [self.activityIndicator removeFromSuperview];
}

- (void)setUpLeftNavigationItem{

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"title_back_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonItemAction)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
}

- (void)leftBarButtonItemAction{

    [self.navigationController popViewControllerAnimated:YES];
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
