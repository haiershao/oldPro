//
//  CustomCollectionViewCell.h
//  HuaWo
//
//  Created by circlely on 3/16/16.
//  Copyright © 2016 circlely. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (strong, nonatomic) NSIndexPath *cellIndexPath;

@end
