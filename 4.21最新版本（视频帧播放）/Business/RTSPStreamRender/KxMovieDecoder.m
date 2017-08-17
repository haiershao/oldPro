//
//  KxMovieDecoder.m
//  kxmovie
//
//  Created by Kolyvan on 15.10.12.
//  Copyright (c) 2012 Konstantin Boukreev . All rights reserved.
//
//  https://github.com/kolyvan/kxmovie
//  this file is part of KxMovie
//  KxMovie is licenced under the LGPL v3, see lgpl-3.0.txt

#import "KxMovieDecoder.h"
#import <Accelerate/Accelerate.h>

////////////////////////////////////////////////////////////////////////////////////////////////////
NSString * kxmovieErrorDomain = @"ru.kolyvan.kxmovie";
static NSMutableData *_md[3];

static NSError * kxmovieError (NSInteger code, id info)
{
    NSDictionary *userInfo = nil;
    
    if ([info isKindOfClass: [NSDictionary class]]) {
        
        userInfo = info;
        
    } else if ([info isKindOfClass: [NSString class]]) {
        
        userInfo = @{ NSLocalizedDescriptionKey : info };
    }
    
    return [NSError errorWithDomain:kxmovieErrorDomain
                               code:code
                           userInfo:userInfo];
}

static NSString * errorMessage (kxMovieError errorCode)
{
    switch (errorCode) {
        case kxMovieErrorNone:
            return @"";
            
        case kxMovieErrorOpenFile:
            return NSLocalizedString(@"Unable to open file", nil);
            
        case kxMovieErrorStreamInfoNotFound:
            return NSLocalizedString(@"Unable to find stream information", nil);
            
        case kxMovieErrorStreamNotFound:
            return NSLocalizedString(@"Unable to find stream", nil);
            
        case kxMovieErrorCodecNotFound:
            return NSLocalizedString(@"Unable to find codec", nil);
            
        case kxMovieErrorOpenCodec:
            return NSLocalizedString(@"Unable to open codec", nil);
            
        case kxMovieErrorAllocateFrame:
            return NSLocalizedString(@"Unable to allocate frame", nil);
            
        case kxMovieErroSetupScaler:
            return NSLocalizedString(@"Unable to setup scaler", nil);
            
        case kxMovieErroReSampler:
            return NSLocalizedString(@"Unable to setup resampler", nil);
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////



static NSData * copyFrameData(UInt8 *src, int linesize, int width, int height, KxVideoYUVType videoYUVType)
{
    width = MIN(linesize, width);
    //NSMutableData *md = [NSMutableData dataWithLength: width * height];
    if (!_md[videoYUVType])
        _md[videoYUVType] = [[NSMutableData alloc] init];
    _md[videoYUVType].length = width*height;
    Byte *dst =  _md[videoYUVType].mutableBytes;
    for (NSUInteger i = 0; i < height; ++i) {
        memcpy(dst, src, width);
        dst += width;
        src += linesize;
    }
    return  _md[videoYUVType];
}
////////////////////////////////////////////////////////////////////////////////////////////////////

@interface KxMovieFrame()
@property (readwrite, nonatomic) CGFloat position;
@property (readwrite, nonatomic) CGFloat duration;
@end

@implementation KxMovieFrame

- (void) dealloc
{
  
}

@end


@interface KxAudioFrame()
@property (readwrite, nonatomic, strong) NSData *samples;
@end

@implementation KxAudioFrame
- (KxMovieFrameType) type { return KxMovieFrameTypeAudio; }
@end


@interface KxVideoFrame()
//@property (readwrite, nonatomic) NSUInteger width;
//@property (readwrite, nonatomic) NSUInteger height;
@end

@implementation KxVideoFrame
- (KxMovieFrameType) type { return KxMovieFrameTypeVideo; }
@end


@interface KxVideoFrameRGB ()
//@property (readwrite, nonatomic) NSUInteger linesize;
//@property (readwrite, nonatomic, strong) NSData *rgb;
@end

@implementation KxVideoFrameRGB
- (KxVideoFrameFormat) format { return KxVideoFrameFormatRGB; }

- (void) freevideo
{
    self.rgb = nil;
}

- (UIImage *) asImage
{
    UIImage *image = nil;
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)(_rgb));
    if (provider) {
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        if (colorSpace) {
            CGImageRef imageRef = CGImageCreate(self.width,
                                                self.height,
                                                8,
                                                24,
                                                self.linesize,
                                                colorSpace,
                                                kCGBitmapByteOrderDefault,
                                                provider,
                                                NULL,
                                                YES, // NO
                                                kCGRenderingIntentDefault);
            
            if (imageRef) {
                image = [UIImage imageWithCGImage:imageRef];
                CGImageRelease(imageRef);
            }
            CGColorSpaceRelease(colorSpace);
        }
        CGDataProviderRelease(provider);
    }
    
    return image;
}

