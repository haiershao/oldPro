//
//  HttpRequestV2.h
//  LimitFreeMaster
//
//  Created by tanghaibo on 12-12-18.
//
//
//  2013.3.22 增加对文件的上传支持 by tanghaibo
//  

#import "ASIFormDataRequest.h"

typedef enum HttpMethod{
    HttpMethodGet,
    HttpMethodPost,
}HttpMethod;

#if NS_BLOCKS_AVAILABLE
typedef void (^ASIRequsetBlock)(ASIHTTPRequest *request);
#endif

@interface HttpRequestV2 : ASIFormDataRequest{
    //带ASIHttprequest对象的block
	ASIRequsetBlock _completionReqBlock;
    
	ASIRequsetBlock _failureReqBlock;
}


+ (id)requestWithURLStr:(NSString *)initURLString
                               param:(NSDictionary *)param
                          httpMethod:(HttpMethod)httpMethod
                              isAsyn:(BOOL)isAsyn
                             timeout:(NSTimeInterval)timeInterval
                     completionBlock:(ASIRequsetBlock)aCompletionReqBlock
                         failedBlock:(ASIRequsetBlock)aFailedReqBlock;

+ (id)requestWithURLStr:(NSString *)initURLString
                              isPure:(BOOL)pure
                          postData:(NSData *)postData
                               param:(NSDictionary *)param
                          httpMethod:(HttpMethod)httpMethod
                              isAsyn:(BOOL)isAsyn
                             timeout:(NSTimeInterval)timeInterval
                     completionBlock:(ASIRequsetBlock)aCompletionReqBlock
                         failedBlock:(ASIRequsetBlock)aFailedReqBlock;

+ (id)requestWithURLStr:(NSString *)initURLString
                          postData:(NSData *)postData
                              isAsyn:(BOOL)isAsyn
                             timeout:(NSTimeInterval)timeInterval
                     completionBlock:(ASIRequsetBlock)aCompletionReqBlock
                         failedBlock:(ASIRequsetBlock)aFailedReqBlock;

+ (NSDictionary *)commonParams;

+ (BOOL)isRequestSuccess:(ASIHTTPRequest *)request;

#if NS_BLOCKS_AVAILABLE
- (void)setCompletionReqBlock:(ASIRequsetBlock)aCompletionBlock;
- (void)setFailedReqBlock:(ASIRequsetBlock)aFailedBlock;
#endif

@end