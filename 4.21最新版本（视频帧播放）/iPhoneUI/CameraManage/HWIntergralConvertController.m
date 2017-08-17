//
//  HWIntergralConvertController.m
//  HuaWo
//
//  Created by hwawo on 16/6/25.
//  Copyright © 2016年 HW. All rights reserved.
//

#import "HWIntergralConvertController.h"
#import <MJRefresh.h>
#import "HWIntegralCell.h"
#import "MJExtension.h"

#import "NSString+encrypto.h"
#import "MemberData.h"
#import "NSString+Helper.h"
#import "MBProgressHUD.h"
#import "HWIntegral.h"
#import "HWIntegralConvertView.h"

static NSString *const HWIntegralId = @"integral";
@interface HWIntergralConvertController ()<UITableViewDelegate, UITableViewDataSource, HWIntegralConvertViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, weak) UIView *titlesView;
@property (nonatomic, strong) NSMutableArray *integrals;
@property (strong, nonatomic) UIAlertView *alertIntegral;
@property (strong, nonatomic) UIAlertView *alertIntegralConvert;
@property (strong, nonatomic) MBProgressHUD *hud;
@property (strong, nonatomic) NSDictionary *params;
@property (assign, nonatomic) NSInteger page;
@property (copy, nonatomic) NSString *currentpoint;
@property (weak, nonatomic) UILabel *lntegralLabel;
@property (nonatomic, weak) UIView *popConvertView;

@property (weak, nonatomic) NSString *identityCardText;
@property (weak, nonatomic) NSString *zhifuAccountText;
@property (weak, nonatomic) NSString *integralText;
@end

@implementation HWIntergralConvertController
- (NSMutableArray *)integrals{
    
    if (!_integrals) {
        _integrals = [NSMutableArray array];
    }
    return _integrals;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = kBackgroundColor;
    
    [self setUpLeftBarButtonItem];
    
    [self setUpRightBarButtonItem];
    
    [self setUpTitleView];
    
    [self setUpTableView];
    
    [self setUpRefresh];
    
}

- (void)setUpRefresh{
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewIntegral)];
    
    [self.tableView.mj_header beginRefreshing];
    self.tableView.mj_header.automaticallyChangeAlpha = YES;
    
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreIntegral)];
}

- (void)loadNewIntegral{
    [self.tableView.mj_footer endRefreshing];
    
    NSURL *url = [NSURL URLWithString:kIntegralUrl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSString *secretUid = [kUid sha1].uppercaseString;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"uid"] = secretUid;
    params[@"cid"] = self.cidNum;
    params[@"num"] = @"5";
    params[@"order"] = @"desc";
    params[@"order_by_col"] = @"gentime";
    params[@"page_no"] = @"1";
    self.params = params;
    HWLog(@"--params--%@",params);
    
    if ([NSJSONSerialization isValidJSONObject:params])
    {
        
        NSData *data = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil];
        NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        HWLog(@"------------加密前的data转为字符串dataStr---------%@",dataStr);
        
        NSData *secretData = [NSString EncryptRequestString:dataStr];
        HWLog(@"-------NSData加密后secretData---------------%@",secretData);
        
        NSData *dataJ = [NSString DecryptData:secretData];
        NSString *dataStrJ = [[NSString alloc] initWithData:dataJ encoding:NSUTF8StringEncoding];
        HWLog(@"-------------dataStrJ--------------%@",dataStrJ);
        request.HTTPBody = secretData;
        
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            
            if (!connectionError) {
                if (self.params != params) return;
                
                self.page = 1;
                
                NSData *dataDe = [NSString DecryptData:data];
                HWLog(@"datalength:%lu",(unsigned long)data.length);
                
                HWLog(@"dataDe:%@",dataDe);
                
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:dataDe options:NSJSONReadingMutableContainers error:nil];
                HWLog(@"dict--%@",dict);
                
                HWLog(@"--%@",dict[@"point_list"]);
                self.integrals = [HWIntegral mj_objectArrayWithKeyValuesArray:dict[@"point_list"]];
                
                self.lntegralLabel.text = dict[@"currentpoint"];
                
                for (HWIntegral *model in self.integrals) {
                    HWLog(@"model.pointtype -- %@",model.pointtype);
                }
                
                HWLog(@"--integrals--%@",_integrals);
                
                [self.tableView.mj_header endRefreshing];
                
                [self.tableView reloadData];
            }
            else{
                [self.tableView.mj_header endRefreshing];
                HWLog(@"error:%@",connectionError);
            }
        }];
    }
    else
    {
        HWLog(@"数据有误");
    }
}

