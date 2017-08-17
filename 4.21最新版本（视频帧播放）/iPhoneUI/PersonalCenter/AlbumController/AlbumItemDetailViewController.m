//
//  AlbumItemDetailViewController.m
//  HuaWo
//
//  Created by circlely on 2/20/16.
//  Copyright © 2016 circlely. All rights reserved.
//

#import "AlbumItemDetailViewController.h"
#import "ItemDetailCell.h"
#import "AlbumManager.h"
#import "UIImageView+WebCache.h"
#import "UIImageView+RecodPictureCache.h"
#import "MJRefresh.h"
#import "AlbumManager.h"
#import "SJAvatarBrowser.h"
#import <MediaPlayer/MediaPlayer.h>
#import "MBProgressHUD.h"
#import "RecordVideoPlayBackViewController.h"
#import "SharePageViewController.h"
#import "HWImmediatelyShareController.h"

#define kDeleteItemAlertTag 1000
#define kDeleteAllAlertTag  1001

@interface AlbumItemDetailViewController ()<UITableViewDataSource, UITableViewDelegate,UIAlertViewDelegate, ItemDetailCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (assign, nonatomic) NSInteger currentPageIndex;
@property (assign, nonatomic) NSInteger currentItemTag;
@end

@implementation AlbumItemDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self addRightButtonItem];
    
    [self setUpTableView];
    
    [self setUpNav];
    
    if (!self.isLocalAlbum) {
        
        [self.items removeAllObjects];
    
        self.currentPageIndex = 2;
        
        __typeof(self) __weak safeSelf = self;
        
        [self.tableView addHeaderWithCallback:^{
            
            [safeSelf refreshHeaderAction];
            
        }];
        
        [self.tableView addFooterWithCallback:^{
            
            [safeSelf refreshFooterAction];
        }];
        
    }
    
    [self.tableView headerBeginRefreshing];

}

- (void)setUpNav{

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"title_back_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonItemAction)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 44)];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = @"";
    self.navigationItem.titleView = titleLabel;
}

- (void)setUpTableView{

    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 20)];
    footerView.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = footerView;
    self.tableView.separatorColor = kBackgroundColor;
    self.tableView.backgroundColor = nil;
    self.tableView.backgroundColor = kBackgroundColor;
    self.view.backgroundColor = kBackgroundColor;
}

- (void)leftBarButtonItemAction {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    
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

- (void)addRightButtonItem {
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"video_list_controller_delete_all_btn", nil) style:UIBarButtonItemStylePlain target:self action:@selector(showAlertViewDeleteAll)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    
    
}

- (void)showAlertViewDeleteAll {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title", nil) message:NSLocalizedString(@"warnning_delete_all_file", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"cancel_btn", nil) otherButtonTitles:NSLocalizedString(@"confirm_btn", nil), nil];
    alertView.tag = kDeleteAllAlertTag;
    [alertView show];
}



- (void)deleteAllItems {
    
    if (self.isLocalAlbum) {
        
        
        for (AlbumInfo *item in self.items) {
            
            if ([item.iconPath isEqualToString:kNULL]) {
                
                [[AlbumManager shareAlbumManager] deleteItemInAlbumList:item forVideo:NO];
            }else {
                
                [[AlbumManager shareAlbumManager] deleteItemInAlbumList:item forVideo:YES];
            }

        }
        
        [self.items removeAllObjects];
        
        [self.tableView reloadData];
        
        if (_delegate) {
            [_delegate updateAlbumDetail];
        }

    }else{
        
        if (!self.items.count) {
            return;
        }
        
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES configBlock:^(MBProgressHUD *HUD) {
            HUD.customView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            HUD.removeFromSuperViewOnHide = YES;
            [(UIActivityIndicatorView *)HUD.customView startAnimating];
        }];
        
        
        
        
    }
    
    
}

- (void)refreshHeaderAction {
    
    
    if (self.items.count) {
        
        [self.tableView headerEndRefreshing];
        return;
    }
    
    
    
}

- (void)refreshFooterAction {
    
    
}

- (NSString *)formatRecordFileDate:(NSString *)fileDate {
    
    NSRange foundObj = [fileDate rangeOfString:@"-"];
    
    if (foundObj.location == NSNotFound) {
        return fileDate;
    }

    
    NSArray *dateArr = [fileDate componentsSeparatedByString:@"-"];
    NSString *formatDate = [NSString stringWithFormat:@"%@%@%@",[dateArr objectAtIndex:0], [dateArr objectAtIndex:1], [dateArr objectAtIndex:2]];
    
    return formatDate;
    
    
}

- (NSString *)fileSizeAtPath:(NSString *)filePath {
    
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]) {
        
        float size = [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
        
        if (size < 1024.f*1024.f) {
            
            return [NSString stringWithFormat:@"文件大小:%.0fK",size/1024.f];
        }
        
        return [NSString stringWithFormat:@"文件大小:%.2fM",size/1024.f/1024.f];
    }
    
    return nil;
}


- (NSString *)itemType:(NSString *)fileName {
    
    NSRange foundObjLoop = [fileName rangeOfString:@"loop"];
    NSRange foundObjParking = [fileName rangeOfString:@"parking"];
    
    if (foundObjLoop.location != NSNotFound) {
        return @"循环";
    }
    
    else if (foundObjParking.location != NSNotFound) {
        return @"停车";
    }
    
    return nil;
    
}

