//
//  HWBindUserInfoView.h
//  HuaWo
//
//  Created by hwawo on 16/6/13.
//  Copyright © 2016年 HW. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HWBindUserInfoView;
@protocol HWBindUserInfoViewDelegate <NSObject>
- (void)bindUserInfoView:(HWBindUserInfoView*)bindUserInfoView IDCardText:(NSString *)IDCardText realNameText:(NSString *)realNameText phoneNumText:(NSString *)phoneNumText plateNumText:(NSString *)plateNumText emailText:(NSString *)emailText zhifuAccountText:(NSString *)zhifuAccountText;

@end

@interface HWBindUserInfoView : UIView
@property (weak, nonatomic) IBOutlet UIView *popBindView;
@property (weak, nonatomic) IBOutlet UITextField *identityCardTextField;
@property (weak, nonatomic) IBOutlet UITextField *userRealNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumTextField;
@property (weak, nonatomic) IBOutlet UITextField *plateNumberTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailAddressTextField;
@property (weak, nonatomic) IBOutlet UITextField *zhifubaoAccount;

@property (weak, nonatomic) id<HWBindUserInfoViewDelegate>delegate;
+ (instancetype)bindUserInfoView;
@end
