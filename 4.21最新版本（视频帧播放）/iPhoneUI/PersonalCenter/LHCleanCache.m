//
//  SZKCleanCache.m
//  CleanCache
//
//  Created by sunzhaokai on 16/5/11.
//  Copyright © 2016年 孙赵凯. All rights reserved.
//

#import "LHCleanCache.h"

@implementation LHCleanCache

/**
 *  清理缓存
 */
+(void)cleanCache:(cleanCacheBlock)block
{
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        //文件路径
//        NSString *directoryPath=[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
//        
//        NSArray *subpaths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directoryPath error:nil];
//        
//        for (NSString *subPath in subpaths) {
//            NSString *filePath = [directoryPath stringByAppendingPathComponent:subPath];
//            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
//        }
    NSMutableArray *arr = [NSMutableArray array];
    [arr addObject:NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject];
    [arr addObject:NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).lastObject];
    [arr addObject:[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]];
    [arr addObject:NSTemporaryDirectory()];
    for (NSString *tem in arr) {
        [self cleanCaches:tem];
    }

    //返回主线程
    dispatch_async(dispatch_get_main_queue(), ^{
        block();
    });

    
}
/**
 *  计算整个目录大小
 */
+(float)folderSizeAtPath
{
    CGFloat size = [self folderSizeAtPath:NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject] + [self folderSizeAtPath:NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).lastObject] + [self folderSizeAtPath:NSTemporaryDirectory()] + [self folderSizeAtPath:[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]];
    
//    NSString *folderPath=[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
//    
//    NSFileManager * manager=[NSFileManager defaultManager ];
//    if (![manager fileExistsAtPath :folderPath]) {
//        return 0 ;
//    }
//    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath :folderPath] objectEnumerator ];
//    NSString * fileName;
//    long long folderSize = 0 ;
//    while ((fileName = [childFilesEnumerator nextObject ]) != nil ){
//        NSString * fileAbsolutePath = [folderPath stringByAppendingPathComponent :fileName];
//        folderSize += [ self fileSizeAtPath :fileAbsolutePath];
//    }
    
    return size;
}
/**
 *  计算单个文件大小
 */
+(long long)fileSizeAtPath:(NSString *)filePath{
    
    NSFileManager *manager = [NSFileManager defaultManager];
    
    if ([manager fileExistsAtPath :filePath]){
        
        return [[manager attributesOfItemAtPath :filePath error : nil ] fileSize];
    }
    return 0 ;
    
}

//清除缓存按钮的点击事件
- (void)putBufferBtnClicked:(UIButton *)btn{
//    CGFloat size = [self folderSizeAtPath:NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject] + [self folderSizeAtPath:NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).lastObject] + [self folderSizeAtPath:NSTemporaryDirectory()];
//    
//    NSString *message = size > 1 ? [NSString stringWithFormat:@"缓存%.2fM, 删除缓存", size] : [NSString stringWithFormat:@"缓存%.2fK, 删除缓存", size * 1024.0];
//    
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:(UIAlertControllerStyleAlert)];
//    
//    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction *action) {                [self cleanCaches];            }];
//    
//    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleCancel) handler:nil];
//    [alert addAction:action];
//    [alert addAction:cancel];
//    [self showDetailViewController:alert sender:nil];
}

// 计算目录大小
+ (CGFloat)folderSizeAtPath:(NSString *)path{
    // 利用NSFileManager实现对文件的管理
    NSFileManager *manager = [NSFileManager defaultManager];
    CGFloat size = 0;
    if ([manager fileExistsAtPath:path]) {
        // 获取该目录下的文件，计算其大小
        NSArray *childrenFile = [manager subpathsAtPath:path];
        for (NSString *fileName in childrenFile) {
            NSString *absolutePath = [path stringByAppendingPathComponent:fileName];
            size += [manager attributesOfItemAtPath:absolutePath error:nil].fileSize;
        }
        // 将大小转化为M
        return size / 1024.0 / 1024.0;
    }
    return 0;
}
// 根据路径删除文件
+ (void)cleanCaches:(NSString *)path{
    // 利用NSFileManager实现对文件的管理
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        // 获取该路径下面的文件名
        NSArray *childrenFiles = [fileManager subpathsAtPath:path];
        for (NSString *fileName in childrenFiles) {
            // 拼接路径
            NSString *absolutePath = [path stringByAppendingPathComponent:fileName];
            // 将文件删除
            [fileManager removeItemAtPath:absolutePath error:nil];
        }
    }

}



@end
