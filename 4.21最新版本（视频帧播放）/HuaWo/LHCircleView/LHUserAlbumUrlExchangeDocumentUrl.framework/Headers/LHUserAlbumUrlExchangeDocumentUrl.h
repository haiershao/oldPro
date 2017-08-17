//
//  LHUserAlbumUrlExchangeDocumentUrl.h
//  HuaWo
//
//  Created by hwawo on 17/2/27.
//  Copyright © 2017年 HW. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void(^resultValue)(NSMutableArray *videoPaths, NSMutableArray *imagePaths, NSMutableArray *fileNames, NSMutableArray *images);
typedef void(^resultValue0)(NSMutableArray *videoPaths0, NSMutableArray *imagePaths0);


@interface LHUserAlbumUrlExchangeDocumentUrl : NSObject
@property (nonatomic,strong) NSMutableArray *groupArrays;
@property (nonatomic,strong) NSMutableArray *videoArrays;
//@property (nonatomic,strong) UIImage *litimage;
@property (nonatomic, copy) NSString *videoPath;
@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, copy) NSString *iconPath;
@property (nonatomic,strong) NSMutableArray *litImages;
@property (nonatomic,strong) NSMutableArray *fileNames;
@property (nonatomic,strong) NSMutableArray *iconPaths;
@property (nonatomic,strong) NSMutableArray *images;
@property (nonatomic, copy) NSString *dirName;

- (void)getLocalVideoListResultValue:(resultValue)resultValue;
@end
