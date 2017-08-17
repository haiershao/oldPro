//
// REMenu.m
// REMenu
//
// Copyright (c) 2013 Roman Efimov (https://github.com/romaonthego)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "REMenu.h"
#import "REMenuItem.h"
#import "REMenuItemView.h"

@interface REMenuItem ()

@property (assign, readwrite, nonatomic) REMenuItemView *itemView;

@end

@interface REMenu ()

@property (strong, readwrite, nonatomic) UIView *menuView;
@property (strong, readwrite, nonatomic) UIView *menuWrapperView;
@property (strong, readwrite, nonatomic) REMenuContainerView *containerView;
@property (strong, readwrite, nonatomic) UIButton *backgroundButton;
@property (assign, readwrite, nonatomic) BOOL isOpen;
@property (strong, readwrite, nonatomic) NSMutableArray *itemViews;
@property (weak, readwrite, nonatomic) UINavigationBar *navigationBar;

@end

@implementation REMenu

- (id)init
{
    if ((self = [super init])) {
        self.imageAlignment = REMenuImageAlignmentLeft;
        self.closeOnSelection = YES;
        self.itemHeight = 70.0;
        self.separatorHeight = 1.0;
        self.waitUntilAnimationIsComplete = YES;
        
        self.textOffset = CGSizeMake(0, 0);
        self.subtitleTextOffset = CGSizeMake(0, 0);
        self.font = [UIFont systemFontOfSize:17.0];
        self.subtitleFont = [UIFont systemFontOfSize:14.0];
        
        self.backgroundColor = kBackgroundColor;
        self.separatorColor = [UIColor blackColor];//[UIColor colorWithPatternImage:self.separatorImage];
        self.textColor = kColor(241, 252, 223, 1);  //[UIColor colorWithRed:79/255.0 green:79/255.0 blue:79/255.0 alpha:1.0];
        self.textAlignment = NSTextAlignmentLeft;
        self.isTitleCenter = NO;
        
        self.highlightedBackgroundColor = kBackgroundColor;
        //self.highlightedSeparatorColor = [UIColor lightGrayColor];//[UIColor colorWithRed:28/255.0 green:28/255.0 blue:27/255.0 alpha:1.0];
        //self.highlightedTextColor = [UIColor whiteColor];//[UIColor colorWithRed:128/255.0 green:126/255.0 blue:124/255.0 alpha:1.0];
//        self.highlightedTextShadowColor = [UIColor blackColor];
//        self.highlightedTextShadowOffset = CGSizeMake(0, -1.0);
        
        self.subtitleTextColor = [UIColor colorWithWhite:0.425 alpha:1.000];
//        self.subtitleTextShadowColor = [UIColor blackColor];
//        self.subtitleTextShadowOffset = CGSizeMake(0, -1.0);
        self.subtitleHighlightedTextColor = [UIColor colorWithRed:0.389 green:0.384 blue:0.379 alpha:1.000];
//        self.subtitleHighlightedTextShadowColor = [UIColor blackColor];
//        self.subtitleHighlightedTextShadowOffset = CGSizeMake(0, -1.0);
        self.subtitleTextAlignment = NSTextAlignmentCenter;
        
        self.borderWidth = 0.0;//1.0;
        self.borderColor =  [UIColor colorWithRed:28/255.0 green:28/255.0 blue:27/255.0 alpha:1.0];
        self.animationDuration = 0.2;
        self.bounce = YES;
        self.bounceAnimationDuration = 0.2;
        
        self.appearsBehindNavigationBar = REUIKitIsFlatMode() ? YES : NO;
        
        self.backgroundView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        self.backgroundView.backgroundColor = [UIColor blackColor];
    }
    return self;
}

- (id)initWithItems:(NSArray *)items
{
    if ((self = [self init])) {
        self.items = items;
    }
    return self;
}

