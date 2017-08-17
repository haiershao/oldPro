//
//  HWNetworkStauts.h
//  HuaWo
//
//  Created by yjc on 2017/4/19.
//  Copyright © 2017年 HW. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HWNetworkStauts : NSObject
@property(nonatomic ,assign)BOOL isNetWork;
+ (instancetype)sharedManager;

@end
