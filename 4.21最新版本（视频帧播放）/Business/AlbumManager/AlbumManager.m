//
//  AlbumManager.m
//  HuaWo
//
//  Created by circlely on 1/23/16.
//  Copyright © 2016 circlely. All rights reserved.
//


#import "AlbumManager.h"

@implementation AlbumInfo

- (NSDictionary *)dictionary {
    
    NSDictionary *dic = @{kFILENAME : self.fileName,
                          kFULLPATH : self.fullPath,
                          kICONPATH : self.iconPath,
                          kLOCATIONPATH : self.locationPath};
    return dic;
}

- (id)initWithDictionary:(NSDictionary *)dic {
    
    self = [super init];
    
    if (self) {
        
        self.fileName   = [dic objectForKey:kFILENAME];
        self.iconPath   = [dic objectForKey:kICONPATH];
        self.fullPath   = [dic objectForKey:kFULLPATH];
        self.locationPath = [dic objectForKey:kLOCATIONPATH];
    }
    
    return self;
}

@end




@interface AlbumManager ()

@property (nonatomic, strong) NSMutableArray *AlbumItemList;
@property (nonatomic, strong) NSMutableArray *AlbumItemForVideoList;
@property (nonatomic, strong) NSMutableArray *AlbumDays;

@end

@implementation AlbumManager

+ (AlbumManager *)shareAlbumManager {
    
    static AlbumManager *g_AlbumManager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
       
        g_AlbumManager = [[AlbumManager alloc] init];
        
    });
    
    return g_AlbumManager;
    
}

- (void)clearAllAlbum{
    
    _AlbumItemList = nil;
}

- (NSMutableArray *)transformToAlbumInfoWithMutableArray:(NSMutableArray *)arrary{
    
    NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:42];
    
    for (NSDictionary *dic in arrary) {
        
        AlbumInfo* albumInfo = [[AlbumInfo alloc] init];
        
        //覆盖安装APP，绝对路径会发生变化，这里将相对路径重新拼接
        
        albumInfo.fileName   = [dic objectForKey:kFILENAME];
        albumInfo.fullPath = [NSHomeDirectory() stringByAppendingString:[dic objectForKey:kFULLPATH]];
//        albumInfo.locationPath = albumInfo.fullPath;
        if (![[dic objectForKey:kICONPATH] isEqualToString:kNULL]) {
            
            albumInfo.iconPath = [NSHomeDirectory() stringByAppendingString:[dic objectForKey:kICONPATH]];
        }else{
            
            albumInfo.iconPath = [dic objectForKey:kICONPATH];
        }
    
        [arr addObject:albumInfo];
    }
    
    return arr;
}

- (NSMutableArray *)transformToMutableArrayWithAlbumArray:(NSMutableArray *)array{
    
    NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:42];
    
    for (AlbumInfo *item in array) {
        
        
        
        //覆盖重装APP后，沙盒绝对路径会发生变化，这里截取相对路径
        HWLog(@"--------item.fullPath%@",item.fullPath);
        NSRange homeDirctoryRange = [item.fullPath rangeOfString:NSHomeDirectory()];
        HWLog(@"--------homeDirctoryRange%@",NSStringFromRange(homeDirctoryRange));
        NSString *subFullPath = [item.fullPath substringFromIndex:homeDirctoryRange.location + homeDirctoryRange.length];
//        NSString *subLocationPath = [item.fullPath substringFromIndex:homeDirctoryRange.location + homeDirctoryRange.length];
        HWLog(@"---------subFullPath*%@*",subFullPath);
        
        NSString *subIconPath = nil;
        
        NSRange foundObject = [item.iconPath rangeOfString:NSHomeDirectory()];
        
        if (foundObject.location != NSNotFound) {
            subIconPath = [item.iconPath substringFromIndex:homeDirctoryRange.location + homeDirctoryRange.length];
        }else{
            subIconPath   = item.iconPath;
        }
        
//        if ([item.iconPath containsString:NSHomeDirectory()]) {
//            
//            subIconPath = [item.iconPath substringFromIndex:homeDirctoryRange.location + homeDirctoryRange.length];
//            
//        }else{
//            
//            subIconPath   = item.iconPath;
//        }
        
        NSDictionary *dic = @{kFILENAME : item.fileName,
                              kFULLPATH : subFullPath,
                              kICONPATH : subIconPath
                              };
        
        [arr addObject:dic];
        
    }
    
    return arr;
}

