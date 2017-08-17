//
//  AlbumController.m
//  HuaWo
//
//  Created by circlely on 1/25/16.
//  Copyright © 2016 circlely. All rights reserved.
//

#import "AlbumController.h"
#import "AlbumManager.h"
#import "AlbumTableViewCell.h"
#import <MediaPlayer/MediaPlayer.h>
#import "SJAvatarBrowser.h"
#import "MemberData.h"
#import "AlbumItem.h"
#import "AHCServerCommunicator.h"
#import "MBProgressHUD.h"
#import "RecordVideoPlayBackViewController.h"
#import "MJRefresh.h"
#import "AlbumItemDetailViewController.h"
#import "CustomCollectionViewCell.h"
#import "AKSegmentedControl.h"
#import "HWImmediatelyShareController.h"
#import "HWLocalVideoListView.h"
#import "HWLocalVideoListTableViewController.h"
#import "HWLocalVideoListViewController.h"
#import <CustomPhotoAlbum/ALAssetsLibrary+CustomPhotoAlbum.h>

#define kIsSelected  @"isselected"
#define kSeletedItemTag  1011

typedef void(^complete) (BOOL isFinish);

@interface AlbumController ()<UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, AlbumTableViewCellDelegate,AlbumItemDetailViewControllerDelegate>


@property (weak, nonatomic) IBOutlet UITableView *tableView;
//@property (strong, nonatomic) IBOutlet UIView *sectionHeaderView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;


@property (strong, nonatomic) UIButton *deleteBtn;
@property (strong, nonatomic) AlbumManager *albumManager;
@property (strong, nonatomic) NSMutableArray *sortItems;
@property (strong, nonatomic) NSMutableArray *daysTitleArr;
@property (strong, nonatomic) MPMoviePlayerViewController *player;
@property (strong, nonatomic) NSMutableArray *videoItemsForDelete;
@property (strong, nonatomic) NSMutableArray *pictureItemsForDelete;
@property (strong, nonatomic) AKSegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewTopConstraint;
@property (strong, nonatomic) NSMutableArray *cidNameList;
@property (strong, nonatomic) NSMutableArray *cidStrList;
@property (strong, nonatomic) NSString *cidStr;
@property (weak, nonatomic) IBOutlet UIView *noVideoVIew;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
//@property (strong, nonatomic) NSMutableArray *cacheLockItems;
//@property (strong, nonatomic) NSMutableArray *cacheUnlockItems;



@property (assign, nonatomic) BOOL isLocalAlbum;
@property (assign, nonatomic) BOOL isLock;
@property (assign, nonatomic) BOOL isFirst;
@property (assign, nonatomic) NSInteger currentPage;
@property (strong, nonatomic) UILabel *longPressedTips;

@property (assign, nonatomic) NSInteger currentSelectedCollectionItem;
@property (assign, nonatomic) NSInteger currentSegmentIndex;
@property (assign, nonatomic) NSInteger moveFirstIndex;

//@property (strong, nonatomic) StreamerAlbumManager *streamerAlbumManager;
//@property (copy, nonatomic) NSString *path;
@property (strong, nonatomic) UIButton *leftBtn;
@property (strong, nonatomic) UIButton *rightBtn;
@property (strong, nonatomic) HWLocalVideoListViewController *localVideoVc;
@property (strong, nonatomic) MBProgressHUD *hud;

@property (weak, nonatomic) UIWindow *mainWindow;
@property (nonatomic,strong) NSMutableArray *videoPaths;
@property (nonatomic,strong) NSMutableArray *images;
@property (nonatomic,strong) ALAssetsLibrary *assetLibrary;
@end

@implementation AlbumController

- (NSMutableArray *)images{
    
    if (!_images) {
        _images = [NSMutableArray array];
    }
    return _images;
}

- (ALAssetsLibrary *)assetLibrary{
    
    if (!_assetLibrary) {
        
        _assetLibrary = [[ALAssetsLibrary alloc] init];
        
    }
    return _assetLibrary;
}

- (NSMutableArray *)videoPaths{
    
    if (!_videoPaths) {
        _videoPaths = [NSMutableArray array];
    }
    return _videoPaths;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isFirst = YES;
//    [self setUpNav];

    [self setUpTableView];
    
    self.isLock = YES;
    self.isSelected = NO;
    self.isLocalAlbum = YES;
    self.currentPage = 2;
    self.currentSegmentIndex = -1;
    self.currentSelectedCollectionItem = -1;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:self.isSelected]  forKey:kIsSelected];

    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    
    self.collectionView.backgroundColor = nil;
    self.collectionView.backgroundColor = kBackgroundColor;
    
    //[self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"ALBUMCOLLECTIONCELL"];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"CustomCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"ALBUMCOLLECTIONCELL"];
    
    self.sortItems = [NSMutableArray array];
    
    [StreamerAlbumManager shareStreamerAlbumManager];
