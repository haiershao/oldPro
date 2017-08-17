//
//  PersonalInfoViewController.m
//  HuaWo
//
//  Created by circlely on 1/26/16.
//  Copyright © 2016 circlely. All rights reserved.
//

#import "PersonalInfoViewController.h"
#import "MemberData.h"
#import "MBProgressHUD.h"
#import "ResetPasswordViewController.h"
#import "ChangeNickNameViewController.h"
#import "AlbumController.h"
#import <AWSS3.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "Reachability.h"
#import "NSString+encrypto.h"
#import "NSData+Encryption.h"
#import "NSData+AES256.h"
#import "NSData+AES.h"
#import "NSString+Helper.h"
#import "PersonalCenterViewController.h"
#import <ShareSDK/ShareSDK.h>
#import <CCImage/CCImage.h>
#import "SDWebImageManager.h"
#import <LBClearCacheTool/LBClearCacheTool.h>
#import "AlbumManager.h"
#import "Reachability.h"
#import "HWUserInstanceInfo.h"
#import "MBProgressHUD+MG.h"
#define kMenuTitle @"menuTitle"
#define kMenuSelector @"menuSelector"
#define kMenuAccessoryStyle @"menuAccessoryStyle"
#define kMenuAccessoryDisclosureIndicator @"UITableViewCellAccessoryDisclosureIndicator"
#define kMenuAccessoryNone @"UITableViewCellAccessoryNone"
#define kMenuDetailText @"menuDetailText"
#define BucketName @"huawo"
#define kUid [[MemberData memberData] getMemberAccount]
#define isLogin [[MemberData memberData] isMemberLogin]
#define iconImageName [NSString stringWithFormat:@"%@.png",kUid]
// 照片原图路径
#define KOriginalPhotoImagePath  \
[[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"OriginalPhotoImages"]
@interface PersonalInfoViewController ()<UITableViewDataSource, UITableViewDelegate,changeNickNameDelegate, UIAlertViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate, PersonalCenterViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;

@property (nonatomic ,strong)UILabel *rightLabel;
@property (strong, nonatomic) NSMutableArray *FirstSecCells;
@property (strong, nonatomic) NSMutableArray *SecondSecCells;
@property (strong, nonatomic) NSMutableArray *ThirdSecCells;
@property (strong, nonatomic) NSMutableArray *FourSecCells;
@property (strong, nonatomic) NSMutableArray *sections;

@property (strong, nonatomic) UIImageView *iconImageView;
@property (copy, nonatomic) NSString *pictureName;
@property (copy, nonatomic) NSString *filePath;

@property (strong, nonatomic) UIImage *userIconImage;
@property (strong, nonatomic) MBProgressHUD *hud;
@property (copy, nonatomic) NSString *fullPath;
@property (copy, nonatomic) NSString *iconImagePath;
@property (copy, nonatomic) NSMutableString *localDataPath;
@property (copy, nonatomic) NSString *fileSizeStr;
@property (strong, nonatomic) NSArray *documents;
@property (strong, nonatomic) NSArray *documents1;
@property (assign, getter=isDeleteDataSuccess,nonatomic) BOOL DeleteDataSuccess;
@property (strong, nonatomic) UIAlertView *alertPersionInfo;

@end

@implementation PersonalInfoViewController{
    
    NSInteger _fileSize;
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    
    [viewController viewDidAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //加载头像
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    self.logoutButton.hidden = YES;
    //self.pictureName = [HWUserInstanceInfo shareUser].nickname;
    [self setUpTableView];
    
    [self setUpNav];
    
    [self createLogoutButton];
    
    
    
    
    [self initSectionArray];
    
    [DZNotificationCenter addObserver:self selector:@selector(setLocalIconImage:) name:@"postLocalImagePath" object:nil];
    
    //    self.navigationController.delegate = self;
    
    PersonalCenterViewController *personCenter = [[PersonalCenterViewController alloc] initWithNibName:@"PersonalCenterViewController" bundle:nil];
    personCenter.delegate = self;
    
    [self setIconImage];
    
    [self downLoadIconImage];
}

-(BOOL) isConnectionAvailable{
    
    BOOL isExistenceNetwork = YES;
    Reachability *reach = [Reachability reachabilityWithHostname:@"www.apple.com"];
    switch ([reach currentReachabilityStatus]) {
        case NotReachable:
            isExistenceNetwork = NO;
            //HWLog(@"notReachable");
            break;
        case ReachableViaWiFi:
            isExistenceNetwork = YES;
            //HWLog(@"WIFI");
            break;
        case ReachableViaWWAN:
            isExistenceNetwork = YES;
            //HWLog(@"3G");
            break;
    }
    
    if (!isExistenceNetwork) {
        //<span style="font-family: Arial, Helvetica, sans-serif;">MBProgressHUD为第三方库，不需要可以省略或使用AlertView</span>
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES configBlock:nil];
        hud.removeFromSuperViewOnHide =YES;
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"当前网络不可用，请检查网络连接";  //提示的内容
        hud.minSize = CGSizeMake(132.f, 108.0f);
        [hud hide:YES afterDelay:3];
        return NO;
    }
    
    return isExistenceNetwork;
}

- (void)createLogoutButton{
    
    self.logoutButton.layer.masksToBounds = YES;
    self.logoutButton.layer.cornerRadius = 5;
    //    self.logoutButton.titleLabel.text = NSLocalizedString(@"root_sidebar_logout_btn", nil);
    [self.logoutButton setTitle:NSLocalizedString(@"root_sidebar_logout_btn", nil) forState:UIControlStateNormal];
    self.logoutButton.tintColor = [UIColor whiteColor];
}

- (void)setUpNav{
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"title_back_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonItemAction)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 44)];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = NSLocalizedString(@"user_info_personal_account", nil);
    self.navigationItem.titleView = titleLabel;
}

- (void)setUpTableView{
    
    self.tableView.tableFooterView = self.footerView;
    self.view.backgroundColor = kBackgroundColor;
    self.tableView.backgroundColor = nil;
    self.tableView.backgroundColor = kBackgroundColor;
    self.tableView.separatorColor = kBackgroundColor;
}

- (void)setIconImage{
    
    //加载首先访问本地沙盒是否存在相关图片
    HWLog(@"--------iconImageName---------------%@",iconImageName);
    self.fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[NSString stringWithFormat:@"iconimage%@",identifierForVendor]];
    self.userIconImage = [UIImage imageWithContentsOfFile:_fullPath];
    HWLog(@"--------fullPath----------%@",_fullPath);
    HWLog(@"--------self.userIconImage----------%@",self.userIconImage);
    if (!self.userIconImage)
    {
        //默认头像
        self.iconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"find_new_head_bg"]];
        self.iconImageView.backgroundColor = [UIColor clearColor];
    }
    else
    {
        if ([self isConnectionAvailable]) {
            
            self.iconImageView.image = self.userIconImage;
            self.iconImageView.backgroundColor = [UIColor clearColor];
            HWLog(@"--%@-----zzzzzzzzz-self.userIconImage----------%@--%d--%@",_fullPath,self.userIconImage,isLogin,kUid);
        }
        
        
    }
}

