//
//  AudioRender.m
//  AtHomeCam
//
//  Created by Circlely Networks on 12/4/14.
//
//

#import "AudioRender.h"
#include <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import "AudioSessionManager.h"



#define KOutbus 0
#define KInputbus 1

#define K_PCM_BUF_MAX_LENGTH 100*1024

#define kRedudantHeaderOfAAC  7
short ulaw2linear(unsigned char	u_val);
unsigned char linear2ulaw(short pcm_val);
short alaw2linear(	unsigned char	a_val);


typedef enum
{
	AS_INITIALIZED = 0,
	
	AS_RUNNING,
	
	AS_STOPPED
	
} AudioState;


@interface AudioRender () <AudioSessionManagerProtocol>
{
	
	AudioComponentInstance audioUnit;
	AudioStreamBasicDescription streamDescriptionFromRtsp;
	AudioStreamBasicDescription outputStreamDescription;
	AudioStreamBasicDescription inputStreamDescription;
	
	AudioConverterRef audioConverter;

	
	AudioBuffer outPCMBuf; //当aac转pcm时使用
	UInt32 maxOutputPacketSize;
	void* decodeBuffer;
	UInt32 bytesToDecode;
	AudioStreamPacketDescription outputPacketDesc[1];
	
	unsigned char pcmBuf[K_PCM_BUF_MAX_LENGTH];
	int avaliabPCMData;
	BOOL isUsePCMBuf;
	
    
    short* convertG711toPCMBuf;
    int convertG711toPCMBufLen;
    
	
	//播放声音队列
    dispatch_queue_t             dispatchQueue;

	AudioState audioStatus;
	
	BOOL isPlaying;
	BOOL isRecording;
    
    RVS_HANDLE _reveseAudioHandler;
}

@property (nonatomic, retain) RvsMediaAVDesc* MediaDesc;
@property (nonatomic, assign) RVS_HANDLE handle;
@property (nonatomic, assign) unsigned long long cid;


@end

static AudioRender* g_audioRender = nil;

@implementation AudioRender


+ (instancetype)shareRender {

    
    if (g_audioRender == nil) {
    
        g_audioRender = [[AudioRender alloc] init];
    
    }
    

    return g_audioRender;
}


static void slienceAudio(AudioBuffer buffer) {
	
	memset(buffer.mData, 0, buffer.mDataByteSize);
	
}


static OSStatus decodeProc(AudioConverterRef inAudioConverter,
						   UInt32* ioNumberDataPackets ,
						   AudioBufferList* ioData ,
						   AudioStreamPacketDescription** outDataPacketDescription ,
						   void* inUserData)

{
	OSStatus status = noErr ;
	AudioRender* audiostream = (__bridge AudioRender*)inUserData;
	
	
	if (audiostream->bytesToDecode == 0) {
		
		return 1;
	}
		
	if (*ioNumberDataPackets > 1) {
	
		*ioNumberDataPackets = 1;
	}
	

	ioData->mBuffers[0].mData = audiostream->decodeBuffer;
	ioData->mBuffers[0].mDataByteSize = audiostream->bytesToDecode;
	ioData->mBuffers[0].mNumberChannels = audiostream->streamDescriptionFromRtsp.mChannelsPerFrame;
	
	
	if (outDataPacketDescription) {
	
		audiostream->outputPacketDesc[0].mStartOffset = 0;
		audiostream->outputPacketDesc[0].mVariableFramesInPacket = 0;
		audiostream->outputPacketDesc[0].mDataByteSize = audiostream->bytesToDecode;
		
		*outDataPacketDescription = audiostream->outputPacketDesc;
	
	}

	
	audiostream->bytesToDecode = 0;
	return noErr ;
}

static void copyDataFromPCMBuftoAudioBuffer(AudioRender* audiostream, AudioBuffer buffer){

	//如果pcm缓冲中的数据仍然比mBuffers[i].mDataByteSize大
	if(audiostream->avaliabPCMData >= buffer.mDataByteSize) {
		
		memcpy(buffer.mData, audiostream->pcmBuf, buffer.mDataByteSize);
		memcpy(audiostream->pcmBuf, audiostream->pcmBuf + buffer.mDataByteSize, audiostream->avaliabPCMData - buffer.mDataByteSize);
		audiostream->avaliabPCMData -= buffer.mDataByteSize;
	}
	else {
		
		memcpy(buffer.mData, audiostream->pcmBuf, audiostream->avaliabPCMData);
		memset((char*)buffer.mData + audiostream->avaliabPCMData, 0, buffer.mDataByteSize - audiostream->avaliabPCMData);
		audiostream->avaliabPCMData = 0;
		
	}
	
}