//    [self setUpActivityIndicatorView];
    self.longPressedTips = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-30, self.view.frame.size.width, 30)];
    self.longPressedTips.backgroundColor = [UIColor blackColor];
    self.longPressedTips.textAlignment = NSTextAlignmentLeft;
    self.longPressedTips.text = NSLocalizedString(@"avs_album_lock_hint", nil);
    self.longPressedTips.textColor = [UIColor whiteColor];
    [self.view addSubview:self.longPressedTips];
    self.longPressedTips.hidden = YES;
    
    [self addDeleteButton];
    [self initMJRefresh];
    [self initSegmentedController];
    [self initCidListArray];
    [self sortAlbumItems];
    
    [self addNavButton];
    
    
     [self.tableView headerBeginRefreshing];
    [self.tableView reloadData];
    [self readVideoAndPngFile:^(BOOL isFinish) {
        if (isFinish == YES) {
            
            for (int i = 0; i < self.videoPaths.count; i++) {
                NSURL *videoUrl = [NSURL fileURLWithPath:self.videoPaths[i]];
                HWLog(@"AlbumController videoUrl %@",videoUrl);

                [self.images addObject: [self.assetLibrary thumbnailImageForVideo:videoUrl atTime:1]];
                HWLog(@"AlbumController images %@",self.images[i]);
                
            }
        }
        
    }];
    
    
}

- (void)readVideoAndPngFile:(complete)complete{
    
    NSString *extension = @"mp4";
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dirName = @"video";
    documentsDirectory = [NSString stringWithFormat:@"%@/%@",documentsDirectory, dirName];
    
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:documentsDirectory error:nil];
    NSEnumerator *enumerator = [contents objectEnumerator];
    NSString *filename;
    while ((filename = [enumerator nextObject])) {
        if ([[filename pathExtension] isEqualToString:extension]) {
            
            [self.videoPaths addObject:[documentsDirectory stringByAppendingPathComponent:filename]];
            
        }
    }
    complete(YES);
    
}

- (void)addNavButton{

    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.width = 40;
    leftButton.height = self.collectionView.height;
    leftButton.x = 0;
    leftButton.y = 64;
    [leftButton setImage:[UIImage imageNamed:@"left-jiantou"] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(leftButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:leftButton];
    self.leftBtn = leftButton;
    self.leftBtn.hidden = YES;
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.width = 40;
    rightButton.height = self.collectionView.height;
    rightButton.x = screenW - rightButton.width;
    rightButton.y = 64;
    [rightButton setImage:[UIImage imageNamed:@"right-jiantou"] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(rightButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:rightButton];
    self.rightBtn = rightButton;
    HWLog(@"-------self.cidNameList.count---------%lu",(unsigned long)self.cidNameList.count);
    if (self.cidNameList.count <4) {
        leftButton.hidden = YES;
        rightButton.hidden = YES;
    }
}

- (void)leftButtonClick{
    if (self.cidNameList.count == 4) {
        self.leftBtn.hidden = !self.leftBtn.hidden;
        self.rightBtn.hidden = NO;
    }
    
    self.moveFirstIndex -= 2;
    NSIndexPath *nextIndexPath = [NSIndexPath indexPathForItem:self.moveFirstIndex inSection:0];
    HWLog(@"-----%ld",(long)nextIndexPath.item);
    [self.collectionView scrollToItemAtIndexPath:nextIndexPath atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
    
    if (self.moveFirstIndex == 2) {
        self.leftBtn.hidden = YES;
        self.rightBtn.hidden = NO;
    }

}

- (void)rightButtonClick{
    HWLog(@"---self.cidNameList.count--%ld",self.cidNameList.count);
    
    if (self.moveFirstIndex == 1) {
        self.moveFirstIndex = 2;
    }
    
    if (self.cidNameList.count == 4) {
        
        self.moveFirstIndex += 1;
        self.rightBtn.hidden = YES;
    }else{
    
        self.moveFirstIndex += 2;
    }
    
    NSIndexPath *nextIndexPath = [NSIndexPath indexPathForItem:self.moveFirstIndex inSection:0];
    HWLog(@"-----%ld",(long)nextIndexPath.item);
    [self.collectionView scrollToItemAtIndexPath:nextIndexPath atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
    
    if (self.moveFirstIndex > 2) {
        self.leftBtn.hidden = NO;
    }
    
    if (self.cidNameList.count % 2 == 0) {
        if (self.moveFirstIndex == (self.cidNameList.count - 2)) {
            self.rightBtn.hidden = YES;
        }
    }else{
    
        if (self.moveFirstIndex == (self.cidNameList.count - 1)) {
            self.rightBtn.hidden = YES;
        }
    }
}

- (void)setUpTableView{
    self.navigationController.navigationBar.barTintColor = kNavigation7Color;
    self.view.backgroundColor = kBackgroundColor;
    self.tableView.backgroundColor = nil;
    self.tableView.backgroundColor = kBackgroundColor;
    self.tableView.separatorColor = kTableViewSeparatorColor;
    
    //self.daysTitleArr = [AlbumManager shareAlbumManager].AlbumDays;
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 10)];
    footerView.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = footerView;
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)setUpNav{
    
    self.navigationController.navigationBar.barTintColor = kNavigation7Color;
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"title_back_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonItemAction)];
//    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 44)];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = NSLocalizedString(@"my_photo_album", nil);
    //    titleLabel.font = HWCellFont;
    self.navigationItem.titleView = titleLabel;
    
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"my_album_select_opt", nil) style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonClicked)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
}

