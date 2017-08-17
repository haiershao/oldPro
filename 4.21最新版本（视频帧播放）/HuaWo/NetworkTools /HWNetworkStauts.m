//
//  HWNetworkStauts.m
//  HuaWo
//
//  Created by yjc on 2017/4/19.
//  Copyright © 2017年 HW. All rights reserved.
//

#import "HWNetworkStauts.h"
#import "Reachability.h"
@implementation HWNetworkStauts
+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    static HWNetworkStauts *manager;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc]init];
        [manager netWork];
    });
    return manager;
}
-(void)netWork {
    self.isNetWork = YES;
    AFNetworkReachabilityManager *netManager = [AFNetworkReachabilityManager sharedManager];
    [netManager startMonitoring];  //开始监听
    [netManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status){
        
        if (status == AFNetworkReachabilityStatusNotReachable)
        {
            self.isNetWork = NO;
            [[[UIAlertView alloc]initWithTitle:@"提示" message:@"网络链接错误，请检查网络设置" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil]show];
           
            return ;
        
        }else if(status == AFNetworkReachabilityStatusReachableViaWWAN){
            self.isNetWork = YES;
        }else if(status == AFNetworkReachabilityStatusReachableViaWiFi){
            self.isNetWork = YES;
        }
    }];
}

@end
