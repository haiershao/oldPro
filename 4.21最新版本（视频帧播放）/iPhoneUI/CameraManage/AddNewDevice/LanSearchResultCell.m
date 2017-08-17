//
//  LanSearchResultCell.m
//  AtHomeCam
//
//  Created by Ning on 6/8/15.
//  Copyright (c) 2015 ichano. All rights reserved.
//

#import "LanSearchResultCell.h"

@implementation LanSearchResultCell

- (void)awakeFromNib {
    // Initialization code
    
    
    self.addBtn.layer.masksToBounds = YES;
    self.addBtn.layer.cornerRadius = 6;
    
    [self.addBtn setTitle:NSLocalizedString(@"wlan_search_add_button", nil) forState:UIControlStateNormal];
    
    [self.addBtn addTarget:self action:@selector(addHighlight:) forControlEvents:UIControlEventTouchDown];
    [self.addBtn addTarget:self action:@selector(removeHighlight:) forControlEvents:UIControlEventTouchCancel | UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
}
- (void)addHighlight:(UIButton *)btn{
    
    //[btn setBackgroundColor:kColor(118, 118,118, 1)];
    
}
- (void)removeHighlight:(UIButton *)btn{
    
    
    //[btn performSelector:@selector(setBackgroundColor:) withObject:kColor(252,127,106, 1)  afterDelay:0.03];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)setTypeOfAVS:(AVSType)typeOfAVS{
    
//    switch (typeOfAVS) {
//        case WindowsAVS:
//        
//            self.avsImage.image = [UIImage imageNamed:@"avs_type_icon_windows_ipad.png"];
//        
//            break;
//        case iOSAVS:
//        
//            self.avsImage.image = [UIImage imageNamed:@"avs_type_icon_iphone_ipad.png"];
//            
//            break;
//        case MacAVS:
//            
//            self.avsImage.image = [UIImage imageNamed:@"avs_type_icon_mac_ipad.png"];
//            
//            break;
//        case AndroidPhoneAVS:
//            
//            self.avsImage.image = [UIImage imageNamed:@"avs_type_icon_android_phone_ipad.png"];
//            
//            break;
//        case AndroidTVAVS:
//            
//            self.avsImage.image = [UIImage imageNamed:@"avs_type_icon_android_phone_ipad"];
//            
//            break;
//        case IPCameraAVS:
//            
//            self.avsImage.image = [UIImage imageNamed:@"avs_type_icon_ipcam_ipad.png"];
//            
//            break;
//            
//        default:
//        
//            self.avsImage.image = [UIImage imageNamed:@"avs_type_icon_defaultt_ipad.png"];
//            
//            break;
//    }
    
}
- (void)dealloc {

}
- (IBAction)addBtnClicked:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(addAvs:)]) {
        [self.delegate addAvs:self.indexPath];
    }
    
    
}
@end