- (void)setLocalIconImage:(NSNotification *)note{
    
    NSURL *imageUrl = [NSURL fileURLWithPath: note.object];
    self.userIconImage = [UIImage imageWithContentsOfFile:note.object];
    //上传图片
    [self upLoadIconUrl:imageUrl];
}

- (void)loadIconImage{
    
    //判断当前有无网络
    if ( [self isConnectionAvailable] ) {
        if(!self.iconImageView.image){
            //            [self downLoadIconImage];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)leftBarButtonItemAction {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}


- (void)initSectionArray {
    
    NSMutableDictionary *sec0row0 = [NSMutableDictionary dictionaryWithDictionary:@{kMenuTitle:NSLocalizedString(@"user_info_headportrait", nil),kMenuSelector:NSStringFromSelector(@selector(onHeaderInfoPressed)),kMenuAccessoryStyle:kMenuAccessoryDisclosureIndicator,kMenuDetailText:@""}];
    
    self.FirstSecCells = [[NSMutableArray alloc] initWithObjects:sec0row0, nil];
    
    NSString *nickName = [[MemberData memberData] getMemberNickName] ? [[MemberData memberData] getMemberNickName]:@"";
    
    NSMutableDictionary *sec1row0 = [NSMutableDictionary dictionaryWithDictionary:@{kMenuTitle:NSLocalizedString(@"user_info_nickname", nil),kMenuSelector:NSStringFromSelector(@selector(onRenameNick)),kMenuAccessoryStyle:kMenuAccessoryDisclosureIndicator,kMenuDetailText:nickName}];
    
    NSMutableDictionary *sec1row1 = [NSMutableDictionary dictionaryWithDictionary:@{kMenuTitle:NSLocalizedString(@"user_info_account", nil),kMenuSelector:NSStringFromSelector(@selector(onAlbumPressed)),kMenuAccessoryStyle:kMenuAccessoryNone,kMenuDetailText:[[MemberData memberData] getMemberAccount]}];
    
    NSMutableDictionary *sec1row2 = [NSMutableDictionary dictionaryWithDictionary:@{kMenuTitle:NSLocalizedString(@"user_info_change_password", nil),kMenuSelector:NSStringFromSelector(@selector(onChangePWPressed)),kMenuAccessoryStyle:kMenuAccessoryDisclosureIndicator,kMenuDetailText:@""}];
    
#warning 没实现先隐藏掉
    //    NSMutableDictionary *sec1row3 = [NSMutableDictionary dictionaryWithDictionary:@{kMenuTitle:NSLocalizedString(@"user_info_mailbox_account", nil),kMenuSelector:NSStringFromSelector(@selector(onAlbumPressed)),kMenuAccessoryStyle:kMenuAccessoryDisclosureIndicator,kMenuDetailText:NSLocalizedString(@"user_info_not_bound", nil)}];
    
    
    
    //    self.SecondSecCells = [[NSMutableArray alloc] initWithObjects:
    //                           sec1row0,
    //                           sec1row1,
    //                           sec1row2,
    //                           nil];
    
    self.SecondSecCells = [[NSMutableArray alloc] initWithObjects:
                           sec1row0,nil];
    
    
    
    
    NSMutableDictionary *sec2row0 = [NSMutableDictionary dictionaryWithDictionary:@{kMenuTitle:NSLocalizedString(@"user_info_wechat", nil),kMenuSelector:NSStringFromSelector(@selector(onAlbumPressed)),kMenuAccessoryStyle:kMenuAccessoryDisclosureIndicator,kMenuDetailText:@""}];
    
    NSMutableDictionary *sec2row1 = [NSMutableDictionary dictionaryWithDictionary:@{kMenuTitle:NSLocalizedString(@"user_info_qq", nil),kMenuSelector:NSStringFromSelector(@selector(onSharePressed)),kMenuAccessoryStyle:kMenuAccessoryDisclosureIndicator,kMenuDetailText:NSLocalizedString(@"user_info_not_bound", nil)}];
    
    NSMutableDictionary *sec2row2 = [NSMutableDictionary dictionaryWithDictionary:@{kMenuTitle:NSLocalizedString(@"user_info_sina_weibo", nil),kMenuSelector:NSStringFromSelector(@selector(onSharePressed)),kMenuAccessoryStyle:kMenuAccessoryDisclosureIndicator,kMenuDetailText:NSLocalizedString(@"user_info_not_bound", nil)}];
    
    
    
    self.ThirdSecCells = [[NSMutableArray alloc] initWithObjects:
                          sec2row0,
                          sec2row1,
                          sec2row2,
                          nil];
    
    NSMutableDictionary *sec3row0 = [NSMutableDictionary dictionaryWithDictionary:@{kMenuTitle:NSLocalizedString(@"clear_all_cache", nil),kMenuSelector:NSStringFromSelector(@selector(onClearAllCache)),kMenuAccessoryStyle:kMenuAccessoryDisclosureIndicator,kMenuDetailText:NSLocalizedString(@"", nil)}];
    
    self.FourSecCells = [[NSMutableArray alloc] initWithObjects:sec3row0, nil];
    
    
    self.sections = [[NSMutableArray alloc] initWithObjects:self.FirstSecCells, self.SecondSecCells, nil];
}

- (void)onHeaderInfoPressed {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"quit_btn", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"user_change_headportrait_from_gallery", nil), nil];
    
    actionSheet.delegate = self;//3.18 add --- by mj
    
    [actionSheet showInView:self.view];
    // NSLocalizedString(@"user_change_headportrait_from_album", nil)
}


// 3.18 add start --- by mj
#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    switch (buttonIndex) {
        case 0://打开手机相册
            
            [self onPhoneAlbum];
            break;
            
            //        case 1://打开我的相册
            //
            //            [self onLocalAlbum];
            //            break;
            
        default:
            break;
    }
}
- (void)viewWillAppear:(BOOL)animated {
    //[[RDVTabBarController shareTabBar] setTabBarHidden:NO animated:NO];
}

