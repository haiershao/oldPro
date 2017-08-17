
//
//  MemberData.m
//  AtHomeCam
//
//  Created by ker on 3/26/13.
//
//

#import "MemberData.h"
#import "NSString+Helper.h"
#import "NSObject+SBJson.h"
#import "AHCServerCommunicator.h"


#define kMemberInfoDictionary @"memberInfoDictionary"
#define kMemberVersion        @"memberVersion"
#define kMemberOSVersion        @"memberOSVersion"
#define kMemberServiceVersion        @"memberServiceVersion"

#define kMemberAccount     @"memberAccount"
#define kMemberPassword    @"memberPassword"
#define kMemberSessionID   @"memberSessionID"
#define kMemberCIDList     @"memberCIDList"     //存储的是CID的列表信息
#define kMemberCIDDetailInfos     @"memberCIDDetailInfos" //存储的CID列表中每个CID的详细信息
#define kMemberIsRemeber   @"memberIsRemeber"
#define kMemberNickName    @"nickname"
#define kMemberUid    @"uid"



NSString *const kMemberCIDNumber     = @"cid";
NSString *const kMemberCIDUserName   = @"cuser";
NSString *const kMemberCIDPassword   = @"cpasswd";




#define K_MOST_CID_NUMBER_WITHOUT_LOGIN 1 //当体验登陆时允许添加的最大cid数

static MemberData *memberData = nil;

@implementation MemberData

+(void)initialize
{
	memberData = [[MemberData alloc] init];
}

+(MemberData*)memberData
{
	return memberData;
}

- (id) init
{
	self = [super init];
	
	if (self) {
		
		if ([[NSUserDefaults standardUserDefaults] objectForKey:kMemberInfoDictionary]) {
			
			id resultData = [[NSUserDefaults standardUserDefaults] objectForKey:kMemberInfoDictionary];
			
			if ([resultData isKindOfClass:[NSDictionary class]]) {
				memberDictionary = [[NSMutableDictionary alloc] initWithDictionary:resultData];
			}
			else if ([resultData isKindOfClass:[NSData class]])
			{
				NSError* error = nil;
				resultData = [NSString DecryptData:resultData];
				
				memberDictionary = [[NSMutableDictionary alloc] initWithDictionary:[NSJSONSerialization JSONObjectWithData:resultData
																												   options:kNilOptions
																													 error:&error]];
				
				if (memberDictionary.count == 0) {
					NSDictionary *tmpDictionary = @{kMemberAccount:     @"",
													kMemberPassword:    @"",
													kMemberIsRemeber:   @"",
													kMemberSessionID:   @"",
													kMemberCIDList:     [NSMutableArray array]};
					
					[memberDictionary setDictionary:tmpDictionary];
				}
				else {
					//如果从2.0.13之前的版本升级至3.0.要把之前的缓存的cid详情信息去掉，这部分由sdk保存
					if ([memberDictionary objectForKey:kMemberCIDDetailInfos]){
						
						[memberDictionary removeObjectForKey:kMemberCIDDetailInfos];
					}
					
				}
			}
			
		}else{
			NSMutableArray *array = [[NSMutableArray alloc] init];
			NSDictionary *tmpDictionary = @{kMemberAccount:     @"",
											kMemberPassword:    @"",
											kMemberIsRemeber:   @"",
											kMemberSessionID:   @"",
											kMemberCIDList:     array};
			
			memberDictionary = [[NSMutableDictionary alloc] initWithDictionary:tmpDictionary];
		}
		
		memberOnlineStateDict = [[NSMutableDictionary alloc] initWithCapacity:1];
        memberTunnelStateDict = [[NSMutableDictionary alloc] initWithCapacity:1];
        CIDDetailInfoDict = [[NSMutableDictionary alloc] initWithCapacity:1];

	}

	
	return self;
}

- (BOOL)setMemberAccount:(NSString *)account
{

    [memberDictionary setValue:account forKey:kMemberAccount];
    [self saveMemberInfo];
    return YES;

}

