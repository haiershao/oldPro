//
//  NSData+AES.h
//  HuaWo
//
//  Created by liuhai on 16/5/3.
//  Copyright © 2016年 circlely. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
@interface NSData (AES)
//加密
- (NSData *) AES256_Encrypt:(NSString *)key;

//解密
- (NSData *) AES256_Decrypt:(NSString *)key;

//追加64编码
- (NSString *)newStringInBase64FromData;

//同上64编码
+ (NSString*)base64encode:(NSString*)str;
@end
