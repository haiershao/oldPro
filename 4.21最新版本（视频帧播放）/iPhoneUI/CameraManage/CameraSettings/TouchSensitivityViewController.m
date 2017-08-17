//
//  TouchSensitivityViewController.m
//  HuaWo
//
//  Created by circlely on 1/30/16.
//  Copyright © 2016 circlely. All rights reserved.
//

#import "TouchSensitivityViewController.h"
#import "CameraSettingsConfigData.h"
#import "MBProgressHUD.h"


#define kMenuTitle    @"menuTitle"
#define kMenuSelected @"menuSelected"
#define kMenuCmd      @"menuCmd"


@interface TouchSensitivityViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *footView;
@property (weak, nonatomic) IBOutlet UILabel *footerLabel;
@property (strong, nonatomic) NSMutableArray *tableViewCells;
@property (strong, nonatomic) CameraSettingsConfigData *configData;
@end

@implementation TouchSensitivityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = kBackgroundColor;
    self.tableView.backgroundColor = nil;
    self.tableView.backgroundColor = kBackgroundColor;
    self.tableView.separatorColor = kBackgroundColor;
    self.footView.backgroundColor = kBackgroundColor;
    self.tableView.tableFooterView = self.footView;

    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 44)];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = NSLocalizedString(@"collision_sensitivity", nil);
    self.navigationItem.titleView = titleLabel;
    
    
    self.footerLabel.text = NSLocalizedString(@"sensitivity_info", nil);
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"title_back_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonItemAction)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    
    
    self.configData = [CameraSettingsConfigData shareConfigData];
    [self createSections];
    
    [self currentSensitivity];
}

- (void)leftBarButtonItemAction {
    
    [self.navigationController popViewControllerAnimated:YES];
    
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

- (void)createSections {
    
    NSMutableDictionary *row0 = [NSMutableDictionary dictionaryWithDictionary:@{kMenuTitle:NSLocalizedString(@"关闭", nil), kMenuSelected : @"",kMenuCmd : @"none"}];
    NSMutableDictionary *row1 = [NSMutableDictionary dictionaryWithDictionary:@{kMenuTitle:NSLocalizedString(@"video_quality_high", nil), kMenuSelected : @"",kMenuCmd : @"high"}];
    NSMutableDictionary *row2 = [NSMutableDictionary dictionaryWithDictionary:@{kMenuTitle:NSLocalizedString(@"video_quality_middle", nil), kMenuSelected : @"",kMenuCmd : @"medium"}];
    NSMutableDictionary *row3 = [NSMutableDictionary dictionaryWithDictionary:@{kMenuTitle:NSLocalizedString(@"video_quality_low", nil), kMenuSelected : @"",kMenuCmd : @"low"}];
    
    _tableViewCells = [NSMutableArray arrayWithObjects:row0, row1, row2, row3, nil];
    
}

- (NSInteger)currentSensitivity {
    
    
    if ([self.configData.touchSensitivity isEqualToString:@"NONE"]) {
        
        [[_tableViewCells objectAtIndex:0] setObject:@"list_select" forKey:kMenuSelected];
        [_tableView reloadData];
        return 0;
    }
    
    else if ([self.configData.touchSensitivity isEqualToString:@"HIGH"]) {
        
        [[_tableViewCells objectAtIndex:1] setObject:@"list_select" forKey:kMenuSelected];
        [_tableView reloadData];
        return 1;
    }
    
    else if([self.configData.touchSensitivity isEqualToString:@"MEDIUM"]) {
        
        [[_tableViewCells objectAtIndex:2] setObject:@"list_select" forKey:kMenuSelected];
        
        [_tableView reloadData];
        return 2;
    }
    
    else if([self.configData.touchSensitivity isEqualToString:@"LOW"]) {
        
        [[_tableViewCells objectAtIndex:3] setObject:@"list_select" forKey:kMenuSelected];
        
        [_tableView reloadData];
        return 3;
    }
    return -1;
}


- (void)updateSelectedCell:(NSIndexPath*)indexPath {
    
    
    if (indexPath.row == [self currentSensitivity]) {
        return;
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES configBlock:^(MBProgressHUD *HUD) {
        
    }];
    
    __typeof(self) __weak safeSelf = self;
    
}


#pragma mark TableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _tableViewCells.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *menuDic = [_tableViewCells objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TouchSensitivitySettingCell"];
    if (!cell) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TouchSensitivitySettingCell"];
        cell.backgroundColor = kTableViewCellColor;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textColor = [UIColor whiteColor];
        cell.textLabel.font = HWCellFont;
    }
    
    cell.textLabel.text = [menuDic objectForKey:kMenuTitle];
    cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[menuDic objectForKey:kMenuSelected]]];
    
    return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
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
