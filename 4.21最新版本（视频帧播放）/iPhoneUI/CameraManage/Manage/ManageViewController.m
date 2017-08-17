//
//  ManageViewController.m
//  HuaWo
//
//  Created by circlely on 2/23/16.
//  Copyright © 2016 circlely. All rights reserved.
//

#import "ManageViewController.h"
#import "MemberData.h"
#import "ChangeCameraNameViewController.h"
#import "ChangeCameraPWViewController.h"
#import "MBProgressHUD.h"
#import "AHCServerCommunicator.h"

#define kCellText @"celltext"
#define kMenuSytle @"menuSytle"
#define kCellDetailText @"celldetailtext"
#define kCellButtonText @"cellButtonText"

#define kManageCellID @"managecellid"
#define kManageCell @"managecell"
#define kDeleteCIDAlertViewTag 1001
@interface ManageViewController ()<UITableViewDataSource, UITableViewDelegate, ChangeCameraNameDelegate>
@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *cellArr;
@property (weak, nonatomic) IBOutlet UILabel *cameraCidTipsLabel;
@property (weak, nonatomic) IBOutlet UILabel *CIDLabel;

@end

@implementation ManageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = kBackgroundColor;
    
    [self setUpNav];
    
    [self setUpTableView];
    
    
    self.cameraCidTipsLabel.text = NSLocalizedString(@"manual_add_cell_label", nil);
    self.CIDLabel.text = self.CIDNumber;
    
    [self initCellArr];
    
    [self setUpDeleteButton];
}

- (void)setUpTableView{

    self.tableView.separatorColor = kBackgroundColor;
    self.tableView.backgroundColor = nil;
    self.tableView.backgroundColor = kBackgroundColor;
    
    self.headerView.backgroundColor = kBackgroundColor;
    self.tableView.tableHeaderView = self.headerView;
}

- (void)setUpNav{

    self.navigationController.navigationBar.barTintColor = kNavigation7Color;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"title_back_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonItemAction)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 44)];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = NSLocalizedString(@"cid_cell_manage_camera", nil);
    self.navigationItem.titleView = titleLabel;
}

- (void)setUpDeleteButton{

    UIButton *deleteBtn = [[UIButton alloc] init];
    deleteBtn.titleLabel.text = @"删除记录仪";
    CGFloat deleteBtnX = 10;
    CGFloat screenw = screenW;
    deleteBtn.frame = CGRectMake(10, 200, screenw - 2*deleteBtnX, 45);
    [self.tableView addSubview:deleteBtn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)leftBarButtonItemAction {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)initCellArr {
    
    NSString *cameraName = [[MemberData memberData] getAvsNameOfCID:self.CIDNumber];
    
    NSMutableDictionary *cameraNameDic = [NSMutableDictionary
                                          dictionaryWithDictionary:@{kCellText : NSLocalizedString(@"setting_page_camera_name", nil),
                                                                     kCellDetailText : cameraName,
                                                                     kMenuSytle:kCellDetailText}];
    NSMutableDictionary *changeCameraPW = [NSMutableDictionary
                                           dictionaryWithDictionary:@{kCellText : NSLocalizedString(@"menu_change_password_label", nil),
                                                                      kCellDetailText : @"",
                                                                      kMenuSytle:kCellDetailText}];
    
   NSMutableArray *section0  = [NSMutableArray arrayWithObjects:cameraNameDic, changeCameraPW, nil];
    
    
    NSMutableDictionary *deleteBtnCell = [NSMutableDictionary
                                          dictionaryWithDictionary:@{kMenuSytle:kCellButtonText}];
    
    NSMutableArray *section1  = [NSMutableArray arrayWithObjects:deleteBtnCell, nil];
    
    self.cellArr = [NSMutableArray arrayWithObjects:section0, section1, nil];
}

#pragma mark -----TableViewDelegate-----

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    
//    
//}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 1) {
       
        return 60;
    }else{
    
        return 0;
    }
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{

    return self.cellArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [[self.cellArr objectAtIndex:section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 60;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = [[self.cellArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    UITableViewCell *Cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if ([[dict objectForKey:kMenuSytle] isEqualToString:kCellDetailText]) {
        UITableViewCell *detailCell = [tableView dequeueReusableCellWithIdentifier:kManageCellID];
        if (!detailCell) {
            detailCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kManageCellID];
            detailCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            detailCell.selectionStyle = UITableViewCellSelectionStyleNone;
            detailCell.backgroundColor = kTableViewCellColor;
            detailCell.textLabel.font = HWCellFont;
            detailCell.textColor = [UIColor whiteColor];
        }
        
        detailCell.textLabel.text = [[[self.cellArr objectAtIndex:0] objectAtIndex:indexPath.row] objectForKey:kCellText];
        detailCell.detailTextLabel.text = [[[self.cellArr objectAtIndex:0 ]objectAtIndex:indexPath.row ] objectForKey:kCellDetailText];
        return detailCell;
    }else{
        if (indexPath.section == 1 && [[dict objectForKey:kMenuSytle] isEqualToString:kCellButtonText]) {
           
            UITableViewCell *manageCell = [tableView dequeueReusableCellWithIdentifier:kManageCell];
            if (!manageCell) {
                manageCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kManageCell];
                manageCell.backgroundColor = [UIColor clearColor];
                manageCell.textLabel.font = HWCellFont;
                manageCell.textColor = [UIColor whiteColor];
                
                UIButton *btn = [[UIButton alloc] init];
                CGFloat btnX = 10;
                btn.frame = CGRectMake(btnX, 0, manageCell.frame.size.width - 2*btnX, manageCell.frame.size.height);
                btn.backgroundColor = DZColor(0, 204, 204);
                btn.layer.cornerRadius = 5;
                btn.layer.masksToBounds = YES;
                [btn setTitle:@"记录仪删除" forState:UIControlStateNormal];
                btn.titleLabel.textColor = [UIColor whiteColor];
                [btn addTarget:self action:@selector(deleteDevice) forControlEvents:UIControlEventTouchUpInside];
                [manageCell addSubview:btn];
                
               return manageCell;
            }
            
        }
        
    }
    
    return Cell;
}

- (void)deleteDevice{
    HWLog(@"-----------------------------------");
    UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"warnning_be_sure_to_del_cid", nil) message:NSLocalizedString(@"warnning_prompt_delete_server", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"cancel_btn", nil) otherButtonTitles:NSLocalizedString(@"remove_btn", nil), nil];
    
    alerView.tag = kDeleteCIDAlertViewTag;
    [alerView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == kDeleteCIDAlertViewTag) {
        if (buttonIndex == 1) {
            [self deleteCIDFromLocalAndService];
        }
    }
    
}