- (void)onLocalAlbum{
    
    [[RDVTabBarController shareTabBar] setTabBarHidden:YES animated:NO];
    AlbumController *albumController = [AlbumController albumController];
    albumController.getIconImage = YES;
    [self.navigationController pushViewController:albumController animated:YES];
    //[[RDVTabBarController shareTabBar] setTabBarHidden:NO animated:YES];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    self.pictureName = [NSString stringWithFormat:@"%@.png",identifierForVendor];
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *iconImage = info[UIImagePickerControllerEditedImage];
    
    HWLog(@"-------iconImage------%@",iconImage);
    [self imageWithUrl:[NSURL fileURLWithPath:[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[NSString stringWithFormat:@"iconimage%@",identifierForVendor]]]];
    
    //先存入沙盒
    NSData *imageData1 = UIImageJPEGRepresentation(iconImage, 0.0000001);
    
    NSString *fullPath1 = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[NSString stringWithFormat:@"iconimage%@",identifierForVendor]];
    
    if ([imageData1 writeToFile:fullPath1 atomically:NO]) {
        HWLog(@"--------------写入OK");
    }else{
        
        HWLog(@"--------------写入失败");
    }
    
    UIImage *image1 = [UIImage imageWithContentsOfFile:fullPath1];
    
    //修改缩小图片
    image1 = [self getImageByCuttingImage:image1];
    
    self.userIconImage = [CCImage circleImage:image1];
    NSLog(@"%@",NSStringFromCGSize(self.userIconImage.size));
    [self saveUserIconImage:self.userIconImage];
    [self upLoadIconUrl:[NSURL fileURLWithPath:[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[NSString stringWithFormat:@"iconimage%@",identifierForVendor]]]];
    [self.tableView reloadData];
    HWLog(@"----------image-------------%@",self.userIconImage);
}