- (BOOL)setMemberNickName:(NSString *)nickName
{
    [memberDictionary setValue:nickName forKey:kMemberNickName];
    [self saveMemberInfo];
    return YES;
}

- (BOOL)setMemberUid:(NSString *)uid
{
    [memberDictionary setValue:uid forKey:kMemberNickName];
    [self saveMemberInfo];
    return YES;
}

- (NSString *)getMemberAccount
{
	return [memberDictionary objectForKey:kMemberAccount];
}

- (NSString *)getMemberNickName
{
    
    return [memberDictionary objectForKey:kMemberNickName];
}

- (BOOL)setMemberPassword:(NSString *)password
{

    [memberDictionary setValue:password forKey:kMemberPassword];
    [self saveMemberInfo];
    return YES;
	
}

- (NSString *)getMemberPassword
{
	return [memberDictionary objectForKey:kMemberPassword];
}

- (BOOL)setMemberIsRemeber:(BOOL)isRemeber
{
	
    if (!isRemeber) {
        
        [memberDictionary setValue:@"0" forKey:kMemberIsRemeber];
        
    }else{
        
        [memberDictionary setValue:@"1" forKey:kMemberIsRemeber];
    }
    
    [self saveMemberInfo];
    return YES;
	
}

- (BOOL)getMemberIsRemeber
{
	//只有標記了0才是NO.否則爲YEs
	if ([[memberDictionary objectForKey:kMemberIsRemeber] isEqualToString:@"0"]) {
		return NO;
	}
	return YES;
}



- (BOOL)setMemberSessionID:(NSString *)session
{

    [memberDictionary setValue:session forKey:kMemberSessionID];
    [self saveMemberInfo];
    return YES;

}

- (NSString *)getMemberSessionID
{
	return [memberDictionary objectForKey:kMemberSessionID];
}


#pragma mark - 

- (void)NotifyCIDListChange {
    
    [[AHCServerCommunicator sharedAHCServerCommunicator] loadLocalCIDConfigFromSDK];
}


#pragma mark -
#pragma mark - About CID List -

- (BOOL)updateMemberCIDList:(NSArray *)CIDListArray
{
    [memberDictionary setValue:CIDListArray forKey:kMemberCIDList];
    [self saveMemberInfo];
    
    //通知cidlist 变化
    [self NotifyCIDListChange];
    
    return YES;

}



- (NSArray *)getMemberCIDList
{
	//return [memberDictionary objectForKey:kMemberCIDList];
	
	NSMutableArray* cidlist = [NSMutableArray arrayWithArray:[memberDictionary objectForKey:kMemberCIDList]];
	
	
	[cidlist sortUsingComparator:^(id obj1, id obj2){
		
		NSDictionary* dic1= (NSDictionary*)obj1;
		NSDictionary* dic2= (NSDictionary*)obj2;
		
		
		NSString* cid1 = [dic1 objectForKey:kMemberCIDNumber];
		NSString* cid2 = [dic2 objectForKey:kMemberCIDNumber];
		
		
		NSNumber* onlinenum1 = [memberOnlineStateDict objectForKey:cid1];
		NSNumber* onlinenum2 = [memberOnlineStateDict objectForKey:cid2];
		
		
		int online1 = (onlinenum1 ? [onlinenum1 intValue] : -1);
		int online2 = (onlinenum2 ? [onlinenum2 intValue] : -1);
        
        
        BOOL onlinetype1 = online1 == PEER_STATUS_STATE_ONLINE || online1 == PEER_STATUS_STATE_ERRUSERPWD;
        BOOL onlinetype2 = online2 == PEER_STATUS_STATE_ONLINE || online2 == PEER_STATUS_STATE_ERRUSERPWD;
        

        if (onlinetype1 && !onlinetype2) {
        
            return NSOrderedAscending;
        
        }
        else if (onlinetype2 && !onlinetype1) {
        
            return NSOrderedDescending;
        }
        else {
            
            if (online1 == PEER_STATUS_STATE_ONLINE && online2 != PEER_STATUS_STATE_ONLINE) {
                
                    return NSOrderedAscending;
                
            }
            else if (online1 != PEER_STATUS_STATE_ONLINE && online2 == PEER_STATUS_STATE_ONLINE) {
                
                return NSOrderedDescending;
                    
            }
            else {
                
                return [cid1 compare:cid2];
                
            }
            
        }
            
    }];
        
      
        
        
        

	
	return cidlist;
	
}