- (void)leftBarButtonItemAction {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
    
    [super viewWillDisappear:animated];
    
    self.deleteBtn.hidden = YES;
    
    [self cleanItemsSelectedStatus];
    
    
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
}

- (void)viewDidLayoutSubviews {
    
    //设置tableview.separatorLine 左边顶到头
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        
        self.tableView.separatorInset = UIEdgeInsetsZero;
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutManager:)]) {
        
        self.tableView.layoutMargins = UIEdgeInsetsZero;
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    
    
    [[StreamerAlbumManager shareStreamerAlbumManager] destory];
    
}


- (void)initMJRefresh {
    
    __typeof(self) __weak safeSelf = self;
    [self.tableView addHeaderWithCallback:^{
        [safeSelf refreshDownCameraRecordList];
    }];
    
    
    [self.tableView addFooterWithCallback:^{
        [safeSelf refreshUpCameraRecordList];
    }];
    
    self.tableView.headerHidden = YES;
    self.tableView.footerHidden = YES;
}

- (void)segmentedControlAction:(UISegmentedControl *)segmented {
    
    if (self.currentSegmentIndex == segmented.selectedSegmentIndex) {
        
        return;
    }
    
    self.isLock = segmented.selectedSegmentIndex == 0 ? YES : NO;
    
    if ([self isAVSStatusOn:self.cidStr]) {
        
        
        if (segmented.selectedSegmentIndex == 0) {
            
            self.longPressedTips.text = NSLocalizedString(@"avs_album_lock_hint", nil);
            
            NSMutableArray *cacheLock = [[StreamerAlbumManager shareStreamerAlbumManager] getStreamerAlbumItemsForCIDNumber:self.cidStr forLock:YES];
            
            if (!cacheLock.count) {
                
                [self.tableView headerBeginRefreshing];
                
            }else {
                
                self.sortItems = cacheLock;
                [self.tableView reloadData];
            }
            
            
        }else {
            
            self.longPressedTips.text = NSLocalizedString(@"avs_album_unlock_hint", nil);
            
            NSMutableArray *cacheUnlock = [[StreamerAlbumManager shareStreamerAlbumManager] getStreamerAlbumItemsForCIDNumber:self.cidStr forLock:NO];
            
            if (!cacheUnlock.count) {
                
                [self.tableView headerBeginRefreshing];
                
            }else{
                
                self.sortItems = cacheUnlock;
                [self.tableView reloadData];
            }
            
        }
        
    }
}

