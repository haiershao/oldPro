//
//  ChangeNickNameViewController.h
//  HuaWo
//
//  Created by circlely on 2/24/16.
//  Copyright © 2016 circlely. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol changeNickNameDelegate <NSObject>

- (void)updateNickNameDone;

@end


@interface ChangeNickNameViewController : UIViewController
@property (strong, nonatomic) NSString *nickName;
@property (assign, nonatomic) id<changeNickNameDelegate> delegate;
@end
