//
//  HttpRequestV2.m
//  LimitFreeMaster
//
//  Created by tanghaibo on 12-12-18.
//
//

#import "HttpRequestV2.h"
#import "NSString+URLEncode.h"

#define DEBUG_USEPROXY 0

@interface ASIHTTPRequest(protected)

- (void)releaseBlocksOnMainThread;
- (void)reportFinished;
- (void)reportFailure;

@end


@interface HttpRequestV2(){
}
@end

@implementation HttpRequestV2

+ (id)requestWithURLStr:(NSString *)initURLString
                              isPure:(BOOL)pure
                          postData:(NSData *)postData
                               param:(NSDictionary *)param
                          httpMethod:(HttpMethod)httpMethod
                              isAsyn:(BOOL)isAsyn
                             timeout:(NSTimeInterval)timeInterval
                     completionBlock:(ASIRequsetBlock)aCompletionReqBlock
                         failedBlock:(ASIRequsetBlock)aFailedReqBlock{
    
    NSMutableDictionary *mParam = [NSMutableDictionary dictionaryWithDictionary:param];
    [mParam addEntriesFromDictionary:[HttpRequestV2 commonParams]];
    param = mParam;
    HttpRequestV2 *aRequest = [[self alloc] initWithURL:nil];
    
    // https请求，不验证证书的有效性
    [aRequest setValidatesSecureCertificate:NO];
    
    // 设置超时时间
    [aRequest setTimeOutSeconds:timeInterval];
    
    // 本地Hack，添加请求头
    [aRequest addRequestHeader:@"Response-Content-Type" value:@"application/json"];
    
#if DEBUG_USEPROXY
    // 设置请求代理
    
    aRequest.proxyHost = @"127.0.0.1";
    aRequest.proxyPort = 9090;
#endif
    
    NSString *requestUrlStr = initURLString;
    if (httpMethod==HttpMethodPost) {
        if (nil != postData) {
            [aRequest appendPostData:postData ];
        }else if (pure) {
            NSData *data = [NSJSONSerialization dataWithJSONObject:param
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:nil];
            NSMutableString *postString  = [[NSMutableString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            [postString replaceOccurrencesOfString:@" "
                                        withString:@""
                                           options:NSLiteralSearch
                                             range:NSMakeRange(0, [postString length])];
            [postString replaceOccurrencesOfString:@"\n"
                                        withString:@""
                                           options:NSLiteralSearch
                                             range:NSMakeRange(0, [postString length])];
            [aRequest appendPostData:[postString dataUsingEncoding:NSUTF8StringEncoding] ];
        }else{
            [param enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                if ([obj isKindOfClass:[NSURL class]] && [[NSFileManager defaultManager] fileExistsAtPath:[obj path]]) {
                    // 添加上传的文件
                    
                    [aRequest addFile:[obj path] forKey:key];
                }else if ([obj isKindOfClass:[UIImage class]]){
                    // 添加上传的图片
                    
                    NSString *fileName = [key hasSuffix:@".png"] ? key : [NSString stringWithFormat:@"%@.png", key];
                    [aRequest addData:UIImagePNGRepresentation(obj) withFileName:fileName andContentType:@"image/png" forKey:key];
                }else{
                    [aRequest addPostValue:obj forKey:key];
                }
            }];
        }
        
    }else{
        NSMutableString *postString = [NSMutableString stringWithCapacity:0];
        
        if (pure) {
            NSData *data = [NSJSONSerialization dataWithJSONObject:param
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:nil];
            NSString *str = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] urlEncode];
            postString = [NSMutableString stringWithString:str];
            [postString replaceOccurrencesOfString:@" "
                                        withString:@""
                                           options:NSLiteralSearch
                                             range:NSMakeRange(0, [postString length])];
            [postString replaceOccurrencesOfString:@"\n"
                                        withString:@""
                                           options:NSLiteralSearch
                                             range:NSMakeRange(0, [postString length])];
        }else{
            [param enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                if ([obj respondsToSelector:@selector(stringValue)]) {
                    obj = [obj stringValue];
                }
                if ([obj isKindOfClass:[NSString class]]) {
                    [postString appendString:[NSString stringWithFormat:@"%@=%@&", key, obj] ];
                }
            }];
        }
        
        if ([postString length] != 0) {
            NSInteger questLocation = [initURLString rangeOfString:@"?"].location;
            if (NSNotFound!=questLocation) {
                requestUrlStr = [NSString stringWithFormat:@"%@%@", initURLString, postString];
            }else{
                requestUrlStr = [NSString stringWithFormat:@"%@?%@", initURLString, postString];
            }
        }
    }
    
    [aRequest setURL:[NSURL URLWithString:requestUrlStr]];
    
    [aRequest setCompletionReqBlock:aCompletionReqBlock];
    [aRequest setFailedReqBlock:aFailedReqBlock];
    
    if (isAsyn) {
        [aRequest startAsynchronous];
    }else{
        [aRequest startSynchronous];
    }
    
