//
//  NTESTeamSwitchTableViewCell.m
//  NIM
//
//  Created by amao on 5/29/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "NTESTeamSwitchTableViewCell.h"

@implementation NTESTeamSwitchTableViewCell

- (IBAction)valueChanged:(id)sender {
    if (_switchDelegate && [_switchDelegate respondsToSelector:@selector(onStateChanged:)])
    {
        [_switchDelegate onStateChanged:_switcher.on];
    }
}

@end