#pragma mark TableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 90;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AlbumInfo *itemInfo = [self.items objectAtIndex:indexPath.row];
    
    
    ItemDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"detailCell"];
    
    if (!cell) {
        
        cell = [[[NSBundle mainBundle] loadNibNamed:@"ItemDetailCell" owner:self options:nil] firstObject];
        cell.backgroundColor = kTableViewCellColor;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
    }
    
    cell.deleteBtn.tag = indexPath.row;
    
    if (self.isLocalAlbum) {
        
        
        cell.fileStyleLabel.hidden = YES;
        cell.fileTypeImageView.hidden = YES;
        cell.fileSizeLabel.text = [self fileSizeAtPath:itemInfo.fullPath];
        cell.timeRangeLabel.text = itemInfo.fileName;
        cell.createDate.text = [NSString stringWithFormat:@"%@:%@:%@",
                                [itemInfo.fileName substringWithRange:NSMakeRange(8, 2)],
                                [itemInfo.fileName substringWithRange:NSMakeRange(10, 2)],
                                [itemInfo.fileName substringWithRange:NSMakeRange(12, 2)]];
        if ([itemInfo.iconPath isEqualToString:kNULL]) {
            
            cell.playBtn.hidden = YES;
            
            [cell.iconImageView sd_setImageWithURL:[NSURL fileURLWithPath:itemInfo.fullPath] placeholderImage:[UIImage imageNamed:@"videorecord_icon_pic"]];
            
        }
        else {
            
            cell.playBtn.hidden = NO;
            [cell.iconImageView sd_setImageWithURL:[NSURL fileURLWithPath:itemInfo.iconPath] placeholderImage:[UIImage imageNamed:@"videorecord_icon_pic"]];
            
        }
        
        
    }
    
    else {
        
    }
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.isLocalAlbum) {
        
        AlbumInfo *item = [self.items objectAtIndex:indexPath.row];
        if ([item.iconPath isEqualToString:kNULL]) {
            
            [SJAvatarBrowser showImage:item.fullPath fileType:0];
        }else {
//
//            MPMoviePlayerViewController *player = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:item.fullPath]];
//            [self presentMoviePlayerViewControllerAnimated:player];
//            [player.moviePlayer play];
            
            HWImmediatelyShareController *imShareVc = [HWImmediatelyShareController immediatelyShareController];
            imShareVc.videoPath = item.fullPath;
            imShareVc.imageIconPath = item.iconPath;
            NSString *cidStr = [[[[item.fullPath componentsSeparatedByString:@"_"] lastObject] componentsSeparatedByString:@"."]firstObject];
            imShareVc.cidNum = cidStr;
            [self.navigationController pushViewController:imShareVc animated:YES];
            
        }
    }
    
    else {
    
        [[RDVTabBarController shareTabBar] setTabBarHidden:YES animated:NO];
        
    }
    
    
    
}

#pragma mark ItemDetailCellDelegate
- (void)itemDeleteButtonPressed:(NSInteger)btnTag {
    

    NSString *alertTitle = nil;
    
    self.currentItemTag = btnTag;
    
    if (self.isLocalAlbum) {
        
        AlbumInfo *item = [self.items objectAtIndex:btnTag];
        
        if ([item.iconPath isEqualToString:kNULL]) {
            
            alertTitle = @"截图";

        }else {
            
            alertTitle = @"视频";
        }
        
    }else {
        
        RvsRecordFileInfo *recordItem = [self.items objectAtIndex:btnTag];
        
        if ([[recordItem.fileName pathExtension] isEqualToString:@"mp4"]) {
            
            alertTitle = @"截图";
        }else {
            
            alertTitle = @"视频";
        }
        
    }
    
    NSString *alertMessage = [NSString stringWithFormat:@"删除该%@文件?",alertTitle];
    
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title", nil) message:alertMessage delegate:self cancelButtonTitle:NSLocalizedString(@"cancel_btn", nil) otherButtonTitles:NSLocalizedString(@"confirm_btn", nil), nil];
    alertView.tag = kDeleteItemAlertTag;
    [alertView show];
}

- (void)deleteItem {
    
    if (self.isLocalAlbum) {
        AlbumInfo *item = [self.items objectAtIndex:self.currentItemTag];
        
        if ([item.iconPath isEqualToString:kNULL]) {
            
            [[AlbumManager shareAlbumManager] deleteItemInAlbumList:item forVideo:NO];
        }else {
            
            [[AlbumManager shareAlbumManager] deleteItemInAlbumList:item forVideo:YES];
        }
        
        [self.items removeObject:item];
        [self.tableView reloadData];
        
        if (_delegate) {
            [_delegate updateAlbumDetail];
        }

        

    }else {
        
        __typeof(self) __weak safeSelf = self;
        
        RvsRecordFileInfo *item = [self.items objectAtIndex:self.currentItemTag];
        
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == kDeleteItemAlertTag) {
        if (buttonIndex == 1) {
            [self deleteItem];
        }
    }
    
    else if (alertView.tag == kDeleteAllAlertTag) {
        
        if (buttonIndex == 1) {
            [self deleteAllItems];
        }
        
    }
}

/**
 * 让当前控制器对应的状态栏是白色
 */
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
@end
