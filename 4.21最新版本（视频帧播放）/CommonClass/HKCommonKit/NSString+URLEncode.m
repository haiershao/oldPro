//
//  NSString+URLEncode.m
//  UPPay
//
//  Created by tanghaibo on 13-5-2.
//  Copyright (c) 2013年 liwang. All rights reserved.
//

#import "NSString+URLEncode.h"

@implementation NSString (URLEncode)

- (NSString *)urlEncode{
    return (NSString *) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)[self mutableCopy], NULL, CFSTR("￼=,!$&'()*+;@?\n\"<>#\t :/"), kCFStringEncodingUTF8));
}
@end
