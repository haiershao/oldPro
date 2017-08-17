//
//  ChangeCameraNameViewController.m
//  HuaWo
//
//  Created by circlely on 2/23/16.
//  Copyright © 2016 circlely. All rights reserved.
//

#import "ChangeCameraNameViewController.h"
#import "MBProgressHUD.h"

#define kChangeCameraNameCellID @"changecameranamecellid"
#define CELLHEIGHT 60

@interface ChangeCameraNameViewController ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UITextField *textField;
@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UILabel *tipsLabel;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;

@end

@implementation ChangeCameraNameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.backgroundColor = kBackgroundColor;
    [self setUpNav];
    
    [self setUpTableView];

    [self setUpSaveButton];
    
}

- (void)setUpSaveButton{

    self.saveButton.layer.masksToBounds = YES;
    self.saveButton.layer.cornerRadius = 5;
    //self.saveButton.titleLabel.text = NSLocalizedString(@"save_btn", nil);
    [self.saveButton setTitle:NSLocalizedString(@"save_btn", nil) forState:UIControlStateNormal];
    self.saveButton.tintColor = [UIColor whiteColor];
}

- (void)setUpTableView{

    self.footerView.backgroundColor = kBackgroundColor;
    self.tableView.tableFooterView = self.footerView;
}

- (void)setUpNav{

    self.navigationController.navigationBar.barTintColor = kNavigation7Color;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"title_back_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonItemAction)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 44)];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = NSLocalizedString(@"setting_page_camera_name", nil);
    self.navigationItem.titleView = titleLabel;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)leftBarButtonItemAction {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}
- (IBAction)saveButtonPressed:(id)sender {
    
    if ([self.textField.text isEqualToString:@""]) {
        [self.textField becomeFirstResponder];
        return;
    }
    
    
    
    self.saveButton.enabled = NO;
    
    __typeof(self) __block safeSelf = self;
    
    MBProgressHUD* HUD = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow
                                              animated:YES
                                           configBlock:^(MBProgressHUD *HUD) {
                                               HUD.removeFromSuperViewOnHide = YES;
                                               
                                           }];

    
    

}
#pragma mark -----TableViewDelegate-----

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return CELLHEIGHT;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kChangeCameraNameCellID];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kChangeCameraNameCellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = kTableViewCellColor;
        self.textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, CELLHEIGHT)];
        [cell.contentView addSubview:self.textField];
        self.textField.backgroundColor = kTableViewCellColor;
        self.textField.placeholder = NSLocalizedString(@"ipcam_rename_controller_rename_cell_placeholder", nil);
        self.textField.text = self.cameraName;
        
        UIButton *clearButton = [[UIButton alloc] initWithFrame:CGRectMake(320-50, 10, 40, 40)];
        [clearButton setImage:[UIImage imageNamed:@"list_delete"] forState:UIControlStateNormal];
        self.textField.rightView = clearButton;
        [clearButton addTarget:self action:@selector(clearButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        
        [self.textField addTarget:self action:@selector(textFieldValueChanged:) forControlEvents:UIControlEventAllEditingEvents];
        
        self.textField.rightViewMode = UITextFieldViewModeWhileEditing;
        self.textField.textColor = [UIColor whiteColor];
        self.textField.delegate = self;
        [self.textField becomeFirstResponder];
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return YES;

}

- (void)textFieldValueChanged:(UITextField *)textField {
    
    if (self.textField.isEditing && ![self.textField.text isEqualToString:@""]) {
        self.textField.rightView.hidden = NO;
    }else{
        self.textField.rightView.hidden = YES;
    }
    
}

- (void)clearButtonPressed {
    
    self.textField.text = @"";
    self.textField.rightView.hidden = YES;
}

/**
 * 让当前控制器对应的状态栏是白色
 */
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
@end
