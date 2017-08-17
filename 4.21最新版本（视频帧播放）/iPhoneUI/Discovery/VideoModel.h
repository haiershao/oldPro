

#import <Foundation/Foundation.h>
@class SidModel;
@interface VideoModel : NSObject

@property (nonatomic, strong) NSString * viewtimes;
@property (nonatomic, assign) NSString * goodtimes;
@property (nonatomic, assign) NSString * comtimes;
@property (nonatomic, copy) NSString * gentime;
@property (nonatomic, assign) NSInteger alarm_type;
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSString * location;
@property (nonatomic, strong) NSString * videoid;
@property (nonatomic, strong) NSString * uid;

@property (nonatomic, strong) SidModel * videoinfo;

//@property (nonatomic, strong) NSString * cover;
//@property (nonatomic, strong) NSString * descriptionDe;
//@property (nonatomic, assign) NSInteger  length;
//@property (nonatomic, strong) NSString * m3u8_url;
//@property (nonatomic, strong) NSString * m3u8Hd_url;
//@property (nonatomic, strong) NSString * mp4_url;
//@property (nonatomic, strong) NSString * mp4_Hd_url;
//@property (nonatomic, assign) NSInteger  playCount;
//@property (nonatomic, strong) NSString * playersize;
//@property (nonatomic, strong) NSString * ptime;
//@property (nonatomic, strong) NSString * replyBoard;
//@property (nonatomic, strong) NSString * replyCount;
//@property (nonatomic, strong) NSString * replyid;
//@property (nonatomic, strong) NSString * title;
//@property (nonatomic, strong) NSString * vid;
//@property (nonatomic, strong) NSString * videosource;


@end
