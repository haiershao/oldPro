//
//  TextView.h


#import <UIKit/UIKit.h>

@interface TextView : UITextView
@property (nonatomic, copy) NSString *placeholder;
@property (nonatomic, weak) UILabel *placeholderLabel;
@end
