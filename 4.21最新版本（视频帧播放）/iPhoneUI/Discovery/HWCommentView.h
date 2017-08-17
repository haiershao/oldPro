//
//  HWCommentView.h
//  HuaWo
//
//  Created by hwawo on 16/7/19.
//  Copyright © 2016年 HW. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HWCommentView;
@protocol HWCommentViewDelegate <NSObject>
- (void)commentView:(HWCommentView *)commentView commentText:(UITextField *)commentTextField;

@end
@interface HWCommentView : UIView
@property (weak, nonatomic) IBOutlet UITextField *commentTextField;
@property (weak, nonatomic) id<HWCommentViewDelegate>delegate;
+ (instancetype)commentView;
@end