#if DEBUG
    if (httpMethod==HttpMethodGet) {
    }else{
        NSString *postStr = [[NSString alloc] initWithData:aRequest.postBody encoding:NSUTF8StringEncoding];
    }
    
#endif
    return aRequest;
}

+ (id)requestWithURLStr:(NSString *)initURLString
                               param:(NSDictionary *)param
                          httpMethod:(HttpMethod)httpMethod
                              isAsyn:(BOOL)isAsyn
                             timeout:(NSTimeInterval)timeInterval
                     completionBlock:(ASIRequsetBlock)aCompletionBlock
                         failedBlock:(ASIRequsetBlock)aFailedBlock{
    return [self requestWithURLStr:initURLString
                                     isPure:NO
                                   postData:nil
                                      param:param
                                 httpMethod:httpMethod
                                     isAsyn:isAsyn
                                    timeout:timeInterval
                            completionBlock:aCompletionBlock
                                failedBlock:aFailedBlock];
}


+ (id)requestWithURLStr:(NSString *)initURLString
                            postData:(NSData *)postData
                              isAsyn:(BOOL)isAsyn
                             timeout:(NSTimeInterval)timeInterval
                     completionBlock:(ASIRequsetBlock)aCompletionReqBlock
                         failedBlock:(ASIRequsetBlock)aFailedReqBlock{
    return [self requestWithURLStr:initURLString
                                     isPure:NO
                                   postData:postData
                                      param:nil
                                 httpMethod:HttpMethodPost
                                     isAsyn:isAsyn
                                    timeout:timeInterval
                            completionBlock:aCompletionReqBlock
                                failedBlock:aFailedReqBlock];
}

+ (BOOL)isRequestSuccess:(ASIHTTPRequest *)request{
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:request.responseData
                                                             options:NSJSONReadingMutableLeaves | NSJSONReadingAllowFragments
                                                               error:nil];
    NSInteger resultCode = [[[jsonDict objectForKey:@"result"] objectForKey:@"resultCode"] intValue];
    if (nil==jsonDict ||
        resultCode == 0 ||
        resultCode == 2) {
        return YES;
    }
    return NO;
}

#if NS_BLOCKS_AVAILABLE
- (void)setCompletionReqBlock:(ASIRequsetBlock)aCompletionBlock{
	_completionReqBlock = [aCompletionBlock copy];
}

- (void)setFailedReqBlock:(ASIRequsetBlock)aFailedBlock{
	_failureReqBlock = [aFailedBlock copy];
}


- (void)releaseBlocksOnMainThread
{
	NSMutableArray *blocks = [NSMutableArray array];
	if (_completionReqBlock) {
		[blocks addObject:_completionReqBlock];
		_completionReqBlock = nil;
	}
	if (_failureReqBlock) {
		[blocks addObject:_failureReqBlock];
		_failureReqBlock = nil;
	}
	
	[[self class] performSelectorOnMainThread:@selector(releaseBlocks:) withObject:blocks waitUntilDone:[NSThread isMainThread]];
    
    [super releaseBlocksOnMainThread];
}

#endif

- (void)reportFinished
{
#if NS_BLOCKS_AVAILABLE
	if(_completionReqBlock){
		_completionReqBlock(self);
	}
#endif
    [super reportFinished];
}

- (void)reportFailure
{
#if NS_BLOCKS_AVAILABLE
    if(_failureReqBlock){
        _failureReqBlock(self);
    }
#endif
    [super reportFailure];
}

#pragma mark - getter/setter
+ (NSDictionary *)commonParams
{
    static NSDictionary *gCommonParams = nil;
    
    return gCommonParams;
}
@end
