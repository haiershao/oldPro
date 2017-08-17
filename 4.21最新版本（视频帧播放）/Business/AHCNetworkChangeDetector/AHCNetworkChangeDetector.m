//
//  AHCNetworkChangeDetector.m
//  AtHomeCam
//
//  Created by Circlely Networks on 24/4/14.
//  Copyright (c) 2014 ichano. All rights reserved.
//

#import "AHCNetworkChangeDetector.h"
#import "Reachability.h"

#define kNetworkAlertTag    1000
#define kNetworkDisAlertTag 2000

enum T_SHOW_ALERT_STATUS {

    E_NO_ALERT = 0, //界面上没有任何alert提示框
    
    E_SHOW_NO_NETWORK_ALERT, //界面有无网络提示框
    
    E_SHOW_RECONNECT_ALERT   //界面上有重连网络提示框

};


@interface AHCNetworkChangeDetector () <UIAlertViewDelegate>
{
    enum T_SHOW_ALERT_STATUS alertStatus;
}

@property (nonatomic, strong) UIAlertView* showAlert;
@property (nonatomic, strong) Reachability* curReachability;

@end

@implementation AHCNetworkChangeDetector

+ (AHCNetworkChangeDetector *)sharedNetworkChangeDetector {
    static AHCNetworkChangeDetector *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[AHCNetworkChangeDetector alloc] init];
    });
    return shared;
}

-(id)init
{
    self = [super init];
    
    if  (self)
    {
        Reachability *reachability = [Reachability reachabilityForInternetConnection];
        [reachability startNotifier];
        [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
        
        self.curReachability = reachability;

        alertStatus = E_NO_ALERT;
    }
    
    return self;
}

- (void) reachabilityChanged: (NSNotification* )note
{
    if (self.delegate == nil)
        return;
            
    BOOL isReachable = NO;
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    NetworkStatus netStatus = [curReach currentReachabilityStatus];
    switch (netStatus){
        case ReachableViaWWAN:
        {
            isReachable = YES;
            break;
        }
        case ReachableViaWiFi:
        {
            isReachable = YES;
            break;
        }
        case NotReachable:
        {
            isReachable = NO;
            break;
        }
    }
	
    
	//监测到有网络了
    if (isReachable)
    {
        switch (alertStatus) {
				
            case E_SHOW_NO_NETWORK_ALERT: {
				//把之前的无网络提示取消掉
				[self.showAlert dismissWithClickedButtonIndex:-1 animated:NO];
				
            }
			//这里没有break，直接穿过
			
            case E_NO_ALERT:{
				//弹出重连网络提示框
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title", nil)
																message:NSLocalizedString(@"network_changed", nil)
															   delegate:self
													  cancelButtonTitle:nil
													  otherButtonTitles:NSLocalizedString(@"ok_btn", nil),nil];
				alert.tag = kNetworkAlertTag;
				[alert show];
				
				self.showAlert = alert;

				
				alertStatus = E_SHOW_RECONNECT_ALERT;
            
            }
                break;
                

            default:{
            
            }
                break;
        }
    }
    else {
        
        switch (alertStatus) {
				
            case E_SHOW_RECONNECT_ALERT: {
                
				//把之前的重连网络提示取消掉
				[self.showAlert dismissWithClickedButtonIndex:-1 animated:NO];
            }
			//这里没有break，直接穿过
				
            case E_NO_ALERT:{
				
				//弹出无网络的提示框
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title", nil)
																message:NSLocalizedString(@"network_disconnect", nil)
															   delegate:self
													  cancelButtonTitle:nil
													  otherButtonTitles:NSLocalizedString(@"ok_btn", nil), nil];
				alert.tag = kNetworkDisAlertTag;
				[alert show];
				self.showAlert = alert;
				
				alertStatus = E_SHOW_NO_NETWORK_ALERT;
                
            }
                break;
                

                
            default:{
                
            }
                break;
        }

    }
    
    if ([self.delegate respondsToSelector:@selector(notifyNetworkChange:)]) {
    
        [self.delegate notifyNetworkChange:self];
    }

}



- (BOOL)isNetworkConnected {

    return ([self.curReachability currentReachabilityStatus] != NotReachable);
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kNetworkAlertTag) {
        if (buttonIndex == 0){
            if ([self.delegate respondsToSelector:@selector(onNeedReconnect)]) {
                [self.delegate onNeedReconnect];
               // [[Reachability reachabilityForInternetConnection] startNotifier];
            }
        }
    }
    
	alertStatus = E_NO_ALERT;
}

@end
