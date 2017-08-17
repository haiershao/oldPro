//
//  AlbumManager.h
//  HuaWo
//
//  Created by circlely on 1/23/16.
//  Copyright © 2016 circlely. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlbumInfo : NSObject

@property (nonatomic, copy)   NSString* fileName;
@property (nonatomic, copy)   NSString* fullPath;
@property (nonatomic, copy)   NSString *iconPath;
@property (nonatomic, copy)   NSString *locationPath;
@property (nonatomic, assign) BOOL isSelected;

- (NSDictionary *)dictionary;
- (id)initWithDictionary:(NSDictionary *)dic;

@end


@interface AlbumManager : NSObject

@property (nonatomic, strong, readonly) NSMutableArray *AlbumItemList;
@property (nonatomic, strong, readonly) NSMutableArray *AlbumItemForVideoList;
@property (nonatomic, strong, readonly) NSMutableArray *AlbumDays;

+ (AlbumManager *)shareAlbumManager;


- (void)insertItemInAlbumList:(AlbumInfo *)albumInfo forVideo:(BOOL)isVideo;
- (void)deleteItemInAlbumList:(AlbumInfo *)albumInfo forVideo:(BOOL)isVideo;

- (NSString *)createRecordLocationPathForVideo:(BOOL)isVideo;

- (void)clearAllAlbum;
@end

@interface StreamerAlbumManager : NSObject

- (void)destory;
+ (StreamerAlbumManager *)shareStreamerAlbumManager;

- (void)addStreamerAlbumItems:(NSMutableArray *)items withCIDNmuber:(NSString *)cid forLock:(BOOL)isLock;
- (void)deleteStreamerAlbumItems:(NSMutableArray *)items withCIDNmuber:(NSString *)cid forLock:(BOOL)isLock;

- (NSMutableArray *)getStreamerAlbumItemsForCIDNumber:(NSString *)cid forLock:(BOOL)isLock;

- (void)deleteStreamerAlbumItemsAllWithCIDNumber:(NSString *)cid deleteDate:(NSString *)date forLock:(BOOL)isLock;
- (void)removeCachewithLock:(BOOL)isLock forCIDNumber:(NSString *)cid;
@end
