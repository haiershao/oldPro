//
//  NetWorkInterfaceBase.h
//  AtHomeCam
//
//  Created by Circlely Networks on 7/12/13.
//


#import "CloudSystemBase.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "SBJson.h"
#import "NSString+Helper.h"
#import "CommonUtility.h"

#define kCloudSysSuccessCode 0
#define kStatus @"status"


@interface CloudSystemBase ()

@property (nonatomic, strong) ASIHTTPRequest* request;
@property (nonatomic, strong) ASIFormDataRequest* dataRequest;
@property (nonatomic, strong) NSString* httpMethod;
@property (nonatomic, strong) NSDictionary* returnDictionary;

@property (nonatomic) BOOL isNeedEncryptData;
@property (nonatomic) NSTimeInterval duration;

-(NSDictionary*)responseData;

@end

@implementation CloudSystemBase
@synthesize request;
@synthesize dataRequest;
@synthesize returnCode;

@synthesize returnDictionary;
@synthesize httpMethod;

-(id)initWithEncryptData:(BOOL)isNeedEncrypt
              httpMethod:(NSString*)method
                 timeout:(NSTimeInterval)aDuration
{
    self = [super init];
    
    if (self) {
        self.isNeedEncryptData = isNeedEncrypt;
        self.httpMethod = method;
        self.duration = aDuration;
        self.isSyncRequest = NO;
    }
    
    return self;
}

-(id)init
{
    self = [super init];
    
    if (self) {
        self.isNeedEncryptData = YES;
        self.httpMethod = HTTP_POST;
        self.duration = CLOUD_SYS_DEFAULT_TIME_OUT;
        self.isSyncRequest = NO;
    }
    
    return self;
}

-(void)startRequestWithCompletion:(NetworkBasicBlock)completionBlock
                      failedBlock:(NetworkBasicBlock)errorBlock
{
    __typeof(self) __block safeSelf = self;
    
    ASIBasicBlock defaultErrorBlock = ^(void){
        
        [safeSelf onRequestFailed];
        
        errorBlock();
        
        [safeSelf cancelRequest];

        NSLog(@"errorBlock NetWorkInterfaceBase");
    };
    
    ASIBasicBlock defaultCompletionBlock = ^(void){
        NSDictionary *returnDic = [safeSelf responseData];
        safeSelf.returnCode = [returnDic objectForKey:kStatus];
        safeSelf.returnDictionary = returnDic;

        
        if ([safeSelf isRequestLogicSuccess]) {
            [safeSelf onRequestCompleted];
            completionBlock();
        }
        else {
            [safeSelf onRequestFailed];
            errorBlock();
        }
        
        [safeSelf cancelRequest];
        
        NSLog(@"completionBlock NetWorkInterfaceBase");
    };
    
    if ([self onShouldStartRequest]) {
		
		//APP_LOG_INF(@"Cloud Server HTTP Request URL[%@]", [self onRequestedURL]);
        [self cancelRequest];
		
        [self setRequest:[ASIHTTPRequest requestWithURL:[self onRequestedURL]]];
        
        self.request.requestMethod = self.httpMethod;
		
		NSDictionary* bodyDic = [self onRequestBody];
		
		if (bodyDic) {
			self.request.postBody = [self dictionaryToData:bodyDic];
		}
		
		self.request.requestHeaders = [self onRequestHeader];
		//APP_LOG_INF(@"Cloud Server HTTP Request Header[%@]", [self onRequestHeader]);
        
        [request setTimeOutSeconds:self.duration];
        
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
        [request setShouldContinueWhenAppEntersBackground:YES];
#endif
        
        [request setCompletionBlock:defaultCompletionBlock];
        [request setFailedBlock:defaultErrorBlock];
        
        if (self.isSyncRequest) {
            [request startSynchronous];
        }
        else {
            [request startAsynchronous];
        }
    }
    else{
        defaultErrorBlock();
    }
}

