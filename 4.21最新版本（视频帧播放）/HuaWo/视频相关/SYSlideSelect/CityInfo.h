//
//  cityInfo.h
//  聚合
//
//  Created by 刘海 on 16/3/9.
//  Copyright © 2016年 刘海. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CityInfo : NSObject
@property (nonatomic, strong) NSString *City;
@property (nonatomic, strong) NSString *Country;
@property (nonatomic, strong) NSString *CountryCode;
@property (nonatomic, strong) NSArray *FormattedAddressLines;
@property (nonatomic, strong) NSString *Name;
@property (nonatomic, strong) NSString *State;
@property (nonatomic, strong) NSString *Street;
@property (nonatomic, strong) NSString *SubLocality;
@property (nonatomic, strong) NSString *SubThoroughfare;
@property (nonatomic, strong) NSString *Thoroughfare;

//- (instancetype)initWithDict:(NSDictionary *)dict;
+ (instancetype)CityUser;
+ (instancetype)cityInfoDict:(NSDictionary *)dict;
@end
