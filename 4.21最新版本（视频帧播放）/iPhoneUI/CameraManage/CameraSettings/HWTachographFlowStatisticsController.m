//
//  HWTachographFlowStatisticsController.m
//  HuaWo
//
//  Created by hwawo on 16/5/13.
//  Copyright © 2016年 HW. All rights reserved.
//

#import "HWTachographFlowStatisticsController.h"


#define kMenuTitle    @"menuTitle"
#define kMenuSelected @"menuSelected"
#define kMenuCmd      @"menuCmd"
@interface HWTachographFlowStatisticsController ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (strong, nonatomic) NSMutableArray *sections;

@end

@implementation HWTachographFlowStatisticsController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = kBackgroundColor;
    self.tableview.backgroundColor = nil;
    self.tableview.separatorColor = kBackgroundColor;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"title_back_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonItemAction)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    
    [self createSections];
}

+ (instancetype)tachographFlowStatisticsController{

    return [[HWTachographFlowStatisticsController alloc] initWithNibName:@"HWTachographFlowStatisticsController" bundle:nil];
}

- (void)leftBarButtonItemAction{

    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLayoutSubviews{

    if ([self.tableview respondsToSelector:@selector(setSeparatorInset:)]) {
        
        self.tableview.separatorInset = UIEdgeInsetsZero;
    }
    
    if ([self.tableview respondsToSelector:@selector(setLayoutMargins:)]) {
        
        self.tableview.layoutMargins = UIEdgeInsetsZero;
    }
}

- (void)createSections{
    
    NSString *WifiGprsData = [self countWifiData:self.getWifiGprsData];
    NSMutableDictionary *sections0row0 = [NSMutableDictionary dictionaryWithDictionary:@{kMenuTitle:NSLocalizedString(@"已使用流量", nil), kMenuSelected:@"", kMenuCmd:WifiGprsData}];
    NSMutableDictionary *sections0row1 = [NSMutableDictionary dictionaryWithDictionary:@{kMenuTitle:NSLocalizedString(@"套餐总流量", nil), kMenuSelected:@"", kMenuCmd:@"1G"}];
    NSMutableArray *section0 = [[NSMutableArray alloc] initWithObjects:sections0row0, sections0row1, nil];
    
    NSMutableDictionary *sections1row0 = [NSMutableDictionary dictionaryWithDictionary:@{kMenuTitle:NSLocalizedString(@"Wi-Fi热点流量", nil), kMenuSelected:@"", kMenuCmd:WifiGprsData}];
    NSMutableArray *section1 = [[NSMutableArray alloc] initWithObjects:sections1row0, nil];
    
    NSMutableDictionary *sections2row0 = [NSMutableDictionary dictionaryWithDictionary:@{kMenuTitle:NSLocalizedString(@"", nil), kMenuSelected:@"", kMenuCmd:@""}];
    NSMutableArray *section2 = [[NSMutableArray alloc] initWithObjects:sections2row0, nil];
    
    self.sections = [NSMutableArray arrayWithObjects:section0, section1, section2, nil];
}

- (NSString *)countWifiData:(NSString *)wifiData{
    float floatStr = [wifiData floatValue];
    HWLog(@"-----------------------%f",floatStr);
    if (floatStr >= 1024) {
        return [NSString stringWithFormat:@"%.1fM",floatStr/1024];
    }else if (floatStr >= 1024*1024){
    
        return [NSString stringWithFormat:@"%.1fG",floatStr/(1024*1024)];
    }else if (floatStr > 0 && floatStr < 1024){
    
        return [NSString stringWithFormat:@"%.1fK",floatStr];
    }
    return [NSString stringWithFormat:@"0B"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{

    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [[self.sections objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    NSMutableDictionary *menuDic = [[_sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HWTachographFlowStatisticsController"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"HWTachographFlowStatisticsController"];
        cell.backgroundColor = kTableViewCellColor;
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.font = HWCellFont;
    }
    cell.textLabel.text = [menuDic objectForKey:kMenuTitle];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
    label.textColor = [UIColor whiteColor];
    label.text = [menuDic objectForKey:kMenuCmd];
    label.font = [UIFont systemFontOfSize:11];
    label.textAlignment = NSTextAlignmentRight;
    cell.accessoryView = label;
    if ((indexPath.section == 2) && (indexPath.row == 0)) {
        cell.backgroundColor = [UIColor clearColor];
        CGFloat screenw = screenW;
        CGFloat btnx = 5;
        CGFloat btny = 2;
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(5, 2, screenw - 2*btnx, cell.frame.size.height - 2*btny)];
        btn.backgroundColor = DZColor(0, 204, 204);
        btn.layer.cornerRadius = 5;
        btn.layer.masksToBounds = YES;
        [btn setTitle:NSLocalizedString(@"短信查询实际流量", nil) forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(checkFlow) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:btn];
    }
    
    return cell;
}

- (void)checkFlow{

    HWLog(@"-----------------------------------");
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{

    if (section == 1) {
        return 10;
    }
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{

    CGFloat screenw = screenW;
    CGFloat screenh = screenH;
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenw, screenh)];
    footerView.backgroundColor = kBackgroundColor;
    return footerView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 * 让当前控制器对应的状态栏是白色
 */
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
