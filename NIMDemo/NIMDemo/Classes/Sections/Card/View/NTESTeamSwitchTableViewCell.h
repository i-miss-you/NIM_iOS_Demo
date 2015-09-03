//
//  NTESTeamSwitchTableViewCell.h
//  NIM
//
//  Created by amao on 5/29/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NTESTeamSwitchProtocol <NSObject>
- (void)onStateChanged:(BOOL)on;
@end

@interface NTESTeamSwitchTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *switchLabel;
@property (weak, nonatomic) IBOutlet UISwitch *switcher;
@property (weak, nonatomic) id<NTESTeamSwitchProtocol> switchDelegate;

@end