static OSStatus renderCallback(void *userData,
							   AudioUnitRenderActionFlags *actionFlags,
							   const AudioTimeStamp *audioTimeStamp,
							   UInt32 busNumber,
							   UInt32 numFrames, AudioBufferList *buffers) {
	

	AudioRender* audiostream = (__bridge AudioRender*)userData;
	
	OSStatus status = 0;

	for (int i = 0; i < buffers->mNumberBuffers; i++){
	
		//判定在播放过程中是否使用pcm缓冲，如果使用pcm缓冲，会增加内存拷贝次数，尽量避免
		audiostream->isUsePCMBuf = audiostream->isUsePCMBuf || ((audiostream->streamDescriptionFromRtsp.mFormatID == kAudioFormatLinearPCM)
						 ? YES
						 :(buffers->mBuffers[i].mDataByteSize < 1024*2*audiostream->outputStreamDescription.mChannelsPerFrame));
		
		
		unsigned char *inInputData = NULL;
		NSInteger packetSize = [audiostream readAudioFrame:&inInputData];
		
		//如果是mute
		if (!audiostream->isPlaying) {
			
			//如果正在使用pcm缓冲则清空缓冲
			if(audiostream->isUsePCMBuf ) {
			
				audiostream->avaliabPCMData = 0;
			}
			
			slienceAudio(buffers->mBuffers[i]);
			
		}
		//收到数据包为0
		else if (packetSize <= 0) {
		
			if (audiostream->isUsePCMBuf) {
			
				
				copyDataFromPCMBuftoAudioBuffer(audiostream, buffers->mBuffers[i]);
				
			}
			else {
			
				slienceAudio(buffers->mBuffers[i]);
			}
		
		}
		else if (audiostream->streamDescriptionFromRtsp.mFormatID == kAudioFormatLinearPCM) {
			
			//ipcamera 目前都使用pcmbuf来做，否则会有问题
			if (audiostream->isUsePCMBuf) {
				
				//如果超过pcm缓冲则直接丢弃,否则将数据copy进pcm缓冲
				if (packetSize + audiostream->avaliabPCMData <= K_PCM_BUF_MAX_LENGTH) {
				
					memcpy(audiostream->pcmBuf + audiostream->avaliabPCMData, inInputData, packetSize);
					audiostream->avaliabPCMData += packetSize;
				}
				
				copyDataFromPCMBuftoAudioBuffer(audiostream, buffers->mBuffers[i]);
				
			}
			else {
			
				memcpy(buffers->mBuffers[i].mData, inInputData, packetSize);
				memset((char*)buffers->mBuffers[i].mData + packetSize, 0, buffers->mBuffers[i].mDataByteSize - packetSize);
			}

		}
		else if (audiostream->streamDescriptionFromRtsp.mFormatID == kAudioFormatMPEG4AAC) {
			
			AudioBufferList outBufferList;
			outBufferList.mNumberBuffers = 1;
			outBufferList.mBuffers[i].mNumberChannels = audiostream->outPCMBuf.mNumberChannels;
			outBufferList.mBuffers[i].mDataByteSize = audiostream->outPCMBuf.mDataByteSize;
			outBufferList.mBuffers[i].mData = audiostream->outPCMBuf.mData;
			
			UInt32 numOutputDataPackets = audiostream->outPCMBuf.mDataByteSize/audiostream->maxOutputPacketSize;
			
			
			audiostream->decodeBuffer = inInputData;
			audiostream->bytesToDecode = packetSize;
			

			status = AudioConverterFillComplexBuffer(audiostream->audioConverter,
															  decodeProc,
															  (__bridge void * _Nullable)(audiostream),
															  &numOutputDataPackets,
															  &outBufferList,
															  NULL);
			
			
			if (status == noErr) {
				
				//解码之后PCM的长度
				int packetLen = numOutputDataPackets*audiostream->outputStreamDescription.mBytesPerPacket;
				
				if (audiostream->isUsePCMBuf) {
					
					//如果超过pcm缓冲则直接丢弃,否则将数据copy进pcm缓冲
					if (packetLen + audiostream->avaliabPCMData <= K_PCM_BUF_MAX_LENGTH) {
						
						memcpy(audiostream->pcmBuf + audiostream->avaliabPCMData, outBufferList.mBuffers[i].mData, packetLen);
						audiostream->avaliabPCMData += packetLen;
					}
					
					copyDataFromPCMBuftoAudioBuffer(audiostream, buffers->mBuffers[i]);

				}
				else {
				
					
					memcpy(buffers->mBuffers[i].mData, outBufferList.mBuffers[i].mData , packetLen);
					memset((char*)buffers->mBuffers[i].mData + packetLen, 0, buffers->mBuffers[i].mDataByteSize - packetLen);
				}
			}
			else {
				
				if (audiostream->isUsePCMBuf) {
					
					copyDataFromPCMBuftoAudioBuffer(audiostream, buffers->mBuffers[i]);
					
				}
				else {
					
					slienceAudio(buffers->mBuffers[i]);
				}
			
			
			}
		
		}
		else {
			slienceAudio(buffers->mBuffers[i]);
		}
		

		
	}
	

	
	return noErr;
}