- (void)initSegmentedController {
    
//    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"锁定",@"未锁定"]];
//    self.segmentedControl.frame = CGRectMake(0, 115, self.view.frame.size.width, 40);
//    self.segmentedControl.selectedSegmentIndex = 0;
//    self.segmentedControl.hidden = YES;
//    self.segmentedControl.layer.masksToBounds = NO;
//    self.segmentedControl.tintColor = kHuaWoTintColor;
//    
//    [self.segmentedControl addTarget:self action:@selector(segmentedControlAction:) forControlEvents:UIControlEventValueChanged];
//    
//    [self.view addSubview:self.segmentedControl];
    
    
    self.segmentedControl = [[AKSegmentedControl alloc] initWithFrame:CGRectMake(0, 115, screenW, 30)];
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.titleLabel.font = HWCellFont;
    [leftBtn setTitle:@"已锁定" forState:UIControlStateNormal];
    [leftBtn setImage:[UIImage imageNamed:@"album_lock_normal-1"] forState:UIControlStateNormal];
    [leftBtn setImage:[UIImage imageNamed:@"album_lock_select"] forState:UIControlStateSelected];
    [leftBtn setImage:[UIImage imageNamed:@"album_lock_select"] forState:UIControlStateHighlighted];
    
    
    //[leftBtn setBackgroundImage:[UIImage imageNamed:@"selectedImage"] forState:UIControlStateHighlighted];
    //[leftBtn setBackgroundImage:[UIImage imageNamed:@"selectedImage"] forState:UIControlStateSelected];
    [leftBtn setBackgroundColor:kNavigation7Color];
    
    [leftBtn setTitleColor:kHuaWoTintColor forState:UIControlStateHighlighted];
    [leftBtn setTitleColor:kHuaWoTintColor forState:UIControlStateSelected];
    [leftBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    
    UIButton *rightBtn = [[UIButton alloc] init];
    [rightBtn setTitle:@"未锁定" forState:UIControlStateNormal];
    rightBtn.titleLabel.font = HWCellFont;
    [rightBtn setImage:[UIImage imageNamed:@"album_unlock_normal"] forState:UIControlStateNormal];
    
    [rightBtn setImage:[UIImage imageNamed:@"album_unlock_select"] forState:UIControlStateSelected];
    [rightBtn setImage:[UIImage imageNamed:@"album_unlock_select"] forState:UIControlStateHighlighted];
    //[rightBtn setBackgroundImage:[UIImage imageNamed:@"selectedImage"] forState:UIControlStateHighlighted];
    //[rightBtn setBackgroundImage:[UIImage imageNamed:@"selectedImage"] forState:UIControlStateSelected];
    [rightBtn setBackgroundColor:kNavigation7Color];
    
    [rightBtn setTitleColor:kHuaWoTintColor forState:UIControlStateHighlighted];
    [rightBtn setTitleColor:kHuaWoTintColor forState:UIControlStateSelected];
    [rightBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    
    [self.segmentedControl setButtonsArray:@[leftBtn, rightBtn]];
    [self.segmentedControl addTarget:self action:@selector(segmentedViewController:) forControlEvents:UIControlEventValueChanged];
    [self.segmentedControl setSelectedIndexes:[NSIndexSet indexSetWithIndex:0]];
    self.segmentedControl.hidden = YES;
    [self.view addSubview:self.segmentedControl];
}

- (void)segmentedViewController:(id)sender {
    AKSegmentedControl *segmentedControl = (AKSegmentedControl *)sender;
    self.isLock = [segmentedControl.selectedIndexes isEqualToIndexSet:[NSIndexSet indexSetWithIndex:0]] ? YES : NO;
    //segmentedControl.selectedIndexes
    
    if ([self.tableView headerIsRefreshing]) {
        [self.tableView headerEndRefreshing];
    }
    
    
    //self.isLock = segmented.selectedSegmentIndex == 0 ? YES : NO;
    
    if ([self isAVSStatusOn:self.cidStr]) {
        
        if (self.isLock) {
            
            self.longPressedTips.text = NSLocalizedString(@"avs_album_lock_hint", nil);
            
            NSMutableArray *cacheLock = [[StreamerAlbumManager shareStreamerAlbumManager] getStreamerAlbumItemsForCIDNumber:self.cidStr forLock:YES];
            
            if (!cacheLock.count) {
                
                [self.tableView headerBeginRefreshing];
                
            }else {
                
                self.sortItems = cacheLock;
                [self.tableView reloadData];
            }
            
        }else {
            
            self.longPressedTips.text = NSLocalizedString(@"avs_album_unlock_hint", nil);
            
            NSMutableArray *cacheUnlock = [[StreamerAlbumManager shareStreamerAlbumManager] getStreamerAlbumItemsForCIDNumber:self.cidStr forLock:NO];
            
            if (!cacheUnlock.count) {
                
                [self.tableView headerBeginRefreshing];
                
            }else{
                
                self.sortItems = cacheUnlock;
                [self.tableView reloadData];
            }
        }
    }
}

- (void)initCidListArray {
    
    NSArray *cidList = [[MemberData memberData] getMemberCIDList];
    
    self.cidNameList = [NSMutableArray array];
    self.cidStrList  = [NSMutableArray array];
    
    [self.cidNameList addObject:@"循环录像"];
    [self.cidStrList addObject:@"0"];
    
//    [self.cidNameList addObject:@"抢拍视频"];
//    [self.cidStrList addObject:@"1"];
//    
//    [self.cidNameList addObject:@"循环录像"];
//    [self.cidStrList addObject:@"2"];
    
    
    for (NSDictionary *dic in cidList) {
        
        NSString *avsName = [[MemberData memberData] getAvsNameOfCID:[dic objectForKey:@"cid"]];
        
        if (self.cidNameList.count > 7) {
            break;
        }
        
        [self.cidNameList addObject:avsName];
        [self.cidStrList addObject:[dic objectForKey:@"cid"]];
    }
    
    [self.collectionView reloadData];
    
    NSIndexPath *firstIndexPath = [NSIndexPath indexPathForItem:1 inSection:0];
    self.moveFirstIndex = firstIndexPath.item;
    [self.collectionView selectItemAtIndexPath:firstIndexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    [self collectionView:self.collectionView didSelectItemAtIndexPath:firstIndexPath];
}


- (void)addDeleteButton {
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    self.deleteBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, window.frame.size.height-70, window.frame.size.width, 70)];
    [self.deleteBtn addTarget:self action:@selector(deleteBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.deleteBtn setImage:[UIImage imageNamed:@"album_delete"] forState:UIControlStateNormal];
    self.deleteBtn.backgroundColor = kBackgroundColor;
    [window addSubview:self.deleteBtn];
    self.deleteBtn.hidden = YES;
    
}

- (void)deleteBtnPressed {
    
    if (!self.sortItems || !self.sortItems.count) {
        
        [self rightBarButtonClicked];
        return;
    }
    
    if (self.isLocalAlbum) {
        
        for (AlbumInfo *item in self.pictureItemsForDelete) {
            
            [[AlbumManager shareAlbumManager] deleteItemInAlbumList:item forVideo:NO];
        }
        
        for (AlbumInfo *item in self.videoItemsForDelete) {
            
            [[AlbumManager shareAlbumManager] deleteItemInAlbumList:item forVideo:YES];
        }
        
        [self sortAlbumItems];
    }
    
    else {
        
        
        
        BOOL isLock = self.isLock;
        
        __typeof(self) __weak safeSelf = self;
        NSMutableArray *cameraDeleteArr = [NSMutableArray arrayWithArray:self.pictureItemsForDelete];
        [cameraDeleteArr addObjectsFromArray:self.videoItemsForDelete];
        
        if (!cameraDeleteArr.count) {
            return;
        }
        
        MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES configBlock:^(MBProgressHUD *HUD) {
            
            HUD.labelText = @"正在删除";
        }];
        
    }
    
    [self rightBarButtonClicked];
}



- (void)rightBarButtonClicked {
        
    self.isSelected = !self.isSelected;
    
    if (self.isSelected) {
        
        self.deleteBtn.hidden = NO;
        
        self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"cancel_btn", nil);
        [self.navigationItem.rightBarButtonItem setTintColor:kColor(230, 139, 30, 1)];
    }else{
        
        self.deleteBtn.hidden = YES;
        
        [self cleanItemsSelectedStatus];
        
        self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"my_album_select_opt", nil);
        [self.navigationItem.rightBarButtonItem setTintColor:[UIColor whiteColor]];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:self.isSelected]  forKey:kIsSelected];
}

