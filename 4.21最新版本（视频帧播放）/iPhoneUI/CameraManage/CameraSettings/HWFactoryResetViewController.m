//
//  HWFactoryResetViewController.m
//  HuaWo
//
//  Created by Hwawo on 16/4/21.
//  Copyright © 2016年 circlely. All rights reserved.
//

#import "HWFactoryResetViewController.h"
#import "CameraSettingsConfigData.h"
#import "MBProgressHUD.h"
@interface HWFactoryResetViewController ()
@property (strong, nonatomic) CameraSettingsConfigData *configData;

- (IBAction)factoryRestBtn:(UIButton *)sender;

- (IBAction)quitBtn:(UIButton *)sender;

@end

@implementation HWFactoryResetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.configData = [CameraSettingsConfigData shareConfigData];
}

- (void)factoryRest{

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES configBlock:^(MBProgressHUD *HUD) {
        
    }];
    
    __typeof(self) __weak safeSelf = self;
    
}

- (void)setLeftBarButton{
    
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

+ (instancetype)factoryResetViewController{
    
    return [[HWFactoryResetViewController alloc] initWithNibName:@"HWFactoryResetViewController" bundle:nil];
    
}

- (IBAction)factoryRestBtn:(UIButton *)sender {
    
   
}

- (IBAction)quitBtn:(UIButton *)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 * 让当前控制器对应的状态栏是白色
 */
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
@end
