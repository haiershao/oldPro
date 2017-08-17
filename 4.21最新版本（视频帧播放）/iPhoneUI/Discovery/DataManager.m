


#import "DataManager.h"
#import "VideoModel.h"
#import "SidModel.h"
#import "MJExtension.h"

@implementation DataManager
//- (NSMutableArray *)videoArray{
//
//    if (!_videoArray) {
//        _videoArray = [NSMutableArray array];
//    }
//    return _videoArray;
//}
//
//- (NSMutableArray *)sidArray{
//    
//    if (!_sidArray) {
//        _sidArray = [NSMutableArray array];
//    }
//    return _sidArray;
//}

+(DataManager *)shareManager{
    
    static DataManager* manager = nil;
    
    static dispatch_once_t predicate;
    
    dispatch_once(&predicate, ^{

        manager = [[[self class] alloc] init];
    });
    
    return manager;
    
}

- (NSString *)timeOfNow{
    NSDate *currentDate = [NSDate date];//获取当前时间，日期
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYYMMdd"];
    NSString *dateString = [dateFormatter stringFromDate:currentDate];
    return dateString;
}

- (void)getSIDArrayWithURLString:(NSString *)URLString success:(onSuccess)success failed:(onFailed)failed{
    
    dispatch_queue_t global_t = dispatch_get_global_queue(0, 0);
    dispatch_async(global_t, ^{
        NSURL *url = [NSURL URLWithString:URLString];
        
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        request.HTTPMethod = @"POST";
        
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        NSString *nowTime = [self timeOfNow];
//        NSString *nickName = deviceNickName;
//        NSString *cidStr = identifierForVendor;
        
        NSDictionary *dict = @{
                               @"end_date":nowTime,
                               @"num": @10,
                               @"order": @"desc",
                               @"page_no":@1,
                               @"order_by_col":@"gen_time",
                               };
        
        HWLog(@"---dict*%@*",dict);
        
        if ([NSJSONSerialization isValidJSONObject:dict])
        {
            
            NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
            request.HTTPBody = data;
            
            __typeof(self) __weak safeSelf = self;
            [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                
                if (!connectionError) {
                    HWLog(@"datalength:%lu",(unsigned long)data.length);
                    //                    HWLog(@"data:%@",data);
                    NSMutableArray *sidArray = [NSMutableArray array];
                    NSMutableArray *videoArray = [NSMutableArray array];
                    
                    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                    HWLog(@"dict==%@",dict);
                    
                    HWLog(@"min_gen_time-----%@",dict[@"min_gen_time"]);
                    HWLog(@"max_gen_time-----%@",dict[@"max_gen_time"]);
                    HWLog(@"alarm_list-----%@",dict[@"alarm_list"]);
                    NSArray *temArr = dict[@"alarm_list"];
                    VideoModel * v = [[VideoModel alloc] init];
                    videoArray = [VideoModel mj_objectArrayWithKeyValuesArray:temArr];
                    v = videoArray[0];
                    HWLog(@"VideoModel==%@--%@--%@--%@--%@",v,v.videoinfo,v.videoinfo.video_url,v.title, v.gentime);
                    //                    for (NSDictionary * videoDic in videoList) {
                    //                        Video * v = [[Video alloc] init];
                    //                        [v setValuesForKeysWithDictionary:videoDic];
                    //                        [videoArray addObject:v];
                    //                        NSLog(@"%@",Video.alarm_info.im)
                    //                    }
//                    [self.videoArray addObjectsFromArray:videoSidList];
                    // 加载头标题
                    //                    for (NSDictionary *d in videoSidList) {
                    //                        VideoSid *g = [[VideoSid alloc] init];
                    //                        [g setValuesForKeysWithDictionary:d];
                    //                        [heardArray addObject:g];
                    //                    }
                    success(videoArray,sidArray);
                    
                }
                else{
                    HWLog(@"GetVideoDataTools==error:%@",connectionError);
                    
                }
            }];
        }
        else
        {
            HWLog(@"数据有误");
        }
    
    
       }); 
//    dispatch_queue_t global_t = dispatch_get_global_queue(0, 0);
//    dispatch_async(global_t, ^{
//        NSURL *url = [NSURL URLWithString:URLString];
//        NSMutableArray *sidArray = [NSMutableArray array];
//        NSMutableArray *videoArray = [NSMutableArray array];
//        
//        
//        [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:url] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * response, NSData *  data, NSError *  connectionError) {
//            if (connectionError) {
//                NSLog(@"错误%@",connectionError);
//                failed(connectionError);
//            }else{
//                NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
//            for (NSDictionary * video in [dict objectForKey:@"videoList"]) {
//                VideoModel * model = [[VideoModel alloc] init];
//                [model setValuesForKeysWithDictionary:video];
//                [videoArray addObject:model];
//            }
//            self.videoArray = [NSArray arrayWithArray:videoArray];
//            // 加载头标题
//            for (NSDictionary *d in [dict objectForKey:@"videoSidList"]) {
//                SidModel *model= [[SidModel alloc] init];
//                [model setValuesForKeysWithDictionary:d];
//                [sidArray addObject:model];
//            }
//                self.sidArray = [NSArray arrayWithArray:sidArray];
//
//            }
//            if (success) {
//                success(sidArray,videoArray);
//            }
//
//        }];
//        
//    });
    
}