-(void)startRequest
{
    __typeof(self) __block safeSelf = self;
    
    ASIBasicBlock completionBlock = ^(void){
        NSDictionary *returnDic = [safeSelf responseData];
        safeSelf.returnCode = [returnDic objectForKey:kStatus];
        safeSelf.returnDictionary = returnDic;
        

        if ([safeSelf isRequestLogicSuccess]) {
            [safeSelf onRequestCompleted];
        }
        else{
            [safeSelf onRequestFailed];
        }
        
        [safeSelf cancelRequest];

        NSLog(@"completionBlock NetWorkInterfaceBase");
    };
    
    ASIBasicBlock errorBlock = ^(void){
        [safeSelf onRequestFailed];
        [safeSelf cancelRequest];
        NSLog(@"errorBlock NetWorkInterfaceBase");
    };
    
    if ([self onShouldStartRequest]) {
		
		//APP_LOG_INF(@"Cloud Server  HTTP Request URL[%@]", [self onRequestedURL]);
		
        [self cancelRequest];
        [self setRequest:[ASIHTTPRequest requestWithURL:[self onRequestedURL]]];
        
        self.request.requestMethod = self.httpMethod;
        self.request.postBody = [self dictionaryToData:[self onRequestBody]];
		self.request.requestHeaders = [self onRequestHeader];
		//APP_LOG_INF(@"Cloud Server HTTP Request Header[%@]", [self onRequestHeader]);
		
        [request setTimeOutSeconds:self.duration];
        
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
        [request setShouldContinueWhenAppEntersBackground:YES];
#endif
        
        [request setCompletionBlock:completionBlock];
        [request setFailedBlock:errorBlock];
        
        if (self.isSyncRequest) {
            [request startSynchronous];
        }
        else {
           [request startAsynchronous];
        }
    }
    else{
        errorBlock();
    }
}

-(NSDictionary*)responseData
{
    NSData* receivedData = [request responseData];
	
	NSString* s = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding] ;
	
	//APP_LOG_INF(@"recv UnEncryptdata From CloudServer [%@]", s);
	

    if (self.isNeedEncryptData) {
        receivedData = [NSString DecryptData:receivedData];
		
		NSString* m = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding] ;
		
		//APP_LOG_INF(@"recv Encryptdata From CloudServer [%@]", m);
    }
    
    if (receivedData == nil){
        return nil;
    }
    
    NSError* error = nil;
    NSDictionary* resultDict;
    
    if (kiOSVersionIs5)
    {
        resultDict = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:receivedData
                                                                    options:kNilOptions
                                                                      error:&error];
        if(error !=nil)
        {
            NSLog(@"%@",[NSString stringWithFormat:@"%@",error]);
        }

    }else{
        resultDict = (NSDictionary*)[self parseJsonResponse:receivedData
                                                      error:&error];
        
        if(error !=nil)
            NSLog(@"%@",[NSString stringWithFormat:@"%@",error]);
    }
    
    if (!error) {
        return resultDict;
    }
    
    return nil;
}

-(void)cancelRequest
{
    [request clearDelegatesAndCancel];
}

-(BOOL)isRequestLogicSuccess
{
    return [returnCode integerValue] == kCloudSysSuccessCode;
}

- (id)parseJsonResponse:(NSData *)data error:(NSError **)error {
	
	NSString* responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	SBJsonParser *jsonParser = [[SBJsonParser alloc]init];
	
	NSError* parserError = nil;
	id result = [jsonParser objectWithString:responseString error:&parserError];
	
    if( parserError )
        NSLog(@"%@",[NSString stringWithFormat:@"%@",parserError]);
    	
	return result;
	
}

- (NSMutableData *)dictionaryToData:(NSDictionary *)dictionary
{
    NSString *string = [dictionary JSONRepresentation];
	
	//APP_LOG_INF(@"HTTP Request Body[%@]", string);
	
    NSData *data = nil;
    
    if (self.isNeedEncryptData) {
        data = [NSString EncryptRequestString:string];
    }else{
        data = [string dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    return [NSMutableData dataWithData:data];
}

-(NSString*)getErrorMessage
{
//    if ([self isRequestLogicSuccess]) {
//        return nil;
//    }
//    
    return [CommonUtility getDefaultErrorString:self.returnCode];
}

#pragma mark - virtual function
-(NSURL*)onRequestedURL
{
    //this method is callback which will be implemented by subclass.
    return nil;
}

-(NSDictionary*)onRequestBody
{
    //this method is callback which will be implemented by subclass.
    return nil;
}

-(NSMutableDictionary*)onRequestHeader {

	return nil;
}

-(void)onRequestCompleted
{
    //this method is callback which will be implemented by subclass.
    return;
}

-(void)onRequestFailed
{
    //this method is callback which will be implemented by subclass.
    return;
}

-(BOOL)onShouldStartRequest
{
    //this method is callback which will be implemented by subclass.
    return YES;
}

@end
