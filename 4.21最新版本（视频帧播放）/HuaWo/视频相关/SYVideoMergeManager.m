//
//  SYVideoMergeManager.m
//  HuaWo
//
//  Created by leju_esf on 17/3/29.
//  Copyright © 2017年 HW. All rights reserved.
//

#import "SYVideoMergeManager.h"
#import <AVFoundation/AVFoundation.h>
#import <AWSS3/AWSS3.h>
#import <AWSCore/AWSCore.h>
#import "Reachability.h"
#import "MBProgressHUD.h"
#import "CityInfo.h"
#import "HWUserInstanceInfo.h"
#import "SYRecordVideoController.h"
#import "MBProgressHUD+MG.h"
#import "Reachability.h"
#define kBucketName @"huawo"

@interface SYVideoMergeManager ()
@property (strong, nonatomic) AVAssetExportSession *exportSession;
@property (nonatomic, strong) NSMutableArray *shareModels;
@property (nonatomic, strong) NSMutableArray *waitModels;
@property (nonatomic, assign) BOOL isEditing;
@property (nonatomic ,strong)MBProgressHUD *hud;

@end

@implementation SYVideoMergeManager
+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    static SYVideoMergeManager *manager;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc]init];
        [manager netWork];
    });
    return manager;
}
-(void)netWork {
    
    AFNetworkReachabilityManager *netManager = [AFNetworkReachabilityManager sharedManager];
    [netManager startMonitoring];  //开始监听
    [netManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status){
        
        if (status == AFNetworkReachabilityStatusReachableViaWiFi)
        {
            self.iSWIFI = YES;
            [self upload];
        }else{
            self.iSWIFI = NO;
        }
    }];
}
-(void)upload {
    for (SYVideoModel *fileItem in self.shareModels){
       
        NSString *video_id1=  [SYVideoMergeManager uuidString];
        NSString* video_id = [video_id1 stringByReplacingOccurrencesOfString:@"-" withString:@""];
        NSString *sharepng = @"";
        NSString *sharemp4 = @"";
        NSString *illegalpng = @"";
        NSString *illegalmp4 = @"";
        NSString * currentDateStr =    [self currentTimePara];
        if (fileItem.type == SYVideoTypeShare) {
            sharepng  = [NSString stringWithFormat:@"share_pic/thumb/%@/%@.png",currentDateStr,video_id];
            sharemp4 = [NSString stringWithFormat:@"share_pic/mp4/%@/%@.mp4",currentDateStr,video_id];
        }else{
            illegalmp4 = [NSString stringWithFormat:@"illegal_video/mp4/%@/%@.mp4",currentDateStr,video_id];
            illegalpng =  [NSString stringWithFormat:@"illegal_video/thumb/%@/%@.png",currentDateStr,video_id];
        }
        __typeof(self) __weak safeSelf = self;
        NSString *newVideoPath = fileItem.path;
        [fileItem sy_setImage:^(UIImage *image) {
            UIImage *image1 = image;
            if (image1 == nil) {
                [MBProgressHUD showError:@"分享失败"];
            }
            NSString *imagePath = [self saveSnapeVideoImage:image1];
            
            [ safeSelf uploadVideo:newVideoPath imagePath:imagePath Video_id:video_id imageKeyshare:sharepng videoKeyshare:sharemp4 imageKeyill:illegalpng videoKeyill:illegalmp4 currentDateStr:currentDateStr isShare:fileItem.type == SYVideoTypeShare];
        }];
    }
    [self.shareModels removeAllObjects];
}