- (void)cleanItemsSelectedStatus {
    
    
    for (int i = 0; i<self.sortItems.count; i++) {
        AlbumTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        
        for (UIView *subView in cell.contentView.subviews) {
                
            for (UIView *albumView in subView.subviews) {
                
                if (albumView.tag == kSeletedItemTag) {
                    albumView.hidden = YES;
                }
            }
            
        }
        
        
    }
    
    if (self.isLocalAlbum) {
        
        for (AlbumInfo *itemInfo in [AlbumManager shareAlbumManager].AlbumItemList) {
            
            itemInfo.isSelected = NO;
        }

    }
    
    else {
        
        
        
    }
    
    
}

- (void)sortAlbumItems {
    
    [self.sortItems removeAllObjects];
    
    //NSMutableArray *days = [AlbumManager shareAlbumManager].AlbumDays;
    
    NSMutableArray *days = [NSMutableArray array];
    
    NSMutableArray *allAlbumItems = [AlbumManager shareAlbumManager].AlbumItemList;
    
    NSString *fileDay = nil;
    
    for (AlbumInfo *info in allAlbumItems) {
        
        if (![days containsObject:[info.fileName substringToIndex:8]]) {
            
            [days addObject:[info.fileName substringToIndex:8]];
        }
        
    }
    
    self.daysTitleArr = days;
    
    for (int i = 0; i<days.count; i++) {
        
        NSMutableArray *oneDayItems = [[NSMutableArray alloc] initWithCapacity:42];
        
        for (AlbumInfo *item in allAlbumItems) {

            if ([[item.fileName substringToIndex:8] isEqualToString:[days objectAtIndex:i]]) {

                [oneDayItems addObject:item];
            }
        }

        if (oneDayItems.count > 0) {

            [self.sortItems addObject:oneDayItems];
        }else{
            
            //[self.daysTitleArr removeObject:[days objectAtIndex:i]];
        }
        
        oneDayItems = nil;

        
    }
    
    [self checkRightBarItemHiden];
    
    [self.tableView reloadData];
}

- (void)refreshUpCameraRecordList {
    
    if ([self.tableView headerIsRefreshing]) {
        [self.tableView footerEndRefreshing];
        return;
    }
    
    if ([self.tableView footerIsRefreshing]) {
        return;
    }
    
    
    __typeof(self) __weak safeSelf = self;
    
    BOOL selectedLock = self.isLock;
    
    if (selectedLock) {
        
        NSMutableArray *cachLock = [[StreamerAlbumManager shareStreamerAlbumManager] getStreamerAlbumItemsForCIDNumber:self.cidStr forLock:YES];
        
        if (!cachLock.count) {
            
            [self.tableView footerEndRefreshing];
        }
    }else{
        
        NSMutableArray *cacheUnlock = [[StreamerAlbumManager shareStreamerAlbumManager] getStreamerAlbumItemsForCIDNumber:self.cidStr forLock:NO];
        
        if (!cacheUnlock.count) {
            
            [self.tableView footerEndRefreshing];
        }
    }
    
}

