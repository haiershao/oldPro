//
//  HWTachographFlowStatisticsController.h
//  HuaWo
//
//  Created by hwawo on 16/5/13.
//  Copyright © 2016年 HW. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HWTachographFlowStatisticsController : UIViewController
@property (strong, nonatomic) NSString *cidNumber;
//wifiGprsData
@property (strong, nonatomic) NSString *getWifiGprsData;
+ (instancetype)tachographFlowStatisticsController;
@end