static OSStatus recordingCallback(void *userData,
                                  AudioUnitRenderActionFlags *ioActionFlags,
                                  const AudioTimeStamp *inTimeStamp,
                                  UInt32 inBusNumber,
                                  UInt32 inNumberFrames,
                                  AudioBufferList *ioData) {

	
	AudioBufferList inputBufferList;
	inputBufferList.mNumberBuffers = 1;
	inputBufferList.mBuffers[0].mDataByteSize = 0;
	inputBufferList.mBuffers[0].mData = NULL;
	inputBufferList.mBuffers[0].mNumberChannels = 1;
	
	AudioRender* audiostream = (__bridge AudioRender*)userData;
	OSStatus status = AudioUnitRender(audiostream->audioUnit ,
									  ioActionFlags,
									  inTimeStamp ,
									  KInputbus,
									  inNumberFrames ,
									  &inputBufferList);
	
	
	if(status == noErr && audiostream->isRecording) {
		
		[audiostream uploadAudio:inputBufferList.mBuffers[0].mData dateLength:inputBufferList.mBuffers[0].mDataByteSize];
		
	}
	
	return noErr;
}



-(id)init
{
    self = [super init];
    
    if (self) {

        dispatchQueue  = dispatch_queue_create("AudioRender", DISPATCH_QUEUE_SERIAL);
		
		isPlaying = YES;
		isRecording = NO;
		
		audioStatus = AS_INITIALIZED;

    }
    
    return self;
}

-(void)dealloc
{
	[self stop];
	

    if (dispatchQueue) {
        dispatchQueue = NULL;
    }

    if (convertG711toPCMBuf){
        
        free(convertG711toPCMBuf);
        convertG711toPCMBuf = NULL;
    }
    
    
}


-(NSInteger)readAudioFrame:(unsigned char**)buffer
{
    NSInteger frameSize = 0;
    unsigned char* tmpBuf = NULL;
    unsigned int timestamps = 0;
    
    [[Rvs_Viewer defaultViewer].viewerMedia getAudioDataWithHandle:_handle streamBuffer:&tmpBuf BufLen:&frameSize TimeStamp:&timestamps];
    
    if (frameSize > 0) {
        
        if (_MediaDesc.audioType == E_RVS_VIEWER_AUDIO_TYPE_PCM16) {
            
            *buffer = tmpBuf;
            
        }
        else if (_MediaDesc.audioType == E_RVS_VIEWER_AUDIO_TYPE_AAC){
            
            (*buffer) = (tmpBuf + kRedudantHeaderOfAAC);
            frameSize -= kRedudantHeaderOfAAC;
        }
        else if (_MediaDesc.audioType == E_RVS_VIEWER_AUDIO_TYPE_G711A){
            
            
            if (convertG711toPCMBufLen < frameSize*2){
                
                if (convertG711toPCMBuf){
                    
                    free(convertG711toPCMBuf);
                    convertG711toPCMBuf = NULL;
                }
                
                convertG711toPCMBuf = malloc(frameSize*2);
                convertG711toPCMBufLen = 2*frameSize;
            }
            
            for(int i = 0; i < frameSize; i++) {
                
                convertG711toPCMBuf[i] = alaw2linear(tmpBuf[i]);
                
            }
            
            *buffer = convertG711toPCMBuf;
            frameSize = frameSize*2;
            
        }
        else if (_MediaDesc.audioType == E_RVS_VIEWER_AUDIO_TYPE_G711U){
            
            if (convertG711toPCMBufLen < frameSize*2){
                
                if (convertG711toPCMBuf){
                    
                    free(convertG711toPCMBuf);
                    convertG711toPCMBuf = NULL;
                }
                
                convertG711toPCMBuf = malloc(frameSize*2);
                convertG711toPCMBufLen = 2*frameSize;
            }
            
            for(int i = 0; i < frameSize; i++) {
                
                convertG711toPCMBuf[i] = ulaw2linear(tmpBuf[i]);
                
            }
            
            *buffer = convertG711toPCMBuf;
            frameSize = frameSize*2;
        }
        else {
            
            
        }
        
        
    }
    

    
    return frameSize;
}