- (void)getVideoListWithURLString:(NSString *)URLString para:(NSArray *)paras ListID:(NSString *)ID success:(onSuccess)success failed:(onFailed)failed{
    
    dispatch_queue_t global_t = dispatch_get_global_queue(0, 0);
    dispatch_async(global_t, ^{
        NSURL *url = [NSURL URLWithString:[URLString componentsSeparatedByString:@"?"].firstObject];
        
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        request.HTTPMethod = @"POST";
        
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        NSString *nowTime = [self timeOfNow];
        NSString *actionStr = @"";
        NSString *orderbyStr = @"";
        NSString *vtype = @"";
        if (paras) {
            actionStr = paras[0];
            if (paras[1]) {
                orderbyStr = paras[1];
            }else{
            
                return ;
            }
            if (paras[2]) {
                vtype = paras[2];
            }else{
            
                return;
            }
        }else{
        
            return;
        }
        
        
        
        
//        NSString *tempStr = [URLString componentsSeparatedByString:@"?"].lastObject;
//        NSString *actionStr = [tempStr componentsSeparatedByString:@"/"].firstObject;
//        NSString *orderbyStr0 = [tempStr componentsSeparatedByString:[NSString stringWithFormat:@"%@/",actionStr]].lastObject;
//        NSString *orderbyStr = [orderbyStr0 componentsSeparatedByString:@"/"].firstObject;
//        NSString *vtype = [tempStr componentsSeparatedByString:[NSString stringWithFormat:@"%@",orderbyStr]].lastObject;
        
        NSDictionary *para = @{
                               @"num":@10,
                               @"edate":nowTime,
                               @"orderby":orderbyStr,
                               @"order":@"desc",
                               @"pno":ID
                               };
        
        if (vtype) {
            para = @{
                     @"num":@10,
                     @"edate":nowTime,
                     @"orderby":orderbyStr,
                     @"order":@"desc",
                     @"pno":ID,
                     @"vtype":vtype
                     };
        }
        
        NSDictionary *dict = @{
                               @"token":@"public001",
                               @"para":para,
                               @"action":actionStr,
                               };
        
        HWLog(@"---dict*%@*",dict);
        
        if ([NSJSONSerialization isValidJSONObject:dict])
        {
            
            NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
            request.HTTPBody = data;
            
            __typeof(self) __weak safeSelf = self;
            [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                
                if (!connectionError) {
                    HWLog(@"datalength:%lu",(unsigned long)data.length);
                    //                    HWLog(@"data:%@",data);
                    NSMutableArray *sidArray = [NSMutableArray array];
                    NSMutableArray *videoArray = [NSMutableArray array];
                    
                    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                    HWLog(@"dict==%@",dict);
                    
                    HWLog(@"min_gen_time-----%@",dict[@"min_gen_time"]);
                    HWLog(@"max_gen_time-----%@",dict[@"max_gen_time"]);
                    HWLog(@"data-----%@",dict[@"data"]);
                    if (!dict[@"data"]) {
                        return ;
                    }
                    NSDictionary *datalist = dict[@"data"];
                    HWLog(@"data-----%@",dict[@"datalist"]);
                    NSArray *temArr = datalist[@"datalist"];
                    VideoModel * v = [[VideoModel alloc] init];
                    
                    videoArray = [VideoModel mj_objectArrayWithKeyValuesArray:temArr];
                    if (videoArray.count) {
                        v = videoArray[0];
                    }
                    
                    HWLog(@"VideoModel==%@--%@--%@--%@--%@",v,v.videoinfo,v.videoinfo.video_url,v.title, v.gentime);
                    //                    for (NSDictionary * videoDic in videoList) {
                    //                        Video * v = [[Video alloc] init];
                    //                        [v setValuesForKeysWithDictionary:videoDic];
                    //                        [videoArray addObject:v];
                    //                        NSLog(@"%@",Video.alarm_info.im)
                    //                    }
                    //                    [self.videoArray addObjectsFromArray:videoSidList];
                    // 加载头标题
                    //                    for (NSDictionary *d in videoSidList) {
                    //                        VideoSid *g = [[VideoSid alloc] init];
                    //                        [g setValuesForKeysWithDictionary:d];
                    //                        [heardArray addObject:g];
                    //                    }
                    success(videoArray,sidArray);
                    
                }
                else{
                    HWLog(@"GetVideoDataTools==error:%@",connectionError);
                    
                    
                }
            }];
        }
        else
        {
            HWLog(@"数据有误");
        }
        
        
    });
    
//    dispatch_queue_t global_t = dispatch_get_global_queue(0, 0);
//    dispatch_async(global_t, ^{
//        NSURL *url = [NSURL URLWithString:URLString];
//        NSMutableArray *listArray = [NSMutableArray array];
//        [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:url] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * response, NSData *  data, NSError *  connectionError) {
//            if (connectionError) {
//                NSLog(@"错误%@",connectionError);
//                failed(connectionError);
//            }else{
//                NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
//                NSArray *videoList = [dict objectForKey:ID];
//                for (NSDictionary * video in videoList) {
//                    VideoModel * model = [[VideoModel alloc] init];
//                    [model setValuesForKeysWithDictionary:video];
//                    [listArray addObject:model];
//                }
//                if (success) {
//                    success(listArray,nil);
//                }
//            }
//            
//        }];
//        
//    });
    
}
@end