- (void)loadMoreIntegral{
    [self.tableView.mj_header endRefreshing];
    
    NSInteger page = self.page + 1;
    
    NSURL *url = [NSURL URLWithString:kIntegralUrl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSString *secretUid = [kUid sha1].uppercaseString;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"uid"] = secretUid;
    params[@"cid"] = self.cidNum;
    params[@"num"] = @"5";
    params[@"order"] = @"desc";
    params[@"order_by_col"] = @"gentime"; 
    params[@"page_no"] = @(page);
    self.params = params;
    HWLog(@"--params--%@",params);
    
    if ([NSJSONSerialization isValidJSONObject:params])
    {
        
        NSData *data = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil];
        NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        HWLog(@"------------加密前的data转为字符串dataStr---------%@",dataStr);
        
        NSData *secretData = [NSString EncryptRequestString:dataStr];
        HWLog(@"-------NSData加密后secretData---------------%@",secretData);
        
        NSData *dataJ = [NSString DecryptData:secretData];
        NSString *dataStrJ = [[NSString alloc] initWithData:dataJ encoding:NSUTF8StringEncoding];
        HWLog(@"-------------dataStrJ--------------%@",dataStrJ);
        request.HTTPBody = secretData;
        
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            
            if (!connectionError) {
                if (self.params != params) return;
                
                self.page = page;
                
                NSData *dataDe = [NSString DecryptData:data];
                HWLog(@"datalength:%lu",(unsigned long)data.length);
                
                HWLog(@"dataDe:%@",dataDe);
                
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:dataDe options:NSJSONReadingMutableContainers error:nil];
                HWLog(@"dict--%@",dict);
                
                HWLog(@"--%@",dict[@"point_list"]);
                NSArray *integrals = [HWIntegral mj_objectArrayWithKeyValuesArray:dict[@"point_list"]];
                [self.integrals addObjectsFromArray:integrals];
                
                for (HWIntegral *model in self.integrals) {
                    HWLog(@"model.pointtype -- %@",model.pointtype);
                }
                HWLog(@"--integrals--%@",_integrals);
                
                NSInteger total = [dict[@"total"] integerValue];
                if (self.integrals.count >= total) {
                    [self.tableView.mj_footer endRefreshingWithNoMoreData];
                }else{
                
                    [self.tableView.mj_footer endRefreshing];
                }
                
                [self.tableView reloadData];
            }
            else{
                [self.tableView.mj_footer endRefreshing];
                HWLog(@"error:%@",connectionError);
            }
        }];
    }
    else
    {
        HWLog(@"数据有误");
    }
}

- (void)setUpTableView{
    
    self.tableView.backgroundColor = kBackgroundColor;
    self.tableView.separatorColor = kBackgroundColor;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    CGFloat top = self.titlesView.height;
    self.tableView.contentInset = UIEdgeInsetsMake(top, 0, 0, 0);
    
    [DZNotificationCenter addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([HWIntegralCell class]) bundle:nil] forCellReuseIdentifier:HWIntegralId];
}