- (void)shareVideoModel:(SYVideoModel *)model {
    [SYVideoModel saveVideo:model];
    NSString *video_id1=  [SYVideoMergeManager uuidString];
  NSString* video_id = [video_id1 stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSString *sharepng = @"";
    NSString *sharemp4 = @"";
    NSString *illegalpng = @"";
    NSString *illegalmp4 = @"";
    NSString * currentDateStr =    [self currentTimePara];
    if (model.type == SYVideoTypeShare) {
        sharepng  = [NSString stringWithFormat:@"share_pic/thumb/%@/%@.png",currentDateStr,video_id];
        sharemp4 = [NSString stringWithFormat:@"share_pic/mp4/%@/%@.mp4",currentDateStr,video_id];
    }else{
     illegalmp4 = [NSString stringWithFormat:@"illegal_video/mp4/%@/%@.mp4",currentDateStr,video_id];
    illegalpng =  [NSString stringWithFormat:@"illegal_video/thumb/%@/%@.png",currentDateStr,video_id];
    }
        if (([SYVideoMergeManager sharedManager].iSWIFI == YES)) {
            __typeof(self) __weak safeSelf = self;
            NSString *newVideoPath = model.path;
            
            [model sy_setImage:^(UIImage *image) {
                UIImage *image1 = image;
                if (image1 == nil) {
                    [MBProgressHUD showError:@"分享失败"];
                }
                NSString *imagePath = [self saveSnapeVideoImage:image1];
                [ safeSelf uploadVideo:newVideoPath imagePath:imagePath Video_id:video_id imageKeyshare:sharepng videoKeyshare:sharemp4 imageKeyill:illegalpng videoKeyill:illegalmp4 currentDateStr:currentDateStr isShare:model.type == SYVideoTypeShare];
            }];
           // NSLog(@"分享的视频的url---%@",model.path);
              HWLog(@"wifi");
        }else {
             [self.shareModels addObject:model];
            HWLog(@"bus wifi");
        }
}
- (void)s3ConfigParams{
    
    AWSStaticCredentialsProvider *credentialsProvider = [[AWSStaticCredentialsProvider alloc] initWithAccessKey:@"AKIAOVUGNAXFVVE5IALQ" secretKey:@"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"];
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionCNNorth1 credentialsProvider:credentialsProvider];
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
}
// uuid
+ (NSString *)uuidString
{
    CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
    CFStringRef uuid_string_ref= CFUUIDCreateString(NULL, uuid_ref);
    NSString *uuid = [NSString stringWithString:(__bridge NSString *)uuid_string_ref];
    CFRelease(uuid_ref);
    CFRelease(uuid_string_ref);
    return [uuid  lowercaseString];
}

// 当前时间
-(NSString *)timeOfNow{
    NSDate *currentDate = [NSDate date];//获取当前时间，日期
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [dateFormatter stringFromDate:currentDate];
    return dateString;
}
-(NSString *)timeOfNowQuhuaxian{
    NSDate *currentDate = [NSDate date];//获取当前时间，日期
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYYMMddHHmmss"];
    NSString *dateString = [dateFormatter stringFromDate:currentDate];
    return dateString;
}
- (NSString *)currentTimePara {
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYYMMdd"];
    NSString *currentDateStr = [dateFormatter stringFromDate:currentDate];
    HWLog(@"====================== %@",currentDateStr);
    return currentDateStr;
}
- (void)uploadVideo:(NSString *)videoPath imagePath:(NSString *)imagePath Video_id:(NSString *)video_id imageKeyshare:(NSString *)imageKeyshare videoKeyshare:(NSString *)videoKeyshare imageKeyill:(NSString *)imageKeyill videoKeyill:(NSString *)videoKeyill isShare:(BOOL)isShare{
    
    [self s3ConfigParams];
    
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    
    //设置uploadrequest
    AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
    uploadRequest.bucket = kBucketName;
    if (isShare) {
         uploadRequest.key = imageKeyshare;
    }else{
         uploadRequest.key = imageKeyill;
    }
   
    NSURL *url = [NSURL fileURLWithPath:imagePath];
    
    uploadRequest.body = url;
    
    [[transferManager upload:uploadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor] withBlock:^id(AWSTask*task) {
        if (task.error) {
            HWLog(@"*****************************Error: %@", task.error);
        }
        else {
            
            // The file uploaded successfully.
            HWLog(@"------image------OK");
            if (isShare) {
                // 分享
                [self writeToSnapServerVideo_id:video_id imageKeyshare:imageKeyshare videoKeyshare:videoKeyshare];
            }else{
                [self writeToReportServerimageKeyill:imageKeyill videoKeyill:videoKeyill Video_id:video_id];
            }
            
        }
        return nil;
    }];
}
- (void)writeToReportServerimageKeyill:(NSString *)imageKeyill videoKeyill:(NSString *)videoKeyill Video_id:(NSString *)video_id{
    
//    NSString *ss =  [NSString stringWithFormat:@"illegal_video/thumb/%@/%@.png",self.currentDateStr,video_id];
//    NSString *ss1 =  [NSString stringWithFormat:@"illegal_video/mp4/%@/%@.mp4",self.currentDateStr,video_id];
    NSString *strimageKey = [NSString stringWithFormat:@"%@|%@",kBucketName,imageKeyill];
    NSString *strvideoKey = [NSString stringWithFormat:@"%@|%@",kBucketName,videoKeyill];
    
    CityInfo *info = [CityInfo CityUser];
    NSString *occuraddr = [NSString stringWithFormat:@"%@%@%@",info.State ,info.SubLocality,info.Street];
    HWUserInstanceInfo *record = [HWUserInstanceInfo shareUser];
    NSString *str1 = [NSString stringWithFormat:@"%f",record.longitude];
    NSString *str2 = [NSString stringWithFormat:@"%f",record.coordinate];
    
    HWUserInstanceInfo *instanceInfo = [HWUserInstanceInfo shareUser];
    NSString *str = [self timeOfNow];
    
    NSDictionary *dict = @{
                           @"did":@"",
                           @"longitude":str1,
                           @"latitude":str2,
                           @"occurtime":str,
                           @"occuraddr":occuraddr,
                           @"store_type":@"0",
                           @"vpara":strvideoKey,
                           @"ipara":strimageKey
                           
                           };
    APIRequest *request = [[APIRequest alloc] initWithApiPath:@"/ControlCenter/v3/restapi/doaction" method:APIRequestMethodPost];
    request.urlQueryParameters = @{
                                   @"action":@"add_illegalreport",
                                   @"para":dict,
                                   @"token":instanceInfo.token
                                   };
    
    [[APIRequestOperationManager sharedRequestOperationManager] requestAPI:request completion:^(id result, NSError *error) {
        if ([result[@"result"]isEqualToString:@"0"]) {
            
            [MBProgressHUD showError:@"举报失败"];
        }else{
            [MBProgressHUD showSuccess:@"举报成功"];
        }
        //NSDictionary *dict = result[@"token"];
        //NSString *str1 = [NSString stringWithFormat:@"%@",dict];
        
        NSLog(@"------接口结果%@-----%@",result,error);
    }];
    
}

