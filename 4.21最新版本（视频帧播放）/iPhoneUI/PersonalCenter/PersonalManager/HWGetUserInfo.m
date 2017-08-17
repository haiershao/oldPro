//
//  HWGetUserInfo.m
//  HuaWo
//
//  Created by hwawo on 16/12/13.
//  Copyright © 2016年 HW. All rights reserved.
//

#import "HWGetUserInfo.h"
#import "Reachability.h"


typedef void(^CallBack)(NSString *);
@interface HWGetUserInfo (){

    NSString *name;
}

@property (strong, nonatomic) HWGetUserInfo *getUserInfo;
@end
static HWGetUserInfo *getUserInfo = nil;

@implementation HWGetUserInfo

- (HWGetUserInfo *)getUserInfo{
    
    if (!getUserInfo) {
        getUserInfo = [[HWGetUserInfo alloc] init];
    }
    return getUserInfo;
}

- (instancetype)init{
    
    if (self = [super init]) {
        self.name = [self getDeviceNickname];
    }
    return self;
}

-(BOOL) isConnectionAvailable{
    
    BOOL isExistenceNetwork = YES;
    Reachability *reach = [Reachability reachabilityWithHostname:@"www.apple.com"];
    switch ([reach currentReachabilityStatus]) {
        case NotReachable:
            isExistenceNetwork = NO;
            //HWLog(@"notReachable");
            break;
        case ReachableViaWiFi:
            isExistenceNetwork = YES;
            //HWLog(@"WIFI");
            break;
        case ReachableViaWWAN:
            isExistenceNetwork = YES;
            //HWLog(@"3G");
            break;
    }
    
    if (!isExistenceNetwork) {
        //<span style="font-family: Arial, Helvetica, sans-serif;">MBProgressHUD为第三方库，不需要可以省略或使用AlertView</span>
        //        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES configBlock:nil];
        //        hud.removeFromSuperViewOnHide =YES;
        //        hud.mode = MBProgressHUDModeText;
        //        hud.labelText = @"当前网络不可用，请检查网络连接";  //提示的内容
        //        hud.minSize = CGSizeMake(132.f, 108.0f);
        //        [hud hide:YES afterDelay:3];
        return NO;
    }
    
    return isExistenceNetwork;
}

//自动注册
- (void)requestDeviceNickName:(CallBack)callBack{
    
    if (![self isConnectionAvailable]) {
    }
    
    
    NSString *urlStr = [NSString stringWithFormat:@"http://112.124.22.101:8190/user/registerDeviceInfo?deviceid=%@",identifierForVendor];
    
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *url = [NSURL URLWithString:@"http://find.hwawo.com:9090/ControlCenter/v3/restapi/doaction"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSDictionary *para = @{
                           @"did":identifierForVendor,
                           @"stype":@"111",
                           @"license":@"1"
                           };
    
    NSDictionary *dict = @{
                           @"action" :@"dev_register",
                           @"para": para
                           };
    
    __typeof(self) __weak safeSelf = self;
    // 3. 连接
    
    HWLog(@"------------------%@",dict);
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    request.HTTPBody = data;

    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        if (!connectionError) {
            // 反序列化
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            
            NSLog(@"result---%@--%@--%@", result,result[@"result"],result[@"token"]);
            NSString *str0 = [NSString stringWithFormat:@"%@",result[@"result"]];
            if ([str0 isEqualToString:@"1"]) {
                [self getStatus:result[@"token"]];
                callBack(result[@"nickname"]);
                
                
            }else{
                
                HWLog(@"===getNickName============");
            }
        }
        
    }];
    
}

