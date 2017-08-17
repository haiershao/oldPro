//
//  HWFcousOnViewController.m
//  HuaWo
//
//  Created by hwawo on 16/12/30.
//  Copyright © 2016年 HW. All rights reserved.
//

#import "HWFcousOnViewController.h"
#import "HWFcousOnCell.h"
@interface HWFcousOnViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
static NSString *cellid = @"HWFcousOnCellId";
@implementation HWFcousOnViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setUpNav];
}

- (void)setUpNav{
    
    self.view.backgroundColor = DZColor(80, 80, 80);
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"title_back_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonItemAction)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 44)];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = @"我的关注";
    self.navigationItem.titleView = titleLabel;
    self.tableView.backgroundColor = kBackgroundColor;
    
}

- (void)leftBarButtonItemAction {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

+(instancetype)fcousOnViewController{
    
    return [[HWFcousOnViewController alloc] initWithNibName:@"HWFcousOnViewController" bundle:nil];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{

    return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    HWFcousOnCell *cell = [tableView dequeueReusableCellWithIdentifier:cellid];
    if (!cell) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"HWFcousOnCell" owner:self options:nil].firstObject;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return 65;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
