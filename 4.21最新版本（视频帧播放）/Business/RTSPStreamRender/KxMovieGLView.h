//
//  ESGLView.h
//  kxmovie
//
//  Created by Kolyvan on 22.10.12.
//  Copyright (c) 2012 Konstantin Boukreev . All rights reserved.
//
//  https://github.com/kolyvan/kxmovie
//  this file is part of KxMovie
//  KxMovie is licenced under the LGPL v3, see lgpl-3.0.txt

#import <UIKit/UIKit.h>

@class KxVideoFrame;
@class KxMovieDecoder;

//typedef enum {
//    GLVIEW_DISPLAY_RATIO_16_9,
//    GLVIEW_DISPLAY_RATIO_4_3,
//    GLVIEW_DISPLAY_RATIO_DEFAULT
//} GLVIEW_DISPLAY_RATIO;

@interface KxMovieGLView : UIView

//@property (nonatomic) GLVIEW_DISPLAY_RATIO displayRatio;
@property (nonatomic, assign) CGPoint displayRatio;
@property (assign) BOOL isScreenRotating;

//- (id) initWithFrame:(CGRect)frame
//        displayRatio:(GLVIEW_DISPLAY_RATIO)ratio
//     backgroundColor:(UIColor*)color
//             decoder:(KxMovieDecoder *) decoder;

- (id) initWithFrame:(CGRect)frame
        displayRatio:(CGPoint)displayRatio
     backgroundColor:(UIColor*)color
             decoder:(KxMovieDecoder *) decoder;


- (void) render: (KxVideoFrame *) frame;
- (void) updateVertices;

- (void)clear;


@end