-(NSInteger)uploadAudio:(unsigned char*)buffer dateLength:(int)length
{
    
    short* pcmbuf = (short*)buffer;
    
    for(int i = 0; i < length/2; i++) {
        
        buffer[i] = linear2ulaw(pcmbuf[i]);
    }
    
    [[Rvs_Viewer defaultViewer].viewerMedia writeRevStreamData:buffer DataLen:length/2 TimeStamp:0 StreamType:EN_RVS_REV_STREAM_TYPE_AUDIO];
    
    
    return 0;
    
    
}

- (BOOL)getAudioDescription:(AudioStreamBasicDescription*)outASDesc
{
    _MediaDesc = [[Rvs_Viewer defaultViewer].viewerMedia getStreamDescWithHandle:_handle];
    
    BOOL suc = YES;
    
    if (_MediaDesc.audioType == E_RVS_AUDIO_TYPE_PCM16) {
        
        outASDesc->mSampleRate       = _MediaDesc.sampleRate;
        outASDesc->mFormatID         = kAudioFormatLinearPCM;
        outASDesc->mFormatFlags      = kLinearPCMFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
        outASDesc->mChannelsPerFrame = _MediaDesc.channel;
        outASDesc->mFramesPerPacket  = 1;
        outASDesc->mBitsPerChannel   = 16;
        outASDesc->mBytesPerFrame    = (outASDesc->mBitsPerChannel/8)*outASDesc->mChannelsPerFrame;
        outASDesc->mBytesPerPacket   = outASDesc->mBytesPerFrame;
        
    }
    else if (_MediaDesc.audioType == E_RVS_AUDIO_TYPE_AAC){
        
        outASDesc->mFormatID         = kAudioFormatMPEG4AAC;
        outASDesc->mSampleRate       = _MediaDesc.sampleRate;
        outASDesc->mChannelsPerFrame = _MediaDesc.channel;
        outASDesc->mFramesPerPacket  = 1024;
        outASDesc->mBitsPerChannel   = 0;
        outASDesc->mBytesPerFrame    = 0;
        outASDesc->mBytesPerPacket   = 0;
        outASDesc->mReserved         = 0;
        outASDesc->mFormatFlags = kMPEG4Object_AAC_LC;
        
    }
    else if (_MediaDesc.audioType == E_RVS_AUDIO_TYPE_G711A){
        
        outASDesc->mSampleRate       = _MediaDesc.sampleRate;
        outASDesc->mFormatID         = kAudioFormatLinearPCM;
        outASDesc->mFormatFlags      = kLinearPCMFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
        outASDesc->mChannelsPerFrame = _MediaDesc.channel;
        outASDesc->mFramesPerPacket  = 1;
        outASDesc->mBitsPerChannel   = 16;
        outASDesc->mBytesPerFrame    = (outASDesc->mBitsPerChannel/8)*outASDesc->mChannelsPerFrame;
        outASDesc->mBytesPerPacket   = outASDesc->mBytesPerFrame;
        
    }
    else if (_MediaDesc.audioType == E_RVS_AUDIO_TYPE_G711U){
        
        outASDesc->mSampleRate       = _MediaDesc.sampleRate;
        outASDesc->mFormatID         = kAudioFormatLinearPCM;
        outASDesc->mFormatFlags      = kLinearPCMFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
        outASDesc->mChannelsPerFrame = _MediaDesc.channel;
        outASDesc->mFramesPerPacket  = 1;
        outASDesc->mBitsPerChannel   = 16;
        outASDesc->mBytesPerFrame    = (outASDesc->mBitsPerChannel/8)*outASDesc->mChannelsPerFrame;
        outASDesc->mBytesPerPacket   = outASDesc->mBytesPerFrame;
    }
    else {
        
        suc = NO;
    }
    
    return suc;

}


