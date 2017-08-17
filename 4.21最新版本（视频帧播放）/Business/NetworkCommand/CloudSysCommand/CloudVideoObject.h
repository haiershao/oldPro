//
//  CloudVideoList.h
//  AtHomeCam
//
//  Created by Lvyi on 2/3/15.
//  Copyright (c) 2015 ichano. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CloudVideoObject : NSObject

@property (nonatomic, copy) NSString* eid;
@property (nonatomic, assign) int event_long;
@property (nonatomic, copy) NSString* createTime;
@property (nonatomic, assign) int cameraID;
@property (nonatomic, assign) int size;

- (id)initWithDictionary:(NSDictionary*)dic;

- (NSDictionary*)dictionary;

@end

@interface CloudVideoListOneDay : NSObject


@property (nonatomic, strong) NSMutableArray* cloudVideoObjectArray;
@property (nonatomic, assign) BOOL isMore;
@property (nonatomic, copy) NSString* date;

//本地化日期显示，缓存用，不做持久化
@property (nonatomic, copy) NSString* localDateStr;


- (id)initWithDictionary:(NSDictionary*)dic;

- (NSDictionary*)dictionary;



@end
