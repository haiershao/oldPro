//
//  LanSearchResultViewController.m
//  AtHomeCam
//
//  Created by Circlely Networks on 4/12/13.
//
//

#import "LanSearchResultViewController.h"
#import "NSString+Helper.h"
#import "MBProgressHUD.h"
#import "AHCServerCommunicator.h"
#import "LanSearchResultCell.h"


#define KCIDStr   @"Cid"
#define KAvsName  @"Name"
#define KAvsType  @"Ostype"

#define KAlertViewShouldLoginIn 100
#define KAlertViewAddAvs        101

@interface LanSearchResultViewController ()<UITableViewDataSource,UITableViewDelegate,LanSearchResultCellDelegate,UIAlertViewDelegate>
{
    
}

@property (nonatomic,retain)UIAlertView * alerView;
@property (nonatomic,copy)NSString *cidStr;
@property (nonatomic,retain)NSIndexPath *path;

@end

@implementation LanSearchResultViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        

    }
    return self;
}

- (void)leftBarButtonItemAction {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}


- (void)viewDidLayoutSubviews{
    
    [super viewDidLayoutSubviews];
    
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    if([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]){
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
}



#pragma mark -UITableViewDelegate-
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{


    return _dataArr.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return 75;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    static NSString *cellid = @"lan_search_cellid";
    LanSearchResultCell *cell = [tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"LanSearchResultCell" owner:self options:nil] lastObject];
        cell.delegate = self;
        cell.indexPath = indexPath;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSDictionary *dic = [_dataArr objectAtIndex:indexPath.row];
    
    cell.avsName.text = [dic objectForKey:KAvsType];
    cell.avsCid.text = [NSString stringWithFormat:@"CID : %@",[dic objectForKey:KCIDStr]];
    cell.typeOfAVS = [[dic objectForKey:KAvsType] floatValue];
    
    return cell;

}

#pragma mark --LanSearchResultCellDelegate--
- (void)addAvs:(NSIndexPath *)indexpath{
    
//    if(![[MemberData memberData] isAllowedToAddMoreCID]){
//    
//        [self shouldLogin];
//        
//        return;
//    }
    
    _path = indexpath;
    
    NSMutableDictionary *dic = [self.dataArr objectAtIndex:indexpath.row];
    _cidStr = [dic objectForKey:KCIDStr];
    
    
     _alerView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"wlan_search_add_title_label", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"cancel_btn", nil) otherButtonTitles:NSLocalizedString(@"confirm_btn", nil),nil];
    
    _alerView.tag = KAlertViewAddAvs;
    _alerView.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    _alerView.delegate = self;
    
    UITextField *nameField = [_alerView textFieldAtIndex:0];
    nameField.placeholder = NSLocalizedString(@"manual_add_username_cell_placeholder", nil);
    
    UITextField *pswField = [_alerView textFieldAtIndex:1];
    pswField.placeholder = NSLocalizedString(@"manual_add_password_cell_placeholder", nil);
    
    [_alerView show];
   
    
    
    
}


//- (void)shouldLogin{
//    
//    
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title", nil)
//                                                    message:NSLocalizedString(@"warnning_experience_add_avs_alert", nil)
//                                                   delegate:self cancelButtonTitle:NSLocalizedString(@"warning_alert_ok_btn", nil) otherButtonTitles:NSLocalizedString(@"cancel_btn", nil),nil];
//    alert.tag = KAlertViewShouldLoginIn;
//    [alert show];
//
//    
//    
//}


#pragma nark --UIAlertViewDelegate--
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{

    if (alertView.tag == KAlertViewAddAvs ) {
        if (buttonIndex == 1) {
            
            [self addAVS];
            
        }
    }
//    if (alertView.tag == KAlertViewShouldLoginIn) {
//        if (buttonIndex == 0) {
//            
//            [self goToLoginIn];
//            
//        }
//    }


}
- (void)goToLoginIn{
    
//    MemberLoginViewController *loginViewController = [[MemberLoginViewController alloc] initWithNibName:@"MemberLoginViewController" bundle:nil];
//    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
//    
//    if (kiOS7) {
//        navigationController.navigationBar.tintColor = [UIColor whiteColor];
//        navigationController.navigationBar.barTintColor = kNavigation7Color;
//        NSDictionary *textColorDictionary = @{UITextAttributeFont: CG_BOLD_FONT(20),UITextAttributeTextColor: [UIColor whiteColor]};
//        navigationController.navigationBar.titleTextAttributes = textColorDictionary;
//        navigationController.navigationBar.translucent = NO;
//    }else{
//        navigationController.navigationBar.tintColor = kNavigation6Color;
//    }
    
//    
//    [self presentViewController:navigationController animated:YES completion:^{
//        
//
//        
//    }];
    
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 44)];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = NSLocalizedString(@"wlan_search_cid_result_title", nil);
    self.navigationItem.titleView = titleLabel;

    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.navigationItem.titleView = titleLabel;
    self.view.backgroundColor = kBackgroundColor;
    self.tableView.backgroundColor = nil;
    self.tableView.backgroundColor = kBackgroundColor;
    self.tableView.separatorColor = kBackgroundColor;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"title_back_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonItemAction)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    
    
    //监听APP切入后台的通知，用于资源清理，在下一次APP拉起时，界面会回到CID LIST 界面
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
}
- (void)applicationDidEnterBackground{

    if (_alerView) {
        [_alerView dismissWithClickedButtonIndex:-1 animated:NO];
        _alerView = nil;
    }

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

-(void)dealloc
{
    
    [MBProgressHUD hideHUDForView:self.view animated:NO];
    
    if (_alerView) {
        [_alerView dismissWithClickedButtonIndex:-1 animated:NO];
        _alerView = nil;
    }


}

- (void)alertViewShow{

    [_alerView show];

}
#pragma mark UITextFieldDelegate
- (void)addAVS
{
    if ([[_alerView textFieldAtIndex:0].text length] == 0) {
       
        [self performSelector:@selector(alertViewShow) withObject:nil afterDelay:1];
        return ;
    }
    else if([[_alerView textFieldAtIndex:1].text length] == 0)
    {
        [self performSelector:@selector(alertViewShow) withObject:nil afterDelay:1];
        return ;
    }
    
    UITextField *nameField = [_alerView textFieldAtIndex:0];
    UITextField *pswField = [_alerView textFieldAtIndex:1];
    
    MBProgressHUD* HUD = [MBProgressHUD showHUDAddedTo:self.view
                                              animated:YES
                                           configBlock:nil];
	
	
    __typeof(self) __weak myself = self;
    void (^addSucBlk)() = ^{
        
        //        [myself dismissViewController];
        NSDictionary* CIDInfo = @{ kCIDInfoNumber:   _cidStr,
                                   kCIDInfoUsername: nameField.text,
                                   kCIDInfoPassword: pswField.text};
        [[AHCServerCommunicator sharedAHCServerCommunicator] subscribeCID:CIDInfo];
        [MBProgressHUD hideHUDForView:myself.view animated:YES];
        
        
        HUD.detailsLabelText =  NSLocalizedString(@"warnning_cid_add_succes", nil);;
        HUD.labelFont = CG_BOLD_FONT(15);
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.removeFromSuperViewOnHide = YES;
        HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CheckMark.png"]];
        [HUD hide:YES afterDelay:1.0];
        
        [myself.dataArr removeObjectAtIndex:_path.row];
        [myself.tableView reloadData];
        
        [myself.navigationController popToRootViewControllerAnimated:YES];
    
    
    };
   
}

/**
 * 让当前控制器对应的状态栏是白色
 */
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
@end
