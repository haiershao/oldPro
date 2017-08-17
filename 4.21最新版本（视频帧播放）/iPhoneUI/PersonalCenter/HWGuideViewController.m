//
//  HWGuideViewController.m
//  HuaWo
//
//  Created by hwawo on 16/5/22.
//  Copyright © 2016年 HW. All rights reserved.
//

#import "HWGuideViewController.h"

@interface HWGuideViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *guideScrollView;

@end

@implementation HWGuideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = kBackgroundColor;
    
    [self setUpLeftNavigationItem];
    
    [self setUpGuideScrollView];
}

- (void)setUpGuideScrollView{
    CGFloat screenw = screenW;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenw,2500)];
    imageView.image = [UIImage imageNamed:@"guide"];
    self.guideScrollView.contentSize = CGSizeMake(screenw, 2500);
    self.guideScrollView.showsHorizontalScrollIndicator = NO;
//    self.guideScrollView.delegate = self;
    self.guideScrollView.pagingEnabled = YES;
    [self.guideScrollView addSubview:imageView];
}

+ (instancetype)guideViewController{
    
    return [[HWGuideViewController alloc] initWithNibName:@"HWGuideViewController" bundle:nil];
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