- (void)keyboardWillChangeFrame:(NSNotification *)note{

    CGRect frame = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat screenh = screenH;
    self.popConvertView.y = screenh - (self.popConvertView.height + frame.size.height);
    
    CGFloat duration = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    [UIView animateWithDuration:duration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)setUpTitleView{
    
    CGFloat screenw = screenW;
    
    UIView *titleView = [[UIView alloc] init];
    titleView.width = screenw;
    titleView.height = 40;
    titleView.frame = CGRectMake(0, 64, titleView.frame.size.width, titleView.frame.size.height);
    [self.view addSubview:titleView];
    self.titlesView = titleView;
    
    UILabel *nowLntegralLabel = [[UILabel alloc] init];
    CGFloat nowLntegralLabelX = 0.1*screenw;
    CGFloat nowLntegralLabelY = 0.2*titleView.height;
    nowLntegralLabel.center = CGPointMake(nowLntegralLabelX, nowLntegralLabelY);
    nowLntegralLabel.text = @"当前积分 :";
    [nowLntegralLabel sizeToFit];
    nowLntegralLabel.textColor = [UIColor whiteColor];
    nowLntegralLabel.font = [UIFont systemFontOfSize:16];
    [titleView insertSubview:nowLntegralLabel atIndex:0];
    
    UILabel *lntegralLabel = [[UILabel alloc] init];
    CGFloat lntegralLabelX = CGRectGetMaxX(nowLntegralLabel.frame) + 10;
    CGFloat lntegralLabelY = nowLntegralLabel.y;
    lntegralLabel.center = CGPointMake(lntegralLabelX, lntegralLabelY);
    lntegralLabel.text = @"0000.00";
    [lntegralLabel sizeToFit];
    lntegralLabel.textColor = DZColor(0, 204, 204);
    [titleView addSubview:lntegralLabel];
    self.lntegralLabel = lntegralLabel;
    
}

- (void)setUpRightBarButtonItem{
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"积分兑换" style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonItemAction)];
    self.navigationItem.rightBarButtonItem.tintColor = DZColor(0, 204, 204);
    
}

- (void)rightBarButtonItemAction{
    
    HWLog(@"-------------------积分兑换---------------------------");
    HWIntegralConvertView *integralConvert = [HWIntegralConvertView integralConvertView];
    self.popConvertView = integralConvert.popConvertView;
    integralConvert.delegate = self;
    integralConvert.frame = self.view.bounds;
    [self.view addSubview:integralConvert];

    
}

- (void)integralConvertViewView:(HWIntegralConvertView *)integralConvertViewView IDCardText:(NSString *)IDCardText zhifuAccountText:(NSString *)zhifuAccountText integral:(NSString *)integralText{

    self.identityCardText = IDCardText;
    self.zhifuAccountText = zhifuAccountText;
    self.integralText = integralText;
    HWLog(@"self.identityCardTextField.text*%@*",self.identityCardText);
    HWLog(@"self.identityCardTextField.text*%@*",self.zhifuAccountText);
    HWLog(@"self.identityCardTextField.text*%@*",self.integralText);
    [self integralConvert];
}

