//
//  AlbumItem.m
//  HuaWo
//
//  Created by circlely on 2/3/16.
//  Copyright © 2016 circlely. All rights reserved.
//

#import "AlbumItem.h"


@implementation AlbumItem

- (void)awakeFromNib {
    
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 4;
    
    UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognizerAction:)];
    [self addGestureRecognizer:longPressGestureRecognizer];
    
    
}

- (void)longPressGestureRecognizerAction:(id)sender{

    
    
    
    if (_delegate) {
        
        [_delegate changeFileType:self];
    }
}


- (void)dealloc {
    
    
}
- (IBAction)playBtnPressed:(id)sender {
    
    
    
    if (_delegate) {
        
        [_delegate videoBtnClickedOnItem:self];
        [_delegate streamerVideoBtnClickedOnItem:self];
    }
    
    
    
}

- (IBAction)showPictureBtnPressed:(id)sender {
    
    if (_delegate) {
        
        [_delegate showPictureBtnClickedOnItem:self];
        [_delegate streamerPictureBtnClickedOnItem:self];
    }
}




@end
