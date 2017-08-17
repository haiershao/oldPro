//
//  MemberData.h
//  AtHomeCam
//
//  Created by ker on 3/26/13.
//
//

#import <Foundation/Foundation.h>
#import "AVSConfigData.h"
//cid list item
extern NSString *const kMemberCIDNumber;
extern NSString *const kMemberCIDUserName;
extern NSString *const kMemberCIDPassword;


@interface MemberData : NSObject
{
    
@private
	NSMutableDictionary *memberDictionary;
    NSMutableDictionary* CIDDetailInfoDict;
    
    NSMutableDictionary *memberOnlineStateDict;
    NSMutableDictionary *memberTunnelStateDict;
    
}



+(MemberData*)memberData;
//正常登陆
- (BOOL)isMemberLogin;
//是否是体验登陆
- (BOOL)isExperienceLogin;


- (BOOL)setMemberAccount:(NSString *)account;
- (NSString *)getMemberAccount;
- (BOOL)setMemberPassword:(NSString *)password;
- (NSString *)getMemberPassword;
- (BOOL)setMemberIsRemeber:(BOOL)isRemeber;
- (BOOL)getMemberIsRemeber;
- (BOOL)setMemberNickName:(NSString *)nickName;
- (BOOL)setMemberUid:(NSString *)uid;
- (NSString *)getMemberNickName;

- (BOOL)setMemberSessionID:(NSString *)session;
- (NSString *)getMemberSessionID;



- (NSArray *)getMemberCIDList;
- (BOOL)updateMemberCIDList:(NSArray *)CIDListArray;
- (BOOL)isCIDExist:(NSString*)CIDNumber;


//註銷的時候清除所有的記錄
- (void)removeAllCID;
- (void)removeAllMemberData;


//單個CID方法
- (NSDictionary*)getMemberCIDInfo:(NSString*)cid;
- (void)updateOneCID:(NSString *)old withDictionary:(NSDictionary *)newCIDDictionary;
- (void)deleteOneCID:(NSString *)cid;
- (BOOL)addNewCID:(NSDictionary *)dictionary;
- (void)addOneLocalCID:(NSString*)cid UserName:(NSString*)username Pwd:(NSString*)pwd;
- (void)updateOneLocalCID:(NSString*)cid UserName:(NSString*)username Pwd:(NSString*)pwd;
- (void)deleteOneLocalCID:(NSString*)cid;

// avs presence status
- (int)getAvsStatusOfCID:(NSString *)cid;
- (void)setAvsStatus:(int)status forCID:(NSString*)cid;
- (void)removeAvsStatusforCID:(NSString*)cid;
- (void)clearAllAvsStatus;

// avs tunnel status
- (int)getAvsTunnelStatusOfCID:(NSString *)cid;
- (void)setAvsTunnelStatus:(int)status forCID:(NSString*)cid;
- (void)removeAvsTunnelStatusforCID:(NSString*)cid;
- (void)clearAllAvsTunnelStatus;


- (AVSType)getAvsTypeOfCID:(NSString *)cid;
- (NSString*)getAvsNameOfCID:(NSString *)cid;



- (void)updateDetailConfigInfo:(AVSConfigData*)configData ForCID:(NSString*)CID;

- (AVSConfigData*)getDetailConfigInfoForCID:(NSString*)CID;

//保存上次登录的用户名
- (void)setLastLoginUsername:(NSString *)name;
- (NSString *)getLastLoginUsername;






@end
