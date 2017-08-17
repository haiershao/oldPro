//
//  HWBandInfoController.m
//  HuaWo
//
//  Created by yjc on 2017/3/31.
//  Copyright © 2017年 HW. All rights reserved.
//

#import "HWBandInfoController.h"
#import "HWUserInstanceInfo.h"
#import "Reachability.h"
#import "MBProgressHUD+MG.h"
#import "HWNetworkStauts.h"
#define MAXLenth 20
@interface HWBandInfoController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITextField *telnumber;
@property (weak, nonatomic) IBOutlet UITextField *accentID;
@property (weak, nonatomic) IBOutlet UITextField *carNumber;
@property (weak, nonatomic) IBOutlet UIButton *bandNum;
@property (strong, nonatomic) UIAlertView *alertWiFi;
@end

@implementation HWBandInfoController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
      [self.carNumber resignFirstResponder];
}
- (IBAction)bandNum:(UIButton *)sender {
    
    if (![HWNetworkStauts sharedManager].isNetWork) {
        [MBProgressHUD showError:@"请检查网络设置"];
        return ;
    }

    [self bandUserInfo];
}

- (void)bandUserInfo {
    [self.view resignFirstResponder];
    HWUserInstanceInfo *InstanceInfo = [HWUserInstanceInfo shareUser];
    NSDictionary *dict = @{
                           @"did":@"",
                           @"idno":self.accentID.text,
                           @"name":self.name.text,
                           @"phonenumber":self.telnumber.text,
                           @"licenseno":self.carNumber.text
                           };
    
    APIRequest *request = [[APIRequest alloc] initWithApiPath:@"/ControlCenter/v3/restapi/doaction" method:APIRequestMethodPost];
    request.urlQueryParameters = @{
                                   @"action":@"bind_devuser",
                                   @"para":dict,
                                   @"token":InstanceInfo.token
                                   };
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title", nil) message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    
        if (!(self.accentID.text.length == 18)) {
            alertView.message = @"请输入合法的身份证号";
            [alertView show];
            return;
        }else if (!(self.telnumber.text.length == 11)){
            alertView.message = @"请输入正确的手机号";
            [alertView show];
            return;
        }else if(!(self.carNumber.text.length == 7)){
            alertView.message = @"请输入正确的车牌号";
            [alertView show];
            return;
        }

    NSLog(@"request---%@",request);
    [[APIRequestOperationManager sharedRequestOperationManager] requestAPI:request completion:^(id result, NSError *error) {
        if ([result[@"data"] isEqual:@"success"]) {
            
            [self dismissViewControllerAnimated:YES completion:nil];
            [DZNotificationCenter postNotificationName:@"GORECORDVIDEOUI" object:nil];
            HWLog(@"账号绑定成功");
        }
        
       
    }];

}
- (IBAction)backinfo:(UIButton *)sender {
    UIViewController *vc = self;
    while (vc.presentingViewController) {
        vc = vc.presentingViewController;
    }
    [vc dismissViewControllerAnimated:YES completion:nil];
    //[self dismissViewControllerAnimated:YES completion:nil];
}
@end