- (BOOL)isCIDExist:(NSString*)CIDNumber
{
    
    NSArray* cidArray = [memberDictionary objectForKey:kMemberCIDList];
    
	for (NSDictionary* CIDInfo in cidArray) {
		if ([CIDNumber isEqualToString:[CIDInfo objectForKey:kMemberCIDNumber]])
		{
			return YES;
		}
	}
	
	return NO;
}

#pragma mark -
#pragma mark - About on CID Detail Info —

- (void)updateDetailConfigInfo:(AVSConfigData*)configData ForCID:(NSString*)CID {
    
    [CIDDetailInfoDict setObject:[configData copy] forKey:CID];
    
    
}
- (AVSConfigData*)getDetailConfigInfoForCID:(NSString*)CID {
    
   
    AVSConfigData* conf = [CIDDetailInfoDict objectForKey:CID];
    
    if (conf){
    
        //返回一个拷贝这样外部使用的时候就不会影响到CIDDetailInfoDict的值
        return [conf copy];
    }
    else {
    
        return nil;
    }
}


#pragma mark -
#pragma mark - About ont CID Method -

- (int)getAvsStatusOfCID:(NSString *)cid
{
	
    NSString* statusStr = [memberOnlineStateDict objectForKey:cid];
    
	if (!statusStr) {
    
		return PEER_STATUS_STATE_UNKNOWN;
		
	}
    
    return [statusStr intValue];
}

- (void)setAvsStatus:(int)status forCID:(NSString*)cid
{
    [memberOnlineStateDict setObject:[NSString stringWithFormat:@"%d", status] forKey:cid];
}

- (void)removeAvsStatusforCID:(NSString*)cid {

    [memberOnlineStateDict removeObjectForKey:cid];
}

- (void)clearAllAvsStatus {

    [memberOnlineStateDict removeAllObjects];
}

- (int)getAvsTunnelStatusOfCID:(NSString *)cid {
    
    NSString* tunnelStatusStr = [memberTunnelStateDict objectForKey:cid];
    
    if (!tunnelStatusStr) {
    
       return STREAMER_CONN_STATE_CONNECT_ERROR;
    }
    
    return [tunnelStatusStr intValue];
    
}

- (void)setAvsTunnelStatus:(int)status forCID:(NSString*)cid {
    
    [memberTunnelStateDict setObject:[NSString stringWithFormat:@"%d", status] forKey:cid];
}

- (void)removeAvsTunnelStatusforCID:(NSString*)cid {

    [memberTunnelStateDict removeObjectForKey:cid];

}

- (void)clearAllAvsTunnelStatus {
    
     [memberTunnelStateDict removeAllObjects];
}


- (AVSType)getAvsTypeOfCID:(NSString *)cid
{
    
    AVSConfigData* config = [CIDDetailInfoDict objectForKey:cid];
    
    if(!config){
    
        return  DefaultAVS;
        
    }else
    if(config.streamerInfo.streamerType != WindowsAVS && config.streamerInfo.streamerType != iOSAVS && config.streamerInfo.streamerType != MacAVS && config.streamerInfo.streamerType != AndroidPhoneAVS && config.streamerInfo.streamerType != IPCameraAVS && config.streamerInfo.streamerType != WebcamAVS && config.streamerInfo.streamerType != AndroidTVAVS) {
        
        return  DefaultAVS;
        
    }else{
    
        return config.streamerInfo.streamerType;
        
    }
    
}

