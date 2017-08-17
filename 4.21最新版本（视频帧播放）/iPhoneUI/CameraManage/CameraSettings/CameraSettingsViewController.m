//
//  CameraSettingsViewController.m
//  HuaWo
//
//  Created by circlely on 1/27/16.
//  Copyright © 2016 circlely. All rights reserved.
//

#import "CameraSettingsViewController.h"
#import "MBProgressHUD.h"
#import "CameraSettingsConfigData.h"
#import "OnCameraQualitySettingViewController.h"
#import "TouchSensitivityViewController.h"

#import "HWTachographFlowStatisticsController.h"
#import "HWVideoQualitySettingViewController.h"

#define kMenuTitle            @"menuTitle"
#define kMenuSytle            @"menuStyle"
#define kMenuSelector         @"menuSelector"
#define kMenuDetailText       @"menuDetailText"



#define kDetailStyleCellID    @"CameraSettingsDetailStyleCell"
#define kSwitchStyleCellID    @"CameraSettingsSwitchStyleCell"

@interface CameraSettingsViewController ()<UITableViewDataSource, UITableViewDelegate, cameraQualitySetDelegate, cameraTouchSensitivitySetDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *sections;
@property (strong, nonatomic) MBProgressHUD *HUD;
@property (strong, nonatomic) CameraSettingsConfigData *configData;

@end

@implementation CameraSettingsViewController
{
    NSDictionary *detailDic;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self createSections];
    self.view.backgroundColor = kBackgroundColor;
    self.tableView.backgroundColor = nil;
    self.tableView.backgroundColor = kBackgroundColor;
    self.tableView.separatorColor = kBackgroundColor;
    
    
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"title_back_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonItemAction)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 44)];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = NSLocalizedString(@"cid_cell_setting_label", nil);
    self.navigationItem.titleView = titleLabel;
    
    self.HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES configBlock:^(MBProgressHUD *HUD) {
        HUD.removeFromSuperViewOnHide = YES;
    }];

}

- (void)viewDidAppear:(BOOL)animated {
    
 //   [self updateDetailText];
}

- (void)viewWillAppear:(BOOL)animated {
    
    
}

- (void)viewDidDisappear:(BOOL)animated {
    
    
}

- (void)dealloc {
    
    
    
}

