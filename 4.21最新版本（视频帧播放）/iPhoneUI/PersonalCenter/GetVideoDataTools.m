//
//  GetVideoDataTools.m
//  ioshuanwu
//
//  Created by 幻音 on 15/12/28.
//  Copyright © 2015年 幻音. All rights reserved.
//

#import "GetVideoDataTools.h"
#import "VideoSid.h"
#import "Video.h"
#import "MJExtension.h"
@implementation GetVideoDataTools

+ (instancetype)shareDataTools
{
    static GetVideoDataTools *gd = nil;
    static dispatch_once_t token;
    if (gd == nil) {
        dispatch_once(&token, ^{
            gd = [[GetVideoDataTools alloc] init];
        });
    }
    return gd;
}

- (void)getHeardDataWithURL:(NSString *)URL HeardValue:(HeardValue)heardValue
{
    dispatch_queue_t global_t = dispatch_get_global_queue(0, 0);
    dispatch_async(global_t, ^{
        NSURL *url = [NSURL URLWithString:URL];
        NSMutableArray *heardArray = [NSMutableArray array];
        NSMutableArray *videoArray = [NSMutableArray array];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        request.HTTPMethod = @"POST";
        
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        NSString *nowTime = [self timeOfNow];
        NSString *nickName = kDeviceNickName;
        NSString *cidStr = identifierForVendor;

        NSDictionary *dict = @{
                               @"alarm_type" : @"",
                               @"start_date": @"20150810",
                               @"end_date":nowTime,
                               @"num": @5,
                               @"order": @"desc",
                               @"cid": cidStr,
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
                    
                    
                    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                    HWLog(@"dict[%@]",dict);
                    
                    HWLog(@"min_gen_time-----%@",dict[@"min_gen_time"]);
                    HWLog(@"max_gen_time-----%@",dict[@"max_gen_time"]);
                    HWLog(@"alarm_list-----%@",dict[@"alarm_list"]);
                    
                    NSArray *videoSidList = [Video mj_objectArrayWithKeyValuesArray:[dict objectForKey:@"alarm_list"]];
                    Video * v = [[Video alloc] init];
                   
//                    for (NSDictionary * videoDic in videoList) {
//                        Video * v = [[Video alloc] init];
//                        [v setValuesForKeysWithDictionary:videoDic];
//                        [videoArray addObject:v];
//                        NSLog(@"%@",Video.alarm_info.im)
//                    }
                    [self.dataArray addObjectsFromArray:videoSidList];
                    // 加载头标题
//                    for (NSDictionary *d in videoSidList) {
//                        VideoSid *g = [[VideoSid alloc] init];
//                        [g setValuesForKeysWithDictionary:d];
//                        [heardArray addObject:g];
//                    }
                    heardValue(heardArray,videoSidList);
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
        
        
        
        
//        [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:url] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * response, NSData *  data, NSError *  connectionError) {
//            if (data == nil) {
//                NSLog(@"错误%@",connectionError);
//                return ;
//            }
//            NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
//            
//            NSArray *videoList = [dict objectForKey:@"videoList"];
//            NSArray *videoSidList = [dict objectForKey:@"videoSidList"];
//            for (NSDictionary * video in videoList) {
//                Video * v = [[Video alloc] init];
//                [v setValuesForKeysWithDictionary:video];
//                [videoArray addObject:v];
//            }
//            [self.dataArray addObjectsFromArray:videoArray];
//            // 加载头标题
//            for (NSDictionary *d in videoSidList) {
//                VideoSid *g = [[VideoSid alloc] init];
//                [g setValuesForKeysWithDictionary:d];
//                [heardArray addObject:g];
//            }
//            heardValue(heardArray,videoArray);
//        }];
        
    });

}

- (void)getListDataWithURL:(NSString *)URL ListID:(NSString *)ID ListValue:(ListValue) listValue{
    dispatch_queue_t global_t = dispatch_get_global_queue(0, 0);
    dispatch_async(global_t, ^{
        NSURL *url = [NSURL URLWithString:URL];
        NSMutableArray *listArray = [NSMutableArray array];
        [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:url] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * response, NSData *  data, NSError *  connectionError) {
            if (data == nil) {
                NSLog(@"错误%@",connectionError);
                return ;
            }
            NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSArray *videoList = [dict objectForKey:ID];
            for (NSDictionary * video in videoList) {
                Video * v = [[Video alloc] init];
                [v setValuesForKeysWithDictionary:video];
                [listArray addObject:v];
            }
            listValue(listArray);
        }];
        
    });

}

// 懒加载初始数组
- (NSMutableArray *)dataArray
{
    if (_dataArray == nil) {
        self.dataArray = [NSMutableArray array];
    }
    return _dataArray;
}


- (Video *)getModelWithIndex:(NSInteger)index
{
    return self.dataArray[index];
}

-(NSString *)timeOfNow{
    NSDate *currentDate = [NSDate date];//获取当前时间，日期
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYYMMdd"];
    NSString *dateString = [dateFormatter stringFromDate:currentDate];
    return dateString;
}

@end
