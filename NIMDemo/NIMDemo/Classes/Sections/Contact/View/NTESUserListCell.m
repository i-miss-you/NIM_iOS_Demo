//
//  NTESUserListCell.m
//  NIM
//
//  Created by chris on 15/8/18.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NTESUserListCell.h"
#import "NTESAvatarImageView.h"
#import "NTESContactDataItem.h"
#import "UIView+NTES.h"

@interface NTESUserListCell()

@property (nonatomic,strong) ContactDataMember *member;

@property (nonatomic,strong) UIView *sep;

@end

@implementation NTESUserListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _avatarImageView = [NTESAvatarImageView demoInstanceUserList];
        [_avatarImageView addTarget:self action:@selector(onTouchAvatar:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_avatarImageView];
        _sep = [[UIView alloc] initWithFrame:CGRectZero];
        _sep.backgroundColor = [UIColor lightGrayColor];
        _sep.height = .5f;
        [self addSubview:_sep];
    }
    return self;
}


- (void)refreshWithMember:(ContactDataMember *)member{
    self.member = member;
    self.textLabel.text = member.nick.length ? member.nick : member.usrId;
    [self.textLabel sizeToFit];
    NSString *avatar = [member iconId] ? : @"DefaultAvatar";
    _avatarImageView.image = [UIImage imageNamed:avatar];
}


- (void)onTouchAvatar:(id)sender{
    if ([self.delegate respondsToSelector:@selector(didTouchUserListAvatar:)]) {
        [self.delegate didTouchUserListAvatar:self.member.usrId];
    }
}


- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
    
}


- (void)layoutSubviews{
    [super layoutSubviews];
    CGFloat avatarLeft = 15.f;
    self.avatarImageView.left = avatarLeft;
    self.avatarImageView.centerY = self.height * .5f;
    self.textLabel.left = self.avatarImageView.right + NTESContactAvatarAndTitleSpacing;
    self.sep.width = self.width - avatarLeft - self.avatarImageView.width - NTESContactAvatarAndTitleSpacing;
    self.sep.left = avatarLeft + NTESContactAccessoryLeft + self.avatarImageView.width;
    self.sep.bottom = self.height - self.sep.height;
}

@end