- ( UIImage *)getImageByCuttingImage:( UIImage *)image{
    CGSize size = CGSizeMake(45, 45);
    UIGraphicsBeginImageContext(size);  //size 为CGSize类型，即你所需要的图片尺寸
    
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return scaledImage;   //返回的就是已经改变的图片
    
}

- (void)imageWithUrl:(NSURL *)url{
    
    if (self.userIconImage) {
        //        self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES configBlock:^(MBProgressHUD *HUD) {
        //            HUD.removeFromSuperViewOnHide = YES;
        //        }];
        // 进这个方法的时候也应该加判断,如果已经转化了的就不要调用这个方法了
        // 如何判断已经转化了,通过是否存在文件路径
        ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc] init];
        // 创建存放原始图的文件夹--->OriginalPhotoImages
        NSFileManager * fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:KOriginalPhotoImagePath]) {
            [fileManager createDirectoryAtPath:KOriginalPhotoImagePath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if (url) {
                // 主要方法
                [assetLibrary assetForURL:url resultBlock:^(ALAsset *asset) {
                    
                    ALAssetRepresentation *rep = [asset defaultRepresentation];
                    Byte *buffer = (Byte*)malloc((unsigned long)rep.size);
                    NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:((unsigned long)rep.size) error:nil];
                    NSData *data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
                    
                    NSString *imagePath = [NSTemporaryDirectory() stringByAppendingPathComponent:self.pictureName];
                    [data writeToFile:imagePath atomically:YES];
                    //NSURL * pathURL = [NSURL fileURLWithPath:imagePath];
                    
                    //上传图片
                    //                    [self upLoadIconUrl:pathURL];
                } failureBlock:nil];
            }
        });
    }
    
}

- (void)s3ConfigParams{
    
    AWSStaticCredentialsProvider *credentialsProvider = [[AWSStaticCredentialsProvider alloc] initWithAccessKey:@"AKIAOVUGNAXFVVE5IALQ" secretKey:@"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"];
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionCNNorth1 credentialsProvider:credentialsProvider];
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
}

