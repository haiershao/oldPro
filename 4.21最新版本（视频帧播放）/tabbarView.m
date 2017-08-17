////
////  tabbarView.m
////  tabbarTest
////
////  Created by Kevin Lee on 13-5-6.
////  Copyright (c) 2013年 Kevin. All rights reserved.
////
//
//#import "tabbarView.h"
//#import "MemberData.h"
//
//
//#define K_FIRTSBTN_LEFT_DIS 50
//#define K_FIRTSBTN_TOP_DIS 0
//
//#define K_BTN_WIDTH K_TABBAR_TOP_HALF*2
//#define K_BTN_HEIGHT K_BTN_WIDTH
//
//#define K_DIS_BETWEEN_BTNS 32
//
//
//#define K_LABEL_WIDTH 90
//#define K_LABEL_HEIGHT 20
//
//#define K_FIRSTBTN_VIEWTAG 1000
//
//@interface tabbarView() {
//
//	int curSelectedBtnTag;
//    
//    int flag;//前一次的选择
//
//}
//
//
//@property(nonatomic,retain) UIImageView *tabbarView;
//
//@end
//
//@implementation tabbarView
//
//- (void)dealloc {
//
//	
//
//}
//
//- (id)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self) {
//        // Initialization code
//        [self setFrame:frame];
//		self.userInteractionEnabled = YES;
//        [self layoutView];
//        flag = -1;
//    }
//    return self;
//}
//
//-(void)layoutView
//{
//    self.tabbarView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"tabbar_background"]];
//
//    [_tabbarView setFrame:CGRectMake(0, K_TABBAR_TOP_HALF, _tabbarView.bounds.size.width, K_TABBAR_BOTTOM_HALF)];
//    [_tabbarView setUserInteractionEnabled:YES];
//    
//    [self addSubview:_tabbarView];
//    
//    [self layoutBtn];
//
//}
//
//- (NSArray*)getLabelTextArray {
//
//
//	return [NSArray arrayWithObjects:NSLocalizedString(@"tabbar_my_camera_label", nil),
//									 NSLocalizedString(@"tabbar_cloud_storage_label", nil),
//									 NSLocalizedString(@"tabbar_album", nil),
//                                     NSLocalizedString(@"tabbar_me_label", nil),
//									 nil];
//
//}
//
//-(void)layoutBtn
//{
//	
//	CGRect imageRect = CGRectMake(K_FIRTSBTN_LEFT_DIS, K_FIRTSBTN_TOP_DIS, K_BTN_WIDTH, K_BTN_HEIGHT);
//	
//	NSArray* textArr = [self getLabelTextArray];
//	
//	for(int i = 0; i < 4; i++) {
//	
//		UIImageView *imageView = [[UIImageView alloc] initWithFrame:imageRect];
//		[imageView setFrame:imageRect];
//		[imageView setTag:K_FIRSTBTN_VIEWTAG + i];
//		imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"tabbar_btn_normal_%d", i]];
//		[self addSubview:imageView];
//		
//		CGRect labelRect = CGRectMake(imageView.center.x - K_LABEL_WIDTH/2,
//									  K_BTN_HEIGHT,
//									  K_LABEL_WIDTH,
//									  K_LABEL_HEIGHT);
//		
//		UILabel *label = [[UILabel alloc] initWithFrame:labelRect];
//		label.textAlignment = NSTextAlignmentCenter;
//		label.textColor = kUIColorFromRGB(0xff7f66);
//		label.text = [textArr objectAtIndex:i];
//		label.font = [UIFont systemFontOfSize:12];
//		[self addSubview:label];
//		
//		imageRect = CGRectMake(imageRect.origin.x + K_BTN_WIDTH + K_DIS_BETWEEN_BTNS,
//							 K_FIRTSBTN_TOP_DIS,
//							 K_BTN_WIDTH,
//							 K_BTN_HEIGHT);
//
//	}
//	
//}
//
//
//
//
//- (void)itemWasSelected:(int)index {
//
//	
//	for(int i = 0; i < 4; i++){
//	
//		UIImageView* v = (UIImageView*)[self viewWithTag:K_FIRSTBTN_VIEWTAG + i];
//		
//		if (i == index) {
//		
//			v.image = [UIImage imageNamed:[NSString stringWithFormat:@"tabbar_btn_selected_%d",
//										   i]];
//		}
//		else {
//		
//			
//			
//			v.image = [UIImage imageNamed:[NSString stringWithFormat:@"tabbar_btn_normal_%d",
//										   i]];
//		}
//        
//        
//	}
//	
////    if (index == 2) {
//    
////        if ( flag != 2 && [[MemberData memberData] isMemberLogin]) {
////            NSNotification	*note = [NSNotification notificationWithName:KSelectPersonalController object:nil userInfo:nil];
////            [[NSNotificationCenter defaultCenter] postNotification:note];
////        }
//        
////    }
//    flag = index;
//    
//}
//
///*
//// Only override drawRect: if you perform custom drawing.
//// An empty implementation adversely affects performance during animation.
//- (void)drawRect:(CGRect)rect
//{
//    // Drawing code
//}
//*/
//
//@end
