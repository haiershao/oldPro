//
//  AlbumCameraItem.m
//  HuaWo
//
//  Created by circlely on 2/19/16.
//  Copyright © 2016 circlely. All rights reserved.
//

#import "AlbumCameraItem.h"

@implementation AlbumCameraItem

- (void)awakeFromNib {
    
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 4;
    //    self.selectImageView.hidden = YES;
    
    UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognizerAction:)];
    [self addGestureRecognizer:longPressGestureRecognizer];

}

- (void)longPressGestureRecognizerAction:(id)sender{
    
    if (_delegate) {
        
        [_delegate changeFileType:self];
    }
    
}


- (IBAction)playBtnPressed:(id)sender {
    
    if (_delegate) {
        
        [_delegate streamerVideoBtnClickedOnItem:self];
    }
}

- (IBAction)pictureBtnPressed:(id)sender {
    
    if (_delegate) {
        
        [_delegate streamerPictureBtnClickedOnItem:self];
    }
}

@end
