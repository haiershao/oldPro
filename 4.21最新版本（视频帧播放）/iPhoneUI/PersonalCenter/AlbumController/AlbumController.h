//
//  AlbumController.h
//  HuaWo
//
//  Created by circlely on 1/25/16.
//  Copyright © 2016 circlely. All rights reserved.
//

#import <UIKit/UIKit.h>





@interface AlbumController : UIViewController

@property (assign, nonatomic) BOOL isSelected;
@property (assign, getter=isGetIconImage) BOOL getIconImage;
+(instancetype)albumController;//3.18 add --- by mj

@end
