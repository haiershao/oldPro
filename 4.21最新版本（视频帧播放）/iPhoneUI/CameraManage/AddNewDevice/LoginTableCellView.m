//
//  LoginTableCellView.m
//  AvsViewer
//
//  Created by Chenhui on 3/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LoginTableCellView.h"
#import "NSString+Additions.h"
#import "Constants.h"

@implementation LoginTableCellView
@synthesize fieldName;
@synthesize textField;
@synthesize textTrimEnable;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        fieldName = [[UILabel alloc] initWithFrame:CGRectMake(12, 6, 170, 32)];
        fieldName.textAlignment = NSTextAlignmentLeft;
        fieldName.font = [UIFont systemFontOfSize:17.0];
        fieldName.backgroundColor = [UIColor clearColor];
        textField = [[UITextField alloc] initWithFrame:CGRectMake(100, 12, 220 ,22)];
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.borderStyle = UITextBorderStyleNone;
        textField.font = [UIFont systemFontOfSize:17.0];
        textField.textColor = kColor(75., 101., 148., 1.);
        textField.backgroundColor = [UIColor clearColor];
        textField.textAlignment = NSTextAlignmentLeft;
        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        textField.delegate = self;
        
        textTrimEnable = NO;
        
        textField.userInteractionEnabled = YES;
        fieldName.userInteractionEnabled = YES;
        self.userInteractionEnabled = YES;
        self.selectionStyle = UITableViewCellSelectionStyleBlue;
        
        [self.contentView addSubview:fieldName];
        [self.contentView addSubview:textField];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)textFieldDidEndEditing:(UITextField *)aTextField
{
    if (textTrimEnable) {
        [aTextField.text stringByTrimmingLeadingWhitespaceAndNewlineCharacters];
        [aTextField.text stringByTrimmingTrailingWhitespaceAndNewlineCharacters];
    }
}

/**
 * 让当前控制器对应的状态栏是白色
 */
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
@end
