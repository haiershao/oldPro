/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "UIImageView+AVSPictureCache.h"
#import "objc/runtime.h"
//#import "UIView+WebCacheOperation.h"
#import "MemberData.h"
#import "AHCServerCommunicator.h"



static  NSMutableDictionary *g_CidInfoDic = nil;

static char Cmd_RequestObjKey;
static char Cmd_RequestLocalImageOp;


#define Success_Reget_Time 600

#define Failed_Reget_Time   30



#define Time          @"time"
#define CIDStr        @"cid"
#define CameraIndex   @"index"
#define ImageType     @"type"

@implementation UIImageView (AVSPictureCache)


//- (void)sd_YaMaXun_setImageWithCid:(NSString*)cid Eid:(NSString*)eid placeholderImage:(UIImage *)placeholder {
//    [self sd_YaMaXun_setImageWithCid:cid Eid:eid placeholderImage:placeholder options:0 progress:nil completed:nil];
//}
//
//- (void)sd_YaMaXun_setImageWithCid:(NSString*)cid Eid:(NSString*)eid placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options {
//    [self sd_YaMaXun_setImageWithCid:cid Eid:eid placeholderImage:placeholder options:options progress:nil completed:nil];
//}
//
//- (void)sd_YaMaXun_setImageWithCid:(NSString*)cid Eid:(NSString*)eid completed:(SDWebImageCompletionBlock)completedBlock {
//    [self sd_YaMaXun_setImageWithCid:cid Eid:eid placeholderImage:nil options:0 progress:nil completed:completedBlock];
//}
//
//- (void)sd_YaMaXun_setImageWithCid:(NSString*)cid Eid:(NSString*)eid placeholderImage:(UIImage *)placeholder completed:(SDWebImageCompletionBlock)completedBlock {
//    [self sd_YaMaXun_setImageWithCid:cid Eid:eid placeholderImage:placeholder options:0 progress:nil completed:completedBlock];
//}
//
//- (void)sd_YaMaXun_setImageWithCid:(NSString*)cid Eid:(NSString*)eid placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options completed:(SDWebImageCompletionBlock)completedBlock {
//    [self sd_YaMaXun_setImageWithCid:cid Eid:eid placeholderImage:placeholder options:options progress:nil completed:completedBlock];
//}


- (void)Request:(NSMutableDictionary*)dic{
    
    NSString* cid = [dic objectForKey:CIDStr];
    
    //如果获取的时候发现CID 的tunnel没创建成功，在延迟一段时间去取
    if ([[MemberData memberData] getAvsTunnelStatusOfCID:cid] != STREAMER_CONN_STATE_CONNECTED) {
    
        [self performSelector:@selector(Request:) withObject:dic afterDelay:Failed_Reget_Time];
        return;
    }
    



}




@end
