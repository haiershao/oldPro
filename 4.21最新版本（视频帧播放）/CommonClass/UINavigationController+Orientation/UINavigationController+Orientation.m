//
//  UINavigationController+Orientation.m
//  AtHomeCam
//
//  Created by ker on 10/16/12.
//
//

#import "UINavigationController+Orientation.h"
//#import "FullViewController.h"
@implementation UINavigationController (Orientation)

- (BOOL)shouldAutorotate
{
    id currentViewController = self.topViewController;
    if ([currentViewController isKindOfClass:[FullViewController class]]){
    
        return NO;
    }else{
    
        return self.topViewController.shouldAutorotate;
    }
}

- (NSUInteger)supportedInterfaceOrientations
{
    return self.topViewController.supportedInterfaceOrientations;
}

@end
