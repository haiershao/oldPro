//
//  NSData+AES256.h
//  HuaWo
//
//  Created by Hwawo on 16/5/2.
//

#import <Foundation/Foundation.h>

@interface NSData (AES256)
-(NSData *) aes256_encrypt:(NSString *)key;
-(NSData *) aes256_decrypt:(NSString *)key;
- (const char *)sha3AsCstring;
- (NSData *)sha3AsData;
- (NSString *)sha3AsString;
@end