-(id)init{
    
    self = [super init];
    HWLog(@"--------------%@",[self getAlbumItemListPathForVideo:NO]);
    NSMutableArray *albumList = [[NSMutableArray alloc] initWithContentsOfFile:[self getAlbumItemListPathForVideo:NO]];
    
    self.AlbumItemList = [self transformToAlbumInfoWithMutableArray:albumList];
    
    
    NSMutableArray *videoList = [[NSMutableArray alloc] initWithContentsOfFile:[self getAlbumItemListPathForVideo:YES]];
    
    self.AlbumItemForVideoList = [self transformToAlbumInfoWithMutableArray:videoList];
    
    if (!self.AlbumItemList) {
        
        self.AlbumItemList = [[NSMutableArray alloc] initWithCapacity:42];
    }
    
    if (!self.AlbumItemForVideoList) {
        
        self.AlbumItemForVideoList = [[NSMutableArray alloc] initWithCapacity:42];
    }
    
    self.AlbumDays = [[NSMutableArray alloc] initWithContentsOfFile:[self getAlbumDaysPath]];
    
    if (!self.AlbumDays) {
        
        self.AlbumDays = [[NSMutableArray alloc] initWithCapacity:42];
    }
    
    
    return self;
}

- (NSString *)getAlbumItemListPathForVideo:(BOOL)isVideo{
    
    NSArray *documents = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSMutableString *path = [NSMutableString stringWithString:[documents firstObject]];
    
    [path appendString:@"/HuaWo"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:path]) {
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    if (isVideo) {
        
        [path appendString:@"/AlbumItemListForVideo.plist"];
        if (![fileManager fileExistsAtPath:path]) {
            [fileManager createFileAtPath:path contents:nil attributes:nil];
        }
        
        return path;
        
    }else{
        
        [path appendString:@"/AlbumItemListForVideoAndPic.plist"];
        if (![fileManager fileExistsAtPath:path]) {
            [fileManager createFileAtPath:path contents:nil attributes:nil];
        }
        
        
        
        return path;
    }
    
}

- (NSString *)getAlbumDaysPath {
    
    NSArray *documents = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSMutableString *path = [NSMutableString stringWithString:[documents firstObject]];
    
    [path appendString:@"/HuaWo"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:path]) {
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    
    NSString *AlbumDaysNumPath = [path stringByAppendingString:@"/AlbumDays.plist"];
    
    if (![fileManager fileExistsAtPath:AlbumDaysNumPath]) {
        
        [fileManager createFileAtPath:AlbumDaysNumPath contents:nil attributes:nil];
    }
    
    return AlbumDaysNumPath;

}

- (void)insertItemInAlbumList:(AlbumInfo *)albumInfo forVideo:(BOOL)isVideo{

    if (isVideo) {
        
        [self.AlbumItemForVideoList insertObject:albumInfo atIndex:0];
    }
        
    [self.AlbumItemList insertObject:albumInfo atIndex:0];
    [self saveAlbumItemListToFileForVideo:isVideo];
    
}

- (void)deleteItemInAlbumList:(AlbumInfo *)albumInfo forVideo:(BOOL)isVideo{
    
    //if (isVideo) {
        
        [self.AlbumItemForVideoList removeObject:albumInfo];
        [[NSFileManager defaultManager] removeItemAtPath:albumInfo.iconPath error:nil];
        
    //}
    
    [self.AlbumItemList removeObject:albumInfo];
    
    [[NSFileManager defaultManager] removeItemAtPath:albumInfo.fullPath error:nil];
    
    [self saveAlbumItemListToFileForVideo:isVideo];

}

-(void)saveAlbumItemListToFileForVideo:(BOOL)isVideo{
    
    
    if (isVideo) {
        
        NSMutableArray *videoList = [self transformToMutableArrayWithAlbumArray:self.AlbumItemForVideoList];
        
        [videoList writeToFile:[self getAlbumItemListPathForVideo:isVideo] atomically:YES];
    }
        
        NSMutableArray *albumList = [self transformToMutableArrayWithAlbumArray:self.AlbumItemList];
        
        [albumList writeToFile:[self getAlbumItemListPathForVideo:NO] atomically:YES];
    
  
}

- (NSString *)createRecordLocationPathForVideo:(BOOL)isVideo{
    
    NSDate *recordDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *recordDir = [dateFormatter stringFromDate:recordDate];
    
    
    if (![self.AlbumDays containsObject:recordDir]) {
        
        [self.AlbumDays insertObject:recordDir atIndex:0];
        
        [self.AlbumDays writeToFile:[self getAlbumDaysPath] atomically:YES];
    }
    
    
    return [self getAlbumFilePath:recordDir forVideo:isVideo];
}

- (NSString *)getAlbumFilePath:(NSString *)videoRecordPath forVideo:(BOOL)isVideo {
    
    NSArray *documents = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSMutableString *path = [NSMutableString stringWithString:[documents firstObject]];
    if (![videoRecordPath isEqualToString:@""]) {
        
        if (isVideo) {
            
            [path appendString:[NSString stringWithFormat:@"/HuaWo/LocalVideo/%@",videoRecordPath]];
        }else{
            
            [path appendString:[NSString stringWithFormat:@"/HuaWo/LocalImage/%@",videoRecordPath]];
        }
         
    }else{
        
        [path appendString:[NSString stringWithFormat:@"/HuaWo"]];
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:path]) {
        
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        
        
    }
    HWLog(@"--------------------------%@",path);
    return path;
}


