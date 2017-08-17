//
//  ManualAddViewController.m
//  HuaWo
//
//  Created by circlely on 1/21/16.
//  Copyright © 2016 circlely. All rights reserved.
//

#import "ManualAddViewController.h"
#import "LoginTableCellView.h"

#import "MBProgressHUD.h"
#import "AHCServerCommunicator.h"


#define CID_TEXT_FIELD_TAG        113
#define USERNAME_TEXT_FIELD_TAG   114
#define PSW_TEXT_FIELD_TAG        115

@interface ManualAddViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *footVIew;
@property (weak, nonatomic) IBOutlet UILabel *footerTipsLabel;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (nonatomic, strong) NSString* CIDNumber;
@property (nonatomic, strong) NSString* username;
@property (nonatomic, strong) NSString* password;

@end

@implementation ManualAddViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = self.footVIew;
    self.footerTipsLabel.text = NSLocalizedString(@"manual_add_section1_instruction", nil);
    self.view.backgroundColor = kBackgroundColor;
    self.navigationController.navigationBar.barTintColor = kNavigation7Color;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"title_back_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonItemAction)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 44)];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = NSLocalizedString(@"manual_add_cid_controller_title", nil);
    self.navigationItem.titleView = titleLabel;
    
    self.tableView.separatorColor = kBackgroundColor;
    self.tableView.backgroundColor = nil;
    self.tableView.backgroundColor = kBackgroundColor;
    
    self.footVIew.backgroundColor = kBackgroundColor;
    
    self.saveButton.layer.masksToBounds = YES;
    self.saveButton.layer.cornerRadius = 5;
    [self.saveButton setTitle:NSLocalizedString(@"connect_recorder_title", nil) forState:UIControlStateNormal];
    self.saveButton.tintColor = [UIColor whiteColor];
    

    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)])
    {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)])
    {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)saveButtonPressed:(id)sender {
    
    [self onSaveBtnPressed];
}

- (void)leftBarButtonItemAction {
    
    [self.navigationController popViewControllerAnimated:YES];
    
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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

        self.CIDNumber = nil;
        self.username  = nil;
        self.password  = nil;
    }
    return self;
}




-(void)onSaveBtnPressed
{
    
    if ([self checkFields]) {
        
        MBProgressHUD* HUD = [MBProgressHUD showHUDAddedTo:self.view
                                                  animated:YES
                                               configBlock:nil];
        
        
        __typeof(self) __weak  safeMyself = self;
        
        void(^addCidSucBlk)() = ^{
            
            
            //[MBProgressHUD hideHUDForView:safeMyself.view animated:YES];

            if (/* DISABLES CODE */ (0)) {//self.isCidListController
                
                [safeMyself dismissViewControllerAnimated:YES completion:nil];
                
            }else{
                //[safeMyself dismissViewControllerAnimated:YES completion:nil];
                [safeMyself.navigationController popToRootViewControllerAnimated:YES];
                
            }
            
            NSDictionary* CIDInfo = @{kCIDInfoNumber:   [safeMyself CIDFromTextField],
                                      kCIDInfoUsername: [safeMyself usernameFromTextField],
                                      kCIDInfoPassword: [safeMyself passwordFromTextField]};
            
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateCameraList object:nil];
            
            
            [[AHCServerCommunicator sharedAHCServerCommunicator] subscribeCID:CIDInfo];
            
            
            
            
            
            HUD.detailsLabelText =  NSLocalizedString(@"warning_cid_add_success", nil);
            HUD.labelFont = CG_BOLD_FONT(15);
            HUD.mode = MBProgressHUDModeCustomView;
            HUD.removeFromSuperViewOnHide = YES;
            HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CheckMark.png"]];
            [HUD hide:YES afterDelay:1.0];
            
            
            
        };
        
        
    }
}