- (void)upLoadIconUrl:(NSURL *)imageUrl{
    HWLog(@"---------imageUrl-----------%@",imageUrl);
    //配置亚马逊参数
    [self s3ConfigParams];
    NSString *fileKey = [NSString stringWithFormat:@"huawo|user_photo/%@.png",[NSString stringWithFormat:@"%@",identifierForVendor]];
   
    HWLog(@"--------------%@",fileKey);
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    
    //设置uploadrequest
    AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
    uploadRequest.bucket = BucketName;
    uploadRequest.key = fileKey;
    uploadRequest.body = imageUrl;
    
    [[transferManager upload:uploadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor] withBlock:^id(AWSTask*task) {
        
        
        if (task.error) {
            HWLog(@"Error: %@", task.error);
        }
        else {
            // The file uploaded successfully.
            HWLog(@"----iconimage--------OK");
//
            [self writeToServerImagePath:fileKey];
            HWLog(@"Error: %@",  task.result);
            
        }
        
        return nil;
    }];
    
}

//下载用户头像
- (UIImage *)downLoadIconImage{
    
    //配置亚马逊参数
    [self s3ConfigParams];
NSString *fileKey = [NSString stringWithFormat:@"huawo|user_photo/%@.png",identifierForVendor];
    
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    
    NSString *downloadingFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"iconimage%@",identifierForVendor]];
    NSURL *downloadingFileURL = [NSURL fileURLWithPath:downloadingFilePath];
    
    AWSS3TransferManagerDownloadRequest *downloadRequest = [AWSS3TransferManagerDownloadRequest new];
    downloadRequest.bucket = BucketName;
    downloadRequest.key = fileKey;
    downloadRequest.downloadingFileURL = downloadingFileURL;
    NSLog(@"888888888%@",downloadingFileURL);
    [[transferManager download : downloadRequest] continueWithExecutor : [AWSExecutor mainThreadExecutor] withBlock: ^id(AWSTask *task) {
        
        if (task.error){
            
            NSLog(@"88=====================Error: %@", task.error);
        }
        else{
            // File downloaded successfully.
            NSLog(@"==================结果：%@",task.result);
            NSString *path = [task.result body];
            NSData *data = [NSData dataWithContentsOfFile:path];
            UIImage *image = [UIImage imageWithData:data];
            self.iconImageView.image = image;
            
            [self saveUserIconImage:image];
            [DZNotificationCenter postNotificationName:@"iconImageName" object:image];
            return image;
        }
        
        return nil;
    }];
    return nil;
}

- (void)writeToServerImagePath:(NSString *)imagePath{
    HWUserInstanceInfo *instanceInfo = [HWUserInstanceInfo shareUser];
    NSDictionary *dict = @{
                           @"photo":imagePath
                           
                           };
    
    APIRequest *request = [[APIRequest alloc] initWithApiPath:@"/ControlCenter/v3/restapi/doaction" method:APIRequestMethodPost];
    request.urlQueryParameters = @{
                                   @"action":@"user_modifyinfo",
                                   @"para":dict,
                                   @"token":instanceInfo.token
                                   };
    NSLog(@"request---%@",request);
    NSFileManager *mgr = [NSFileManager defaultManager];
    [[APIRequestOperationManager sharedRequestOperationManager] requestAPI:request completion:^(id result, NSError *error) {
        if (!error) {
          
            NSString *str0 = [NSString stringWithFormat:@"%@",result[@"result"]];
            NSLog(@"writeToServerImagePath result---%@",result[@"result"]);
            if ([str0 isEqualToString:@"1"]&&!result[@"data"]) {
                [MBProgressHUD showSuccess:@"修改成功"];
                [self backMyUi];
            }else{
            
                [MBProgressHUD showSuccess:@"修改失败"];
                
                if ([mgr fileExistsAtPath:self.iconImagePath]) {
                    [mgr removeItemAtPath:self.iconImagePath error:&error];
                    if (!error) {
                        NSLog(@"writeToServerImagePath self.iconImagePath删了");
                        [self.tableView reloadData];
                        
                    }else{
                    
                        NSLog(@"writeToServerImagePath self.iconImagePath删除失败");
                        
                    }
                }
            }
        }else{
        
            [MBProgressHUD showSuccess:@"修改失败"];
            NSLog(@"writeToServerImagePath error == %@",error);
            
            if ([mgr fileExistsAtPath:self.iconImagePath]) {
                [mgr removeItemAtPath:self.iconImagePath error:&error];
                if (!error) {
                    NSLog(@"writeToServerImagePath self.iconImagePath删了");
                    [self.tableView reloadData];
                    
                }else{
                    
                    NSLog(@"writeToServerImagePath self.iconImagePath删除失败");
                }
            }
        }
        
        
    }];
}
- (void)backMyUi{
    [self.navigationController popToRootViewControllerAnimated:YES];
}
- (void)saveUserIconImage:(UIImage *)image{
    
    HWLog(@"-------------saveUserIconImage------------%@",image);
    
    
    
    NSData *imageData2 = [CCImage ccImage:image];
    NSLog(@"--imageData---%lu",[imageData2 length]/1024);
    //    NSString *imageName = [NSString stringWithFormat:@"%@.png",kUid];
    // 获取沙盒目录
    NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[NSString stringWithFormat:@"iconimage%@",identifierForVendor]];
    self.iconImagePath = fullPath;
    
    // 将图片写入文件
    if ([imageData2 writeToFile:fullPath atomically:NO]) {
        HWLog(@"--------------写入OK");
    }else{
        
        HWLog(@"--------------写入失败");
    }
    
    NSString *ullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[NSString stringWithFormat:@"iconimage%@",identifierForVendor]];
    self.userIconImage = [UIImage imageWithContentsOfFile:ullPath];
    HWLog(@"--------ullPath------image----%@",self.userIconImage);
}

