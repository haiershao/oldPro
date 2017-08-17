//
//  HWLocalVideoListViewController.m
//  HuaWo
//
//  Created by hwawo on 16/9/23.
//  Copyright © 2016年 HW. All rights reserved.
//

#import "HWLocalVideoListViewController.h"
#import "HWLocalVideoCell.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "HWVideoData.h"
#import <AWSS3/AWSS3.h>
#import "SharePageViewController.h"
#import <LHUserAlbumUrlExchangeDocumentUrl/LHUserAlbumUrlExchangeDocumentUrl.h>
#define KCachesPath [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]

@interface HWLocalVideoListViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIView *toolBar;
@property (strong, nonatomic) UIImagePickerController *imagePc;
@property (nonatomic,strong) NSMutableArray *groupArrays;
@property (nonatomic,strong) NSMutableArray *videoArrays;
@property (nonatomic,strong) UIImage *litimage;
@property (nonatomic, copy) NSString *videoPath;
@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, copy) NSString *iconPath;
@property (nonatomic,strong) NSMutableArray *litImages;
@property (nonatomic,strong) NSMutableArray *fileNames;
@property (nonatomic,strong) NSMutableArray *iconPaths;
@property (nonatomic,strong) NSMutableArray *images;
@property (nonatomic,strong) LHUserAlbumUrlExchangeDocumentUrl *albumurls;
@property (weak, nonatomic) UIView *coverView;
@end

static NSString *CellIdentifier = @"localVideoCell";

@implementation HWLocalVideoListViewController
- (NSMutableArray *)loopImages{
    
    if (!_loopImages) {
        _loopImages = [NSMutableArray array];
    }
    return _loopImages;
}

- (NSMutableArray *)videoPaths{
    
    if (!_videoPaths) {
        _videoPaths = [NSMutableArray array];
    }
    return _videoPaths;
}

- (NSMutableArray *)groupArrays{

    if (!_groupArrays) {
        _groupArrays = [NSMutableArray array];
    }
    return _groupArrays;
}

- (NSMutableArray *)videoArrays{
    
    if (!_videoArrays) {
        _videoArrays = [NSMutableArray array];
    }
    return _videoArrays;
}

- (NSMutableArray *)litImages{

    if (!_litImages) {
        _litImages = [NSMutableArray array];
    }
    return _litImages;
}

- (NSMutableArray *)fileNames{

    if (!_fileNames) {
        _fileNames = [NSMutableArray array];
    }
    return _fileNames;
}

- (NSMutableArray *)iconPaths{

    if (!_iconPaths) {
        _iconPaths = [NSMutableArray array];
    }
    return _iconPaths;
}

- (NSMutableArray *)images{
    
    if (!_images) {
        _images = [NSMutableArray array];
    }
    return _images;
}

+ (instancetype)localVideoListViewController{
    
    return [[[self class] alloc] initWithNibName:@"HWLocalVideoListViewController" bundle:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.tableView.backgroundColor = nil;
    self.tableView.backgroundColor = kBackgroundColor;
//    self.tableView.separatorColor = DZColor(80, 80, 80);
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.toolBar.hidden = YES;
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([HWLocalVideoCell class]) bundle:nil] forCellReuseIdentifier:CellIdentifier];
    
    [self setUpCoverView];
}

- (void)setUpCoverView{

//    UIView *coverView = [[UIView alloc] init];
//    coverView.frame = self.view.bounds;
//    [self.view addSubview:coverView];
//    [self.view bringSubviewToFront:coverView];
//    self.coverView = coverView;
//    self.coverView.hidden = NO;
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        self.coverView.hidden = YES;
//    });
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}


- (void)setCellImage{

    for (UIImage *image in self.litImages) {
        self.litimage = image;
        HWLog(@"---image==%@",image);
        [self.tableView reloadData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)shareBtnClick:(UIButton *)sender {
    
    SharePageViewController *shareVc = [SharePageViewController sharePageViewController];
    shareVc.videoPath = self.videoPath;
    shareVc.imagePath = self.iconPath;
    [self.navigationController pushViewController:shareVc animated:YES];
    
}

- (NSString *)createMobileAlbumVideoPath:(NSString *)fileName{
    
    NSString *dirName = @"mobileAlbum";
    NSString *mobileAlbumPath = [NSString stringWithFormat:@"%@/Documents/%@", NSHomeDirectory(), dirName];
//    mobileAlbumPath = [NSString stringWithFormat:@"%@/%@", mobileAlbumPath, fileName];
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:mobileAlbumPath isDirectory:&isDir];
    if (!(isDir == YES && existed == YES) )
    {
        [fileManager createDirectoryAtPath:mobileAlbumPath withIntermediateDirectories:YES attributes:nil error:nil];
    }else{
        
        HWLog(@"-----------创建的文件夹已存在-----------");
    }
    
    return mobileAlbumPath;
}

- (NSString *)createMobileAlbumImagePath:(NSString *)fileName{
    
    NSString *dirName = @"mobileAlbum";
    NSString *mobileAlbumPath = [NSString stringWithFormat:@"%@/Documents/%@", NSHomeDirectory(), dirName];
//    mobileAlbumPath = [NSString stringWithFormat:@"%@/%@", mobileAlbumPath, fileName];
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:mobileAlbumPath isDirectory:&isDir];
    if (!(isDir == YES && existed == YES) )
    {
        [fileManager createDirectoryAtPath:mobileAlbumPath withIntermediateDirectories:YES attributes:nil error:nil];
    }else{
        
        HWLog(@"-----------创建的文件夹已存在-----------");
    }
    
    return mobileAlbumPath;
}

