//
//  LanAddViewController.m
//  HuaWo
//
//  Created by circlely on 1/21/16.
//  Copyright © 2016 circlely. All rights reserved.
//

#import "LanAddViewController.h"
#import "MBProgressHUD.h"
#import "Reachability.h"
#import "LanSearchResultViewController.h"

#define KCIDStr   @"cid"
#define KAvsName  @"name"
#define KAvsType  @"ostype"

@interface LanAddViewController ()
@property (weak, nonatomic) IBOutlet UILabel *tipsLabel;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (nonatomic,retain)MBProgressHUD *hudView;
@end

@implementation LanAddViewController
{
    NSMutableArray *_dataArray;
    
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    //清空数组  防止从后面界面返回 搜索时 重复加入
    if (_dataArray) {
        [_dataArray removeAllObjects];
    }
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = kBackgroundColor;
    self.navigationController.navigationBar.barTintColor = kNavigation7Color;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"title_back_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonItemAction)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 44)];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = NSLocalizedString(@"root_sidebar_add_cid_by_lansearch_label", nil);
    self.navigationItem.titleView = titleLabel;

    self.searchButton.layer.masksToBounds = YES;
    self.searchButton.layer.cornerRadius = 5;
    [self.searchButton setTitle:NSLocalizedString(@"search_btn", nil) forState:UIControlStateNormal];
    self.searchButton.tintColor = [UIColor whiteColor];
    
    self.tipsLabel.text = NSLocalizedString(@"before_search_instruction_content", nil);
    
    _dataArray = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)leftBarButtonItemAction {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (IBAction)searchButtonPressed:(id)sender {
    
    Reachability *r = [Reachability reachabilityForInternetConnection];
    
    if ( [r currentReachabilityStatus] == NotReachable) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title", nil)
                                                        message:NSLocalizedString(@"network_disconnect", nil)
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:NSLocalizedString(@"ok_btn", nil), nil];
        [alert show];
        
        return;
        
    }
    
    [self performSelector:@selector(lanSearchTimeOut) withObject:nil afterDelay:5];
    
    [self.searchButton setEnabled:NO];
    
}

#pragma mark -
#pragma mark LanSearchWapperDelegate
- (void)lanSearchWapperDidStartSearch:(id)sender
{
    
    self.hudView  = [MBProgressHUD showHUDAddedTo:self.view animated:YES configBlock:^(MBProgressHUD *HUD){
        
        HUD.detailsLabelText = NSLocalizedString(@"searching_label", nil);
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.removeFromSuperViewOnHide = YES;
        HUD.customView = [[UIActivityIndicatorView alloc]
                           initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [(UIActivityIndicatorView *)HUD.customView startAnimating];
        
    }];
    
}

- (void)lanSearchWapperDidStopSearch:(id)sender
{
}

- (void)lanSearchWapperDidFindACid:(NSString *)cid AvsName:(NSString *)name AvsType:(NSString *)type
{
    
    if ([_dataArray count] > 0) {
        
        for (NSMutableDictionary *dict in _dataArray) {
            if ([[dict objectForKey:KCIDStr] isEqualToString:cid]) {
                
                return;
            }
        }
    }
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:cid forKey:KCIDStr];
    [dic setObject:name forKey:KAvsName];
    [dic setObject:type forKey:KAvsType];
    
    [_dataArray addObject:dic];
    
}
-(void)lanSearchTimeOut
{
    
    if([_dataArray count] == 0){
        
        _hudView.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"warning.png"]];
        _hudView.detailsLabelText = NSLocalizedString(@"warnning_lansearching_failed", nil);
        _hudView.labelFont = CG_BOLD_FONT(15);
        [_hudView hide:YES afterDelay:2.0];
    }else{
        
        [_hudView hide:YES];
        
        LanSearchResultViewController* resultController = [[LanSearchResultViewController alloc] initWithNibName:@"LanSearchResultViewController" bundle:nil];
        
        resultController.dataArr = _dataArray;
        [self.navigationController pushViewController:resultController animated:YES];
        
        
    }
    
    [self.searchButton setEnabled:YES];
    
}

/**
 * 让当前控制器对应的状态栏是白色
 */
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
@end
