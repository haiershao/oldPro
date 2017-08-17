//
//  ChangeCameraPWViewController.m
//  HuaWo
//
//  Created by circlely on 2/23/16.
//  Copyright © 2016 circlely. All rights reserved.
//

#import "ChangeCameraPWViewController.h"
#import "MemberData.h"
#import "MBProgressHUD.h"
#import "AHCServerCommunicator.h"

#define kChangeCameraPWCellID @"changecamerapwcellid"
#define CELLHEIGHT 60
#define kCellText @"celltext"
#define kCellDetailText @"celldetailtext"

@interface ChangeCameraPWViewController ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UILabel *tipsLabel;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (strong, nonatomic) NSMutableArray *cellArr;
@property (strong, nonatomic) UITextField *accountNameField;
@property (strong, nonatomic) UITextField *passwordField;
@property (strong, nonatomic) UITextField *confirmField;

@end

@implementation ChangeCameraPWViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = kBackgroundColor;
    [self setUpNav];
    
    [self setUpTableView];
    
    [self createSaveButton];
    
    self.tipsLabel.text = NSLocalizedString(@"change_pwd_instruction_content", nil);
    
    [self initCellArr];
}

- (void)createSaveButton{

    self.saveButton.layer.masksToBounds = YES;
    self.saveButton.layer.cornerRadius = 5;
    //self.saveButton.titleLabel.text = NSLocalizedString(@"save_btn", nil);
    [self.saveButton setTitle:NSLocalizedString(@"save_btn", nil) forState:UIControlStateNormal];
    self.saveButton.tintColor = [UIColor whiteColor];
}

- (void)setUpTableView{

    self.footerView.backgroundColor = kBackgroundColor;
    self.tableView.tableFooterView = self.footerView;
    self.tableView.separatorColor = kBackgroundColor;
}

- (void)setUpNav {

    self.navigationController.navigationBar.barTintColor = kNavigation7Color;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"title_back_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonItemAction)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 44)];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = NSLocalizedString(@"menu_change_password_label", nil);
    self.navigationItem.titleView = titleLabel;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)leftBarButtonItemAction {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)initCellArr {
    
    //NSString *accountName = [[MemberData memberData] getMemberAccount];
    
    NSMutableDictionary *accountNameDic = [NSMutableDictionary
                                          dictionaryWithDictionary:@{kCellText : NSLocalizedString(@"manual_add_username_cell_label", nil),
                                                                     kCellDetailText : NSLocalizedString(@"manual_add_username_cell_placeholder", nil)}];
    NSMutableDictionary *passwordDic = [NSMutableDictionary
                                           dictionaryWithDictionary:@{kCellText : NSLocalizedString(@"login_psw_textfield_placeholder", nil),
                                                                      kCellDetailText : NSLocalizedString(@"manual_add_password_cell_placeholder", nil)}];
    
    NSMutableDictionary *confirmpw = [NSMutableDictionary dictionaryWithDictionary:@{kCellText : NSLocalizedString(@"ipcam_change_pwd_controller_repeat_password_cell_label", nil),
                                                                                     kCellDetailText : NSLocalizedString(@"manual_add_password_cell_placeholder", nil)}];
    
    self.cellArr  = [NSMutableArray arrayWithObjects:accountNameDic, passwordDic, confirmpw, nil];
    
    
}

- (IBAction)saveButtonPressed:(id)sender {
    
    if (![self checkField]) {
        return;
    }
    
    [self becomeFirstResponder];
    
    MBProgressHUD* HUD = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow
                                              animated:YES
                                           configBlock:^(MBProgressHUD *HUD) {
                                               HUD.removeFromSuperViewOnHide = YES;
                                           }];
    
   

    
}


