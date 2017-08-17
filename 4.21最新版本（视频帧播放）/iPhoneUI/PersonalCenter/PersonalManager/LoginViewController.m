//
//  LoginViewController.m
//  HuaWo
//
//  Created by circlely on 1/26/16.
//  Copyright © 2016 circlely. All rights reserved.
//

#import "LoginViewController.h"
#import "LoginTableCellView.h"
#import "MBProgressHUD.h"
#import "RegistViewController.h"
#import <ShareSDK/ShareSDK.h>
#import "ResetPasswordViewController.h"
#import "MemberData.h"

#define kLoginTableViewCellID @"logintableviewcellid"
#define CELLHEIGHT 44


@interface LoginViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (strong, nonatomic) UITextField *accountNameField;
@property (strong, nonatomic) UITextField *passwordField;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationController.navigationBarHidden = NO;
    
    [self setUpTableView];
    
    [self createLoginBtn];
    
    [self setUpNav];
}

- (void)setUpNav{

    self.navigationController.navigationBar.barTintColor = kNavigation7Color;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"title_back_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonItemAction)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"user_register", nil) style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonItemAction)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 44)];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = NSLocalizedString(@"login_signIn_btn", nil);
    self.navigationItem.titleView = titleLabel;
}

- (void)createLoginBtn{

    self.loginBtn.layer.masksToBounds = YES;
    self.loginBtn.layer.cornerRadius = 5;
    //self.loginBtn.titleLabel.text = NSLocalizedString(@"login_signIn_btn", nil);
    [self.loginBtn setTitle:NSLocalizedString(@"login_signIn_btn", nil) forState:UIControlStateNormal];
    self.loginBtn.tintColor = [UIColor whiteColor];
}

- (void)setUpTableView{

    self.tableView.tableFooterView = self.footerView;
    self.tableView.allowsSelection = NO;
    self.view.backgroundColor = kBackgroundColor;
    self.tableView.backgroundColor = nil;
    self.tableView.backgroundColor = kBackgroundColor;
    self.tableView.separatorColor = kBackgroundColor;
    self.footerView.backgroundColor = kBackgroundColor;
}

- (void)viewDidLayoutSubviews {
    
    //设置tableview.separatorLine 左边顶到头
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        
        self.tableView.separatorInset = UIEdgeInsetsZero;
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutManager:)]) {
        
        self.tableView.layoutMargins = UIEdgeInsetsZero;
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)rightBarButtonItemAction {
    [[RDVTabBarController shareTabBar] setTabBarHidden:YES animated:NO];
    RegistViewController *registViewController = [[RegistViewController alloc] initWithNibName:@"RegistViewController" bundle:nil];
    [self.navigationController pushViewController:registViewController animated:YES];
}

- (void)leftBarButtonItemAction {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}


- (IBAction)loginBtnClicked:(id)sender {
    
    
    if (![self checkFields]) {
        return;
    }
    
    NSString *userName = self.accountNameField.text;
    NSString *passWord = self.passwordField.text;

    
    MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES configBlock:^(MBProgressHUD *HUD) {
        HUD.removeFromSuperViewOnHide = YES;
    }];

  
}
- (IBAction)loginByQQBtnClicked:(id)sender {
    
    
    MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES configBlock:^(MBProgressHUD *HUD) {
        HUD.removeFromSuperViewOnHide = YES;
    }];
    
    [ShareSDK getUserInfo:SSDKPlatformTypeQQ onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error) {
        if (state == SSDKResponseStateSuccess) {
            
            
            HWLog(@"uid=%@",user.uid);
            HWLog(@"%@",user.credential);
            HWLog(@"token=%@",user.credential.token);
            HWLog(@"nickname=%@",user.nickname);
            
            [[MemberData memberData] setMemberNickName:user.nickname];
            
        }
        
        else if (state == SSDKResponseStateCancel) {
            
            HUD.detailsLabelText = NSLocalizedString(@"用户取消授权", nil);
            HUD.mode = MBProgressHUDModeCustomView;
            HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"warning.png"]];
            [HUD hide:YES afterDelay:2.0];
            
        }
        
        else {
            
            HUD.detailsLabelText = [NSString stringWithFormat:@"%@",[error description]];
            HUD.mode = MBProgressHUDModeCustomView;
            HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"warning.png"]];
            [HUD hide:YES afterDelay:2.0];
            
            APP_LOG_ERR(@"ThirdLogin Error [%@]",error);
        }
    }];
    
}
- (IBAction)loginByWeChatBtnClicked:(id)sender {
    
    //[ShareSDK cancelAuthorize:SSDKPlatformTypeQQ];
    
    MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES configBlock:^(MBProgressHUD *HUD) {
        HUD.removeFromSuperViewOnHide = YES;
    }];
    
    [ShareSDK getUserInfo:SSDKPlatformTypeWechat onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error) {
        
        if (state == SSDKResponseStateSuccess) {
            
            [[MemberData memberData] setMemberNickName:user.nickname];
        }
        
        else if (state == SSDKResponseStateCancel) {
            
            HUD.detailsLabelText = NSLocalizedString(@"用户取消授权", nil);
            HUD.mode = MBProgressHUDModeCustomView;
            HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"warning.png"]];
            [HUD hide:YES afterDelay:2.0];
            
        }
        
        else {
            
            HUD.detailsLabelText = [NSString stringWithFormat:@"%@",[error description]];
            HUD.mode = MBProgressHUDModeCustomView;
            HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"warning.png"]];
            [HUD hide:YES afterDelay:2.0];
            
        }
    }];

    
    
}
- (IBAction)loginByWeboBtnClicked:(id)sender {
    
    MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES configBlock:^(MBProgressHUD *HUD) {
        HUD.removeFromSuperViewOnHide = YES;
    }];
    
    [ShareSDK getUserInfo:SSDKPlatformTypeSinaWeibo onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error) {
        if (state == SSDKResponseStateSuccess) {

            [[MemberData memberData] setMemberNickName:user.nickname];
        }
        
        else if (state == SSDKResponseStateCancel) {
            
            HUD.detailsLabelText = NSLocalizedString(@"用户取消授权", nil);
            HUD.mode = MBProgressHUDModeCustomView;
            HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"warning.png"]];
            [HUD hide:YES afterDelay:2.0];
            
        }
        
        else {
            
            HUD.detailsLabelText = [NSString stringWithFormat:@"%@",[error description]];
            HUD.mode = MBProgressHUDModeCustomView;
            HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"warning.png"]];
            [HUD hide:YES afterDelay:2.0];
            
        }
    }];
    
    
    
}

