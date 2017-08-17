//
//  MapAnnotation.h
//  聚合
//
//  Created by 刘海 on 16/3/21.
//  Copyright © 2016年 刘海. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
@interface MapAnnotation : NSObject
@property (nonatomic) CLLocationCoordinate2D coordinate;

@property (nonatomic, copy) NSString *title;
/** 图片名 */
@property (nonatomic, copy) NSString *icon;
@end
