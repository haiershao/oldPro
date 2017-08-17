//
//  HWUserLocation.h
//  HuaWo
//
//  Created by yjc on 2017/4/4.
//  Copyright © 2017年 HW. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HWUserLocation : NSObject
@property (nonatomic,assign)double latitudes;
@property (nonatomic,assign)double longitudes;
+ (instancetype)locationWithlati:(double)lati longi:(double)longi;
@end
