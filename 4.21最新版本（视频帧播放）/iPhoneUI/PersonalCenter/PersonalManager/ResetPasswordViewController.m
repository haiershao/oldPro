//
//  ResetPasswordViewController.m
//  HuaWo
//
//  Created by circlely on 2/23/16.
//  Copyright © 2016 circlely. All rights reserved.
//

#import "ResetPasswordViewController.h"
#import "MBProgressHUD.h"
#import "NSString+Helper.h"


@interface ResetPasswordViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UILabel *MailLabel;
@property (weak, nonatomic) IBOutlet UIButton *confrimButton;
@property (weak, nonatomic) IBOutlet UIView *customBackView;

@end

@implementation ResetPasswordViewController
{
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.customBackView.backgroundColor = kTableViewCellColor;
    
    [self setUpNav];
    
    [self setUpConfrimButton];
    
}

- (void)createTextField{

    self.textField.backgroundColor = kTableViewCellColor;
    self.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"login_email_textfield_placeholder", nil) attributes:@{NSForegroundColorAttributeName : [UIColor grayColor]}];
    self.textField.textColor = [UIColor whiteColor];
    self.textField.textAlignment = NSTextAlignmentLeft;
    self.textField.delegate = self;
    
    self.MailLabel.backgroundColor = kTableViewCellColor;
    self.MailLabel.textColor = [UIColor whiteColor];
}

- (void)setUpConfrimButton{

    self.confrimButton.layer.masksToBounds = YES;
    self.confrimButton.layer.cornerRadius = 5;
    [self.confrimButton setTitle:NSLocalizedString(@"forget_resetpsw_btn", nil) forState:UIControlStateNormal];
}

- (void)setUpNav{

    self.view.backgroundColor = kBackgroundColor;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"title_back_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonItemAction)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 44)];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = NSLocalizedString(@"forget_title", nil);
    self.navigationItem.titleView = titleLabel;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)leftBarButtonItemAction {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}


- (IBAction)confirmButtonPressed:(id)sender {
    
    [self.textField resignFirstResponder];
    
    if (![NSString validateEmail:self.textField.text]) {
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES configBlock:^(MBProgressHUD *HUD) {
            
            HUD.removeFromSuperViewOnHide = YES;
            HUD.detailsLabelText = NSLocalizedString(@"warnning_email_address_validation", nil);
            HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"warning.png"]];
            [HUD hide:YES afterDelay:2];
            
        }];
        
        return;
        
    }
    
    //去除前后空格
    NSString* account = [self.textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    
    __typeof(self) __block safeSelf = self;
    
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES configBlock:^(MBProgressHUD *HUD) {
        
        HUD.removeFromSuperViewOnHide = YES;
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.customView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];

    }];

    
    

    
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
