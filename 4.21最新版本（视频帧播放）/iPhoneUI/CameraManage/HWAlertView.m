//
//  HWAlertView.m
//  HuaWo
//
//  Created by hwawo on 16/6/15.
//  Copyright © 2016年 HW. All rights reserved.
//

#import "HWAlertView.h"

@interface HWAlertView ()

@end

@implementation HWAlertView
- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...{
    
    if (self = [super initWithTitle:title message:message delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles, nil]) {
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:message];
        [str addAttribute:NSFontAttributeName
                    value:[UIFont systemFontOfSize:12]
                    range:NSMakeRange(0, message.length)];
        [self setValue:str.mutableString forKey:@"message"];
    }
    return self;
}
@end
