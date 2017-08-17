//
//  EditCameraViewController.h
//  HuaWo
//
//  Created by circlely on 2/23/16.
//  Copyright © 2016 circlely. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol EditViewControllerDelegate <NSObject>

@optional
-(void)onEditCIDDone;

@end
@interface EditCameraViewController : UIViewController

@property (strong, nonatomic) NSString *CIDNumber;
@property (assign, nonatomic) id<EditViewControllerDelegate> delegate;
@end
