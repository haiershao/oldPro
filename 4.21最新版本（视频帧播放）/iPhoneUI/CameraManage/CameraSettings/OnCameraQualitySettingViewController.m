//
//  OnCameraQualitySettingViewController.m
//  HuaWo
//
//  Created by circlely on 1/29/16.
//  Copyright © 2016 circlely. All rights reserved.
//

#import "OnCameraQualitySettingViewController.h"
#import "CameraSettingsConfigData.h"
#import "MBProgressHUD.h"


#define kMenuTitle    @"menuTitle"
#define kMenuSelected @"menuSelected"
#define kMenuCmd      @"menuCmd"

@interface OnCameraQualitySettingViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *tableViewCells;
@property (strong, nonatomic) CameraSettingsConfigData *configData;
@end

@implementation OnCameraQualitySettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = kBackgroundColor;
    self.tableView.backgroundColor = nil;
    self.tableView.backgroundColor = kBackgroundColor;
    self.tableView.separatorColor = kBackgroundColor;
    self.configData = [CameraSettingsConfigData shareConfigData];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"title_back_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonItemAction)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 44)];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = NSLocalizedString(@"setting_page_video_quality", nil);
    self.navigationItem.titleView = titleLabel;

    [self createSections];
    
    [self CurrentQuality];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)leftBarButtonItemAction {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)dealloc {
    
    
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

- (void)createSections {
    
    NSMutableDictionary *row0 = [NSMutableDictionary dictionaryWithDictionary:@{kMenuTitle:NSLocalizedString(@"超清1080P", nil), kMenuSelected : @"",kMenuCmd : @"1080P"}];
    NSMutableDictionary *row1 = [NSMutableDictionary dictionaryWithDictionary:@{kMenuTitle:NSLocalizedString(@"高清720P", nil), kMenuSelected : @"",kMenuCmd : @"720P"}];
    NSMutableDictionary *row2 = [NSMutableDictionary dictionaryWithDictionary:@{kMenuTitle:NSLocalizedString(@"标清480P", nil), kMenuSelected : @"",kMenuCmd : @"480P"}];
    
    _tableViewCells = [NSMutableArray arrayWithObjects:row0, row1, row2, nil];
    
}

- (void)updateSelectedCell:(NSIndexPath*)indexPath {
    
    
    if (indexPath.row == [self CurrentQuality]) {
        
        return;
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES configBlock:^(MBProgressHUD *HUD) {
        
    }];
    
}

- (NSInteger)CurrentQuality {
    
    
    if ([self.configData.quality isEqualToString:@"480P"]) {
        
        [[_tableViewCells objectAtIndex:2] setObject:@"list_select" forKey:kMenuSelected];
        [_tableView reloadData];
        return 2;
        
    }
    else if ([self.configData.quality isEqualToString:@"720P"]) {
        
        [[_tableViewCells objectAtIndex:1] setObject:@"list_select" forKey:kMenuSelected];
        [_tableView reloadData];
        return 1;
    }
    
    else if([self.configData.quality isEqualToString:@"1080P"]) {
        
        [[_tableViewCells objectAtIndex:0] setObject:@"list_select" forKey:kMenuSelected];
        
        [_tableView reloadData];
        return 0;
    }
    
    
    return -1;

}

#pragma mark UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _tableViewCells.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *menuDic = [_tableViewCells objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cameraQualitySettingCell"];
    if (!cell) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cameraQualitySettingCell"];
        cell.backgroundColor = kTableViewCellColor;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textColor = [UIColor whiteColor];
        cell.textLabel.font = HWCellFont;
    }
    
    cell.textLabel.text = [menuDic objectForKey:kMenuTitle];
    cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[menuDic objectForKey:kMenuSelected]]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self updateSelectedCell:indexPath];
}

/**
 * 让当前控制器对应的状态栏是白色
 */
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
@end