- (void)showFromRect:(CGRect)rect inView:(UIView *)view
{
    self.isOpen = YES;
    
    // Create views
    //
    self.containerView = ({
        REMenuContainerView *view = [[REMenuContainerView alloc] init];
        view.clipsToBounds = YES;
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        if (self.backgroundView) {
            self.backgroundView.alpha = 1;
            [view addSubview:self.backgroundView];
        }
        view;
    });
    
    self.menuView = ({
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = self.backgroundColor;
        view.alpha = 1;
        view.layer.cornerRadius = self.cornerRadius;
        view.layer.borderColor = self.borderColor.CGColor;
        view.layer.borderWidth = self.borderWidth;
        view.layer.masksToBounds = YES;
        view.layer.shouldRasterize = YES;
        view.layer.rasterizationScale = [UIScreen mainScreen].scale;
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        view;
    });
    
    self.menuWrapperView = ({
        UIView *view = [[UIView alloc] init];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        view.layer.shadowColor = self.shadowColor.CGColor;
        view.layer.shadowOffset = self.shadowOffset;
        view.layer.shadowOpacity = self.shadowOpacity;
        view.layer.shadowRadius = self.shadowRadius;
        view.layer.shouldRasterize = YES;
        view.layer.rasterizationScale = [UIScreen mainScreen].scale;
        view;
    });
    
    self.backgroundButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        button.accessibilityLabel = NSLocalizedString(@"Menu background", @"Menu background");
        button.accessibilityHint = NSLocalizedString(@"Double tap to close", @"Double tap to close");
        [button addTarget:self action:@selector(btnClickedClose) forControlEvents:UIControlEventTouchUpInside];
        button;
    });
    
    CGFloat navigationBarOffset = self.appearsBehindNavigationBar && self.navigationBar ? 64 : 0;
    
    // Append new item views to REMenuView
    //
    for (REMenuItem *item in self.items) {
        NSInteger index = [self.items indexOfObject:item];
        
        CGFloat itemHeight = self.itemHeight;
        if (index == self.items.count - 1)
            itemHeight += self.cornerRadius;
        
        
        UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                         index * self.itemHeight + index * self.separatorHeight + 40.0 + navigationBarOffset,
                                                                         rect.size.width,
                                                                         self.separatorHeight)];
        separatorView.backgroundColor = self.separatorColor;
        separatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.menuView addSubview:separatorView];
        
        REMenuItemView *itemView = [[REMenuItemView alloc] initWithFrame:CGRectMake(0,
                                                                                    index * self.itemHeight + (index + 1.0) * self.separatorHeight + 40.0 + navigationBarOffset,
                                                                                    rect.size.width,
                                                                                    itemHeight)
                                                                    menu:self
                                                             hasSubtitle:item.subtitle.length > 0];
        itemView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        itemView.item = item;
        item.itemView = itemView;
        itemView.separatorView = separatorView;
        itemView.autoresizesSubviews = YES;
        if (item.customView) {
            item.customView.frame = itemView.bounds;
            [itemView addSubview:item.customView];
        }
        
        if (index%2 == 0) {
            itemView.tag = kBackgroundColorTag;
            itemView.backgroundColor = kBackgroundColor;
        }else{
        
            itemView.backgroundColor = kBackgroundColor;
        }
        
        [self.menuView addSubview:itemView];
    }
    
    // Set up frames
    //
    self.menuWrapperView.frame = CGRectMake(0, -self.combinedHeight - navigationBarOffset, rect.size.width, self.combinedHeight + navigationBarOffset);
    self.menuView.frame = self.menuWrapperView.bounds;
    self.containerView.frame = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
    self.backgroundButton.frame = self.containerView.bounds;
    
    self.containerView.backgroundColor = kColor(0, 0, 0, 0.5);
    
    UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(0, self.menuView.frame.size.height-1, self.menuView.frame.size.width, 1)];
    line.backgroundColor =  kNavigation7Color;
    [self.menuView addSubview:line];
    
    // Add subviews
    //
    [self.menuWrapperView addSubview:self.menuView];
    [self.containerView addSubview:self.backgroundButton];
    [self.containerView addSubview:self.menuWrapperView];
    [view addSubview:self.containerView];
    
    // Animate appearance
    //
    [UIView animateWithDuration:self.animationDuration animations:^{
        self.backgroundView.alpha = 1.0;
        CGRect frame = self.menuView.frame;
        frame.origin.y = -40.0 - self.separatorHeight;
        self.menuWrapperView.frame = frame;
    } completion:nil];
}