- (void)dealloc{
    [self freevideo];
}
@end


@interface KxVideoFrameYUV()
@property (readwrite, nonatomic, strong) NSData *luma;
@property (readwrite, nonatomic, strong) NSData *chromaB;
@property (readwrite, nonatomic, strong) NSData *chromaR;
@end

@implementation KxVideoFrameYUV
- (KxVideoFrameFormat) format { return KxVideoFrameFormatYUV; }
@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface KxMovieDecoder () {
	
    KxVideoFrameFormat  _videoFrameFormat;
}

@property (readwrite, nonatomic) NSUInteger frameWidth;
@property (readwrite, nonatomic) NSUInteger frameHeight;

@end

@implementation KxMovieDecoder


@synthesize  frameWidth;
@synthesize  frameHeight;


//@synthesize _md;

#pragma mark -
#pragma mark frame handle


//- (NSUInteger) frameWidth
//{
//    return 0;
//}
//
//- (NSUInteger) frameHeight
//{
//    return 0;
//}

#pragma mark -
#pragma mark init
+ (void)initialize
{

}



-(id) init
{
    self = [super init];
    
    if (self) {

    }
    
    return self;
}

- (void) dealloc
{
}

#pragma mark - private

- (void) restoreInitState
{

}


#pragma mark - public

- (BOOL) setupVideoFrameFormat: (KxVideoFrameFormat) format
{  
    if (format == KxVideoFrameFormatYUV ) {
        
        _videoFrameFormat = KxVideoFrameFormatYUV;
        return YES;
    }
    
    _videoFrameFormat = KxVideoFrameFormatRGB;
    return _videoFrameFormat == format;
}


- (NSData*) copyFrameData:(UInt8 *)src withLinesize:(int) linesize withWidth:(int) width withHeight:(int) height withYUV:(KxVideoYUVType) videoYUVType
{

	if (!_md[videoYUVType]) {
		_md[videoYUVType] = [[NSMutableData alloc] init];
	}
	_md[videoYUVType].length = width*height;
	Byte *dst = _md[videoYUVType].mutableBytes;
	
    if (linesize == width) {
        
        memcpy(dst, src, width*height);
    }
    else {
        
        for (NSUInteger i = 0; i < height; ++i) {
            memcpy(dst, src, width);
            dst += width;
            src += linesize;
        }
    }
    
	return _md[videoYUVType];
}

- (NSData*) copyFrameData:(UInt8 *)src  withWidth:(int) width withHeight:(int) height withYUV:(KxVideoYUVType) videoYUVType
{
    
    if (!_md[videoYUVType]) {
        _md[videoYUVType] = [[NSMutableData alloc] init];
    }
    _md[videoYUVType].length = width*height;
    Byte *dst = _md[videoYUVType].mutableBytes;
    
    
    memcpy(dst, src, width*height);
    
    
    return _md[videoYUVType];
}




- (KxVideoFrameYUV *)decodeVideoFrame:(unsigned char*)yuvBuf Width:(int)width Height:(int)height TimeStamp:(NSUInteger)timestamp {
    
    KxVideoFrameYUV * yuvFrame =[[KxVideoFrameYUV alloc] init];
    
    yuvFrame.luma = [self copyFrameData:yuvBuf withWidth:width withHeight:height withYUV:KxVideoTypeY];
    yuvFrame.chromaB = [self copyFrameData:yuvBuf + width*height withWidth:width/2 withHeight:height/2 withYUV:KxVideoTypeU];
    yuvFrame.chromaR = [self copyFrameData:yuvBuf + width*height*5/4 withWidth:width/2 withHeight:height/2 withYUV:KxVideoTypeV];
    
    yuvFrame.width = width;
    yuvFrame.height = height;
    
    yuvFrame.timetmp = timestamp;
    
    
    frameWidth = width;
    frameHeight = height;
    
    return yuvFrame;
    
}

/*
- (UIImage*) captureImage
{
    if (!_swsContext &&
        ![self setupScaler]) {
        
        HWLog(@"fail setup video scaler");
        return nil;
    }
    
    sws_scale(_swsContext,
              (const uint8_t **)_videoFrame->data,
              _videoFrame->linesize,
              0,
              _videoCodecCtx->height,
              _picture.data,
              _picture.linesize);
    
    KxVideoFrameRGB *rgbFrame = [[KxVideoFrameRGB alloc] init];
    rgbFrame.width  = _videoCodecCtx->width;
    rgbFrame.height = _videoCodecCtx->height;
    rgbFrame.linesize = _picture.linesize[0];
    rgbFrame.rgb = [NSData dataWithBytes:_picture.data[0]
                                  length:rgbFrame.linesize * _videoCodecCtx->height];
    
    return [rgbFrame asImage];
}
 */

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

