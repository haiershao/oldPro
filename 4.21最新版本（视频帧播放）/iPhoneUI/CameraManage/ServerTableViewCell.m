//
//  ServerTableViewCell.m
//  HuaWo
//
//  Created by circlely on 1/21/16.
//  Copyright © 2016 circlely. All rights reserved.
//

#import "ServerTableViewCell.h"
#import "AHCServerCommunicator.h"


@interface ServerTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *avsStatusImageView;
@property (weak, nonatomic) IBOutlet UIButton *editButton;


@end

@implementation ServerTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)editMode:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(expandMoreMessage:)])
    {        
        [self.delegate expandMoreMessage:self.cid];
    }

}

-(void)setIsOnline:(int)isOnline
{
    int subStatus = isOnline&0x0FFFF;
    self.editButton.enabled = YES;
    //cFLAG	如果显示avsapp不支持，则直接提示不支持，否则根据substatus显示
    
    
        
        switch (subStatus) {
            case PEER_STATUS_STATE_OFFLINE:
            {
                self.avsStatusImageView.image = [UIImage imageNamed:@"avs_status_gray"];
                self.avsStatusLabel.text = NSLocalizedString(@"member_cid_status_isoffline", nil);
            }
                break;
            case PEER_STATUS_STATE_ONLINE:
            {
                self.avsStatusImageView.image = [UIImage imageNamed:@"avs_status_light"];
                self.avsStatusLabel.text = NSLocalizedString(@"member_cid_status_isonline", nil);
            }
                break;
            case PEER_STATUS_STATE_ERRUSERPWD:
            {
                self.avsStatusImageView.image = [UIImage imageNamed:@"avs_status_warning"];
                self.avsStatusLabel.text = NSLocalizedString(@"member_cid_status_wrong_password", nil);
                //如果用户名密码错误，移除button的点击响应
                //self.editButton.enabled = NO;
            }
                break;
            case PEER_STATUS_STATE_UNKNOWN:
            {
                self.avsStatusImageView.image = [UIImage imageNamed:@"avs_status_gray"];
                self.avsStatusLabel.text = NSLocalizedString(@"member_cid_no_status", nil);
            }
                break;
            default:
            {
                self.avsStatusImageView.image = [UIImage imageNamed:@"avs_status_gray"];
                self.avsStatusLabel.text = NSLocalizedString(@"member_cid_no_status", nil);
            }
                break;
        }
    
    
    self->_isOnline = isOnline;
}


@end
