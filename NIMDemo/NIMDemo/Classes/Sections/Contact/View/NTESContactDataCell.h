//
//  NTESContactInfoCell.h
//  NIM
//
//  Created by chris on 15/2/26.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NTESContactDefines.h"

@protocol NTESContactDataCellDelegate <NSObject>

- (void)onPressUserAvatar:(NSString *)uid;

@end

@class NTESAvatarImageView;

@interface NTESContactDataCell : UITableViewCell<NTESContactCell>

@property (nonatomic,strong) NTESAvatarImageView * avatarImageView;

@property (nonatomic,strong) UIButton *accessoryBtn;

@property (nonatomic,weak) id<NTESContactDataCellDelegate> delegate;

@end