- (void)onPhoneAlbum{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        UIImagePickerController *imagePc = [[UIImagePickerController alloc] init];
        
        imagePc.delegate = self;
        
        imagePc.allowsEditing = YES;
        
        imagePc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        [self.navigationController presentViewController:imagePc animated:YES completion:nil];
        HWLog(@"支持相片库");
    }
    
}


- (void)onAlbumPressed {
    
}

- (void)onRenameNick{
    
    [[RDVTabBarController shareTabBar] setTabBarHidden:YES animated:NO];
    ChangeNickNameViewController *changeNickNameViewController = [[ChangeNickNameViewController alloc] initWithNibName:@"ChangeNickNameViewController" bundle:nil];
    changeNickNameViewController.delegate = self;
    [self.navigationController pushViewController:changeNickNameViewController animated:YES];
}


- (void)onClearAllCache{
    
    HWLog(@"-----------------------onClearAllCache");
    
    _documents = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    
    for (_localDataPath in _documents) {
        
        NSInteger fileSize = [LBClearCacheTool getCacheSizeWithFilePath:_localDataPath];
        _fileSize = fileSize;
        HWLog(@"---------------fileSize:[%ld]",(long)(fileSize+=fileSize));
        
        if (fileSize > 1000 * 1000)
        {
            _fileSizeStr = [NSString stringWithFormat:@"确定要删除%.1fM数据",fileSize / 1000.0f /1000.0f];
        }else if (fileSize > 1000)
        {
            _fileSizeStr = [NSString stringWithFormat:@"确定要删除%.1fKB数据",fileSize / 1000.0f ];
            
        }else
        {
            _fileSizeStr = [NSString stringWithFormat:@"确定要删除%.1fB数据",fileSize / 1.0f];
        }
        
    }
    
    _documents1 = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    for (_localDataPath in _documents1) {
        
        NSInteger fileSize1 = [LBClearCacheTool getCacheSizeWithFilePath:_localDataPath];
        
        HWLog(@"---------------fileSize:[%ld]",(long)(fileSize1 = fileSize1 + _fileSize));
        
        if (fileSize1 > 1000 * 1000)
        {
            _fileSizeStr = [NSString stringWithFormat:@"确定要删除%.1fM数据",fileSize1 / 1000.0f /1000.0f];
        }else if (fileSize1 > 1000)
        {
            _fileSizeStr = [NSString stringWithFormat:@"确定要删除%.1fKB数据",fileSize1 / 1000.0f ];
            
        }else
        {
            _fileSizeStr = [NSString stringWithFormat:@"确定要删除%.1fB数据",fileSize1 / 1.0f];
        }
        
    }
    
    [[AlbumManager shareAlbumManager] clearAllAlbum];
    HWLog(@"videoListTmp[%@]",[AlbumManager shareAlbumManager].AlbumItemList);
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title", nil) message:_fileSizeStr delegate:self cancelButtonTitle:NSLocalizedString(@"cancel_btn", nil) otherButtonTitles:NSLocalizedString(@"confirm_btn", nil), nil];
    alert.tag = 1022;
    [alert show];
}



