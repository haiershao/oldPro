//
//  SYSlideSelectedView.h
//  SYSlideDemo
//
//  Created by yjc on 16/6/19.
//  Copyright © 2016年 tsy. All rights reserved.
//

#import "SYSlideSelectedView.h"

@interface SYSlideSelectedView ()
@property (nonatomic, strong) UIView *line;
@property (nonatomic, strong) UIColor *selectedColor;
@property (nonatomic, strong) UIColor *normalColor;
@property (nonatomic, assign) NSInteger selectedTag;
@end

@implementation SYSlideSelectedView

- (instancetype)initWithTitles:(NSArray *)titles frame:(CGRect)frame normalColor:(UIColor *)normalColor andSelectedColor:(UIColor *)selectedColor {
    if (self = [super initWithFrame:frame]) {
        _titles = titles;
        _selectedColor = selectedColor;
        _normalColor = normalColor;
        self.backgroundColor = [UIColor clearColor];
        [self setUpUI];
    }
    return self;
}

- (void)setUpUI {
    
    for (int i = 0; i< self.titles.count; i++) {
        NSString *title = self.titles[i];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:title forState:UIControlStateNormal];
        [btn setTitleColor:self.normalColor forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:15];
        btn.tag = i+100;
        [btn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        CGFloat w = self.bounds.size.width/self.titles.count;
        btn.frame = CGRectMake(i*w, 0, w, self.bounds.size.height);
        
        if (i == 0) {
            [btn setTitleColor:self.selectedColor forState:UIControlStateNormal];
            self.selectedTag = btn.tag;
        }

        [self addSubview:btn];
    }
    
    [self addSubview:self.line];
}

- (void)buttonClick:(UIButton *)sender {
    
    if (sender.tag == self.selectedTag) {
        return;
    }else {
        UIButton *lastBtn = [self viewWithTag:self.selectedTag];
        [self exchangeStatusWithButton:sender andButton:lastBtn];
        self.selectedTag = sender.tag;
        if (self.buttonAciton) {
            self.buttonAciton(sender.tag-100);
        }
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        self.line.transform = CGAffineTransformMakeTranslation(sender.frame.origin.x, 0);
    }];
}

- (void)exchangeStatusWithButton:(UIButton *)sender1 andButton:(UIButton *)sender2 {
    [sender1 setTitleColor:self.selectedColor forState:UIControlStateNormal];
    [sender2 setTitleColor:self.normalColor forState:UIControlStateNormal];
}

- (void)changeTitle:(NSString *)title atIndex:(NSInteger)index {
    UIButton *btn = [self viewWithTag:index + 100];
    if (btn) {
        [btn setTitle:title forState:UIControlStateNormal];
    }
}

- (UIView *)line {
    if (_line == nil) {
        CGFloat w = self.bounds.size.width/self.titles.count;
        CGFloat y = self.bounds.size.height - 2;
        _line = [[UIView alloc] initWithFrame:CGRectMake((self.bounds.size.width/self.titles.count - w)*0.5, y, w, 2)];
        _line.backgroundColor = self.selectedColor;
    }
    return _line;
}

- (NSInteger)selectedIndex {
    return self.selectedTag - 100;
}

- (CGFloat)lineWidthWithTitle:(NSString *)title {
    return [title sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]}].width;
}

@end
