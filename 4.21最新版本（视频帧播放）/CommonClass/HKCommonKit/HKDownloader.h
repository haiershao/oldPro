//
//  HKDownloader.h
//  HKCommonKit
//
//  Created by tanghaibo on 13-5-27.
//  Copyright (c) 2013年 cythbgy@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "HttpRequestV2.h"

typedef void (^ DownloadProgressBlock) (CGFloat progress);
typedef void (^ RecognizeTotleSizeBlock) (long long totle);
typedef void (^ DownloadSeedBlock) (CGFloat speed);

@interface HKDownloader : ASIHTTPRequest

+ (HKDownloader *)download:(NSString *)URLStr
                   destPath:(NSString *)destPath
          recognizeTotleSize:(RecognizeTotleSizeBlock)recognizeTotleSizeBlock
               progressBlock:(DownloadProgressBlock)progressBlock
           downloadSeedBlock:(DownloadSeedBlock)downloadSeedBlock
                     success:(ASIRequsetBlock)successBlock
                        fail:(ASIRequsetBlock)failBlock;
@end