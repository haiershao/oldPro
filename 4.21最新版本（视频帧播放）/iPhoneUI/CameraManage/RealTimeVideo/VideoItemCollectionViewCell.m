//
//  VideoItemCollectionViewCell.m
//  HuaWo
//
//  Created by circlely on 1/25/16.
//  Copyright © 2016 circlely. All rights reserved.
//

#import "VideoItemCollectionViewCell.h"
#import "AlbumManager.h"
#import "SharePageViewController.h"
#import "VideoViewController.h"

@implementation VideoItemCollectionViewCell
- (void)awakeFromNib {
    
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 4;
}


- (IBAction)clickCellToSharePage {
    SharePageViewController * shareVC = [SharePageViewController sharePageViewController];
    
    shareVC.cidNum = self.cidNum;
    shareVC.videoPath = self.videoPath;
    shareVC.imagePath = self.imagePath;
    
    [[self viewController] presentViewController:shareVC animated:YES completion:nil];
}

#pragma mark - 拿VC
- (UIViewController *)viewController {
    for (UIView* next = [self superview]; next; next = next.superview) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

/**
 * 让当前控制器对应的状态栏是白色
 */
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
@end
