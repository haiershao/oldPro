//
//  AudioSessionManager.h
//  AtHomeCam
//
//  Created by Lvyi on 7/31/14.
//  Copyright (c) 2014 ichano. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol AudioSessionManagerProtocol<NSObject>

-(void)handleInterruption:(UInt32) inInterruptionState;

@end


@interface AudioSessionManager : NSObject



@property (nonatomic, assign) id<AudioSessionManagerProtocol> delegate;

+(AudioSessionManager*)defaultAudioSessionManager;

- (void)start;

- (void)stop;

//激活VOIP session
-(void)activateVoIPAudioSession;

//激活播放 session
-(void)activatePlaybackAudioSession;

//失效audio session
-(void)deactivateAudioSession;

@end
