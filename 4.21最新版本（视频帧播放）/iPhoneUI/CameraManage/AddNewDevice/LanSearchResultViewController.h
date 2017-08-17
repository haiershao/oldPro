//
//  LanSearchResultViewController.h
//  AtHomeCam
//
//  Created by Circlely Networks on 4/12/13.
//
//

#import <UIKit/UIKit.h>

@interface LanSearchResultViewController : UIViewController<UITextFieldDelegate>


@property (retain, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, retain) NSMutableArray *dataArr;

@end
