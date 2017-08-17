//
//  HWTextAlertView.h
//  HuaWo
//
//  Created by hwawo on 16/5/5.
//  Copyright © 2016年 circlely. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HWTextAlertView : UIView
+ (instancetype)textAlertView;
@property (strong, nonatomic) void(^getDetermine)(int selectIndex);
@property (weak, nonatomic) IBOutlet UIView *commentTextField;

@property (weak, nonatomic) UITextView *textview;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;

@property (weak, nonatomic) IBOutlet UIButton *composeBtn;
@property (weak, nonatomic) IBOutlet UIButton *alertViewBtn;

- (void)showTextAlertView;
- (void)closeTextAlertView;
@end