- (void)integralConvert{

    NSURL *url = [NSURL URLWithString:integralConvertUrl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSString *secretUid = [kUid sha1].uppercaseString;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"uid"] = secretUid;
    params[@"cid"] = self.cidNum;
    params[@"identitycode"] = @"012345678912345678";
    params[@"account"] = @"1485114219@qq.com";
    params[@"points"] = @"200";
    self.params = params;
    HWLog(@"--params--%@",params);
    
//    NSMutableDictionary *params = [NSMutableDictionary dictionary];
//    params[@"uid"] = secretUid;
//    params[@"cid"] = self.cidNum;
//    params[@"identitycode"] = self.identityCardText;
//    params[@"account"] = self.zhifuAccountText;
//    params[@"points"] = self.integralText;
//    self.params = params;
//    HWLog(@"--params--%@",params);

    
    if ([NSJSONSerialization isValidJSONObject:params])
    {
        
        NSData *data = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil];
        NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        HWLog(@"------------加密前的data转为字符串dataStr---------%@",dataStr);
        
        NSData *secretData = [NSString EncryptRequestString:dataStr];
        HWLog(@"-------NSData加密后secretData---------------%@",secretData);
        
        NSData *dataJ = [NSString DecryptData:secretData];
        NSString *dataStrJ = [[NSString alloc] initWithData:dataJ encoding:NSUTF8StringEncoding];
        HWLog(@"-------------dataStrJ--------------%@",dataStrJ);
        request.HTTPBody = secretData;
        
        self.alertIntegral = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title", nil) message:@"" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        
        self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES configBlock:^(MBProgressHUD *HUD) {
            HUD.removeFromSuperViewOnHide = YES;
        }];
        
        
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            
            if (!connectionError) {
                [self.hud hide:YES];
                if (self.params != params) return;
                
                NSData *dataDe = [NSString DecryptData:data];
                HWLog(@"datalength:%lu",(unsigned long)data.length);
                
                HWLog(@"dataDe:%@",dataDe);
                
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:dataDe options:NSJSONReadingMutableContainers error:nil];
                HWLog(@"dict--%@--%@",dict[@"code"], dict[@"desc"]);
              
                if ([dict[@"code"] isEqual: @(1000)]) {
                    
                    self.alertIntegral.message = dict[@"desc"];
                    [self.alertIntegral show];
                }else if ([dict[@"code"] isEqual: @(1001)]){
                
                    self.alertIntegral.message = dict[@"desc"];
                    [self.alertIntegral show];
                }else if ([dict[@"code"] isEqual: @(1003)]){
                    
                    self.alertIntegral.message = dict[@"desc"];
                    [self.alertIntegral show];
                }else if ([dict[@"code"] isEqual: @(1005)]){
                    
                    self.alertIntegral.message = dict[@"desc"];
                    [self.alertIntegral show];
                }
            }
            else{
                [self.hud hide:YES];
                HWLog(@"error:%@",connectionError);
            }
        }];
    }
    else
    {
        HWLog(@"数据有误");
    }
}

- (void)setUpLeftBarButtonItem{
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"title_back_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonItemAction)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
}

- (void)leftBarButtonItemAction{
    
    [self.navigationController popViewControllerAnimated:YES];
}

+ (instancetype)intergralConvertController{
    
    return [[[self class] alloc] initWithNibName:@"HWIntergralConvertController" bundle:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    HWLog(@"--%lu",(unsigned long)self.integrals.count);
    return self.integrals.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    HWIntegralCell *cell = [tableView dequeueReusableCellWithIdentifier:HWIntegralId];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.integral = self.integrals[indexPath.row];
    HWLog(@"--%@",self.integrals[indexPath.row]);
    return cell;
}


- (void)test{
    
    
    NSString *secretUid = [kUid sha1].uppercaseString;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"uid"] = secretUid;
    params[@"cid"] = self.cidNum;
    params[@"num"] = @"20";
    params[@"order"] = @"desc";
    params[@"order_by_col"] = @"gentime";
    params[@"page_no"] = @"1";
    
    HWLog(@"--params--%@",params);
    
    NSData *paramsData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil];
    NSString *paramsDataStr = [[NSString alloc] initWithData:paramsData encoding:NSUTF8StringEncoding];
    HWLog(@"------------加密前的data转为字符串dataStr---------%@",paramsDataStr);
    
    NSData *secretParamsData = [NSString EncryptRequestString:paramsDataStr];
    HWLog(@"-------NSData加密后secretData---------------%@",secretParamsData);
    
    NSData *dataJ = [NSString DecryptData:secretParamsData];
    NSString *dataStrJ = [[NSString alloc] initWithData:dataJ encoding:NSUTF8StringEncoding];
    HWLog(@"-------------dataStrJ--------------%@",dataStrJ);
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager POST:@"http://112.124.22.129/illegalreport/restapi/getPointsDetails" parameters:secretParamsData success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary *responseObject) {
        
        HWLog(@"---%@",responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        HWLog(@"--error:%@",[error description]);
    }];
    
    //    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    //    params[@"a"] = @"tag_recommend";
    //    params[@"action"] = @"sub";
    //    params[@"c"] = @"topic";
    //
    //    [[AFHTTPSessionManager manager] GET:@"http://api.budejie.com/api/api_open.php" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id responseObject) {
    //        HWLog(@"%@",responseObject);
    //    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    //        HWLog(@"--%@",error);
    //    }];
}

/**
 * 让当前控制器对应的状态栏是白色
 */
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
@end
