//
//  CloudVideoList.m
//  AtHomeCam
//
//  Created by Lvyi on 2/3/15.
//  Copyright (c) 2015 ichano. All rights reserved.
//

#import "CloudVideoObject.h"




@implementation CloudVideoObject


- (id)initWithDictionary:(NSDictionary*)dic {
    
    self = [super init];
    
    if (self) {
    
        self.eid = [dic objectForKey:@"eid"];
        self.event_long = [[dic objectForKey:@"event_long"] integerValue];
        self.createTime = [dic objectForKey:@"createTime"];
        self.cameraID = [[dic objectForKey:@"cameraID"] integerValue];
        self.size = [[dic objectForKey:@"size"] integerValue];
    
    }
    
    return self;

}

- (NSDictionary*)dictionary {

    NSDictionary* dic = @{@"eid": [NSString stringWithString:self.eid],
                          @"event_long": [NSString stringWithFormat:@"%d", self.event_long],
                          @"createTime": [NSString stringWithString:self.createTime],
                          @"cameraID": [NSString stringWithFormat:@"%d", self.cameraID],
                          @"size":[NSString stringWithFormat:@"%d", self.size]};
    
    
    return dic;
}

@end


@implementation CloudVideoListOneDay


- (NSString*)createDateFormat{
    
    
    int year = [self.date substringWithRange:NSMakeRange(0, 4)].integerValue;
    int month = [self.date substringWithRange:NSMakeRange(4, 2)].integerValue;
    int day = [self.date substringWithRange:NSMakeRange(6, 2)].integerValue;
    
    
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:day];
    [comps setMonth:month];
    [comps setYear:year];
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDate *date = [gregorian dateFromComponents:comps];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    
    [dateFormatter setLocale:[NSLocale currentLocale]];
    
    NSString* formattedStr = [dateFormatter stringFromDate:date];
    
    return formattedStr;
}

- (id)initWithDictionary:(NSDictionary*)dic {
    
    self = [super init];
    
    if (self) {
        
       
       self.isMore = [[dic objectForKey:@"isMore"] boolValue];
       self.date = [dic objectForKey:@"date"];
        
        self.localDateStr = [self createDateFormat];
        
        NSMutableArray* cloudlist = [NSMutableArray arrayWithCapacity:3];
        
        NSArray* videoListDic = [dic objectForKey:@"videolist"];
        
        
        for (NSDictionary* dic in videoListDic) {
        
            CloudVideoObject* cvo = [[CloudVideoObject alloc] initWithDictionary:dic];
            [cloudlist addObject:cvo];
            
        }
        
        self.cloudVideoObjectArray = cloudlist;
        
    }
    
    return self;
}

- (NSDictionary*)dictionary {
    
    NSMutableArray* videoArray = [NSMutableArray arrayWithCapacity:3];
    
    
    for (CloudVideoObject* cvo in self.cloudVideoObjectArray) {
        
        [videoArray addObject:[cvo dictionary]];
    
    }
    
    
    NSDictionary* dic = @{@"isMore": [NSString stringWithFormat:@"%d", self.isMore],
                          @"date": [NSString stringWithString:self.date],
                          @"videolist": videoArray};
    
    
    return dic;
}

@end
