//
//  NSString+Helper.h
//  AtHomeCam
//
//  Created by  on 12-7-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Helper)

/*
 Encrypt string
 */
+ (NSData*) EncryptRequestString:(NSString*) strBody;
+ (NSData*) DecryptData:(NSData*)returnData;
- (NSString *) stringFromMD5;
+ (BOOL)validateCID:(NSString *)CID;
+ (BOOL)validateEmail:(NSString *)email;
+ (BOOL) isLetterOrNumberWithString:(NSString*) string;

+ (BOOL ) stringIsEmpty:(NSString *) aString;
+ (BOOL ) stringIsEmpty:(NSString *) aString shouldCleanWhiteSpace:(BOOL)cleanWhileSpace;

//中 英 符号
+ (BOOL) isValidateAvsName:(NSString *)avsName;

@end