- (void)activateVoiceWithCID:(unsigned long long)cid
                      Handle:(RVS_HANDLE)handle
                        Play:(BOOL)isPlay
                      Record:(BOOL)isRecord {

    if (_handle != handle) {
    
        [self stop];
        
        _cid = cid;
        _handle = handle;
        
        [self start];
        
    }
    
    if (isPlay) {
    
        [self resumePlay:handle];
    }
    else {
    
        [self pausePlay:handle];
    }
    
    
    if (isRecord) {
    
        [self resumeRecord:handle];
    }
    else {
    
        [self pauseRecord:handle];
    }
    

}
- (void)deactivateVoiceWithCID:(unsigned long long)cid Handle:(RVS_HANDLE)handle {


    if (_handle == handle) {
        
        [self stop];
        _handle = 0;
        _cid = 0;
        
    }
}



-(void)start
{
	//启动之前先stop，保证资源回复到初始状态
	[self stop];
	
	dispatch_async(dispatchQueue,^{
		
		
		if (audioStatus != AS_INITIALIZED && audioStatus != AS_STOPPED) {
			
			return;
		}
		

		[[AudioSessionManager defaultAudioSessionManager] activateVoIPAudioSession];
        [AudioSessionManager defaultAudioSessionManager].delegate = self;
		OSStatus err = 0;
		
		AudioComponentDescription componentDescription;
		componentDescription.componentType = kAudioUnitType_Output;
		componentDescription.componentSubType = kAudioUnitSubType_VoiceProcessingIO;
		componentDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
		componentDescription.componentFlags = 0;
		componentDescription.componentFlagsMask = 0;
		AudioComponent component = AudioComponentFindNext(NULL, &componentDescription);
		if(AudioComponentInstanceNew(component, &(audioUnit)) != noErr) {
						
			return;
		}
		
		//open output unit
		UInt32 enable = 1;
		if(AudioUnitSetProperty(audioUnit, kAudioOutputUnitProperty_EnableIO,
								kAudioUnitScope_Output, KOutbus, &enable, sizeof(UInt32)) != noErr) {
			
			
			return;
		}
		
		//open input unit
		if(AudioUnitSetProperty(audioUnit, kAudioOutputUnitProperty_EnableIO,
								kAudioUnitScope_Input, KInputbus, &enable, sizeof(UInt32)) != noErr) {
			
			
			return;
		}
		
		AURenderCallbackStruct rendCallbackStruct;
		rendCallbackStruct.inputProc = renderCallback; // Render function
		rendCallbackStruct.inputProcRefCon = (__bridge void * _Nullable)(self);
		if(AudioUnitSetProperty(audioUnit,
								kAudioUnitProperty_SetRenderCallback,
								kAudioUnitScope_Global,
								KOutbus,
								&rendCallbackStruct,
								sizeof(AURenderCallbackStruct)) != noErr) {
			
			
			
			return;
		}
		
		
		
		AURenderCallbackStruct recordingCallbackStruct;
		recordingCallbackStruct.inputProc = recordingCallback;
		recordingCallbackStruct.inputProcRefCon = (__bridge void * _Nullable)(self);
		if(AudioUnitSetProperty(audioUnit,
								kAudioOutputUnitProperty_SetInputCallback,
								kAudioUnitScope_Global,
								KInputbus,
								&recordingCallbackStruct,
								sizeof(AURenderCallbackStruct)) != noErr) {
		
			return;
		
		}
        
        if (![self getAudioDescription:&streamDescriptionFromRtsp]
            || (streamDescriptionFromRtsp.mFormatID != kAudioFormatLinearPCM && streamDescriptionFromRtsp.mFormatID != kAudioFormatMPEG4AAC)) {
            
            return;
        }
				

		UInt32 dataSize = 0;
		
		//如果是aac，需要创建一个转码器用于 aac->pcm
		if (streamDescriptionFromRtsp.mFormatID == kAudioFormatMPEG4AAC){
		
			
			outputStreamDescription.mFormatID = kAudioFormatLinearPCM;
			outputStreamDescription.mSampleRate = streamDescriptionFromRtsp.mSampleRate;
			outputStreamDescription.mChannelsPerFrame = streamDescriptionFromRtsp.mChannelsPerFrame;
			outputStreamDescription.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
			outputStreamDescription.mBitsPerChannel   = 16;
			outputStreamDescription.mFramesPerPacket  = 1;
			outputStreamDescription.mBytesPerFrame = outputStreamDescription.mBitsPerChannel/8*outputStreamDescription.mChannelsPerFrame;
			outputStreamDescription.mBytesPerPacket = outputStreamDescription.mBytesPerFrame*outputStreamDescription.mFramesPerPacket;


			dataSize = sizeof(streamDescriptionFromRtsp);
			if (AudioFormatGetProperty(kAudioFormatProperty_FormatInfo, 0, NULL, &dataSize, &(streamDescriptionFromRtsp)) != noErr) {
				
				return;
				
			}
			
			if ((err = AudioConverterNew(&streamDescriptionFromRtsp, &outputStreamDescription, &audioConverter)) != noErr) {
			
				char errStr[sizeof(err) + 1] = {0};
				*(int*)errStr = err;
				return;
			}
			

			
			if (outputStreamDescription.mBytesPerPacket == 0) {
			
				UInt32 maxOutputPacket = 0;
				dataSize = sizeof(maxOutputPacket);
				AudioConverterGetProperty (audioConverter,kAudioConverterPropertyMaximumOutputPacketSize, &dataSize, &maxOutputPacket);
				maxOutputPacketSize = maxOutputPacket;
			}
			else {
			
				maxOutputPacketSize = outputStreamDescription.mBytesPerPacket;
			}
			
			
			outPCMBuf.mDataByteSize = outputStreamDescription.mBytesPerFrame*streamDescriptionFromRtsp.mFramesPerPacket;
			outPCMBuf.mData = malloc(outPCMBuf.mDataByteSize);
			outPCMBuf.mNumberChannels = streamDescriptionFromRtsp.mChannelsPerFrame;
			

			
		}
		else {
		
		
			outputStreamDescription.mFormatID = kAudioFormatLinearPCM;
			outputStreamDescription.mSampleRate = streamDescriptionFromRtsp.mSampleRate;
			outputStreamDescription.mChannelsPerFrame = streamDescriptionFromRtsp.mChannelsPerFrame;
			outputStreamDescription.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
			outputStreamDescription.mBitsPerChannel   = 16;
			outputStreamDescription.mFramesPerPacket  = 1;
			outputStreamDescription.mBytesPerFrame = outputStreamDescription.mBitsPerChannel/8*outputStreamDescription.mChannelsPerFrame;
			outputStreamDescription.mBytesPerPacket = outputStreamDescription.mBytesPerFrame*outputStreamDescription.mFramesPerPacket;
					

		}
		
		//8kh->0.35   44.1khz->0.02
		float aBufferLength = (outputStreamDescription.mSampleRate == 8000 ? 0.015 : 0.02); // In seconds
		err = AudioSessionSetProperty(kAudioSessionProperty_PreferredHardwareIOBufferDuration,
									  sizeof(aBufferLength), &aBufferLength);
		
		
		if (err) {
			
			
		}

		// Set up input stream with above properties
		if(AudioUnitSetProperty(audioUnit,
								kAudioUnitProperty_StreamFormat,
								kAudioUnitScope_Input,
								KOutbus,
								&outputStreamDescription,
								sizeof(outputStreamDescription)) != noErr) {
			
			
			return;
		}
		
		inputStreamDescription.mFormatID = kAudioFormatLinearPCM;
		inputStreamDescription.mSampleRate = 8000;
		inputStreamDescription.mChannelsPerFrame = 1;
		inputStreamDescription.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
		inputStreamDescription.mBitsPerChannel   = 16;
		inputStreamDescription.mFramesPerPacket  = 1;
		inputStreamDescription.mBytesPerFrame = inputStreamDescription.mBitsPerChannel/8*inputStreamDescription.mChannelsPerFrame;
		inputStreamDescription.mBytesPerPacket = inputStreamDescription.mBytesPerFrame*inputStreamDescription.mFramesPerPacket;
		
		if(AudioUnitSetProperty(audioUnit,
								kAudioUnitProperty_StreamFormat,
								kAudioUnitScope_Output,
								KInputbus,
								&inputStreamDescription,
								sizeof(inputStreamDescription)) != noErr) {
			
			
			return;
		}
	
        err = AudioUnitInitialize(audioUnit);
							
		if(err != noErr) {
			
			
			if (AudioComponentInstanceDispose(audioUnit) != noErr) {
				
			}
			
			return;
			
		}
		
		if(AudioOutputUnitStart(audioUnit) != noErr) {
			
			
			return;
			
		}
        
		
		//pcm buf 清空
		avaliabPCMData = 0;
		
		//rendcallback会对该标志位判定，默认不使用pcm buf
		isUsePCMBuf = NO;
        
        
        _reveseAudioHandler = [[Rvs_Viewer defaultViewer].viewerMedia startRevStreamWithStreamer:_cid];
				
		audioStatus = AS_RUNNING;
		
	});
}