- (void)writeToSnapServerVideo_id:(NSString *)video_id imageKeyshare:(NSString *)imageKeyshare videoKeyshare:(NSString *)videoKeyshare {
    NSString *strimageKey = [NSString stringWithFormat:@"%@|%@",kBucketName,imageKeyshare];
    NSString *strvideoKey = [NSString stringWithFormat:@"%@|%@",kBucketName,videoKeyshare];
    
    NSString *titleStr = @"啥也不想说，先看视频吧！！！";
    CityInfo *info = [CityInfo CityUser];
    NSString *occuraddr = [NSString stringWithFormat:@"%@%@%@",info.State ,info.SubLocality,info.Street];
    HWUserInstanceInfo *instanceInfo = [HWUserInstanceInfo shareUser];
    NSString *str = [self timeOfNow];
    NSDictionary *dict = @{
                           @"nickname":instanceInfo.nickname,
                           @"vtype": @"1",
                           @"vid":video_id,
                           @"title":titleStr,
                           @"gentime":str,
                           @"vloc":occuraddr,
                           @"store_type":@"0",
                           @"vpara":strvideoKey,
                           @"ipara":strimageKey
                           
                           };
    APIRequest *request = [[APIRequest alloc] initWithApiPath:@"/ControlCenter/v3/restapi/doaction" method:APIRequestMethodPost];
    request.urlQueryParameters = @{
                                   @"action":@"add_sharevideo",
                                   @"para":dict,
                                   @"token":instanceInfo.token
                                   };
    
    NSLog(@"request---%@",request);
    [[APIRequestOperationManager sharedRequestOperationManager] requestAPI:request completion:^(id result, NSError *error) {
        
        
        
        NSString *strd = [NSString stringWithFormat:@"%@",result[@"result"]];
        if ([strd isEqualToString:@"1"]&&result[@"data"]) {
            HWLog(@"视频分享成功");
            [MBProgressHUD showSuccess:@"分享成功"];
        }else{
            [MBProgressHUD showError:@"分享失败"];
        }
        
        NSLog(@"------接口结果%@-----%@",result,error);
    }];
}

- (void)uploadVideo:(NSString *)videoPath imagePath:(NSString *)imagePath Video_id:(NSString *)video_id imageKeyshare:(NSString *)imageKeyshare videoKeyshare:(NSString *)videoKeyshare imageKeyill:(NSString *)imageKeyill videoKeyill:(NSString *)videoKeyill currentDateStr:(NSString *)currentDateStr isShare:(BOOL)isShare{
    
    [self s3ConfigParams];
       AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
    uploadRequest.bucket = kBucketName;
    if (isShare) {
        uploadRequest.key = videoKeyshare;
    }else{
       uploadRequest.key = videoKeyill;
    }
   
    
    NSURL *url = [NSURL fileURLWithPath:videoPath];
    
    uploadRequest.body = url;
    [[transferManager upload:uploadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor] withBlock:^id(AWSTask*task) {
        
        if (task.error) {
            [self.hud hide:YES];
            HWLog(@"=====================Error: %@", task.error);
        }
        else {
            [self.hud hide:YES];
            
            HWLog(@"video upload------------OK");
            [self uploadVideo:videoPath imagePath:imagePath Video_id:video_id imageKeyshare:imageKeyshare videoKeyshare:videoKeyshare imageKeyill:imageKeyill videoKeyill:videoKeyill isShare:isShare];
           // [self uploadVideo:videoPath imagePath:imagePath Video_id:video_id imageKeyshare:imageKeyshare imageKeyill:imageKeyill currentDateStr:currentDateStr isShare:isShare];
        }
        
        return nil;
    }];
}

