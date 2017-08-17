//
//  CameraSettingsConfigData.h
//  HuaWo
//
//  Created by circlely on 1/28/16.
//  Copyright © 2016 circlely. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CameraSettingsConfigData : NSObject

+ (CameraSettingsConfigData *)shareConfigData;
- (void)setConfigDataWithResponseDict:(NSDictionary *)dict;

@property (strong, nonatomic) NSDictionary *dict;

@property (assign, nonatomic) BOOL indicateorLightSwitch;
@property (assign, nonatomic) BOOL loopVideoSwitch;
@property (assign, nonatomic) BOOL parkingSwitch;
@property (assign, nonatomic) BOOL soundSwitch;
@property (assign, nonatomic) BOOL warningToneSwitch;
@property (strong, nonatomic) NSString *quality;
@property (strong, nonatomic) NSString *touchSensitivity;
@property (strong, nonatomic) NSDictionary *upGradeVersionDict;
@property (strong, nonatomic) NSString *getWifiGprsData;

@property (assign, nonatomic) BOOL atuoSynchroTimeSwitch;
@end
