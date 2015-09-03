//
//  NTESContactInfoCell.m
//  NIM
//
//  Created by chris on 15/2/26.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NTESContactDataCell.h"
#import "NTESAvatarImageView.h"
#import "UIView+NTES.h"


@interface NTESContactDataCell()

@property (nonatomic,copy) NSString *userId;

@end

@implementation NTESContactDataCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _avatarImageView = [NTESAvatarImageView demoInstanceContactDataList];
        [_avatarImageView addTarget:self action:@selector(onPressUserAvatar:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_avatarImageView];
        _accessoryBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_accessoryBtn setImage:[UIImage imageNamed:@"icon_accessory_normal"] forState:UIControlStateNormal];
        [_accessoryBtn setImage:[UIImage imageNamed:@"icon_accessory_pressed"] forState:UIControlStateHighlighted];
        [_accessoryBtn setImage:[UIImage imageNamed:@"icon_accessory_selected"] forState:UIControlStateSelected];
        [_accessoryBtn sizeToFit];
        _accessoryBtn.hidden = YES;
        _accessoryBtn.userInteractionEnabled = NO;
        [self addSubview:_accessoryBtn];
    }
    return self;
}

- (void)refreshWithContactItem:(id<NTESContactItem>)item{
    self.textLabel.text = item.nick;
    [self.textLabel sizeToFit];
    self.userId = [item usrId];
    NSString *avatar = [item iconId] ? : @"DefaultAvatar";
    _avatarImageView.image = [UIImage imageNamed:avatar];
}


- (void)onPressUserAvatar:(id)sender{
    if ([self.delegate respondsToSelector:@selector(onPressUserAvatar:)]) {
        [self.delegate onPressUserAvatar:self.userId];
    }
}

- (void)addDelegate:(id)delegate{
    self.delegate = delegate;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    [self.accessoryBtn setHighlighted:highlighted];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated{

}


- (void)layoutSubviews{
    [super layoutSubviews];
    self.accessoryBtn.left = NTESContactAccessoryLeft;
    self.accessoryBtn.centerY = self.height * .5f;
    self.avatarImageView.left = self.accessoryBtn.hidden ? NTESContactAvatarLeft : NTESContactAvatarAndAccessorySpacing + self.accessoryBtn.right;
    self.avatarImageView.centerY = self.height * .5f;
    self.textLabel.left = self.avatarImageView.right + NTESContactAvatarAndTitleSpacing;
}

@end
