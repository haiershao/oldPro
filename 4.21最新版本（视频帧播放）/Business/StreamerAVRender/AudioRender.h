//
//  AudioStreamer.h
//  AtHomeCam
//
//  Created by Circlely Networks on 12/4/14.
//
//

#import <Foundation/Foundation.h>
#import <Rvs_Viewer/Rvs_Viewer_API.h>


@interface AudioRender : NSObject

+ (instancetype)shareRender;

- (void)activateVoiceWithCID:(unsigned long long)cid Handle:(RVS_HANDLE)handle Play:(BOOL)isPlay Record:(BOOL)isRecord;
- (void)deactivateVoiceWithCID:(unsigned long long)cid Handle:(RVS_HANDLE)handle;

-(id)init;

-(void)start;
-(void)stop;


-(void)resumePlay:(RVS_HANDLE)handle;
-(void)pausePlay:(RVS_HANDLE)handle;


- (void)pauseRecord:(RVS_HANDLE)handle;
- (void)resumeRecord:(RVS_HANDLE)handle;

@end
