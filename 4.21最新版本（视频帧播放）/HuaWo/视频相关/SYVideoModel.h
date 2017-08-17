//
//  SYVideoModel.h
//  SYRecordVideoDemo
//
//  Created by leju_esf on 17/3/16.
//  Copyright © 2017年 yjc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, SYVideoType) {
    SYVideoTypeNormal = 0,//常规视频
    SYVideoTypeShare,//抢拍分享
    SYVideoTypeReport//举报视频
};

@interface SYVideoModel : NSObject
@property (nonatomic, copy) NSString *path;
@property (nonatomic, assign) CGFloat totalTime;
@property (nonatomic, strong) UIImage *defaultImage;
@property (nonatomic, assign) NSString *sizeStr;
@property (nonatomic, assign) long long size;
@property (nonatomic, assign) SYVideoType type;
@property (nonatomic, copy) NSString *takeDate;
/**
 设置缩略图
 
 @param block 回调
 */
- (void)sy_setImage:(void (^)(UIImage *image))block;
/**
 保存视频
 
 @param video 视频
 */
+ (void)saveVideo:(SYVideoModel *)video;
/**
 删除视频
 
 @param video 视频
 @return 删除后的数组
 */
+ (NSArray *)removeVideo:(SYVideoModel *)video;
/**
 视频列表
 @param type 视频类型
 SYVideoTypeNormal = 0,//常规视频
 SYVideoTypeShare,//抢拍分享
 SYVideoTypeReport//举报视频
 @return 列表
 */
+ (NSArray *)videoListWithType:(SYVideoType)type;

@end