- (BOOL)checkFields {
    
    if (!self.accountNameField.text.length) {
        [self.accountNameField becomeFirstResponder];
        return NO;
    }
    
    if (!self.passwordField.text.length) {
        [self.passwordField becomeFirstResponder];
        return NO;
    }
    
    return YES;
    
}

- (IBAction)forgetPasswordBtnPressed:(id)sender {
    
    ResetPasswordViewController *resetPasswordVC = [[ResetPasswordViewController alloc] initWithNibName:@"ResetPasswordViewController" bundle:nil];
    [[RDVTabBarController shareTabBar] setTabBarHidden:YES animated:NO];
    [self.navigationController pushViewController:resetPasswordVC animated:YES];
    
}



#pragma mark TableViewDelegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kLoginTableViewCellID];
    
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kLoginTableViewCellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = kTableViewCellColor;
        
        cell.accessoryView = [[UITextField alloc] initWithFrame:CGRectMake(320-180, 1, 180, CELLHEIGHT-2)];
        cell.accessoryView.backgroundColor = kTableViewCellColor;
        
    }
    
//    cell.textLabel.text = [[self.cellArr objectAtIndex:indexPath.row] objectForKey:kCellText];
    cell.textColor = [UIColor whiteColor];
    if (indexPath.row == 0) {
        cell.textLabel.text = NSLocalizedString(@"user_login_account", nil);
        self.accountNameField = cell.accessoryView;
        self.accountNameField.delegate = self;
        //self.accountNameField.placeholder = [[self.cellArr objectAtIndex:indexPath.row] objectForKey:kCellDetailText];
//        self.accountNameField.text = [[MemberData memberData] getAvsNameOfCID:self.CIDNumber];
        self.accountNameField.textColor = [UIColor whiteColor];
        self.accountNameField.clearButtonMode = UITextFieldViewModeAlways;
        self.accountNameField.textAlignment = NSTextAlignmentLeft;
        self.accountNameField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"login_email_textfield_placeholder", nil) attributes:@{NSForegroundColorAttributeName : [UIColor grayColor]}];
    }
    
    else if (indexPath.row == 1) {
        cell.textLabel.text = NSLocalizedString(@"user_login_password", nil);
        self.passwordField = cell.accessoryView;
        self.passwordField.delegate = self;
        //self.passwordField.placeholder = [[self.cellArr objectAtIndex:indexPath.row] objectForKey:kCellDetailText];
//        self.passwordField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:[[self.cellArr objectAtIndex:indexPath.row] objectForKey:kCellDetailText] attributes:@{NSForegroundColorAttributeName : [UIColor grayColor]}];
        self.passwordField.textColor = [UIColor whiteColor];
        self.passwordField.clearButtonMode = UITextFieldViewModeAlways;
        self.passwordField.textAlignment = NSTextAlignmentLeft;
        self.passwordField.secureTextEntry = YES;
        
    }
    
    return cell;
    
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    
    [textField resignFirstResponder];
    return YES;
    
}

/**
 * 让当前控制器对应的状态栏是白色
 */
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
@end
