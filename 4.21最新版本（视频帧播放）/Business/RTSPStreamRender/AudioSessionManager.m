//
//  AudioSessionManager.m
//  AtHomeCam
//
//  Created by Lvyi on 7/31/14.
//  Copyright (c) 2014 ichano. All rights reserved.
//

#import "AudioSessionManager.h"
#include <AudioToolbox/AudioToolbox.h>

static AudioSessionManager* g_AudioSessionManager = nil;

@interface AudioSessionManager()



@end




@implementation AudioSessionManager


//handleInterruption
static void MyAudioSessionInterruptionListener(void* inClientData, UInt32 inInterruptionState) {
	
	AudioSessionManager* audioManager = (__bridge AudioSessionManager*)inClientData;
	
	if(audioManager) {
		
		[audioManager handleInterruption:inInterruptionState];
		
	}
	
}

static void MyAudioSessionPropertyListenerCallback (void *                  inClientData,
                                                    AudioSessionPropertyID	inID,
                                                    UInt32                  inDataSize,
                                                    const void *            inData)
{

}


+(AudioSessionManager*)defaultAudioSessionManager {


	if (g_AudioSessionManager == nil) {
	
		g_AudioSessionManager = [[AudioSessionManager alloc] init];
	
	}
	
	
	return g_AudioSessionManager;
}


- (id)init {


	self = [super init];
	
	if (self){
	
	
	}
	
	
	return self;

}

- (void)start {
	
	//初始化session
    OSStatus err = AudioSessionInitialize (NULL,
										   NULL,
										   MyAudioSessionInterruptionListener,
										   (__bridge void *)(self));
	
	
	
	if (err) {
		
		
	}
	
	
	
    err = AudioSessionAddPropertyListener( kAudioSessionProperty_AudioRouteChange, MyAudioSessionPropertyListenerCallback, (__bridge void*)self);
	
	if (err) {
		
		
	}
	
}

- (void)stop{
	
		AudioSessionRemovePropertyListenerWithUserData( kAudioSessionProperty_AudioRouteChange, MyAudioSessionPropertyListenerCallback, (__bridge void *)(self));
	
	   AudioSessionSetActive(false);
}

-(void)activateVoIPAudioSession
{
	
	//[self deactivateAudioSession];
	
	//初始化session
    OSStatus err =  0;
	
	//配置session属性为同时支持播放和录制
    UInt32 sessionCategory = kAudioSessionCategory_PlayAndRecord;
    err = AudioSessionSetProperty (kAudioSessionProperty_AudioCategory,
								   sizeof (sessionCategory),
								   &sessionCategory);

	UInt32 mode = kAudioSessionMode_VoiceChat;
    err = AudioSessionSetProperty (kAudioSessionProperty_Mode,
								   sizeof (mode),
								   &mode
								   );
    
	
	UInt32 defaultToSpeaker = 1;
	
	err = AudioSessionSetProperty (kAudioSessionProperty_OverrideCategoryDefaultToSpeaker,
								   sizeof (defaultToSpeaker),
								   &defaultToSpeaker
								   );
	
	
	//激活session
	err = AudioSessionSetActive(true);
	
    
}


-(void)activatePlaybackAudioSession {


	//[self deactivateAudioSession];
	
	
	//初始化session
    OSStatus err =  0;
	
	//配置session属性为同时支持播放和录制
    UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
    err = AudioSessionSetProperty (kAudioSessionProperty_AudioCategory,
								   sizeof (sessionCategory),
								   &sessionCategory);
	
	//激活session
	err = AudioSessionSetActive(true);
	
	
}


-(void) deactivateAudioSession {
	
	AudioSessionSetActive(false);
	
}

- (void)handleInterruption:(UInt32) inInterruptionState {


	if(self.delegate){
	
		[self.delegate handleInterruption:inInterruptionState];
	}
}



@end
