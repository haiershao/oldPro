//
//  LoginTableCellView.h
//  AvsViewer
//
//  Created by Chenhui on 3/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//  登录界面的Cell自定义

#import <UIKit/UIKit.h>

#define LoginTableCellViewReuseIdentifier @"LoginTableCellView"

@interface LoginTableCellView : UITableViewCell<UITextFieldDelegate>

@property (nonatomic, readonly) UILabel* fieldName;
@property (nonatomic, readonly) UITextField* textField;
@property (nonatomic) BOOL textTrimEnable;

@end