- (BOOL) checkFields
{
    LoginTableCellView* cell1 = (LoginTableCellView*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    LoginTableCellView* cell2 = (LoginTableCellView*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    LoginTableCellView* cell3 = (LoginTableCellView*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    
    if ([cell1.textField.text length] == 0) {
        [cell1.textField becomeFirstResponder];
        return NO;
    }
    else if([cell2.textField.text length] == 0)
    {
        [cell2.textField becomeFirstResponder];
        return NO;
    }
    else if([cell3.textField.text length] == 0)
    {
        [cell3.textField becomeFirstResponder];
        return NO;
    }
    
    [cell1.textField resignFirstResponder];
    [cell2.textField resignFirstResponder];
    [cell3.textField resignFirstResponder];
    
    return YES;
}

-(NSString*)CIDFromTextField
{
    LoginTableCellView* cell = (LoginTableCellView*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    return cell.textField.text;
}

-(NSString*)usernameFromTextField
{
    LoginTableCellView* cell = (LoginTableCellView*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    
    return cell.textField.text;
}

-(NSString*)passwordFromTextField
{
    LoginTableCellView* cell = (LoginTableCellView*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    
    return cell.textField.text;
}



- (void)applicationDidEnterBackground {
    
    //程序进入后台時，將彈出的界面dismiss掉
    [self.navigationController dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark ---- TableViewDelegate -----

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)])
    {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)])
    {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    if (section == 0) {
        return 35.f;
    }
    
    return 0.0001f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 3;
    }
    
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LoginTableCellView *cell = [tableView dequeueReusableCellWithIdentifier:LoginTableCellViewReuseIdentifier];
    if (cell == nil) {
        cell = [[LoginTableCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LoginTableCellViewReuseIdentifier ];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    //cell.backgroundColor = kTableViewCellColor;
    cell.contentView.backgroundColor = kTableViewCellColor;
    [cell.fieldName setFrame:CGRectMake(320-180, 1, 180, 44-2)];
    if (indexPath.section == 0) {
        [cell.textField setHidden:NO];
        cell.textField.delegate        = self;
        cell.textField.textColor = [UIColor whiteColor];
        
        if (indexPath.row == 0) {
            cell.textLabel.text = NSLocalizedString(@"manual_add_cell_label", nil);
            cell.textLabel.textColor = [UIColor whiteColor];
            //cell.textField.placeholder = NSLocalizedString(@"manual_add_cid_cell_placeholder", nil);
            cell.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"manual_add_cid_cell_placeholder", nil) attributes:@{NSForegroundColorAttributeName : [UIColor grayColor]}];
            cell.textField.secureTextEntry = NO;
            
            cell.textField.keyboardType    = UIKeyboardTypeNumberPad;
            cell.textField.tag             = CID_TEXT_FIELD_TAG;
            cell.textField.text            = self.CIDNumber;
            cell.textField.delegate = self;
            if([self.CIDNumber length] == 0){
                cell.textField.enabled = YES;
            }else {
                cell.textField.enabled = NO;
            }
            
            //cell.imageView.image = [UIImage imageNamed:@"edit_cid_cid_phone"];
            
            
            
        }
        else if (indexPath.row == 1)
        {
            cell.textLabel.text            = NSLocalizedString(@"manual_add_username_cell_label", nil);
            cell.textLabel.textColor = [UIColor whiteColor];
            //cell.textField.placeholder     = NSLocalizedString(@"manual_add_username_cell_placeholder", nil);
            //cell.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"manual_add_username_cell_placeholder", nil) attributes:@{NSForegroundColorAttributeName : [UIColor grayColor]}];
            cell.textField.secureTextEntry = NO;
            cell.textField.tag             = USERNAME_TEXT_FIELD_TAG;
            cell.textField.text            = self.username;
            cell.textField.keyboardType    = UIKeyboardTypeDefault;
            cell.textField.delegate = self;
            //cell.imageView.image = [UIImage imageNamed:@"user_image_pad"];
            
        }
        else if (indexPath.row == 2)
        {
            cell.textLabel.text            = NSLocalizedString(@"login_psw_textfield_placeholder", nil);
            cell.textLabel.textColor = [UIColor whiteColor];
            //cell.textField.placeholder     = NSLocalizedString(@"manual_add_password_cell_placeholder", nil);
            //cell.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"manual_add_password_cell_placeholder", nil) attributes:@{NSForegroundColorAttributeName : [UIColor grayColor]}];
            cell.textField.secureTextEntry = YES;
            cell.textField.tag             = PSW_TEXT_FIELD_TAG;
            cell.textField.text            = self.password;
            cell.textField.delegate = self;
            //cell.imageView.image = [UIImage imageNamed:@"pswd_image_pad"];
            
        }
        
        cell.textField.delegate = self;
        cell.textField.returnKeyType = UIReturnKeyDone;
        cell.textField.delegate = self;
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
//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    NSString *str = @"";
//    if (section == 0){
//        str = [NSString stringWithString:NSLocalizedString(@"manual_add_section1_instruction", nil)];
//    }else if (section == 1) {
//        str = [NSString stringWithString:NSLocalizedString(@"mannul_add_section2_instruction", nil)];
//    }
//    CGSize labelSize = [str sizeWithFont:CG_FONT(12) constrainedToSize:CGSizeMake(280.0, MAXFLOAT)];
//    return labelSize.height+17.0 + (section == 1 ? 0 : 0);
//}

//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
//{
//    UIView* container = [[UIView alloc] init];
//    
//    [container setBackgroundColor:[UIColor clearColor]];
//    UILabel* footer = [[UILabel alloc] init];
//    footer.font = CG_FONT(12);
//    footer.textColor = kFooterColor;
//    footer.textAlignment = NSTextAlignmentCenter;
//    footer.lineBreakMode = NSLineBreakByWordWrapping;
//    footer.backgroundColor = [UIColor clearColor];
//    
//    [container addSubview:footer];
//    
//    if (section == 0) {
//        
//        NSString *str = [NSString stringWithString:NSLocalizedString(@"manual_add_section1_instruction", nil)];
//        CGSize labelHeight = [str sizeWithFont:CG_FONT(12)];
//        CGSize labelSize = [str sizeWithFont:CG_FONT(12) constrainedToSize:CGSizeMake(280.0, MAXFLOAT)];
//        
//        footer.numberOfLines = ceil(labelSize.height/labelHeight.height);
//        footer.text = str;
//        [footer setFrame:CGRectMake(20, 0, 280, labelSize.height+27.0)];
//    }
//    
//    return container;
//}

@end