- (void)showInView:(UIView *)view
{
    [self showFromRect:view.bounds inView:view];
}

- (void)showFromNavigationController:(UINavigationController *)navigationController
{
    self.navigationBar = navigationController.navigationBar;
    [self showFromRect:CGRectMake(0, 0, navigationController.navigationBar.frame.size.width, navigationController.view.frame.size.height) inView:navigationController.view];
    self.containerView.appearsBehindNavigationBar = self.appearsBehindNavigationBar;
    self.containerView.navigationBar = navigationController.navigationBar;
    if (self.appearsBehindNavigationBar) {
        [navigationController.view bringSubviewToFront:navigationController.navigationBar];
    }
}

- (void)closeWithCompletion:(void (^)(void))completion
{
    void (^closeMenu)(void) = ^{
        [UIView animateWithDuration:self.animationDuration animations:^{
            CGRect frame = self.menuView.frame;
            frame.origin.y = - self.combinedHeight;
            self.menuWrapperView.frame = frame;
            self.backgroundView.alpha = 0;
        } completion:^(BOOL finished) {
            [self.menuView removeFromSuperview];
            [self.menuWrapperView removeFromSuperview];
            [self.backgroundButton removeFromSuperview];
            [self.backgroundView removeFromSuperview];
            [self.containerView removeFromSuperview];
            self.isOpen = NO;
            if (completion)
                completion();
            
            if (self.closeCompletionHandler)
                self.closeCompletionHandler();
        }];
        
        if (self.appearsBehindNavigationBar) {
            [UIView animateWithDuration:self.animationDuration / 2.0 delay:self.animationDuration / 2.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.menuWrapperView.alpha = 0;
            } completion:nil];
        }
    };
    
    
    if (self.bounce) {
        [UIView animateWithDuration:self.bounceAnimationDuration animations:^{
            CGRect frame = self.menuView.frame;
            frame.origin.y = -20.0;
            self.menuWrapperView.frame = frame;
        } completion:^(BOOL finished) {
            closeMenu();
        }];
    } else {
        closeMenu();
    }
}

- (void)close
{

    [self closeWithCompletion:nil];
}
- (void)btnClickedClose{

    
    
    [self closeWithCompletion:^{
        
        if ([self.delegate respondsToSelector:@selector(viewDismissed)]) {
            [self.delegate viewDismissed];
        }
        
        
    }];

}
- (void)closeWithoutAnimation
{
    [self.menuView removeFromSuperview];
    [self.menuWrapperView removeFromSuperview];
    [self.backgroundButton removeFromSuperview];
    [self.backgroundView removeFromSuperview];
    [self.containerView removeFromSuperview];
    self.isOpen = NO;

    if (self.closeCompletionHandler)
        self.closeCompletionHandler();
        
    if (self.appearsBehindNavigationBar) {
        [UIView animateWithDuration:self.animationDuration / 2.0 delay:self.animationDuration / 2.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.menuWrapperView.alpha = 0;
        } completion:nil];
    }
}

- (CGFloat)combinedHeight
{
    return self.items.count * self.itemHeight + self.items.count  * self.separatorHeight + 40.0 + self.cornerRadius;
}

- (void)setNeedsLayout
{
    [UIView animateWithDuration:0.35 animations:^{
        [self.containerView layoutSubviews];
    }];
}

#pragma mark -
#pragma mark Setting style

- (UIImage *)separatorImage
{
    UIGraphicsBeginImageContext(CGSizeMake(1, 4.0));
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(context);
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:28/255.0 green:28/255.0 blue:27/255.0 alpha:1.0].CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, 1.0, 2.0));
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:79/255.0 green:79/255.0 blue:77/255.0 alpha:1.0].CGColor);
    CGContextFillRect(context, CGRectMake(0, 3.0, 1.0, 2.0));
    UIGraphicsPopContext();
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return [UIImage imageWithCGImage:outputImage.CGImage scale:2.0 orientation:UIImageOrientationUp];
}

@end
