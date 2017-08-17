//
//  HWVideoViewController.h
//  HuaWo
//
//  Created by hwawo on 16/12/23.
//  Copyright © 2016年 HW. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FullViewController;
@class Video;
@interface HWVideoViewController : UIViewController
@property (nonatomic, strong) Video *video;
@property (nonatomic, strong) FMGVideoPlayView *playView;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) UITextField * testDanma;
@property (nonatomic, strong) UIButton * sendButton;
@property (nonatomic, strong) UIButton * hiddenButton;

+ (instancetype) shareVideoController;
@end