- (void)refreshDownCameraRecordList {

    if ([self.tableView footerIsRefreshing]) {
        [self.tableView headerEndRefreshing];
        return;
    }
    

    __typeof(self) __weak safeSelf = self;
    
    BOOL selectedLock = self.isLock;
    
    if (selectedLock) {
        
        NSMutableArray *cacheLock = [[StreamerAlbumManager shareStreamerAlbumManager] getStreamerAlbumItemsForCIDNumber:self.cidStr forLock:YES];
        
        if (cacheLock.count) {
            
            [self checkRightBarItemHiden];
            
            [[StreamerAlbumManager shareStreamerAlbumManager] removeCachewithLock:YES forCIDNumber:self.cidStr];
            
        }
        else{
            
            [self.sortItems removeAllObjects];
            [self.tableView reloadData];
        }
        
    }else{
        
        NSMutableArray *cacheUnlock = [[StreamerAlbumManager shareStreamerAlbumManager] getStreamerAlbumItemsForCIDNumber:self.cidStr forLock:NO];
        
        if (cacheUnlock.count) {

            [self checkRightBarItemHiden];
            
            [[StreamerAlbumManager shareStreamerAlbumManager] removeCachewithLock:NO forCIDNumber:self.cidStr];
        }

        else{
            [self.sortItems removeAllObjects];
            [self.tableView reloadData];
        }
    }
    
}

- (void)checkRightBarItemHiden {
    
    if (self.sortItems.count == 0) {
        
        self.navigationItem.rightBarButtonItem = nil;
        
    }else {
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"my_album_select_opt", nil) style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonClicked)];
        self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    }
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    if([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]){
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    HWLog(@"----------self.sortItems.count==%lu",(unsigned long)self.sortItems.count);
    if (!self.sortItems.count) {
        tableView.hidden = YES;
    }else {
        tableView.hidden = NO;
    }
    
    return self.sortItems.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([[self.sortItems objectAtIndex:indexPath.row] count] > 2) {
        
        return 233.f;
    }
    
    return 130.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    int count = [[self.sortItems objectAtIndex:indexPath.row] count] > 2 ? 0: 1;
    
    NSString *identifierStr = [NSString stringWithFormat:@"albumcell%i",count];
    
    AlbumTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifierStr];
    cell.backgroundColor = kTableViewCellColor;
    cell.contentView.backgroundColor = kTableViewCellColor;
    if (!cell) {
        
        cell = [[[NSBundle mainBundle] loadNibNamed:@"AlbumTableViewCell" owner:self options:nil] objectAtIndex:count];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
    }
    
    if ([[self.sortItems objectAtIndex:indexPath.row] count] > 4) {
        cell.moreBtn.hidden = NO;
    }else {
        cell.moreBtn.hidden = YES;
    }
    
    if (self.isLocalAlbum) {
        
        cell.dateLabel.text = [self.daysTitleArr objectAtIndex:indexPath.row];
        cell.dateLabel.textColor = [UIColor whiteColor];
        cell.albumItems = [self.sortItems objectAtIndex:indexPath.row];
    }
    
    else {
        

        

        cell.dateLabel.textColor = [UIColor whiteColor];
        cell.albumCameraItems = [self.sortItems objectAtIndex:indexPath.row];
        cell.CIDNumber = self.cidStr;
        HWLog(@"---------self.cidStr----------%@",self.cidStr);
    }
    
    HWLog(@"-----cell-----==%@",cell);
    cell.frame = CGRectMake(0, 0, 100, 200);
    [cell setTranslatesAutoresizingMaskIntoConstraints:NO];
    cell.backgroundColor = [UIColor whiteColor];
    return cell;
}


- (BOOL)isAVSStatusOn:(NSString *)cid {
    
    NSInteger onlineState = [[MemberData memberData] getAvsStatusOfCID:cid];
    
    if (onlineState == PEER_STATUS_STATE_ONLINE) {
        return YES;
    }
    
    [self.sortItems removeAllObjects];
    [self.tableView reloadData];
    
    return NO;
    
}

#pragma mark UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.cidNameList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CustomCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ALBUMCOLLECTIONCELL" forIndexPath:indexPath];
    
    cell.cellIndexPath = indexPath;
    
    cell.backgroundColor = kBackgroundColor;
//    cell.backgroundColor = [UIColor whiteColor];
    cell.textLabel.text = [self.cidNameList objectAtIndex:indexPath.item];
    if (indexPath.item == 3) {
        
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    }else{
    
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
    }
    
    cell.textLabel.font = HWCellFont;
    
    CGFloat screenw = screenW;
    if (indexPath.item == 0 || indexPath.item == 1 || indexPath.item == 2)  {
        cell.width = screenw / 4;
        HWLog(@"cell.width---%f",cell.width);
    }
    
    return cell;
}

- (void)setUpActivityIndicatorView{
    CGFloat screenw = screenW;
    CGFloat screenh = screenH;
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.45*screenw, 0.45*screenh, 50, 50)];
    self.activityIndicator.layer.cornerRadius = 5;
    self.activityIndicator.layer.masksToBounds = YES;
    self.activityIndicator.backgroundColor = [UIColor lightGrayColor];
    [self.activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
//    [self.tableView addSubview:self.activityIndicator];
//    [self.tableView bringSubviewToFront:self.activityIndicator];
    self.activityIndicator.hidden = YES;
    
//    CGFloat screenw = screenW;
//    CGFloat screenh = screenH;
//    bindView.frame = CGRectMake(0, 0, screenw, screenh);
    NSArray* windows = [UIApplication sharedApplication].windows;
    self.mainWindow = [windows objectAtIndex:0];
    [self.mainWindow addSubview:self.activityIndicator];
}