- (void)leftBarButtonItemAction {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createSections{

    NSMutableDictionary *section0row0 = [NSMutableDictionary
                                         dictionaryWithDictionary:@{kMenuTitle:NSLocalizedString(@"setting_page_video_quality", nil),
                                                                                        kMenuSytle:kDetailStyleCellID,kMenuDetailText:@"",
                                                                                        kMenuSelector:NSStringFromSelector(@selector(onSetQualityCell))}];
    
    NSMutableArray *section0 = [[NSMutableArray alloc] initWithObjects:section0row0 ,nil];
    
    
    NSMutableDictionary *section1row0 = [NSMutableDictionary
                                         dictionaryWithDictionary:@{kMenuTitle:NSLocalizedString(@"setting_page_auto_loop_recording", nil),
                                                                                        kMenuSytle:kSwitchStyleCellID,kMenuDetailText:@"",
                                                                                        kMenuSelector:NSStringFromSelector(@selector(onSwitchCell))}];
    NSMutableDictionary *section1row1 = [NSMutableDictionary
                                         dictionaryWithDictionary:@{kMenuTitle:NSLocalizedString(@"setting_page_sound_recording", nil),
                                                                                        kMenuSytle:kSwitchStyleCellID,kMenuDetailText:@"",
                                                                                        kMenuSelector:NSStringFromSelector(@selector(onSwitchCell))}];
    
    NSMutableArray *section1 = [[NSMutableArray alloc] initWithObjects:section1row0, section1row1, nil];
    
    
    NSMutableDictionary *section2row0 = [NSMutableDictionary
                                         dictionaryWithDictionary:@{kMenuTitle:NSLocalizedString(@"setting_page_tachograph_indicator_light", nil),
                                                                                        kMenuSytle:kSwitchStyleCellID,
                                                                                        kMenuDetailText:@"",
                                                                                        kMenuSelector:NSStringFromSelector(@selector(onSwitchCell))}];
    NSMutableDictionary *section2row1 = [NSMutableDictionary
                                         dictionaryWithDictionary:@{kMenuTitle:NSLocalizedString(@"setting_page_power_prompt_sound", nil),
                                                                                        kMenuSytle:kSwitchStyleCellID,
                                                                                        kMenuDetailText:@"",
                                                                                        kMenuSelector:NSStringFromSelector(@selector(onSwitchCell))}];
    NSMutableDictionary *section2row2 = [NSMutableDictionary
                                         dictionaryWithDictionary:@{kMenuTitle:NSLocalizedString(@"setting_page_collision_sensitivity", nil),
                                                                                        kMenuSytle:kDetailStyleCellID,
                                                                                        kMenuDetailText:@"",
                                                                                        kMenuSelector:NSStringFromSelector(@selector(onTouchSensitivityCellPressed))}];
    NSMutableDictionary *section2row3 = [NSMutableDictionary
                                         dictionaryWithDictionary:@{kMenuTitle:NSLocalizedString(@"setting_page_parking_security", nil),
                                                                                        kMenuSytle:kSwitchStyleCellID,
                                                                                        kMenuDetailText:@"",
                                                                                        kMenuSelector:NSStringFromSelector(@selector(onSwitchCell))}];
    
    
    NSMutableArray *section2 = [[NSMutableArray alloc] initWithObjects:section2row0, section2row1, section2row2, section2row3, nil];
    
    
    
    NSMutableDictionary *section3row0 = [NSMutableDictionary
                                         dictionaryWithDictionary:@{kMenuTitle:NSLocalizedString(@"setting_page_inquire_storage_capacity", nil),
                                                                                        kMenuSytle:kDetailStyleCellID,
                                                                                        kMenuDetailText:@"10GB/20GB",
                                                                                        kMenuSelector:NSStringFromSelector(@selector(setInquireStorageCapacity))}];
    NSMutableDictionary *section3row1 = [NSMutableDictionary
                                         dictionaryWithDictionary:@{kMenuTitle:NSLocalizedString(@"setting_page_tachograph_flow_statistics", nil),
                                                                                        kMenuSytle:kDetailStyleCellID,
                                                                                        kMenuDetailText:@"",
                                                                                        kMenuSelector:NSStringFromSelector(@selector(tachographFlowStatistics))}];
    
    NSMutableArray *section3 = [[NSMutableArray alloc] initWithObjects:section3row0, section3row1, nil];
    
    
    NSMutableDictionary *section6row0 = [NSMutableDictionary dictionaryWithDictionary:@{kMenuTitle:NSLocalizedString(@"setting_page_reset_factory_settings", nil),kMenuSytle:kDetailStyleCellID,kMenuDetailText:@"",kMenuSelector:NSStringFromSelector(@selector(onResetFactorySettings))}];
    
    NSMutableArray *section6 = [[NSMutableArray alloc] initWithObjects:section6row0, nil];
    
#warning updateDetailText 隐藏菜单再加上菜单需打开这个方法里注释掉的类容
    self.sections = [NSMutableArray arrayWithObjects:section0,section1, nil];
}

- (void)switchAction:(UISwitch *)switchBtn {
    
    __typeof(self) __weak safeSelf = self;
    
    if (switchBtn.tag == 101) {//自动循环
        self.HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES configBlock:^(MBProgressHUD *HUD) {
            HUD.removeFromSuperViewOnHide = YES;
        }];
        
    }
    
    else if (switchBtn.tag == 132) {//停车安防
        self.HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES configBlock:^(MBProgressHUD *HUD) {
            HUD.removeFromSuperViewOnHide = YES;
        }];
//        [self.setParkingCmd startRequestToCID:self.cidNumber completionBlock:^(AHCRequest *request) {
//            safeSelf.configData.parkingSwitch = switchBtn.on;
//            [safeSelf.HUD hide:YES];
//        } failedBlock:^(ERROR_TYPE errType) {
//            [switchBtn setOn:!switchBtn.on];
//            safeSelf.HUD.labelText = @"Failed";
//            [switchBtn setOn:!switchBtn.on];
//            [safeSelf.HUD hide:YES afterDelay:1];
//        }];
        
    }
    
    else if (switchBtn.tag == 111) {//声音录制
        self.HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES configBlock:^(MBProgressHUD *HUD) {
            HUD.removeFromSuperViewOnHide = YES;
        }];

    }
    
    else if (switchBtn.tag == 112) {//开关机提示音
        self.HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES configBlock:^(MBProgressHUD *HUD) {
            HUD.removeFromSuperViewOnHide = YES;
        }];
        
    }
    
    else if (switchBtn.tag == 102) {//记录仪指示灯
        self.HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES configBlock:^(MBProgressHUD *HUD) {
            HUD.removeFromSuperViewOnHide = YES;
        }];

    }
    
}

