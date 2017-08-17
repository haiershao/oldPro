//
//  HWVideoQualitySettingViewController.m
//  HuaWo
//
//  Created by hwawo on 16/9/29.
//  Copyright © 2016年 HW. All rights reserved.
//

#import "HWVideoQualitySettingViewController.h"
#import "MBProgressHUD.h"
#import "CameraSettingsConfigData.h"
#define VideoQualityKey @"videoQualityKey"
@interface HWVideoQualitySettingViewController ()<UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UISlider *slider;

@property (weak, nonatomic) IBOutlet UIButton *saveSettingBtn;
@property (strong, nonatomic) UITapGestureRecognizer *tapGesture;

@property (strong, nonatomic) NSArray *numbers;

@property (strong, nonatomic) CameraSettingsConfigData *configData;
@property  (copy, nonatomic) NSString  *videoQuality;
@property (strong, nonatomic) NSUserDefaults *defaults;
@property  (copy, nonatomic) NSString  *filePath;
@end

@implementation HWVideoQualitySettingViewController
//- (NSUserDefaults *)defaults{
//
//    if (_defaults) {
//        _defaults = [NSUserDefaults standardUserDefaults];
//    }
//    return _defaults;
//}

+ (instancetype)videoQualitySettingViewController{

    return [[HWVideoQualitySettingViewController alloc] initWithNibName:@"HWVideoQualitySettingViewController" bundle:nil];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.configData = [CameraSettingsConfigData shareConfigData];
    
    [self setUpView];
    
    [self createLabel];
    
    [self setUpBtn];
    
//    self.slider.value = 0.5;
    
    [self.slider addTarget:self action:@selector(sliderChange:) forControlEvents:UIControlEventValueChanged];
    
    _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTapGesture:)];
    _tapGesture.delegate = self;
    [_slider addGestureRecognizer:_tapGesture];
    
    [self getVideoQuality];
}

- (void)getVideoQuality{

    NSError *error = nil;
    NSArray *documents = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSMutableString *path = [NSMutableString stringWithString:[documents firstObject]];
    [path appendString:[NSString stringWithFormat:@"/HuaWo"]];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:path]) {
        
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *recordDir = [path componentsSeparatedByString:@"/"].lastObject;
    
    recordDir = [NSString stringWithFormat:@"videoQuality.text"];
    NSString *fullPath = [path stringByAppendingPathComponent:recordDir];
    NSString *videQuality = [NSString stringWithContentsOfFile:fullPath encoding:NSUTF8StringEncoding error:&error];
    
    if (error) {
        HWLog(@"---读取失败-----%@",error);
    }else{
        self.slider.value = [videQuality floatValue];
        HWLog(@"----读取成功----%f",self.slider.value);
    }
    
}

- (void)createLabel{

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 84, screenW, 30)];
    label.text = @"远程观看视频";
    label.font = [UIFont systemFontOfSize:15];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    [self.view addSubview:label];
}

- (void)actionTapGesture:(UITapGestureRecognizer *)sender {
    _slider.value = 0;
    CGPoint touchPoint = [sender locationInView:_slider];
    CGFloat value = (_slider.maximumValue - _slider.minimumValue) * (touchPoint.x / _slider.frame.size.width );
    HWLog(@"value---%f",value);
    if (value < 0.25) {
        HWLog(@"--------0----------");
        [_slider setValue:0 animated:YES];
//        self.videoQuality = 0;
    }else if (value > 0.75){
        HWLog(@"--------1----------");
        [_slider setValue:1 animated:YES];
//        self.videoQuality = 1;
    }else{
//        self.videoQuality = 0.5;
        HWLog(@"--------0.5----------");
        [_slider setValue:0.5 animated:YES];
    }

}

- (void)sliderChange:(UISlider *)slider{

    HWLog(@"--------------------------%f",slider.value);
    
    if (slider.value < 0.25) {
        HWLog(@"--------0----------");
        [_slider setValue:0 animated:YES];
//        self.videoQuality = 0;
    }else if (slider.value > 0.75){
        HWLog(@"--------1----------");
        [_slider setValue:1 animated:YES];
//        self.videoQuality = 1;
    }else{
        
        HWLog(@"--------0.5----------");
        [_slider setValue:0.5 animated:YES];
//        self.videoQuality = 0.5;
    }
}

- (void)setUpBtn{

    self.saveSettingBtn.layer.cornerRadius = 5;
    self.saveSettingBtn.layer.masksToBounds = YES;
}

- (void)setUpView{

    self.view.backgroundColor = kBackgroundColor;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"title_back_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonItemAction)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 44)];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = NSLocalizedString(@"setting_page_video_quality", nil);
    self.navigationItem.titleView = titleLabel;
}

- (void)leftBarButtonItemAction {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (IBAction)saveVideoBtnClick:(UIButton *)sender {
    
    HWLog(@"%f",self.slider.value);
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES configBlock:^(MBProgressHUD *HUD) {
        
    }];
    
    
    NSError *error = nil;
    NSArray *documents = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSMutableString *path = [NSMutableString stringWithString:[documents firstObject]];
    [path appendString:[NSString stringWithFormat:@"/HuaWo"]];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:path]) {
        
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *recordDir = [path componentsSeparatedByString:@"/"].lastObject;
    
    recordDir = [NSString stringWithFormat:@"videoQuality.text"];
    NSString *fullPath = [path stringByAppendingPathComponent:recordDir];
    self.filePath = fullPath;
    if ([self.videoQuality writeToFile:fullPath atomically:YES encoding:NSUTF8StringEncoding error:&error]) {
        HWLog(@"写入成功");
    }else{
        HWLog(@"写入失败%@",error);
    }
    
    NSUserDefaults *defaultss = [NSUserDefaults standardUserDefaults];
    HWLog(@"%@",defaultss);
    [defaultss setObject:self.videoQuality forKey:VideoQualityKey];
    [defaultss synchronize];
    self.defaults = defaultss;
    
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //    [defaults setObject:@(self.videoQuality) forKey:VideoQualityKey];
    //    [defaults synchronize];
    NSString *str = [defaultss objectForKey:VideoQualityKey];
//    [self getVideoQuality];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"111" forKey:@"myTest"];
    [defaults synchronize];
    NSString *testStr = [defaults objectForKey:@"myTest"];
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