- (void)viewDidDisappear:(BOOL)animated{

    [super viewDidDisappear:animated];
    self.activityIndicator.hidden = YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        self.activityIndicator.hidden = YES;
    });
    
    if (self.currentSelectedCollectionItem == indexPath.item) {
        return ;
    }
    
    self.currentSelectedCollectionItem = indexPath.item;
    
    
    
    if (indexPath.item == 0|| indexPath.item == 1) {
        
        self.noVideoVIew.hidden = YES;
        
        self.longPressedTips.hidden = YES;
        
        [self.tableView headerEndRefreshing];
        [self.tableView footerEndRefreshing];
        
        self.tableViewTopConstraint.constant = 0;
        self.segmentedControl.hidden = YES;
        self.isLocalAlbum = YES;
        [self sortAlbumItems];
        self.tableView.headerHidden = YES;
        self.tableView.footerHidden = YES;
        
        HWLocalVideoListViewController *localVideoViewVc = [HWLocalVideoListViewController localVideoListViewController];
        localVideoViewVc.navigationController = self.navigationController;
        localVideoViewVc.view.width = self.view.width;
        localVideoViewVc.view.height = self.view.height - 64;
        localVideoViewVc.view.x = 0;
        localVideoViewVc.view.y = 64 + self.collectionView.height;
        localVideoViewVc.videoPaths = self.videoPaths;
        localVideoViewVc.loopImages = self.images;
        [self.view addSubview:localVideoViewVc.view];
        self.localVideoVc = localVideoViewVc;
        
        
        
    }else if (indexPath.item == 2) {
        
        HWLocalVideoListViewController *localVideoViewVc = [HWLocalVideoListViewController localVideoListViewController];
        localVideoViewVc.navigationController = self.navigationController;
        localVideoViewVc.view.width = self.view.width;
        localVideoViewVc.view.height = self.view.height - 64;
        localVideoViewVc.view.x = 0;
        localVideoViewVc.view.y = 64 + self.collectionView.height;
        
        localVideoViewVc.videoPaths = self.videoPaths;
        localVideoViewVc.loopImages = self.images;
        [self.view addSubview:localVideoViewVc.view];
        self.localVideoVc = localVideoViewVc;
        
        
        
//        self.noVideoVIew.hidden = NO;
//        
//        self.longPressedTips.hidden = YES;
//        
//        [self.tableView headerEndRefreshing];
//        [self.tableView footerEndRefreshing];
//        
//        self.tableViewTopConstraint.constant = 0;
//        self.segmentedControl.hidden = YES;
//        self.isLocalAlbum = YES;
//        [self sortAlbumItems];
//        self.tableView.headerHidden = YES;
//        self.tableView.footerHidden = YES;
//        self.localVideoVc.view.hidden = YES;
        
    }else{
        
        self.localVideoVc.view.hidden = YES;
        self.noVideoVIew.hidden = YES;
        
        //self.sortItems = nil;
        self.longPressedTips.hidden = NO;
        
        self.tableViewTopConstraint.constant = 40;
        self.segmentedControl.hidden = NO;
        self.isLocalAlbum = NO;
        self.cidStr = [self.cidStrList objectAtIndex:indexPath.item];
        [[NSUserDefaults standardUserDefaults] setObject:self.cidStr forKey:kCidStr];
        if (![self isAVSStatusOn:self.cidStr]) {
            
            [MBProgressHUD showHUDAddedTo:self.view animated:YES configBlock:^(MBProgressHUD *HUD) {
                HUD.labelText = @"摄像头不在线";
                HUD.mode = MBProgressHUDModeText;
                HUD.removeFromSuperViewOnHide = YES;
                [HUD hide:YES afterDelay:1];
            }];
            
            self.tableView.headerHidden = YES;
            self.tableView.footerHidden = YES;
            
            return;
        }
        
        self.tableView.headerHidden = NO;
        self.tableView.footerHidden = NO;
        
        if (self.isLock) {
            
            NSMutableArray *cacheLock = [[StreamerAlbumManager shareStreamerAlbumManager] getStreamerAlbumItemsForCIDNumber:self.cidStr forLock:YES];
            
            if (!cacheLock.count) {
                [self.tableView headerBeginRefreshing];
            }else {
                
                self.sortItems = cacheLock;
                [self.tableView reloadData];
            }
            
            
        }else {
            
            NSMutableArray *cacheUnlock = [[StreamerAlbumManager shareStreamerAlbumManager] getStreamerAlbumItemsForCIDNumber:self.cidStr forLock:NO];
            
            if (!cacheUnlock.count) {
                
                [self refreshDownCameraRecordList];
            }else{
                
                self.sortItems = cacheUnlock;
                [self.tableView reloadData];
            }

        }
        
        [self checkRightBarItemHiden];

    }
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat screenw = screenW;
    
    if (self.cidNameList.count == 4) {
        
        if (indexPath.item == 0 || indexPath.item == 1 || indexPath.item == 2)  {
            
            return CGSizeMake(screenw/3.5, self.collectionView.height);
        }
    }else{
    
        if (indexPath.item == 0 || indexPath.item == 1 || indexPath.item == 2)  {
            
            return CGSizeMake(screenw/3.4, self.collectionView.height);
        }
    }
    
    if (self.cidNameList.count == 4) {
      
        if (indexPath.item == 2 || indexPath.item == 3)  {
            
            return CGSizeMake(screenw, self.collectionView.height);
        }
    }else{
    
        if (indexPath.item == 2 || indexPath.item == 3)  {
            
            return CGSizeMake(screenw/2.4, self.collectionView.height);
        }
    }
    
    
    return CGSizeMake(screenw/1.9, self.collectionView.height);
}

