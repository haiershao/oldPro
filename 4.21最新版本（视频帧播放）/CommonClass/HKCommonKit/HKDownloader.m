//
//  HKDownloader.m
//  HKCommonKit
//
//  Created by tanghaibo on 13-5-27.
//  Copyright (c) 2013年 cythbgy@gmail.com. All rights reserved.
//

#import "HKDownloader.h"
#import "ASIHTTPRequest.h"

@interface HKDownloader(){
    CGFloat _averageSpeed;  // bytes/s
}

@property (strong, nonatomic) NSMutableArray *datesM;
@property (strong, nonatomic) NSMutableArray *sizesM;
@property (assign, nonatomic) CGFloat averageSpeed;

@end

@implementation HKDownloader

+ (HKDownloader *)download:(NSString *)URLStr
                  destPath:(NSString *)destPath
        recognizeTotleSize:(RecognizeTotleSizeBlock)recognizeTotleSizeBlock
             progressBlock:(DownloadProgressBlock)progressBlock
         downloadSeedBlock:(DownloadSeedBlock)downloadSeedBlock
                   success:(ASIRequsetBlock)successBlock
                      fail:(ASIRequsetBlock)failBlock{
    HKDownloader *downRequest = [[HKDownloader alloc] initWithURL:
                                   [NSURL URLWithString:URLStr] ];
    __weak HKDownloader *weakRequest = downRequest;
    
    [downRequest setCompletionBlock:^{
        successBlock(weakRequest);
    }];
    
    [downRequest setFailedBlock:^{
        failBlock(weakRequest);
    }];
    
    [downRequest setDownloadSizeIncrementedBlock:^(long long size) {
        recognizeTotleSizeBlock(size);
    }];
    
    [downRequest setBytesReceivedBlock:^(unsigned long long size, unsigned long long total) {
        NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
        __block NSNumber *findObj = nil;
        [weakRequest.datesM enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if (interval == [obj longLongValue]) {
                findObj = obj;
                *stop = YES;
            }
        }];
        
        if (nil != findObj) {
            NSInteger index = [weakRequest.datesM indexOfObject:findObj];
            unsigned long long baseSizePerSec = [weakRequest.sizesM[index] longLongValue];
            [weakRequest.sizesM removeObjectAtIndex:index];
            [weakRequest.sizesM insertObject:@(baseSizePerSec + size) atIndex:index];
        }else{
            [weakRequest.datesM addObject:@(interval)];
            [weakRequest.sizesM addObject:@(size)];
        }
        
        NSAssert(weakRequest.sizesM.count == weakRequest.datesM.count, @"数据不匹配，这两个数组元素数必须一致");
        while (weakRequest.sizesM.count > 5) {
            [weakRequest.sizesM removeObjectAtIndex:0];
            [weakRequest.datesM removeObjectAtIndex:0];
        }
        
        unsigned long long totoleTmp = 0;
        for (NSNumber *sizeNum in weakRequest.sizesM) {
            totoleTmp += [sizeNum longLongValue];
        }
        weakRequest.averageSpeed = 1.f * totoleTmp/weakRequest.datesM.count;
        downloadSeedBlock(weakRequest.averageSpeed);
        
        
        
        progressBlock(1.f *
                      (weakRequest.totalBytesRead + weakRequest.partialDownloadSize)
                      / total);
    }];
    
    NSString *tmpDir = NSTemporaryDirectory();
    NSString *temporaryPath = [NSString stringWithFormat:@"%@/%@",
                               tmpDir, URLStr.lastPathComponent];
    
    // The full file will be moved here if and when the request completes successfully
    [downRequest setDownloadDestinationPath:destPath];
    
    // This file has part of the download in it already
    [downRequest setTemporaryFileDownloadPath:temporaryPath];
    [downRequest setAllowResumeForFileDownloads:YES];
    [downRequest startAsynchronous];
    
    return downRequest;
}

#pragma mark - getter/setter
- (NSMutableArray *)datesM{
    if (nil == _datesM) {
        _datesM = [[NSMutableArray alloc] initWithCapacity:5];
    }
    return _datesM;
}

- (NSMutableArray *)sizesM{
    if (nil == _sizesM) {
        _sizesM = [[NSMutableArray alloc] initWithCapacity:5];
    }
    return _sizesM;
}
@end
