

#import <UIKit/UIKit.h>

@interface WMLightView : UIView
@property (strong, nonatomic)  UIView *lightBackView;
@property (strong, nonatomic)  UIImageView *centerLightIV;

@property (nonatomic, strong) NSMutableArray * lightViewArr;

+ (instancetype)sharedLightView;
@end
