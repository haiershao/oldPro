//
//  AHCNetworkChangeDetector.h
//  AtHomeCam
//
//  Created by Circlely Networks on 24/4/14.
//  Copyright (c) 2014 ichano. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AHCNetworkChangeDetector;

@protocol AHCNetworkChangeDetectorDelegate <NSObject>

@optional
-(void) onNeedReconnect;

- (void)notifyNetworkChange:(AHCNetworkChangeDetector*) detector;

@end

@interface AHCNetworkChangeDetector : NSObject

@property (nonatomic, assign) id<AHCNetworkChangeDetectorDelegate> delegate;

+ (AHCNetworkChangeDetector *)sharedNetworkChangeDetector;

- (BOOL)isNetworkConnected;

@end