- (IBAction)logoutBtnClicked:(id)sender {
    
    self.iconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"find_new_head_bg"]];
    
    if ([self.delegate respondsToSelector:@selector(resetIconImage)]) {
        [self.delegate resetIconImage];
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_title", nil) message:NSLocalizedString(@"quite_app", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"cancel_btn", nil) otherButtonTitles:NSLocalizedString(@"confirm_btn", nil), nil];
    
    alertView.tag = 1011;
    [alertView show];
    
}

- (void)logout{
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES configBlock:^(MBProgressHUD *HUD) {
        //        HUD.detailsLabelText = NSLocalizedString(@"warnning_member_logout", nil);
        
        HUD.customView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.removeFromSuperViewOnHide = YES;
        [(UIActivityIndicatorView *)HUD.customView startAnimating];
        
        
    }];
    
}

- (void)logoutDone{
    
    NSNotification	*note = [NSNotification notificationWithName:KLoginOutMsg object:nil userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:note];
    
}

#pragma mark - TableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        return 99.f;
    }
    
    return 40.f;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.0001f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[_sections objectAtIndex:section] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return _sections.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    NSDictionary *menuItem = [[_sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"personalInfoCell"];
    
    if (!cell) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"personalInfoCell"];
        cell.backgroundColor = kTableViewCellColor;
        cell.textLabel.font = HWCellFont;
        cell.detailTextLabel.font = HWCellFont;
        cell.textColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        
        if (!self.iconImageView.image) {
            self.iconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"find_new_head_bg"]];
        }
        
        self.iconImageView.frame = CGRectMake(0, 0, 45, 45);
        self.rightLabel.frame =CGRectMake(0, 0, 45, 45);
        cell.textLabel.text = @"头像";
        //        self.iconImageView.layer.cornerRadius = 32;
        //        self.iconImageView.layer.masksToBounds = YES;
        HWLog(@"--------savedImage----------%@",self.iconImageView.image);
        
        [self setIconImage];
        cell.accessoryView = self.iconImageView;
        
        HWLog(@"--------cell.accessoryView----------%@",cell.accessoryView);
        
    }
    
    
    if ([[menuItem objectForKey:kMenuAccessoryStyle] isEqualToString:kMenuAccessoryDisclosureIndicator]) {
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    else{
        
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    if (indexPath.section == 1) {
        if (indexPath.row == 1) {
            cell.textLabel.text = @"行车号";
            cell.detailTextLabel.text = @"";
        }else if (indexPath.row == 2){
            
            cell.textLabel.text = @"个性签名";
            cell.detailTextLabel.text = @"骑马喝酒走四方";
            cell.accessoryType = UITableViewCellAccessoryNone;
        }else{
            cell.textLabel.text = [menuItem objectForKey:kMenuTitle];
            cell.detailTextLabel.text = [HWUserInstanceInfo shareUser].nickname;
        }
    }
    //    cell.textLabel.text = [menuItem objectForKey:kMenuTitle];
    //    cell.detailTextLabel.text = [menuItem objectForKey:kMenuDetailText];
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *menuItem = [[_sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    SEL currentSelector = NSSelectorFromString([menuItem objectForKey:kMenuSelector]);
    [self performSelector:currentSelector];
}

#pragma mark - changeNickNameDelegate
- (void)updateNickNameDone {
    
    NSString *nickName = [[MemberData memberData] getMemberNickName];
    
    [[[self.sections objectAtIndex:1] objectAtIndex:0] setObject:nickName forKey:kMenuDetailText];
    
    [self.tableView reloadData];
}

#pragma mark - AlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == 1011) {
        if (buttonIndex == 1) {
            [self logout];
        }
    }else if (alertView.tag == 1022){
        
        if (buttonIndex == 1) {
            
            for (NSString *path in _documents) {
                _DeleteDataSuccess = [LBClearCacheTool clearCacheWithFilePath:path];
            }
            
            for (NSString *path in _documents1) {
                _DeleteDataSuccess = [LBClearCacheTool clearCacheWithFilePath:path];
            }
            
            if (_DeleteDataSuccess) {
                
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES configBlock:nil];
                hud.removeFromSuperViewOnHide =YES;
                hud.mode = MBProgressHUDModeText;
                hud.labelText = @"✅";
                [hud hide:YES afterDelay:3];
                HWLog(@"%@",NSStringFromCGRect(hud.bounds));
            }else{
                
                _hud.labelText = @"❌";  //提示的内容
            }
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