- (void)stop
{
	
	//这里用同步
	dispatch_sync(dispatchQueue,^{
		
		if (audioStatus != AS_RUNNING) {
			
			return;
		}
		
		audioStatus = AS_STOPPED;

		
		if(AudioOutputUnitStop(audioUnit) != noErr) {
			
			
		}
		
		if(AudioUnitUninitialize(audioUnit) != noErr) {
			
		}
		
		if (AudioComponentInstanceDispose(audioUnit) != noErr) {
			
		}
		
		audioUnit = NULL;
		
		if (audioConverter) {
		
		
			AudioConverterDispose(audioConverter);
			audioConverter = NULL;
		}
		
		if (outPCMBuf.mData) {
		
			free(outPCMBuf.mData);
			outPCMBuf.mData = NULL;
			
		
		}
		
		
		[[AudioSessionManager defaultAudioSessionManager] deactivateAudioSession];
        [AudioSessionManager defaultAudioSessionManager].delegate = nil;
        
        [[Rvs_Viewer defaultViewer].viewerMedia stopRevStreamWithHandle:_reveseAudioHandler];
        _reveseAudioHandler = 0;
		
		
	});
}

- (void)resumePlay:(RVS_HANDLE)handle
{
    
    if (_handle != handle) {
    
        return;
    }
	
	dispatch_async(dispatchQueue, ^{
		
//		if (audioStatus != AS_RUNNING || isPlaying) {
//			
//			return;
//		}
	
		isPlaying = YES;

	});
}