- (void)updateSwitchStatues {

    //自动循环录像
    UISwitch *loopVideoSwitchBtn = (UISwitch *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]].accessoryView;
    [loopVideoSwitchBtn setOn:self.configData.loopVideoSwitch];
    //停车安防
    UISwitch *parkingSwitchBtn = (UISwitch *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:2]].accessoryView;
    [parkingSwitchBtn setOn:self.configData.parkingSwitch];
    //声音录制
    UISwitch *soundSwitchBtn = (UISwitch *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]].accessoryView;
    [soundSwitchBtn setOn:self.configData.soundSwitch];
    //开关机提示音
    UISwitch *warningToneSwitchBtn = (UISwitch *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:2]].accessoryView;
    [warningToneSwitchBtn setOn:self.configData.warningToneSwitch];
    //记录仪指示灯
    UISwitch *indicaterSwitchBtn = (UISwitch *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]].accessoryView;
    [indicaterSwitchBtn setOn:self.configData.indicateorLightSwitch];
    
    //自动同步到手机时间
    UISwitch *atuoSynchroTimeSwitch = (UISwitch *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]].accessoryView;
    [atuoSynchroTimeSwitch setOn: self.configData.atuoSynchroTimeSwitch];
}

- (void)updateDetailText {
    
    [[[_sections objectAtIndex:0] objectAtIndex:0] setObject:self.configData.quality forKey:kMenuDetailText];
//    [[[_sections objectAtIndex:2] objectAtIndex:2] setObject:self.configData.touchSensitivity forKey:kMenuDetailText];
    [self.tableView reloadData];
}

- (void)cameraSettingSuccessed {
    
    [self updateDetailText];
}

#pragma mark CellPressedMethod
- (void)onSetQualityCell{
    
    [[RDVTabBarController shareTabBar] setTabBarHidden:YES animated:NO];
    HWVideoQualitySettingViewController *videoQualityVc = [HWVideoQualitySettingViewController videoQualitySettingViewController];
    videoQualityVc.cidNumber = self.cidNumber;
    [self.navigationController pushViewController:videoQualityVc animated:YES];
    
}

#pragma mark 碰撞灵敏度
- (void)onTouchSensitivityCellPressed{
    [[RDVTabBarController shareTabBar] setTabBarHidden:YES animated:NO];
    TouchSensitivityViewController *sensitivityVC = [[TouchSensitivityViewController alloc] initWithNibName:@"TouchSensitivityViewController" bundle:nil];
    sensitivityVC.delegate = self;
    sensitivityVC.cidNumber = self.cidNumber;
    HWLog(@"sensitivityVC.cidNumber---%@",sensitivityVC.cidNumber);
    [self.navigationController pushViewController:sensitivityVC animated:YES];
}

