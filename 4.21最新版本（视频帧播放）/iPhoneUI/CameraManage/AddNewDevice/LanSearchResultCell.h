//
//  LanSearchResultCell.h
//  AtHomeCam
//
//  Created by Ning on 6/8/15.
//  Copyright (c) 2015 ichano. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LanSearchResultCellDelegate <NSObject>

@optional

- (void)addAvs:(NSIndexPath *)indexpath;

@end


@interface LanSearchResultCell : UITableViewCell


@property (nonatomic,assign) id<LanSearchResultCellDelegate>delegate;
@property (nonatomic,retain) NSIndexPath *indexPath;


@property (retain, nonatomic) IBOutlet UIImageView *avsImage;

@property (retain, nonatomic) IBOutlet UILabel *avsName;

@property (retain, nonatomic) IBOutlet UILabel *avsCid;

@property (retain, nonatomic) IBOutlet UIButton *addBtn;

@property (nonatomic, assign) AVSType typeOfAVS;

- (IBAction)addBtnClicked:(id)sender;



@end
