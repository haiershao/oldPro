//
//  Video.h
//  ioshuanwu
//
//  Created by 幻音 on 15/12/28.
//  Copyright © 2015年 幻音. All rights reserved.
//  视频Model

#import <Foundation/Foundation.h>
@class VideoSid;
@interface Video : NSObject

@property (nonatomic, strong) NSString * comtimes;
@property (nonatomic, strong) NSString * title;
@property (nonatomic, assign) NSInteger  vtype;
@property (nonatomic, strong) NSString *  videoid;
@property (nonatomic, strong) NSString * goodtimes;
@property (nonatomic, strong) NSString * gentime;
@property (nonatomic, assign) NSString *  location;
@property (nonatomic, strong) NSString * recommend;
@property (nonatomic, strong) NSString * uid;
@property (nonatomic, strong) NSString * viewtimes;
@property (nonatomic, strong) VideoSid * videoinfo;

@end
