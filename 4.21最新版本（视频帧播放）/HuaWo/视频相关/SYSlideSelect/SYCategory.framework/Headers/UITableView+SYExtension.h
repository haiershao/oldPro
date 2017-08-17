//
//  UITableView+SYSlideExtension.h
//  SYSlideDemo
//
//  Created by 唐绍禹 on 16/6/20.
//  Copyright © 2016年 tsy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (SYExtension)

@property (nonatomic, copy) void (^sy_headerRefresh)();

- (void)sy_beginRefresh;
- (void)sy_endRefresh;
- (void)sy_observeTableViewContentOffset;

#pragma mark - 注册cell
- (void)sy_registerNibWithClass:(Class)customClass;
- (void)sy_registerCellWithClass:(Class)customClass;

#pragma mark - 注册SectionHeaderFooter
- (void)sy_registerNibForSectionHeaderFooterWithClass:(Class)customClass;
- (void)sy_registerClassForSectionHeaderFooterWithClass:(Class)customClass;
@end
