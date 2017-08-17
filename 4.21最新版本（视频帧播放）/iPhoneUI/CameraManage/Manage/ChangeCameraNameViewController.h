//
//  ChangeCameraNameViewController.h
//  HuaWo
//
//  Created by circlely on 2/23/16.
//  Copyright © 2016 circlely. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ChangeCameraNameDelegate <NSObject>

- (void)changeNameSucc:(NSString *)rename;

@end


@interface ChangeCameraNameViewController : UIViewController
@property (strong, nonatomic) NSString *cameraName;
@property (strong, nonatomic) NSString *CIDNumber;
@property (assign, nonatomic) id<ChangeCameraNameDelegate> delegate;
@end