- (void)deleteCIDFromLocalAndService{
    
    MBProgressHUD* HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES configBlock:nil];
    __typeof(self) __weak safeSelf = self;
    void(^delCidSucBlk)() = ^{
        
        HWLog(@"RootViewController Delete CID Success!");
        [MBProgressHUD hideHUDForView:safeSelf.view animated:YES];
        NSDictionary* CIDInfo = @{kCIDInfoNumber:safeSelf.CIDNumber};
        [[AHCServerCommunicator sharedAHCServerCommunicator] unsubscribeCID:CIDInfo];
        [self.navigationController popToRootViewControllerAnimated:YES];
//        [safeSelf updateView];
    };
    
    if([[MemberData memberData] isMemberLogin]){
        
    }
    else {
        
        [[MemberData memberData] deleteOneLocalCID:self.CIDNumber];
        delCidSucBlk();
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    

    if (indexPath.section == 0 && indexPath.row == 0) {
        
        [[RDVTabBarController shareTabBar] setTabBarHidden:YES animated:NO];
        ChangeCameraNameViewController *changeNameViewController = [[ChangeCameraNameViewController alloc] initWithNibName:@"ChangeCameraNameViewController" bundle:nil];
        changeNameViewController.cameraName = [[MemberData memberData] getAvsNameOfCID:self.CIDNumber];
        changeNameViewController.CIDNumber = self.CIDNumber;
        changeNameViewController.delegate = self;
        [self.navigationController pushViewController:changeNameViewController animated:YES];
        
    }
    
    else if (indexPath.section == 0 && indexPath.row == 1) {
        
        [[RDVTabBarController shareTabBar] setTabBarHidden:YES animated:NO];
        ChangeCameraPWViewController *changePWViewController = [[ChangeCameraPWViewController alloc] initWithNibName:@"ChangeCameraPWViewController" bundle:nil];
        changePWViewController.CIDNumber = self.CIDNumber;
        changePWViewController.cameraName = [[MemberData memberData] getAvsNameOfCID:self.CIDNumber];
        [self.navigationController pushViewController:changePWViewController animated:YES];

    }
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{

    UIView *view = [[UIView alloc] init];
    view.backgroundColor = kBackgroundColor;
    
    if (section == 0) {
        
        return view;
    }
    
    if (section == 1) {
      
        
    }
    
    return view;
}

#pragma mark ChangeCameraNameDelegate
- (void)changeNameSucc:(NSString *)rename {
    
    [[[self.cellArr objectAtIndex:0] objectAtIndex:0] setObject:rename forKey:kCellDetailText];
    [self.tableView reloadData];
    
}

/**
 * 让当前控制器对应的状态栏是白色
 */
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
