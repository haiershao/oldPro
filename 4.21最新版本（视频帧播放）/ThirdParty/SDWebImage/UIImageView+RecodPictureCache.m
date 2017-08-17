/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "UIImageView+RecodPictureCache.h"
#import "objc/runtime.h"

static char RecordPictureCache_RequestLocalImageKey;
static char RecordPictureCache_RequestObjKey;



@implementation UIImageView (RecodPictureCache)

- (void)sd_RecodPictureCache_setImageWithCid:(NSString*)cid fileName:(NSString*)name recordType:(NSUInteger)type placeholderImage:(UIImage *)placeholder completed:(SDWebImageCompletionBlock)completedBlock {
    [self sd_RecodPictureCache_setImageWithCid:cid fileName:name recordType:type placeholderImage:placeholder options:0 progress:nil completed:completedBlock];
}

- (void)sd_RecodPictureCache_setImageWithCid:(NSString*)cid fileName:(NSString*)name recordType:(NSUInteger)type placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageCompletionBlock)completedBlock {
    
    [self sd_RecodPictureCache_cancelCurrentImageLoad];
    
    if (!cid){
        
        
        return;
    }
    
    NSString* url = [NSString stringWithFormat:@"RecordIcon-%@", name];
    
    __weak UIImageView *wself = self;
    
    NSOperation* op = [[SDImageCache sharedImageCache] queryDiskCacheForKey:url done:^(UIImage *image, SDImageCacheType cacheType) {
        
        if (!wself) {
            
            return;
        }
        
        //如果缓存中有图片直接使用缓存，否则从网络侧加载
        if(image){
            
            wself.image = image;
            
            if (completedBlock ) {
                
                completedBlock(image, nil, SDImageCacheTypeDisk, nil);
            }
            
            return;
        }
        
    }];
    
    if(op) {
        
        self.image = placeholder;
    }
    
    
    objc_setAssociatedObject(self, &RecordPictureCache_RequestObjKey, op, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    
    
}






- (void)sd_RecodPictureCache_cancelCurrentImageLoad {
    
    
    objc_setAssociatedObject(self, &RecordPictureCache_RequestLocalImageKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    NSOperation* op = objc_getAssociatedObject(self, &RecordPictureCache_RequestObjKey);
    
    if (op) {
        [op cancel];
    }
    
    objc_setAssociatedObject(self, &RecordPictureCache_RequestObjKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


@end
