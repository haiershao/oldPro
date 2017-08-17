//
//  KxMovieDecoder.h
//  kxmovie
//
//  Created by Kolyvan on 15.10.12.
//  Copyright (c) 2012 Konstantin Boukreev . All rights reserved.
//
//  https://github.com/kolyvan/kxmovie
//  this file is part of KxMovie
//  KxMovie is licenced under the LGPL v3, see lgpl-3.0.txt

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

extern NSString * kxmovieErrorDomain;

typedef enum {
    
    kxMovieErrorNone,
    kxMovieErrorOpenFile,
    kxMovieErrorStreamInfoNotFound,
    kxMovieErrorStreamNotFound,
    kxMovieErrorCodecNotFound,
    kxMovieErrorOpenCodec,
    kxMovieErrorAllocateFrame,
    kxMovieErroSetupScaler,
    kxMovieErroReSampler,
    
} kxMovieError;

typedef enum {
    
    KxMovieFrameTypeAudio,
    KxMovieFrameTypeVideo,
    
} KxMovieFrameType;

typedef enum {
        
    KxVideoFrameFormatRGB,
    KxVideoFrameFormatYUV,
    
} KxVideoFrameFormat;

@interface KxMovieFrame : NSObject
@property (readonly, nonatomic) KxMovieFrameType type;
@property (readonly, nonatomic) CGFloat position;
@property (readonly, nonatomic) CGFloat duration;
@end

@interface KxAudioFrame : KxMovieFrame
@property (readonly, nonatomic, strong) NSData *samples;
@end

@interface KxVideoFrame : KxMovieFrame
@property (readonly, nonatomic) KxVideoFrameFormat format;
@property (readwrite, nonatomic) NSUInteger width;
@property (readwrite, nonatomic) NSUInteger height;
@property (nonatomic) unsigned int timetmp;
@end

@interface KxVideoFrameRGB : KxVideoFrame
- (void) freevideo;
- (UIImage *) asImage;
@property (readwrite, nonatomic) NSUInteger linesize;
@property (readwrite, nonatomic, strong) NSData *rgb;
@end

@interface KxVideoFrameYUV : KxVideoFrame
@property (readonly, nonatomic, strong) NSData *luma;
@property (readonly, nonatomic, strong) NSData *chromaB;
@property (readonly, nonatomic, strong) NSData *chromaR;
@end


typedef enum{
    KxVideoTypeY = 0,
    KxVideoTypeU,
    KxVideoTypeV
} KxVideoYUVType;

@interface KxMovieDecoder : NSObject
{
	NSMutableData *_md[3];
}

@property (readonly, nonatomic) NSUInteger frameWidth;
@property (readonly, nonatomic) NSUInteger frameHeight;


- (void) restoreInitState;

- (BOOL) setupVideoFrameFormat: (KxVideoFrameFormat) format;


- (KxVideoFrameYUV *)decodeVideoFrame:(unsigned char*)yuvBuf Width:(int)width Height:(int)height TimeStamp:(NSUInteger)timestamp;
//- (UIImage*) captureImage;


@end