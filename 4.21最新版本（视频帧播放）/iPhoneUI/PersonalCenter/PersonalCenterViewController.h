//
//  PersonalCenterViewController.h
//  HuaWo
//
//  Created by circlely on 1/20/16.
//  Copyright © 2016 circlely. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PersonalCenterViewController;
@protocol PersonalCenterViewControllerDelegate <NSObject>
@optional
- (void)loadLocalIconImage;
@end
@interface PersonalCenterViewController : UIViewController
@property (weak, nonatomic) id<PersonalCenterViewControllerDelegate> delegate;
@end
