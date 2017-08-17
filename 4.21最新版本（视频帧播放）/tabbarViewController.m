////
////  tabbarViewController.m
////  tabbarTest
////
////  Created by Kevin Lee on 13-5-6.
////  Copyright (c) 2013年 Kevin. All rights reserved.
////
//
//#import "tabbarViewController.h"
//#import "tabbarView.h"
//#import "DiscoveryController.h"
//#import "CameraViewController.h"
//#import "PersonalCenterViewController.h"
//
//#define SELECTED_VIEW_CONTROLLER_TAG 98456345
//
//
//
//
//#define K_DICTAG_VIEWCONTROLLER @"viewController"
//
//static tabbarViewController *tabbarControl = nil;
//@interface tabbarViewController ()<UINavigationControllerDelegate, UITabBarControllerDelegate>
//
//@property(nonatomic,retain) tabbarView *tabbar;
////@property(nonatomic,retain) NSArray *arrayViewcontrollers;
////@property(nonatomic, retain) UIViewController* currentVC;
//
//@end
//
//@implementation tabbarViewController
//
//+ (tabbarViewController *)shareTabbarController_iphone{
//
//    
//    if (tabbarControl == nil) {
//        tabbarControl = [[tabbarViewController alloc] init];
//    }
//    
//    
//    DiscoveryController *discoverVC = [[DiscoveryController alloc] initWithNibName:@"DiscoveryController" bundle:nil];
//    discoverVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"tabbar_cloud_storage_label", nil) image:[UIImage imageNamed:@"tab_find"] selectedImage:[UIImage imageNamed:@"tab_find_focus"]];
//    UINavigationController *fisrt = [[UINavigationController alloc] initWithRootViewController:discoverVC];
//    
//    
//    CameraViewController *cameraVC = [[CameraViewController alloc] initWithNibName:@"CameraViewController" bundle:nil];
//    cameraVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"tabbar_my_camera_label", nil) image:[UIImage imageNamed:@"tab_camera"] selectedImage:[UIImage imageNamed:@"tab_camera_focus"]];
//    UINavigationController *second = [[UINavigationController alloc] initWithRootViewController:cameraVC];
//    
//    
//    PersonalCenterViewController *pVC = [[PersonalCenterViewController alloc] initWithNibName:@"PersonalCenterViewController" bundle:nil];
//    pVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"tabbar_me_label", nil) image:[UIImage imageNamed:@"tab_my"] selectedImage:[UIImage imageNamed:@"tab_my_focus"]];
//    UINavigationController *third = [[UINavigationController alloc] initWithRootViewController:pVC];
//    
//    tabbarControl.viewControllers = [NSArray arrayWithObjects:fisrt, second, third, nil];
//    
////    tabbarControl.viewControllers
//    
//    
//    
//    
//    
//    
//    return tabbarControl;
//
//}
//- (void)dealloc {
//
//
//}
//
//- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
//
//	[_tabbar itemWasSelected:tabBarController.selectedIndex];
//
//}
//
//- (void)viewDidLoad
//{
//    [super viewDidLoad];
//	// Do any additional setup after loading the view, typically from a nib.
////    CGFloat orginHeight = self.view.frame.size.height- K_TABBAR_HEIGHT;
////    if (kiPhone5) {
////        orginHeight = self.view.frame.size.height- K_TABBAR_HEIGHT + addHeight;
////    }
//	
//    tabbarControl = self;
//	CGRect rect = self.tabBar.bounds;
//	
//	
//	
//    self.tabbar = [[tabbarView alloc]initWithFrame:CGRectMake(0,  rect.size.height- K_TABBAR_HEIGHT, 320, K_TABBAR_HEIGHT)];
//	
//    _tabbar.delegate = self;
//	self.tabBar.backgroundImage = [[UIImage alloc] init];
//	[self.tabBar setShadowImage:[[UIImage alloc] init]];
//	[self.tabBar addSubview:_tabbar];
//	
//	self.selectedIndex = 0;
//	[_tabbar itemWasSelected:0];
//	
//	self.delegate = self;
//}
//
//- (void)didReceiveMemoryWarning
//{
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}
//
//-(void)touchBtnAtIndex:(NSInteger)index
//{
//
//	self.selectedIndex = index;
//}
//
///**
// * 让当前控制器对应的状态栏是白色
// */
//- (UIStatusBarStyle)preferredStatusBarStyle
//{
//    
//    return UIStatusBarStyleLightContent;
//}
//@end
