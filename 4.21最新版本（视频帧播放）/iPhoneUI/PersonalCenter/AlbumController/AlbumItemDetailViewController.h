//
//  AlbumItemDetailViewController.h
//  HuaWo
//
//  Created by circlely on 2/20/16.
//  Copyright © 2016 circlely. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AlbumItemDetailViewControllerDelegate <NSObject>

- (void)updateAlbumDetail;

@end

@interface AlbumItemDetailViewController : UIViewController

@property (strong, nonatomic) NSMutableArray *items;
@property (assign, nonatomic) BOOL isLocalAlbum;
@property (strong, nonatomic) NSString *recordFileDate;
@property (assign, nonatomic) NSInteger fileType;
@property (strong, nonatomic) NSString *cidStr;
@property (assign, nonatomic) id<AlbumItemDetailViewControllerDelegate> delegate;
@end