- (NSString*)getAvsNameOfCID:(NSString *)cid {

    AVSConfigData* config = [CIDDetailInfoDict objectForKey:cid];
    
    if (!config || !config.streamerInfo.deviceName || [config.streamerInfo.deviceName isEqualToString:@""]) {
    
        return  NSLocalizedString(@"default_new_device_name", nil);
    }
    else {
    
        return config.streamerInfo.deviceName;
    }


}

- (NSDictionary*)getMemberCIDInfo:(NSString*)cid
{
    NSMutableArray* cidlist = [memberDictionary objectForKey:kMemberCIDList];
    
	for (NSDictionary* CIDInfo in cidlist) {
        
		if ([cid isEqualToString:[CIDInfo objectForKey:kMemberCIDNumber]])
		{
			return CIDInfo;
		}
	}
	
	return nil;
}

- (void)updateOneCID:(NSString *)oldCIDString withDictionary:(NSDictionary *)newCIDDictionary
{
	//更新記錄CID等信息的Array
	NSMutableArray *memberArray = [[NSMutableArray alloc] initWithArray:[memberDictionary objectForKey:kMemberCIDList]];
	
	for (NSInteger index = 0; index < memberArray.count; index++) {
		NSDictionary* CIDItem = memberArray[index];
		
		if ([oldCIDString isEqualToString:[CIDItem objectForKey:kMemberCIDNumber]])
		{
			NSMutableDictionary* newCIDItem = [NSMutableDictionary dictionaryWithDictionary:CIDItem];
			
//			[CIDItem enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
//				if ([newCIDDictionary objectForKey:key]) {
//					[newCIDItem setObject:[newCIDDictionary objectForKey:key] forKey:key];
//				}
//			}];
			
			
			NSArray* keys = [newCIDItem allKeys];
			
			for(NSString* k in keys) {
				
				id value = [newCIDDictionary objectForKey:k];
				
				if(value != nil){
					
					[newCIDItem setObject:value forKey:k];
				}
			}
			
			
			
			[memberArray replaceObjectAtIndex:index withObject:newCIDItem];
			[memberDictionary setObject:memberArray forKey:kMemberCIDList];
			[self saveMemberInfo];
			
			//通知cidlist 变化
			[self NotifyCIDListChange];
			
			break;
			
		}
	}
	
}

- (void)deleteOneCID:(NSString *)cid
{
	NSMutableArray *memberArray = [[NSMutableArray alloc] initWithArray:[memberDictionary objectForKey:kMemberCIDList]];
	int removeIndex = -1;
	if ([memberArray count] != 0) {
		int objectIndex = 0;
		for (NSDictionary *dic in memberArray) {
			if ([cid isEqualToString:[dic objectForKey:kMemberCIDNumber]]) {
				removeIndex = objectIndex;
				//[memberArray removeObjectAtIndex:objectIndex];
				HWLog(@"現在找到需要刪除的CID了！");
			}
			objectIndex+=1;
			HWLog(@"個數是~%d",objectIndex);
		}
	}
	HWLog(@"保存數據了！！");
	if (removeIndex != -1) {
		[memberArray removeObjectAtIndex:removeIndex];
	}
	[memberDictionary setObject:memberArray forKey:kMemberCIDList];

	[self saveMemberInfo];
	//通知cidlist 变化
	[self NotifyCIDListChange];
}

- (void)removeAllMemberData
{
	[[MemberData memberData] setMemberSessionID:@""];
	[[MemberData memberData] setMemberAccount:@""];
	[[MemberData memberData] setMemberPassword:@""];
	[[MemberData memberData] updateMemberCIDList:[NSArray array]];
	[[MemberData memberData] setMemberIsRemeber:YES];
    [[MemberData memberData] setMemberNickName:@""];
	[self removeAllCID];
}

- (void)removeAllCID
{
	[memberDictionary removeObjectForKey:kMemberCIDList];
	[memberDictionary setObject:[NSArray array] forKey:kMemberCIDList];
    
    [CIDDetailInfoDict removeAllObjects];
	[self saveMemberInfo];
    
}

