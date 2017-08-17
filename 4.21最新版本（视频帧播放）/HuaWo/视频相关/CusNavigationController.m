//
//  CusNavigationController.m
//  HuaWo
//
//  Created by yjc on 2017/3/18.
//  Copyright © 2017年 HW. All rights reserved.
//

#import "CusNavigationController.h"

@interface CusNavigationController ()

@end

@implementation CusNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(BOOL)shouldAutorotate{
         return [self.topViewController shouldAutorotate];
     }


- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
         return [self.topViewController supportedInterfaceOrientations];
    }
@end
