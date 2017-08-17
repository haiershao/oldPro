//
//  TouchSensitivityViewController.h
//  HuaWo
//
//  Created by circlely on 1/30/16.
//  Copyright © 2016 circlely. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol cameraTouchSensitivitySetDelegate <NSObject>

- (void)cameraSettingSuccessed;

@end

@interface TouchSensitivityViewController : UIViewController

@property (assign, nonatomic) id<cameraTouchSensitivitySetDelegate> delegate;
@property (strong, nonatomic) NSString *cidNumber;

@end