- (void)pausePlay:(RVS_HANDLE)handle
{
    if (_handle != handle) {
        
        return;
    }
	dispatch_async(dispatchQueue,^{
		
//		if (audioStatus != AS_RUNNING || !isPlaying) {
//			
//			return;
//		}
		
		isPlaying = NO;

	});
}


- (void)resumeRecord:(RVS_HANDLE)handle
{
    if (_handle != handle) {
        
        return;
    }
	
	dispatch_async(dispatchQueue, ^{
		
//		if (audioStatus != AS_RUNNING || isRecording) {
//			
//			return;
//		}
		
		isRecording = YES;
		
	});
}

- (void)pauseRecord:(RVS_HANDLE)handle
{
    
    if (_handle != handle) {
        
        return;
    }
    
	dispatch_async(dispatchQueue,^{
		
//		if (audioStatus != AS_RUNNING || !isRecording) {
//			
//			return;
//		}
		
		isRecording = NO;
		
	});
}


#pragma  mark -
#pragma  mark AudioSessionManagerProtocol
- (void)handleInterruption:(UInt32) inInterruptionState{
	
	if (inInterruptionState == kAudioSessionBeginInterruption) {
		
		dispatch_async(dispatchQueue,^{
			
			if (audioStatus != AS_RUNNING) {
				
				return;
			}
			
			
			if(AudioOutputUnitStop(audioUnit) != noErr) {
				
				return;
			}
			
			
		});
		
	}
	else if (inInterruptionState == kAudioSessionEndInterruption) {
		
		dispatch_async(dispatchQueue,^{
			
			if (audioStatus != AS_RUNNING) {
				
				return;
			}
			
			
			if(AudioOutputUnitStart(audioUnit) != noErr) {
				
				return;
			}
			
			
		});
		
	}
	
}




@end
