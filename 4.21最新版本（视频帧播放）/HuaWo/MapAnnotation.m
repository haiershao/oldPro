//
//  MapAnnotation.m
//  聚合
//
//  Created by 刘海 on 16/3/21.
//  Copyright © 2016年 刘海. All rights reserved.
//

#import "MapAnnotation.h"

@implementation MapAnnotation
- (BOOL)isEqual:(MapAnnotation *)other
{
    return [self.title isEqual:other.title];
}
@end