@end



//采集端相册管理
@interface StreamerAlbumManager()

@property (strong, nonatomic) NSMutableDictionary *lockStreamerAlbumItems;
@property (strong, nonatomic) NSMutableDictionary *unLockSreamerAlbumItems;

@end


@implementation StreamerAlbumManager



+ (StreamerAlbumManager *)shareStreamerAlbumManager {
    
    static StreamerAlbumManager *g_StreamerAlbumManager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        g_StreamerAlbumManager = [[StreamerAlbumManager alloc] init];
        
        
        
    });
    
    return g_StreamerAlbumManager;
}

- (id)init {
    
    self = [super init];
    if (self) {
        
        self.lockStreamerAlbumItems = [NSMutableDictionary dictionary];
        self.unLockSreamerAlbumItems = [NSMutableDictionary dictionary];
    }
    
    return self;
}


- (void)addStreamerAlbumItems:(NSMutableArray *)items withCIDNmuber:(NSString *)cid forLock:(BOOL)isLock {
    
    
    if (isLock) {
        
        NSMutableArray *savedLockItems = [self.lockStreamerAlbumItems objectForKey:cid];
        if (!savedLockItems) {
            
            [self.lockStreamerAlbumItems setObject:[items mutableCopy] forKey:cid];
            
        }else {
            
            [savedLockItems addObjectsFromArray:[items mutableCopy]];
            [self.lockStreamerAlbumItems setObject:savedLockItems forKey:cid];
            
        }
        
    }else {
        
        NSMutableArray *savedUnLockItems = [self.unLockSreamerAlbumItems objectForKey:cid];
        if (!savedUnLockItems) {
            
            [self.unLockSreamerAlbumItems setObject:[items mutableCopy] forKey:cid];
            
        }else {
            
            [savedUnLockItems addObjectsFromArray:[items mutableCopy]];
            [self.unLockSreamerAlbumItems setObject:savedUnLockItems forKey:cid];
            
        }
        
    }
    
    
    
}
- (void)deleteStreamerAlbumItemsAllWithCIDNumber:(NSString *)cid deleteDate:(NSString *)date forLock:(BOOL)isLock{
    
    if (isLock) {
        
        NSMutableArray *albumItems = [self.lockStreamerAlbumItems objectForKey:cid];
        
        for (int dayIndex = 0; dayIndex < albumItems.count; dayIndex++) {
            
            
        }
        
        [self.lockStreamerAlbumItems setObject:albumItems forKey:cid];
        
        
    }else {
        
        NSMutableArray *albumItems = [self.unLockSreamerAlbumItems objectForKey:cid];
        
        for (int dayIndex = 0; dayIndex < albumItems.count; dayIndex++) {
            
            
        }
        
        [self.unLockSreamerAlbumItems setObject:albumItems forKey:cid];
        
        
    }
    
    
    
    
}

- (void)deleteStreamerAlbumItems:(NSMutableArray *)items withCIDNmuber:(NSString *)cid forLock:(BOOL)isLock {
    
    if (isLock) {
        
        NSMutableArray *lockAlbumItems = [self.lockStreamerAlbumItems objectForKey:cid];
    
        
        
        [self.lockStreamerAlbumItems setObject:lockAlbumItems forKey:cid];
        
    }else {
        
        NSMutableArray *unLockAlbumItems = [self.unLockSreamerAlbumItems objectForKey:cid];
        
        for (id deleteItem in items) {
            
            for (int dayIndex = 0; dayIndex < unLockAlbumItems.count; dayIndex++) {
                
                [[unLockAlbumItems objectAtIndex:dayIndex] removeObject:deleteItem];
                
                if ([[unLockAlbumItems objectAtIndex:dayIndex] count] == 0) {
                    
                    [unLockAlbumItems removeObject:[unLockAlbumItems objectAtIndex:dayIndex]];
                }
            }
        }
        
        [self.unLockSreamerAlbumItems setObject:unLockAlbumItems forKey:cid];

        
    }
    
}

- (NSMutableArray *)getStreamerAlbumItemsForCIDNumber:(NSString *)cid forLock:(BOOL)isLock{
    
    if (isLock) {
        return [NSMutableArray arrayWithArray:[self.lockStreamerAlbumItems objectForKey:cid]];
    }
    
    return [NSMutableArray arrayWithArray:[self.unLockSreamerAlbumItems objectForKey:cid]];
    
}

- (void)removeCachewithLock:(BOOL)isLock forCIDNumber:(NSString *)cid {
    
    if (isLock) {
        
        [[self.lockStreamerAlbumItems objectForKey:cid] removeAllObjects];
    }
    else {
        
        [[self.unLockSreamerAlbumItems objectForKey:cid] removeAllObjects];
    }
    
}

- (void)destory{
    
    [self.lockStreamerAlbumItems removeAllObjects];
    [self.unLockSreamerAlbumItems removeAllObjects];
    
}

@end