- (void)getStatus:(NSString *)token{

    NSDictionary *dict1 = @{
                           @"action" :@"dev_getstatus",
                           @"token":token
                           };
    
    
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    [mgr POST:@"http://find.hwawo.com:9090/ControlCenter/v3/restapi/doaction" parameters:dict1 progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        HWLog(@"AFHTTPSessionManager error %@",responseObject);
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        HWLog(@"AFHTTPSessionManager error %@",error);
    }];
    
    NSURL *url = [NSURL URLWithString:@"http://find.hwawo.com:9090/ControlCenter/v3/restapi/doaction"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSDictionary *dict = @{
                           @"action" :@"dev_getstatus",
                           @"token":token
                           };
    
    __typeof(self) __weak safeSelf = self;
    // 3. 连接
    
    HWLog(@"------------------%@-%@",dict,identifierForVendor);
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    request.HTTPBody = data;
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        HWLog(@"===connectionError============%@",connectionError);
        NSLog(@"response %@",response);
        if (!connectionError) {
            // 反序列化
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            
            NSLog(@"result---%@--%@--%@", result,result[@"result"],result[@"data"]);
            NSDictionary *dataDict = result[@"data"];
            NSLog(@"result---%@--%@--%@", result,result[@"result"],dataDict[@"nickname"]);
            NSString *str0 = [NSString stringWithFormat:@"%@",result[@"result"]];
            if ([str0 isEqualToString:@"1"]) {
                
                while (1) {
                    if (dataDict[@"nickname"]) {
                        [DZNotificationCenter postNotificationName:@"getUserInfoToNickname" object:dataDict[@"nickname"]];
                        [self saveUserInfoNickname:dataDict[@"nickname"] Token:token];
                        break;
                    }
                }
                
                [self.getUserInfo setValue:result[@"nickname"] forKeyPath:@"name"];
                [self.getUserInfo addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:NULL];
                HWLog(@"===getNickName============%@",result[@"nickname"]);
                
                
            }else{
                
                HWLog(@"===connectionError============%@",connectionError);
            }
        }
        
    }];
}

- (void)saveUserInfoNickname:(NSString *)nickname Token:(NSString *)token{

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:nickname forKey:kUserNickName];
    [userDefaults setValue:token forKey:kUserToken];
    [userDefaults synchronize];
}

- (NSString *)getDeviceNickname{
    __block NSCondition *condition = [[NSCondition alloc] init];
    
    __block NSString *name;
        
    [self requestDeviceNickName:^(NSString *nickName) {
            name = nickName;
            HWLog(@"block里面name ==== %@",name);
        [condition lock];
        [condition signal];
        [condition unlock];
    }];
    
    [condition lock];
    [condition signal];
    [condition unlock];
    HWLog(@"block外面name ==== %@",name);
    [self readNSUserNickNameDefaults];
    return name;
}

-(NSString *)readNSUserNickNameDefaults{

   NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    NSString *nickname = [userDefaultes valueForKey:kUserNickName];
    return nickname;
}

-(NSString *)readNSUserTokenDefaults{
    
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    NSString *token = [userDefaultes valueForKey:kUserToken];
    return token;
}

//释放KVO监听
-(void)dealloc
{
    
//    [self.getUserInfo removeObserver:self forKeyPath:@"name"];
    
}


/**
 *  添加KVO监听者
 *
 *  @param observer 观察者（监听器）
 *  @param keyPath  属性名（要观察的属性）
 *  @param options
 *  @param context  传递的参数
 */
- (void)addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context{
    
}

/**
 *  当利用KVO监听到某个对象的属性值发生了改变，就会自动调用这个
 *
 *  @param keyPath 哪个属性被改了
 *  @param object  哪个对象的属性被改了
 *  @param change  改成咋样
 *  @param context 当初addObserver时的context参数值
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSLog(@"%@ %@ %@ %@", object, keyPath, change, context);
}

//- (NSString *)getDeviceNickname{
//    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
//    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
//    __block NSString *name;
//    dispatch_sync(queue, ^(){
//        
//        [self requestDeviceNickName:^(NSString *nickName) {
//            name = nickName;
//            HWLog(@"block里面name ==== %@",name);
//            dispatch_semaphore_signal(semaphore);
//        }];
//    });
//    
//    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
//    HWLog(@"block外面name ==== %@",name);
//    return name;
//}

@end
