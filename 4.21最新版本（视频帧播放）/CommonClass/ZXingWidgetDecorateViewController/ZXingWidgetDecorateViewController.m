//
//  ZXingWidgetDecorateViewController.m
//  AtHomeCam
//
//  Created by Lvyi on 5/15/14.
//  Copyright (c) 2014 ichano. All rights reserved.
//

#import "ZXingWidgetDecorateViewController.h"
#import "Refactor_AddAvsServerViewController.h"
#import "AddHandViewController.h"
#import "TabbarViewController_iPad.h"
@interface ZXingWidgetDecorateViewController ()<AddAvsServerViewControllerDelegate,AddHandViewControllerDelegate>

@end

@implementation ZXingWidgetDecorateViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = NSLocalizedString(@"second_step_add_avs_Label", nil);
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"cancel_btn", nil)
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(cancelled)];
    
    [self.navigationItem setLeftBarButtonItem:leftItem];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"scan_qr_code"] style:UIBarButtonItemStylePlain target:self action:@selector(rightBtnClicked)];
    [self.navigationItem setRightBarButtonItem:rightItem];
    
    if (kIsPad) {
        [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:kNavigation7Color,NSForegroundColorAttributeName, nil]];
        [leftItem setTintColor:kNavigation7Color];
        [rightItem setTintColor:kNavigation7Color];
    }else{
        [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName, nil]];
        [leftItem setTintColor:[UIColor whiteColor]];
        [rightItem setTintColor:[UIColor whiteColor]];
    }
    
    
    [leftItem release];
    [rightItem release];
    

//	if(kiOS7){
//        [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:(90.0/255.0) green:(97.0/255.0) blue:(101.0/255.0) alpha:1]];
//    }else{
//        self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:(90.0/255.0) green:(97.0/255.0) blue:(101.0/255.0) alpha:1];
//    
//    }
    

    
	//监听程序进入后台的通知
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];

}

- (void)rightBtnClicked {
    
    
    if (kIsPad) {
        //[self popoverControllerDidDismissPopover:nil];
        AddHandViewController *addHandController = [[AddHandViewController alloc] initWithNibName:@"AddHandViewController" bundle:nil];
        addHandController.delegate = self;
        addHandController.CIDStr = @"";
        addHandController.userNameStr = @"";
        addHandController.passWordStr =@"";
        addHandController.isCidListContro = self.isCidListContro;
        addHandController.isZXingControllerPushed = YES;
        //[addHandController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
        //[addHandController setModalPresentationStyle:UIModalPresentationFormSheet];
        //[self presentViewController:addHandController animated:YES completion:^{}];
        self.navigationController.navigationBarHidden = YES;
        [self.navigationController pushViewController:addHandController animated:YES];
        [addHandController release];
        
    }else{
        Refactor_AddAvsServerViewController* addServerController = [[Refactor_AddAvsServerViewController alloc] initWithNibName:@"Refactor_AddAvsServerViewController" bundle:nil];
        addServerController.isCidListController = self.isCidListContro;
        addServerController.delegate = self;
        addServerController.isZXingControllerPushed = YES;
//        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:addServerController];
//        if (kiOS7) {
//            navigationController.navigationBar.tintColor = [UIColor whiteColor];
//            navigationController.navigationBar.barTintColor = kNavigation7Color;
//            NSDictionary *textColorDictionary = @{UITextAttributeFont: CG_BOLD_FONT(20),UITextAttributeTextColor: [UIColor whiteColor]};
//            navigationController.navigationBar.titleTextAttributes = textColorDictionary;
//            navigationController.navigationBar.translucent = NO;
//        }else{
//            navigationController.navigationBar.tintColor = kNavigation6Color;
//        }
        
        //    [self presentViewController:navigationController animated:YES completion:^{
        //        [addServerController release];
        //        [navigationController release];
        //    }];
        [self.navigationController pushViewController:addServerController animated:YES];
        //[self presentViewController:navigationController animated:YES completion:^{}];
        [addServerController release];
        //[navigationController release];
    }
    
}


- (void)applicationDidEnterBackground {
	
	//程序进入后台時，將彈出的界面dismiss掉
	[self dismissViewControllerAnimated:NO completion:nil];
}

- (void)dealloc {

	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

-(NSUInteger)supportedInterfaceOrientations
{
	return (kIsPad ? UIInterfaceOrientationMaskLandscape : UIInterfaceOrientationMaskPortrait);
}

-(BOOL)shouldAutorotate
{
	return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
