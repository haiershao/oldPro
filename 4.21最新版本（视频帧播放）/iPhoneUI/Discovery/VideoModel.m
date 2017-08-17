 


#import "VideoModel.h"

@implementation VideoModel
//- (void)setValue:(id)value forUndefinedKey:(NSString *)key
//{
//    if ([key isEqualToString:@"description"]) {
//        self.description = value;
//    }
//}

- (NSString *)gentime{
    
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    [fmt setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSRange range = {0,4};
    NSRange range0 = {4,2};
    NSRange range1 = {6,2};
    NSRange range2 = {8,2};
    NSRange range3 = {10,2};
    NSRange range4 = {12,2};
    HWLog(@"model.gen_time %@",[_gentime substringWithRange:range0]);
    if ([_gentime containsString:@"昨天"]) {
        return _gentime;
    }
    NSString *time = [NSString stringWithFormat:@"%@-%@-%@ %@:%@:%@",[_gentime substringWithRange:range],[_gentime substringWithRange:range0],[_gentime substringWithRange:range1],[_gentime substringWithRange:range2],[_gentime substringWithRange:range3],[_gentime substringWithRange:range4]];
    NSDate *create = [fmt dateFromString:time];
    
    if (create.isThisYear) {
        if (create.isToday) {
            NSDateComponents *cmps = [[NSDate date] deltaFrom:create];
            if (cmps.hour > 1) {
                HWLog(@"_gentime== %@",_gentime);
                return [NSString stringWithFormat:@"%zd小时前",cmps.hour];
            }else if (cmps.minute > 1){
                HWLog(@"_gentime== %@",_gentime);
                return [NSString stringWithFormat:@"%zd分钟前",cmps.minute];
            }else {
                
                HWLog(@"_gentime== %@",_gentime);
                return @"刚刚";
            }
        }else if (create.isYesterday){
            fmt.dateFormat = @"昨天 HH:mm:ss";
            _gentime = [fmt stringFromDate:create];
            HWLog(@"_gentime== %@",_gentime);
            return _gentime;
        }else{
            
            fmt.dateFormat = @"MM-dd HH:mm:ss";
            _gentime = [fmt stringFromDate:create];
            HWLog(@"_gentime== %@",_gentime);
            return _gentime;
        }
    }else{
        HWLog(@"_gentime== %@",_gentime);
        return _gentime;
    }
}
@end
