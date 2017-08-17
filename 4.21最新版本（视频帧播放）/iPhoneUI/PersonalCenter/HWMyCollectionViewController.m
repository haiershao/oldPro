//
//  HWMyCollectionViewController.m
//  HuaWo
//
//  Created by hwawo on 16/5/27.
//  Copyright © 2016年 HW. All rights reserved.
//

#import "HWMyCollectionViewController.h"

@interface HWMyCollectionViewController ()

@end

@implementation HWMyCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = kBackgroundColor;
    
    [self setUpLeftNavigationItem];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

+ (instancetype)myCollectionViewController{

    return [[HWMyCollectionViewController alloc] initWithNibName:@"HWMyCollectionViewController" bundle:nil];
}

- (void)setUpLeftNavigationItem{
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"title_back_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonItemAction)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
}

- (void)leftBarButtonItemAction{
    
    [self.navigationController popViewControllerAnimated:YES];
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