- (BOOL)addNewCID:(NSDictionary *)dictionary
{
    id array = [memberDictionary objectForKey:kMemberCIDList];
    if ([[array description] length] == 0) {
        NSMutableArray *cidListArray = [[NSMutableArray alloc] init];
        [cidListArray addObject:dictionary];
        [memberDictionary setValue:cidListArray forKey:kMemberCIDList];
        [self saveMemberInfo];
        
        //通知cidlist 变化
        [self NotifyCIDListChange];
        
        return YES;
    }else{
        NSMutableArray *newArray = [NSMutableArray arrayWithArray:[memberDictionary valueForKey:kMemberCIDList]];
        [newArray addObject:dictionary];
        [memberDictionary setValue:newArray forKey:kMemberCIDList];
        [self saveMemberInfo];
        
        //通知cidlist 变化
        [self NotifyCIDListChange];
        
        return YES;
    }
    return NO;

}

- (void)addOneLocalCID:(NSString*)cid UserName:(NSString*)username Pwd:(NSString*)pwd {

    
    
    NSArray* cidlist = [memberDictionary objectForKey:kMemberCIDList];
    
    for (NSDictionary* cidinfo in cidlist) {
    
        NSString* cidInList = [cidinfo objectForKey:kMemberCIDNumber];
        
        if(cidInList && [cidInList isEqualToString:cid]) {
        
        
            HWLog(@"warning, cid[%@] is in local cid list");
            
            return;
        }
    
    }
    
    
    
    
    NSDictionary* cidInfoDic =@{
                                kMemberCIDNumber : cid,
                                kMemberCIDUserName : username,
                                kMemberCIDPassword : pwd,
                                
                                };
    //自己构建一个结构体填充到cid list里
    [self addNewCID:cidInfoDic];

}


- (void)updateOneLocalCID:(NSString*)cid UserName:(NSString*)username Pwd:(NSString*)pwd {


    NSDictionary* cidInfoDic =@{
                                kMemberCIDNumber : cid,
                                kMemberCIDUserName : username,
                                kMemberCIDPassword : pwd,

                                };
    //自己构建一个结构体填充到cid list里
    [self updateOneCID:cid withDictionary:cidInfoDic];
}

- (void)deleteOneLocalCID:(NSString*)cid {

    [self deleteOneCID:cid];
    //删除本地持久化的MuteStatus
    //[CIDMuteStateDic removeObjectForKey:cid];
}


- (void)saveMemberInfo
{
	NSString *string  = [memberDictionary JSONRepresentation];
	NSData *data      = [NSString EncryptRequestString:string];
	
	
	[[NSUserDefaults standardUserDefaults] setObject:data forKey:kMemberInfoDictionary];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	//    [[NSUserDefaults standardUserDefaults] setObject:memberDictionary forKey:kMemberInfoDictionary];
	//    [[NSUserDefaults standardUserDefaults] synchronize];
	//    HWLog(@"saveMemberInfo %@",memberDictionary);
}


- (BOOL)isMemberLogin
{
	if ([[memberDictionary objectForKey:kMemberSessionID] isEqualToString:@""] ||
		[memberDictionary objectForKey:kMemberSessionID] == nil) {
		return NO;
	}
	return YES;
}



//是否是体验登陆
- (BOOL)isExperienceLogin {

	NSArray* memArr = [memberDictionary objectForKey:kMemberCIDList];
	
	if(![self isMemberLogin] && memArr && [memArr count] > 0){
	
		return YES;
	}
	
	return NO;
}



- (void)setLastLoginUsername:(NSString *)name{
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:name forKey:@"accountname"];
    [[NSUserDefaults standardUserDefaults] setObject:dic forKey:KUSERNAME_LOGOUT];
    [[NSUserDefaults standardUserDefaults] synchronize];


}
- (NSString *)getLastLoginUsername{

    if ([[NSUserDefaults standardUserDefaults] objectForKey:KUSERNAME_LOGOUT]){
        
        NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:KUSERNAME_LOGOUT];
        return [dic objectForKey:@"accountname"];
    }
    
    return @"";
}

@end
