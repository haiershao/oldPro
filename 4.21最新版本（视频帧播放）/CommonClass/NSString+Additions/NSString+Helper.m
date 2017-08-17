//
//  NSString+Helper.m
//  AtHomeCam
//
//  Created by  on 12-7-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NSString+Helper.h"
#import <CommonCrypto/CommonDigest.h>
#import <Rvs_Viewer/Rvs_Viewer_API.h>

#define MAX_BUF_SIZE    1024*128

@implementation NSString (Helper)


#pragma mark -
#pragma mark  Encrypt string

+ (NSData*) EncryptRequestString:(NSString*) strBody
{
    unsigned char* dstBuf = NULL;
    NSUInteger dstBufLen = 0;
    
    NSUInteger ret = [[Rvs_Viewer defaultViewer] encHttpBuffWithSrcBuf:[strBody UTF8String]
                                                             SrcBufLen:strlen([strBody UTF8String])
                                                                DstBuf:&dstBuf
                                                             DstBufLen:&dstBufLen];
    
    
    NSData *EncryptRequestData = [ NSData dataWithBytes:dstBuf length:dstBufLen];
    
    if (ret == 1){
    
        [[Rvs_Viewer defaultViewer] freeEncOutHttpBuff:dstBuf];
    }
    
    return EncryptRequestData;
}


+ (NSData*) DecryptData:(NSData*)returnData
{
//#define MAX_BUF_SIZE    1024*128
    char buf_to_read[MAX_BUF_SIZE];
    int				len = 0;
	
	
	len = [returnData length];
	
	if (len == 0)
		return nil;
    memset(buf_to_read, 0, MAX_BUF_SIZE);
	
	[returnData getBytes:buf_to_read];
    
    [[Rvs_Viewer defaultViewer] decHttpBuffWithBuf:buf_to_read BufLen:len];
	
    NSData  *DncryptRequestData = [NSData dataWithBytes:buf_to_read length:strlen(buf_to_read)];

    return DncryptRequestData;

}

- (NSString *) stringFromMD5
{
    
    if(self == nil || [self length] == 0)
        return nil;
    
    const char *value = [self UTF8String];
    
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, strlen(value), outputBuffer);
    
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    
    return outputString;
}

+ (BOOL)validateEmail:(NSString *)email 
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"; 
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

+ (BOOL)validateCID:(NSString *)CID
{
    if ([CID hasPrefix:@"0"]) {
        return NO;
    }

    NSString *CIDRegex = @"^[0-9]{8}$";
    NSPredicate *CIDTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CIDRegex];
    return [CIDTest evaluateWithObject:CID];
}

+ (BOOL) isLetterOrNumberWithString:(NSString*) string
{
    NSString *regex = @"^[A-Za-z0-9_ ]+$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];

    if ([predicate evaluateWithObject:string] == YES) {
        //implement
        return YES;
    }else {
        return NO;
    }
}


+ (BOOL ) stringIsEmpty:(NSString *) aString {
    
    if (![aString isKindOfClass:[NSString class]]) {
        return YES;
    }
    
    if ((NSNull *) aString == [NSNull null]) {
        return YES;
    }
    if ([aString isEqualToString:@"(null)"]) {
        return YES;
    }
    
    if (aString == nil) {
        return YES;
    } else if ([aString length] == 0) {
        return YES;
    } else {
        aString = [aString stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([aString length] == 0) {
            return YES;
        }
    }
    
    return NO; 
}

+ (BOOL ) stringIsEmpty:(NSString *) aString shouldCleanWhiteSpace:(BOOL)cleanWhileSpace {
    
    if ((NSNull *) aString == [NSNull null]) {
        return YES;
    }
    
    if (aString == nil) {
        return YES;
    } else if ([aString length] == 0) {
        return YES;
    } 
    
    if (cleanWhileSpace) {
        aString = [aString stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([aString length] == 0) {
            return YES;
        }
    }
    
    return NO; 
}

+ (BOOL) isValidateAvsName:(NSString *)avsName{

    NSString *nameRegex = @"[@%#|?/&\\-_+=\'~$:;<>,.{}()*!\"\\^\\]\\[a-zA-Z0-9_\u4e00-\u9fa5]*";
    NSPredicate *nameTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", nameRegex];
    return [nameTest evaluateWithObject:avsName];

}

@end