#pragma mark - Table view data source
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Incomplete implementation, return the number of sections
//    return 0;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    HWLog(@"self.videoArrays.count = %lu--%@--%lu--%lu==%lu",(unsigned long)self.videoArrays.count, self.fileName, (unsigned long)self.litImages.count,(unsigned long)self.litImages.count, (unsigned long)self.iconPaths.count);
    
//    if (self.videoPaths.count) {
       return self.videoPaths.count;
//    }else{
//    
//        return self.videoArrays.count;
//    }

    
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    HWLocalVideoCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[HWLocalVideoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

//    UIImage *image = [UIImage imageWithContentsOfFile:self.iconPaths[indexPath.row]];
//    if (image) {
//        
//        NSError *error = nil;
//        HWLog(@"----error----%@",error);
//        
//        cell.iconImage = image;
//    }
    if (self.loopImages.count) {
        cell.iconImage = self.loopImages[indexPath.row];
    }else{
    
        cell.iconImage = self.images[indexPath.row];
    }
    
    if (self.videoPaths.count) {
        cell.videoName = [self.videoPaths[indexPath.row] componentsSeparatedByString:@"/"].lastObject ;
    }else{
    
        HWLog(@"--self.fileNames--%@",self.fileNames[indexPath.row]);
        if (self.fileNames) {
            
            cell.videoName = self.fileNames[indexPath.row];
        }
    }
    
    cell.backgroundColor = DZColor(31, 31, 35);
    cell.textLabel.textColor = [UIColor whiteColor];
//    cell.selectionStyle = UITableViewCellEditingStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
 
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }

    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]){
        [cell setPreservesSuperviewLayoutMargins:NO];
    }

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    self.toolBar.hidden = NO;
    if (self.videoPaths.count) {
        
        self.videoPath = self.videoPaths[indexPath.row];
        self.iconPath = @"123456";
  
    }else{
    
        self.videoPath = self.videoArrays[indexPath.row];
        self.iconPath = self.iconPaths[indexPath.row];
    }
    
    //变化宽高
//    self.iconPath = self.iconPaths[indexPath.row];
    //固定宽高
//    self.iconPath = self.iconPaths[indexPath.row];
    HWLog(@"--didSelectRowAtIndexPath---%@--%@",self.videoPath, self.iconPath);
}

- (NSString *)saveUserIconImage:(UIImage *)image iconImageName:(NSString *)iconImageName iconPath:(NSString *)iconPath{
    
    HWLog(@"-------------saveUserIconImage------------%@",image);
    UIImage *scaledImage = [self getImageByCuttingImage:image];
    NSData *imageData = UIImagePNGRepresentation(scaledImage);
//    NSLog(@"--imageData---%u",[imageData length]/1024);
    //    NSString *imageName = [NSString stringWithFormat:@"%@.png",kUid];
    // 获取沙盒目录
//    NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:iconImageName];
    
    // 将图片写入文件
    if ([imageData writeToFile:iconPath atomically:NO]) {
        HWLog(@"--------------写入OK");
    }else {
        
        HWLog(@"--------------写入失败");
    }
    
    NSString *ullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:iconImageName];

    return ullPath;
}

- (UIImage *)getImageByCuttingImage:( UIImage *)image{
    CGSize sizeImage = image.size;
    CGSize size = CGSizeMake(sizeImage.width, 80);
    UIGraphicsBeginImageContext(size);  //size 为CGSize类型，即你所需要的图片尺寸
    
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return scaledImage;   //返回的就是已经改变的图片    
}

- (IBAction)cancelBtnClick:(UIButton *)sender {
    
    self.toolBar.hidden = YES;
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
