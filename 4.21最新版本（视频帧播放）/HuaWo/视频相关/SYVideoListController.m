//
//  SYVideoListController.m
//  SYRecordVideoDemo
//
//  Created by leju_esf on 17/3/16.
//  Copyright © 2017年 yjc. All rights reserved.
//

#import "SYVideoListController.h"
#import "SYVideoModel.h"
#import <MediaPlayer/MediaPlayer.h>
#import "SYVideoListCell.h"
#import <Photos/Photos.h>
#import "SYSlideSelectedView.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "MBProgressHUD+MG.h"
@interface SYVideoListController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *list;
@property (strong, nonatomic) MPMoviePlayerViewController *playerVC;
@property (nonatomic, strong) SYSlideSelectedView *slideView;
@end

@implementation SYVideoListController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barTintColor = kNavigation7Color;
    self.tableView.backgroundColor = kBackgroundColor;
    self.navigationItem.titleView = self.slideView;
    self.tableView.tableFooterView = [UIView new];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([SYVideoListCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([SYVideoListCell class])];
    
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.list = [SYVideoModel videoListWithType:self.slideView.selectedIndex == 0?SYVideoTypeShare:SYVideoTypeNormal];
    
    [self.tableView reloadData];
}

#pragma mark - tableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.list.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SYVideoListCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SYVideoListCell class])];
    cell.model = self.list[indexPath.row];
    cell.backgroundColor = kBackgroundColor;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SYVideoModel *model = self.list[indexPath.row];
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"播放" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.playerVC = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:model.path]];
        [[self.playerVC moviePlayer] prepareToPlay];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playVideoFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:[self.playerVC moviePlayer]];
        [self presentMoviePlayerViewControllerAnimated:self.playerVC];
        [[self.playerVC moviePlayer] play];
    }];
    
    __weak typeof(self) weakSelf = self;
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"存到相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf saveVideoToCustomAblum:model];
    }];
    UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertVC addAction:action];
    [alertVC addAction:action2];
    [alertVC addAction:action3];
    [self presentViewController:alertVC animated:YES completion:nil];
    
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath  {
    __weak __typeof(self)weakSelf = self;
    SYVideoModel *model = self.list[indexPath.row];
    UITableViewRowAction *action = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        weakSelf.list = [SYVideoModel removeVideo:model];
        if (weakSelf.list == nil) {
            return ;
        }
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }];
    action.backgroundColor = [UIColor redColor];
    return @[action];
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return   UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

//当点击Done按键或者播放完毕时调用此函数
- (void) playVideoFinished:(NSNotification *)theNotification {
    MPMoviePlayerController *player = [theNotification object];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:player];
    [player stop];
    [self.playerVC dismissMoviePlayerViewControllerAnimated];
    self.playerVC = nil;
}


- (NSArray *)list {
    if (_list == nil) {
        if (_list.count == 0) {
            _list = [[NSArray alloc] init];
        }
    }
    return _list;
}

- (SYSlideSelectedView *)slideView {
    if (_slideView == nil) {
        _slideView = [[SYSlideSelectedView alloc] initWithTitles:@[@"抢拍视频",@"循环录像"] frame:CGRectMake(0, 0, 150, 44) normalColor:[UIColor whiteColor] andSelectedColor:DZColor(29, 180, 203)];
        __weak typeof(self) weakSelf = self;
        [_slideView setButtonAciton:^(NSInteger index) {
            if (index == 0) {
                weakSelf.list = [SYVideoModel videoListWithType:SYVideoTypeShare];
            }else {
                weakSelf.list = [SYVideoModel videoListWithType:SYVideoTypeNormal];
                
                
            }
            [weakSelf.tableView reloadData];
        }];
    }
    return _slideView;
}
#pragma mark - 创建相册
-(void)saveVideoToCustomAblum:(SYVideoModel *)model {
    PHFetchResult *assets = [self syncSaveImageWithModel:model];
    if (assets == nil) {
        NSLog(@"失败0");
        return;
    }
    PHAssetCollection *assetCollection = [self getAssetCollectionWithAppNameAndCreateIfNo];
    if (assetCollection == nil) {
        NSLog(@"失败1");
        return;
    }
    NSError *error = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        PHAssetCollectionChangeRequest *collectionChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
        [collectionChangeRequest insertAssets:assets atIndexes:[NSIndexSet indexSetWithIndex:0]];
    } error:&error];
    
    
    if (error) {
        NSLog(@"失败2");
        return;
    }
    [MBProgressHUD showSuccess:@"保存成功"];
    NSLog(@"成功");
}


-(PHFetchResult<PHAsset *> *)syncSaveImageWithModel:(SYVideoModel *)model {
    __block NSString *createdAssetID = nil;
    
    NSError *error = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        createdAssetID = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:[NSURL fileURLWithPath:model.path]].placeholderForCreatedAsset.localIdentifier;
    } error:&error];
    
    if (error) {
        return nil;
    }
    PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsWithLocalIdentifiers:@[createdAssetID] options:nil];
    return assets;
}


-(PHAssetCollection *)getAssetCollectionWithAppNameAndCreateIfNo {
    NSString *title = @"行车秀秀";
    PHFetchResult<PHAssetCollection *> *collections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (PHAssetCollection *collection in collections) {
        if ([collection.localizedTitle isEqualToString:title]) {
            return collection;
        }
    }
    NSError *error = nil;
    __block NSString *createID = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:title];
        createID = request.placeholderForCreatedAssetCollection.localIdentifier;
    } error:&error];
    if (error) {
        return nil;
    }else{
        return [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[createID] options:nil].firstObject;
    }
    
}

@end
