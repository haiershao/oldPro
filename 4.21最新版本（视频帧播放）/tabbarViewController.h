//
//  tabbarViewController.h
//  tabbarTest
//
//  Created by Kevin Lee on 13-5-6.
//  Copyright (c) 2013年 Kevin. All rights reserved.
//

#import <UIKit/UIKit.h>

#define addHeight 88

@protocol tabbarDelegate <NSObject>

-(void)touchBtnAtIndex:(NSInteger)index;

@end

@class tabbarView;

@interface tabbarViewController : UITabBarController<tabbarDelegate>

+ (tabbarViewController *)shareTabbarController_iphone;
@end