#pragma mark -----TableViewDelegate-----

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return CELLHEIGHT;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kChangeCameraPWCellID];
    
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kChangeCameraPWCellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = kTableViewCellColor;

        cell.accessoryView = [[UITextField alloc] initWithFrame:CGRectMake(320-180, 1, 180, CELLHEIGHT-2)];
        cell.accessoryView.backgroundColor = kTableViewCellColor;

    }
    
    cell.textLabel.text = [[self.cellArr objectAtIndex:indexPath.row] objectForKey:kCellText];
    cell.textColor = [UIColor whiteColor];
    if (indexPath.row == 0) {
        
        self.accountNameField = cell.accessoryView;
        self.accountNameField.delegate = self;
        //self.accountNameField.placeholder = [[self.cellArr objectAtIndex:indexPath.row] objectForKey:kCellDetailText];
        self.accountNameField.text = self.cameraName;
//        self.accountNameField.text = [[MemberData memberData] getAvsNameOfCID:self.CIDNumber];
        self.accountNameField.textColor = [UIColor whiteColor];
        self.accountNameField.clearButtonMode = UITextFieldViewModeAlways;
        self.accountNameField.textAlignment = NSTextAlignmentLeft;
        self.accountNameField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:[[self.cellArr objectAtIndex:indexPath.row] objectForKey:kCellDetailText] attributes:@{NSForegroundColorAttributeName : [UIColor grayColor]}];
    }
    
    else if (indexPath.row == 1) {
        
        self.passwordField = cell.accessoryView;
        self.passwordField.delegate = self;
        //self.passwordField.placeholder = [[self.cellArr objectAtIndex:indexPath.row] objectForKey:kCellDetailText];
        self.passwordField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:[[self.cellArr objectAtIndex:indexPath.row] objectForKey:kCellDetailText] attributes:@{NSForegroundColorAttributeName : [UIColor grayColor]}];
        self.passwordField.textColor = [UIColor whiteColor];
        self.passwordField.clearButtonMode = UITextFieldViewModeAlways;
        self.passwordField.textAlignment = NSTextAlignmentLeft;
        self.passwordField.secureTextEntry = YES;

    }
    
    else if (indexPath.row == 2) {
        
        self.confirmField = cell.accessoryView;
        self.confirmField.delegate = self;
        //self.confirmField.placeholder = [[self.cellArr objectAtIndex:indexPath.row] objectForKey:kCellDetailText];
        self.confirmField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:[[self.cellArr objectAtIndex:indexPath.row] objectForKey:kCellDetailText] attributes:@{NSForegroundColorAttributeName : [UIColor grayColor]}];
        self.confirmField.textColor = [UIColor whiteColor];
        self.confirmField.textAlignment = NSTextAlignmentLeft;
        self.confirmField.secureTextEntry = YES;
        self.confirmField.clearButtonMode = UITextFieldViewModeAlways;
    }
    
    
    return cell;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    
    [textField resignFirstResponder];
    return YES;
    
}

- (BOOL)checkField {
    
    if (self.accountNameField.text.length == 0) {
        [self.accountNameField becomeFirstResponder];
        return NO;
    }
    
    else if (self.passwordField.text.length == 0) {
        [self.passwordField becomeFirstResponder];
        return NO;
    }
    else if (self.confirmField.text.length == 0) {
        [self.confirmField becomeFirstResponder];
        return NO;
    }
    
    if (![self.confirmField.text isEqualToString:self.passwordField.text]) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title", nil)
                                     message:NSLocalizedString(@"warnning_member_password_different", nil)
                                    delegate:nil
                           cancelButtonTitle:NSLocalizedString(@"ok_btn", nil)
                           otherButtonTitles:nil] show];
        return NO;
    }
    
    NSRegularExpression *num = [NSRegularExpression regularExpressionWithPattern:@"[0-9]" options:NSRegularExpressionCaseInsensitive error:nil];
    
    NSInteger numCount = [num numberOfMatchesInString:self.passwordField.text options:NSMatchingReportProgress range:NSMakeRange(0,self.passwordField.text.length)];
    
    NSRegularExpression *tLetterRegularExpression = [NSRegularExpression regularExpressionWithPattern:@"[A-Za-z]" options:NSRegularExpressionCaseInsensitive error:nil];
    
    NSInteger letterCount = [tLetterRegularExpression numberOfMatchesInString:self.passwordField.text options:NSMatchingReportProgress range:NSMakeRange(0, self.passwordField.text.length)];
    
    
    
    if (!(numCount > 0 && letterCount > 0 && self.passwordField.text.length >= 6)) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title", nil)
                                                        message:NSLocalizedString(@"change_pwd_instruction_content", nil)
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:NSLocalizedString(@"confirm_btn", nil),nil];
        
        
        [alert show];
        return NO;
        
    }
    
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
