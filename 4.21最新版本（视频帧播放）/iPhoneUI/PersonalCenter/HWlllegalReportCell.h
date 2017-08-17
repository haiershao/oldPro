//
//  HWlllegalReportCell.h
//  HuaWo
//
//  Created by yjc on 2017/4/24.
//  Copyright © 2017年 HW. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^Block)();

#import "HWlllegalReportModel.h"
@interface HWlllegalReportCell : UITableViewCell
@property (nonatomic,strong)HWlllegalReportModel *model;
@property (nonatomic, copy) Block deblock;
@end
