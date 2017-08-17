//
//  HWIntegral.h
//  HuaWo
//
//  Created by hwawo on 16/7/12.
//  Copyright © 2016年 HW. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HWIntegral : NSObject
/** 积分类型 */
@property (nonatomic, copy) NSString *pointtype;
/** 积分 */
@property (nonatomic, copy) NSString *point;
/** 剩余积分 */
@property (nonatomic, copy) NSString *leftpoint;
/** 时间 */
@property (nonatomic, copy) NSString *gentime;
/** 设备ID */
@property (nonatomic, copy) NSString *video_id;
@end
