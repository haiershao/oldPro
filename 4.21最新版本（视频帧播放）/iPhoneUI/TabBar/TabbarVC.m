////
////  TabbarVC.m
////  HuaWo
////
////  Created by circlely on 1/28/16.
////  Copyright © 2016 circlely. All rights reserved.
////
//
//#import "TabbarVC.h"
//#import "DiscoveryController.h"
//#import "CameraViewController.h"
//#import "PersonalCenterViewController.h"
//#import "AlbumController.h"
//
//
//@interface TabbarVC ()<UITabBarControllerDelegate, UITabBarDelegate>
//
//@property (weak, nonatomic) IBOutlet UITabBar *tabBar;
//
//
//
//@end
//
//@implementation TabbarVC
//
//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
// 
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    
//    if (self) {
//        
//        self.tabBar.barTintColor = kColor(37, 37, 44, 1);
//
//        DiscoveryController *discoverVC = [[DiscoveryController alloc] initWithNibName:@"DiscoveryController" bundle:nil];
//        discoverVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"tabbar_cloud_storage_label", nil) image:[UIImage imageNamed:@"tab_find"] selectedImage:[UIImage imageNamed:@"tab_find_focus"]];
//        UINavigationController *fisrt = [[UINavigationController alloc] initWithRootViewController:discoverVC];
//        
//        
//        CameraViewController *cameraVC = [[CameraViewController alloc] initWithNibName:@"CameraViewController" bundle:nil];
//        cameraVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"tabbar_my_camera_label", nil) image:[UIImage imageNamed:@"tab_camera"] selectedImage:[UIImage imageNamed:@"tab_camera_focus"]];
//        UINavigationController *second = [[UINavigationController alloc] initWithRootViewController:cameraVC];
//        
//        
//        PersonalCenterViewController *pVC = [[PersonalCenterViewController alloc] initWithNibName:@"PersonalCenterViewController" bundle:nil];
//        pVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"tabbar_me_label", nil) image:[UIImage imageNamed:@"tab_my"] selectedImage:[UIImage imageNamed:@"tab_my_focus"]];
//        UINavigationController *third = [[UINavigationController alloc] initWithRootViewController:pVC];
//        
//        AlbumController *albumVc = [[AlbumController alloc] initWithNibName:@"AlbumController" bundle:nil];
//        albumVc.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"tabbar_me_label", nil) image:[UIImage imageNamed:@"tab_my"] selectedImage:[UIImage imageNamed:@"tab_my_focus"]];
//        UINavigationController *four = [[UINavigationController alloc] initWithRootViewController:albumVc];
//        
//        self.viewControllers = [NSArray arrayWithObjects:fisrt, second, third,four, nil];
//        
//        self.tabBar.tintColor = kHuaWoTintColor;
//    }
//    
//    
//    
//    return self;
//
//}
//
//- (void)viewDidLoad {
//    [super viewDidLoad];
//    // Do any additional setup after loading the view from its nib.
//}
//
//- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}
//
//- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
//    
//    
//    
//}
//
//
//
//@end