//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
//    
//    return 20;
//}
//
//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
//    
//    return 20;
//}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
//    if (section < 4) {
//        return UIEdgeInsetsMake(0, 10, 0, -20);
//    }
    return UIEdgeInsetsMake(0, 10, 0, 0);
}

#pragma mark AlbumTableViewCellDelegate

- (void)videoPlayed:(NSString *)videoPath imageIcon:(NSString *)imagePath{
    
//    self.player = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:path]];
//    [self presentMoviePlayerViewControllerAnimated:self.player];
//    [self.player.moviePlayer play];
    
    HWImmediatelyShareController *immediatelyShareVc = [HWImmediatelyShareController immediatelyShareController];
    immediatelyShareVc.videoPath = videoPath;
    immediatelyShareVc.imageIconPath = imagePath;
    NSString *cidStr = [[[[videoPath componentsSeparatedByString:@"_"] lastObject] componentsSeparatedByString:@"."]firstObject];
    immediatelyShareVc.cidNum = cidStr;
    [self.navigationController pushViewController:immediatelyShareVc animated:YES];
}

- (void)pictureShowed:(NSString *)path {
    
    if (self.isGetIconImage) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"postLocalImagePath" object:path];
    }
}

- (void)postPrePictureItemForDeleteData:(NSMutableArray *)arr {
    
    self.pictureItemsForDelete = arr;
}

- (void)postPreVideoItemForDeleteData:(NSMutableArray *)arr {
    
    self.videoItemsForDelete = arr;
}

                                                     
- (void)streamerVideoPlayedWithStreamURL:(NSString *)streamURL FileName:(NSString *)fileName AVSCID:(NSString *)CIDNubmer timeRange:(NSString *)tiemRange recordType:(NSUInteger)type {

    RecordVideoPlayBackViewController *videoPlayer = [[RecordVideoPlayBackViewController alloc] initWithStreamURL:streamURL FileName:fileName AVSCID:CIDNubmer andTimeRange:tiemRange recordType:type];
    
    
    [[RDVTabBarController shareTabBar] setTabBarHidden:YES animated:NO];
    
    [self.navigationController pushViewController:videoPlayer animated:YES];
    
//    self.player = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:streamURL]];
//    [self presentMoviePlayerViewControllerAnimated:self.player];
//    [self.player.moviePlayer play];
}

- (void)showDetailItem:(NSArray *)items {
    [[RDVTabBarController shareTabBar] setTabBarHidden:YES animated:NO];
    
    AlbumItemDetailViewController *detail = [[AlbumItemDetailViewController alloc] initWithNibName:@"AlbumItemDetailViewController" bundle:nil];
    detail.items = [NSMutableArray arrayWithArray:items];
    detail.delegate = self;
    detail.isLocalAlbum = self.isLocalAlbum;
    
    if (!self.isLocalAlbum) {
        
    }
    
    [self.navigationController pushViewController:detail animated:YES];
    
}

- (void)updateAlbum {
    
//    [self.cacheLockItems removeAllObjects];
//    [self.cacheUnlockItems removeAllObjects];
    
    [[StreamerAlbumManager shareStreamerAlbumManager] destory];
    
    
    [self refreshDownCameraRecordList];
}

#pragma mark -
- (void)updateAlbumDetail {
    if (self.isLocalAlbum) {
        [self sortAlbumItems];
    }else {
        //[self refreshDownCameraRecordList];
        
        self.sortItems = [[StreamerAlbumManager shareStreamerAlbumManager] getStreamerAlbumItemsForCIDNumber:self.cidStr forLock:self.isLock];
        
        [self.tableView reloadData];
        
    }
    
    
}

//3.18 add start --- by mj
#pragma mark -
+ (instancetype)albumController{
    
    return [[AlbumController alloc] initWithNibName:@"AlbumController" bundle:nil];
    
}
//3.18 add end --- by mj

/**
 * 让当前控制器对应的状态栏是白色
 */
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
@end
