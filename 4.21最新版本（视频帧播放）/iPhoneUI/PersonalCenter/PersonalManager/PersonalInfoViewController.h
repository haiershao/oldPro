//
//  PersonalInfoViewController.h
//  HuaWo
//
//  Created by circlely on 1/26/16.
//  Copyright © 2016 circlely. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PersonalInfoViewController;
@protocol PersonalInfoViewControllerDelegate <NSObject>
@optional
- (void)resetIconImage;
- (void)loadLocalIconImage;
@end
@interface PersonalInfoViewController : UIViewController

- (void)loadIconImage;
@property (weak, nonatomic) id<PersonalInfoViewControllerDelegate> delegate;
- (UIImage *)downLoadIconImage;
@end
