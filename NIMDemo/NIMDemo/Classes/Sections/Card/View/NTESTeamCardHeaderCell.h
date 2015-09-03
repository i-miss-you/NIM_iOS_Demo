//
//  TeamCardHeaderCell.h
//  NIM
//
//  Created by chris on 15/3/7.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NTESCardDataSourceProtocol.h"
@class NTESAvatarImageView;
@protocol TeamCardHeaderCellDelegate;



@interface NTESTeamCardHeaderCell : UICollectionViewCell

@property (nonatomic,strong) NTESAvatarImageView *imageView;

@property (nonatomic,strong) UIImageView *roleImageView;

@property (nonatomic,strong) UILabel *titleLabel;

@property (nonatomic,strong) UIButton *removeBtn;

@property (nonatomic,weak) id<TeamCardHeaderCellDelegate>delegate;

@property (nonatomic,readonly) id<NTESCardHeaderData> data;

- (void)refreshData:(id<NTESCardHeaderData>)data;

@end


@protocol TeamCardHeaderCellDelegate <NSObject>

- (void)cellDidSelected:(NTESTeamCardHeaderCell*)cell;


@optional
- (void)cellShouldBeRemoved:(NTESTeamCardHeaderCell*)cell;

@end