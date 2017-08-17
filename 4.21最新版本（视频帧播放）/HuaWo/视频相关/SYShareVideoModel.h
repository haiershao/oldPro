//
//  SYShareVideoModel.h
//  HuaWo
//
//  Created by leju_esf on 17/3/29.
//  Copyright © 2017年 HW. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYShareVideoModel : NSObject
@property (nonatomic, copy) NSString *path1;
@property (nonatomic, copy) NSString *path2;
@property (nonatomic, assign) CGFloat pointTime;
@property (nonatomic, assign) BOOL isTowVideo;
@property (nonatomic, assign) BOOL isShare;
@end
