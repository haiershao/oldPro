//
//  NSString+encrypto.h
//  kkkkkkk
//
//  Created by Hwawo on 16/4/26.
//  Copyright © 2016年 Hwawo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (encrypto)
- (NSString *) md5;
- (NSString *) sha1;
- (NSString *) sha1_base64;
- (NSString *) md5_base64;
- (NSString *) base64;
-(NSData *) aes256_encrypt:(NSString *)key;
-(NSData *) aes256_decrypt:(NSString *)key;
- (NSString *)encodeToPercentEscapeString: (NSString *) input;//url编码
- (NSString *)decodeFromPercentEscapeString: (NSString *) input;//url解码
@end
