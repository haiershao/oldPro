//
//  HWCommentModel.h
//  HuaWo
//
//  Created by hwawo on 17/3/27.
//  Copyright © 2017年 HW. All rights reserved.
//

#import <Foundation/Foundation.h>
/*{
    comment = "\U7f8e\U7684\U8ba9\U4eba\U7a92\U606f";
    "comment_id" = 8a2096265adf0e7d015ae99bbf460001;
    "gen_time" = 20170320104622;
    nickname = "\U5361\U5361";
    uid = 718A1154F6434B61A531965F739CCCFA;
}*/
@interface HWCommentModel : NSObject
@property (nonatomic, strong) NSString *comment;
@property (nonatomic, strong) NSString *commentid;
@property (nonatomic, strong) NSString *gentime;
@property (nonatomic, strong) NSString *nickname;
@property (nonatomic, strong) NSString *photourl;
@property (nonatomic, strong) NSString *uid;
@end
