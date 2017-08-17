//
//  CameraSettingsConfigData.m
//  HuaWo
//
//  Created by circlely on 1/28/16.
//  Copyright © 2016 circlely. All rights reserved.
//

#import "CameraSettingsConfigData.h"

@implementation CameraSettingsConfigData

+ (CameraSettingsConfigData *)shareConfigData {
    
    static CameraSettingsConfigData *configData = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        configData = [[CameraSettingsConfigData alloc] init];
        
    });
    
    return configData;
}

- (void)setConfigDataWithResponseDict:(NSDictionary *)dict {
    
    self.indicateorLightSwitch = [[dict objectForKey:@"indicateorLight"] isEqualToString:@"on"];
    self.loopVideoSwitch = [[dict objectForKey:@"loopVideo"] isEqualToString:@"on"];
    self.parkingSwitch = [[dict objectForKey:@"parking"] isEqualToString:@"on"];
    self.soundSwitch = [[dict objectForKey:@"sound"] isEqualToString:@"on"];
    self.warningToneSwitch = [[dict objectForKey:@"warningTone"] isEqualToString:@"on"];
    self.quality = [dict objectForKey:@"quality"];
    self.touchSensitivity = [[dict objectForKey:@"touchSensitivity"] uppercaseString];
    
    self.atuoSynchroTimeSwitch = [[dict objectForKey:@""] isEqualToString:@"on"];
    self.upGradeVersionDict = dict;
    self.getWifiGprsData = dict[@"wifiGprsData"];
}


@end
