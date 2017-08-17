//
//  EditCameraViewController.m
//  HuaWo
//
//  Created by circlely on 2/23/16.
//  Copyright © 2016 circlely. All rights reserved.
//

#import "EditCameraViewController.h"
#import "MemberData.h"
#import "MBProgressHUD.h"
#import "AHCServerCommunicator.h"

#define kEditCameraCellID @"editcameracellid"
#define CELLHEIGHT 60
#define kCellText @"celltext"
#define kCellDetailText @"celldetailtext"


@interface EditCameraViewController ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) NSMutableArray *cellArr;
@property (strong, nonatomic) UITextField *accountNameField;
@property (strong, nonatomic) UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UILabel *cidLabel;
@property (weak, nonatomic) IBOutlet UILabel *cidTipsLabel;
@property (weak, nonatomic) IBOutlet UILabel *footerTipsLabel;

@end

@implementation EditCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = kBackgroundColor;
    [self setUpNav];
    
    [self setUpTableView];
    
    self.cidTipsLabel.text = NSLocalizedString(@"manual_add_cell_label", nil);
    self.cidLabel.text = self.CIDNumber;

    [self initCellArr];
}

- (void)setUpTableView{

    self.tableView.separatorColor = kBackgroundColor;
    self.tableView.backgroundColor = nil;
    self.tableView.backgroundColor = kBackgroundColor;
    
    self.headerView.backgroundColor = kBackgroundColor;
    
    self.footerView.backgroundColor = kBackgroundColor;
    self.footerTipsLabel.text = NSLocalizedString(@"manual_add_section1_instruction", nil);
    self.tableView.tableFooterView = self.footerView;
    self.tableView.tableHeaderView = self.headerView;
}

- (void)setUpNav{

    self.navigationController.navigationBar.barTintColor = kNavigation7Color;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"title_back_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonItemAction)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"save_btn", nil) style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonItemAction)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 44)];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = NSLocalizedString(@"edit_cid_controller_title", nil);
    self.navigationItem.titleView = titleLabel;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)leftBarButtonItemAction {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)rightBarButtonItemAction {
    
    if ([self checkFields]) {
        
        MBProgressHUD* HUD = [MBProgressHUD showHUDAddedTo:self.view
                                                  animated:YES
                                               configBlock:nil];
        
        __typeof(self) __block  safeMyself = self;
        void(^updateCidSucBlk)() = ^{
            
            [MBProgressHUD hideHUDForView:safeMyself.view animated:YES];
            
            
            NSDictionary* CIDInfo = @{kCIDInfoNumber:   safeMyself.CIDNumber,
                                      kCIDInfoUsername: safeMyself.accountNameField.text,
                                      kCIDInfoPassword: safeMyself.passwordField.text};
            
            [[AHCServerCommunicator sharedAHCServerCommunicator] subscribeCID:CIDInfo];
            
            if ([safeMyself.delegate respondsToSelector:@selector(onEditCIDDone)])
            {
                [safeMyself.delegate onEditCIDDone];
            }
            [safeMyself.navigationController popViewControllerAnimated:YES];
        };
        
        if ([[MemberData memberData] isMemberLogin]) {
            
            
        }
        else {
            
            [[MemberData memberData] updateOneLocalCID:self.CIDNumber UserName:self.accountNameField.text Pwd:self.passwordField.text];
            updateCidSucBlk();
        }
        
    }

    
}

- (void)initCellArr {
    
    //NSString *cameraName = [[MemberData memberData] getAvsNameOfCID:self.CIDNumber];
    //manual_add_password_cell_placeholder
    NSMutableDictionary *cameraNameDic = [NSMutableDictionary
                                          dictionaryWithDictionary:@{kCellText : NSLocalizedString(@"manual_add_username_cell_label", nil),
                                                                     kCellDetailText : NSLocalizedString(@"manual_add_username_cell_placeholder", nil)}];
    NSMutableDictionary *changeCameraPW = [NSMutableDictionary
                                           dictionaryWithDictionary:@{kCellText : NSLocalizedString(@"login_psw_textfield_placeholder", nil),
                                                                      kCellDetailText : NSLocalizedString(@"manual_add_password_cell_placeholder", nil)}];
    
    self.cellArr  = [NSMutableArray arrayWithObjects:cameraNameDic, changeCameraPW, nil];
    
    
}

#pragma mark -----TableViewDelegate-----
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.cellArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return CELLHEIGHT;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kEditCameraCellID];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kEditCameraCellID];

        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = kTableViewCellColor;
        cell.accessoryView = [[UITextField alloc] initWithFrame:CGRectMake(320-180, 1, 180, CELLHEIGHT-2)];
        cell.accessoryView.backgroundColor = kTableViewCellColor;
        cell.textColor = [UIColor whiteColor];
    }
    
    cell.textLabel.text = [[self.cellArr objectAtIndex:indexPath.row] objectForKey:kCellText];
    if (indexPath.row == 0) {
        
        self.accountNameField = cell.accessoryView;
        self.accountNameField.delegate = self;
        //self.accountNameField.placeholder = [[self.cellArr objectAtIndex:indexPath.row] objectForKey:kCellDetailText];
        self.accountNameField.text = [[MemberData memberData] getAvsNameOfCID:self.CIDNumber];
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

    
    
    
    return cell;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    
    [textField resignFirstResponder];
    return YES;
    
}

- (BOOL)checkFields {
    
    if (self.accountNameField.text.length == 0) {
        [self.accountNameField becomeFirstResponder];
        return NO;
    }
    
    else if (self.passwordField.text.length == 0) {
        [self.passwordField becomeFirstResponder];
        return NO;
    }
    
    [self.accountNameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
    
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