- (void)tachographFlowStatistics{
    HWLog(@"------------------autoSynchronizeTime-------------------------");
    HWTachographFlowStatisticsController *tachographFlowStatisticsVc = [HWTachographFlowStatisticsController tachographFlowStatisticsController];
    tachographFlowStatisticsVc.cidNumber = self.cidNumber;
    tachographFlowStatisticsVc.getWifiGprsData = self.configData.getWifiGprsData;
    [self.navigationController pushViewController:tachographFlowStatisticsVc animated:YES];
}

- (void)onSwitchCell{

    HWLog(@"-------------------------------------------");
}

#pragma mark HWFactoryResetViewDelegate
- (void)factoryRest{

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES configBlock:^(MBProgressHUD *HUD) {
        
    }];
    
    __typeof(self) __weak safeSelf = self;
    

}

#pragma mark TableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    if (section == _sections.count-1) {
        return 100;
    }
    
    return 0;
    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return _sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    
    return [[_sections objectAtIndex:section] count];;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *cellMenu = [[_sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    if ([[cellMenu objectForKey:kMenuSytle] isEqualToString:kDetailStyleCellID]) {
        
        UITableViewCell *detailCell = [tableView dequeueReusableCellWithIdentifier:kDetailStyleCellID];
        
        

        if (!detailCell) {
            
            detailCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kDetailStyleCellID];
            detailCell.selectionStyle = UITableViewCellSelectionStyleNone;
            detailCell.backgroundColor = kTableViewCellColor;
            detailCell.textLabel.font = HWCellFont;
//            detailCell.textColor = [UIColor whiteColor];
        }
        
     
        if (indexPath.section == _sections.count-1) {
            detailCell.textLabel.text = [cellMenu objectForKey:kMenuTitle];
            detailCell.textColor = kColor(230, 139, 30, 1);
            detailCell.accessoryType = UITableViewCellAccessoryNone;
            detailCell.detailTextLabel.text = @"";
        }else {
            detailCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            detailCell.textColor = [UIColor whiteColor];
            detailCell.detailTextLabel.font = HWCellFont;
            detailCell.detailTextLabel.text  = [cellMenu objectForKey:kMenuDetailText];
            detailCell.textLabel.text = [cellMenu objectForKey:kMenuTitle];
        }
        
        if (indexPath.section == 0) {
            detailCell.detailTextLabel.text = @"";
        }
        
        return detailCell;
    }
    
    else{
        
        UITableViewCell *switchCell = [tableView dequeueReusableCellWithIdentifier:kSwitchStyleCellID];
        
        if (!switchCell) {
            
            switchCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kSwitchStyleCellID];
            switchCell.selectionStyle = UITableViewCellSelectionStyleNone;
            switchCell.textLabel.font = HWCellFont;
            UISwitch *switchBtn = [[UISwitch alloc] initWithFrame:CGRectMake(255, 7, 0, 0)];
            NSString *tagStr = [NSString stringWithFormat:@"%ld%ld%ld",1l,(long)indexPath.row,(long)indexPath.section];
            switchBtn.tag = [tagStr integerValue];
            switchBtn.onTintColor = kHuaWoTintColor;
            switchBtn.tintColor = [UIColor lightGrayColor];
            [switchBtn addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
            switchCell.accessoryView = switchBtn;
            switchCell.backgroundColor = kTableViewCellColor;
            switchCell.textColor = [UIColor whiteColor];
            
        }
        
        switchCell.textLabel.text = [cellMenu objectForKey:kMenuTitle];

        return switchCell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *cellMenu = [[_sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    SEL currentSelector = NSSelectorFromString([cellMenu objectForKey:kMenuSelector]);
    [self performSelector:currentSelector];
    
}


/**
 * 让当前控制器对应的状态栏是白色
 */
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
@end
