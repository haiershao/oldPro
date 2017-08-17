 //
//  RegistViewController.m
//  HuaWo
//
//  Created by circlely on 1/26/16.
//  Copyright © 2016 circlely. All rights reserved.
//

#import "RegistViewController.h"
#import "LoginTableCellView.h"

#import "MBProgressHUD.h"

#import "NSString+Helper.h"

#define kRegistTableViewCellID @"registtableviewcellid"
#define CELLHEIGHT 44

@interface RegistViewController ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UIButton *registButton;

@property (strong, nonatomic) UITextField *accountNameField;
@property (strong, nonatomic) UITextField *passwordField;
@property (strong, nonatomic) UITextField *nickNameField;


@end

@implementation RegistViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setUpTableView];

    [self setUpNav];
    
    [self createregistButton];
    
}

- (void)createregistButton{

    self.registButton.layer.masksToBounds = YES;
    self.registButton.layer.cornerRadius = 5;
    //self.loginBtn.titleLabel.text = NSLocalizedString(@"login_signIn_btn", nil);
    [self.registButton setTitle:NSLocalizedString(@"register_create_btn", nil) forState:UIControlStateNormal];
    self.registButton.tintColor = [UIColor whiteColor];
}

- (void)setUpNav{

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"title_back_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonItemAction)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 44)];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = NSLocalizedString(@"user_register", nil);
    self.navigationItem.titleView = titleLabel;
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)leftBarButtonItemAction {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (IBAction)registBtnClicked:(id)sender {
    
    
    if (![self checkFields]) {
        return;
    }
    
    
    
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
    
    if (![NSString validateEmail:self.accountNameField.text]) {
        
        [self.accountNameField becomeFirstResponder];
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES configBlock:^(MBProgressHUD *HUD) {
           
            HUD.detailsLabelText = NSLocalizedString(@"warnning_email_address_validation", nil);
            HUD.removeFromSuperViewOnHide = YES;
            [HUD hide:YES afterDelay:2];
            
        }];
        
        return NO;
    }
    
    return YES;
    
}




#pragma mark TableViewDelegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kRegistTableViewCellID];
    
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kRegistTableViewCellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = kTableViewCellColor;
        
        cell.accessoryView = [[UITextField alloc] initWithFrame:CGRectMake(320-230, 1, 230, CELLHEIGHT-2)];
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
    else if (indexPath.row == 2) {
        cell.textLabel.text = NSLocalizedString(@"user_login_nickname", nil);
        self.nickNameField = cell.accessoryView;
        self.nickNameField.delegate = self;
        //self.passwordField.placeholder = [[self.cellArr objectAtIndex:indexPath.row] objectForKey:kCellDetailText];
        self.nickNameField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"user_login_nickname", nil) attributes:@{NSForegroundColorAttributeName : [UIColor grayColor]}];
        self.nickNameField.textColor = [UIColor whiteColor];
        self.nickNameField.clearButtonMode = UITextFieldViewModeAlways;
        self.nickNameField.textAlignment = NSTextAlignmentLeft;
        
    }
    
    return cell;
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
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