- (NSString *)createSnapVideoImagePath{
    NSString *dirName = @"snapImage";
    NSString *snapImagePath = [NSString stringWithFormat:@"%@/Documents/%@", NSHomeDirectory(), dirName];
    
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:snapImagePath isDirectory:&isDir];
    if (!(isDir == YES && existed == YES) )
    {
        [fileManager createDirectoryAtPath:snapImagePath withIntermediateDirectories:YES attributes:nil error:nil];
    }else{
        HWLog(@"-----------创建的文件夹已存在-----------");
    }
      return snapImagePath;
}

- (NSString *)saveSnapeVideoImage:(UIImage *)image{
    
    HWLog(@"-------------saveUserIconImage------------%@",image);
       NSData *imageData2 = UIImagePNGRepresentation(image);
    // 将图片写入文件
  
     NSString *video_id1=  [SYVideoMergeManager uuidString];
    NSString *imagePath = [[self createSnapVideoImagePath] stringByAppendingFormat:@"reportVideo%@.png",video_id1];
    if ([imageData2 writeToFile:imagePath atomically:NO]) {
        
        HWLog(@"--------------写入OK");
    }else{
        
        HWLog(@"--------------写入失败");
    }
    return imagePath;
}

- (void)detailModel:(SYShareVideoModel *)model {
    @synchronized (self) {
        if (self.isEditing) {
            [self.waitModels addObject:model];
            return;
        }else {
            self.isEditing = YES;
        }
        if (model.isTowVideo) {
            AVMutableComposition* mixComposition = [AVMutableComposition composition];
            AVMutableCompositionTrack *compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
            AVMutableCompositionTrack *compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
            
            AVURLAsset *videoAsset2 = [[AVURLAsset alloc]initWithURL:[NSURL fileURLWithPath:model.path2] options:nil];
            CMTimeRange video_timeRange2 = CMTimeRangeMake(kCMTimeZero,videoAsset2.duration);
            [compositionVideoTrack insertTimeRange:video_timeRange2 ofTrack:[videoAsset2 tracksWithMediaType:AVMediaTypeVideo][0] atTime:kCMTimeZero error:nil];
            if ([[videoAsset2 tracksWithMediaType:AVMediaTypeAudio] count] != 0) {
                [compositionAudioTrack insertTimeRange:video_timeRange2 ofTrack:[videoAsset2 tracksWithMediaType:AVMediaTypeAudio][0] atTime:kCMTimeZero error:nil];
            }
            
            AVURLAsset *videoAsset1 = [[AVURLAsset alloc]initWithURL:[NSURL fileURLWithPath:model.path1] options:nil];
            CMTimeRange video_timeRange1 = CMTimeRangeMake(kCMTimeZero,videoAsset1.duration);
            [compositionVideoTrack insertTimeRange:video_timeRange1 ofTrack:[videoAsset1 tracksWithMediaType:AVMediaTypeVideo][0] atTime:kCMTimeZero error:nil];
            if ([[videoAsset1 tracksWithMediaType:AVMediaTypeAudio] count] != 0) {
                [compositionAudioTrack insertTimeRange:video_timeRange1 ofTrack:[videoAsset1 tracksWithMediaType:AVMediaTypeAudio][0] atTime:kCMTimeZero error:nil];
            }
            
            self.exportSession = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
            self.exportSession.outputFileType = @"public.mpeg-4";
            NSString *outPath = [self filePathWithName:[NSString stringWithFormat:@"%zd",(NSInteger)model.pointTime]];
            self.exportSession.outputURL = [NSURL fileURLWithPath:outPath];
            self.exportSession.shouldOptimizeForNetworkUse=NO;
            CGFloat startTime = 0;
            if (model.pointTime < 7) {
                startTime = 120 - (7 - model.pointTime);
            }else {
                startTime = model.pointTime - 7;
            }
            
            CMTime start = CMTimeMakeWithSeconds(startTime, 600);
            CMTime duration = CMTimeMakeWithSeconds(15,600);
            CMTimeRange range = CMTimeRangeMake(start, duration);
            self.exportSession.timeRange = range;
            
            __weak typeof(self) weakSelf = self;
            [self.exportSession exportAsynchronouslyWithCompletionHandler:^{
                if(weakSelf.exportSession.status == AVAssetExportSessionStatusCompleted ) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        SYVideoModel *videomodel = [[SYVideoModel alloc] init];
                        videomodel.totalTime = 15;
                        videomodel.path = outPath;
                        videomodel.type = model.isShare == YES?SYVideoTypeShare:SYVideoTypeReport;
                        
                        [weakSelf shareVideoModel:videomodel];
                        weakSelf.isEditing = NO;
                        if (weakSelf.waitModels.count > 0) {
                            SYShareVideoModel *shareModel = weakSelf.waitModels.firstObject;
                            [weakSelf detailModel:shareModel];
                            [weakSelf.waitModels removeObjectAtIndex:0];
                        }
                    });
                }else {
                    weakSelf.isEditing = NO;
                    if (weakSelf.waitModels.count > 0) {
                        SYShareVideoModel *shareModel = weakSelf.waitModels.firstObject;
                        [weakSelf detailModel:shareModel];
                        [weakSelf.waitModels removeObjectAtIndex:0];
                    }
                }
            }];
        }else {
            AVAsset *mediaAsset = [AVAsset assetWithURL:[NSURL fileURLWithPath:model.path1]];
            self.exportSession = [[AVAssetExportSession alloc] initWithAsset:mediaAsset presetName:AVAssetExportPresetHighestQuality];
            NSString *outPath = [self filePathWithName:[NSString stringWithFormat:@"%zd",(NSInteger)model.pointTime]];
            self.exportSession.outputFileType = AVFileTypeMPEG4;
            self.exportSession.outputURL = [[NSURL alloc] initFileURLWithPath:outPath];
            self.exportSession.shouldOptimizeForNetworkUse=NO;
            
            CGFloat startTime = model.pointTime - 7 < 0 ? 0 : model.pointTime - 7;
            CGFloat durationTime = model.pointTime - 7 < 0 ? 8 + model.pointTime : 15;
            
            CMTime start = CMTimeMakeWithSeconds(startTime, 600);
            CMTime duration = CMTimeMakeWithSeconds(durationTime,600);
            CMTimeRange range = CMTimeRangeMake(start, duration);
            self.exportSession.timeRange = range;
            
            __weak typeof(self) weakSelf = self;
            [self.exportSession exportAsynchronouslyWithCompletionHandler:^{
                if(weakSelf.exportSession.status == AVAssetExportSessionStatusCompleted ) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        SYVideoModel *videomodel = [[SYVideoModel alloc] init];
                        videomodel.totalTime = durationTime;
                        videomodel.path = outPath;
                        videomodel.type = model.isShare == YES?SYVideoTypeShare:SYVideoTypeReport;
                        [weakSelf shareVideoModel:videomodel];
                        weakSelf.isEditing = NO;
                        if (weakSelf.waitModels.count > 0) {
                            SYShareVideoModel *shareModel = weakSelf.waitModels.firstObject;
                            [weakSelf detailModel:shareModel];
                            [weakSelf.waitModels removeObjectAtIndex:0];
                        }
                    });
                }else {
                    weakSelf.isEditing = NO;
                    if (weakSelf.waitModels.count > 0) {
                        SYShareVideoModel *shareModel = weakSelf.waitModels.firstObject;
                        [weakSelf detailModel:shareModel];
                        [weakSelf.waitModels removeObjectAtIndex:0];
                    }
                }
            }];
        }
    }
}

- (NSString *)filePathWithName:(NSString *)name {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *videoCache = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingString:@"/sharevideos"];
    BOOL isExist = [fileManager fileExistsAtPath:videoCache];
    if(!isExist){
        [fileManager createDirectoryAtPath:videoCache withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    NSDate * NowDate = [NSDate dateWithTimeIntervalSince1970:now];
    NSString *timeStr = [formatter stringFromDate:NowDate];
    NSString *fileName = [NSString stringWithFormat:@"%@%@.mp4",name,timeStr];
    
    NSString *outPath = [videoCache stringByAppendingPathComponent:fileName];
    [fileManager removeItemAtPath:outPath error:NULL];
    return outPath;
}

- (NSMutableArray *)shareModels {
    if (_shareModels == nil) {
        _shareModels = [[NSMutableArray alloc] init];
    }
    return _shareModels;
}

- (NSMutableArray *)waitModels {
    if (_waitModels == nil) {
        _waitModels = [[NSMutableArray alloc] init];
    }
    return _waitModels;
}

@end
