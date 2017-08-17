//
//  NSURL+QueryFomat.m
//  HKCommonKit
//
//  Created by tanghaibo on 13-5-21.
//  Copyright (c) 2013年 cythbgy@gmail.com. All rights reserved.
//

#import "NSURL+QueryFomat.h"

@implementation NSURL (QueryFomat)

- (NSDictionary *)fomatQuery{
    NSMutableDictionary *rst = [NSMutableDictionary dictionaryWithCapacity:0];
    
    NSString *query = self.query;
    if ([query hasPrefix:@"&"]) {
        query = [query substringFromIndex:1];
    }
    if ([query hasSuffix:@"&"]) {
        query = [query substringToIndex:query.length - 1];
    }
    
    NSArray *keysAndValues = [query componentsSeparatedByString:@"&"];
    [keysAndValues enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSArray *pair = [obj componentsSeparatedByString:@"="];
        NSString *key = [pair objectAtIndex:0];
        NSString *value = [pair objectAtIndex:1];
        if (nil != value && key != nil) {
            [rst setObject:value forKey:key];
        }
    }];
    return rst;
}
@end
