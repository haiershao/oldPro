//
//  tabbarView.h
//  tabbarTest
//
//  Created by Kevin Lee on 13-5-6.
//  Copyright (c) 2013年 Kevin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "tabbarViewController.h"

#define K_TABBAR_TOP_HALF 26
#define K_TABBAR_BOTTOM_HALF 50
#define K_TABBAR_HEIGHT (K_TABBAR_TOP_HALF + K_TABBAR_BOTTOM_HALF)

@interface tabbarView : UIView



@property(nonatomic, assign) id<tabbarDelegate> delegate;


- (void)itemWasSelected:(int)index;

@end
