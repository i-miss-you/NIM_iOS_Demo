//
//  TeamCardHeaderCell.m
//  NIM
//
//  Created by chris on 15/3/7.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NTESTeamCardHeaderCell.h"
#import "NTESAvatarImageView.h"
#import "UIView+NTES.h"
#import "NTESCardMemberItem.h"

@interface NTESTeamCardHeaderCell()

@property (nonatomic,strong) id<NTESCardHeaderData> data;

@end

@implementation NTESTeamCardHeaderCell

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _imageView                  = [NTESAvatarImageView demoInstanceTeamCardHeader];
        [self addSubview:_imageView];
        _titleLabel                 = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.font            = [UIFont systemFontOfSize:13.f];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textAlignment   = NSTextAlignmentCenter;
        [self addSubview:_titleLabel];
        _roleImageView              = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:_roleImageView];
        _removeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _removeBtn.hidden = YES;
        [_removeBtn setImage:[UIImage imageNamed:@"icon_avatar_del"] forState:UIControlStateNormal];
        [_removeBtn sizeToFit];
        [_removeBtn addTarget:self action:@selector(onTouchRemoveBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_removeBtn];
    }
    return self;
}

- (void)refreshData:(id<NTESCardHeaderData>)data{
    self.data = data;
    self.imageView.image = data.imageNormal;
    self.imageView.hilghtedImage = data.imageHighLight;
    [self.imageView addTarget:self action:@selector(onSelected:) forControlEvents:UIControlEventTouchUpInside];
    self.titleLabel.text = data.title;
    if([data isKindOfClass:[NTESTeamCardMemberItem class]]) {
        NTESTeamCardMemberItem *member = data;
        self.titleLabel.text = member.title.length ? member.title : member.memberId;
        switch (member.type) {
            case NIMTeamMemberTypeOwner:
                self.roleImageView.image = [UIImage imageNamed:@"icon_team_creator"];
                break;
            case NIMTeamMemberTypeManager:
                self.roleImageView.image = [UIImage imageNamed:@"icon_team_manager"];
                break;
            default:
                self.roleImageView.image = nil;
                break;
        }
    }else{
        self.roleImageView.image = nil;
    }
    [self.titleLabel sizeToFit];
}

- (void)onSelected:(id)sender{
    if ([self.delegate respondsToSelector:@selector(cellDidSelected:)]) {
        [self.delegate cellDidSelected:self];
    }
}

- (void)onTouchRemoveBtn:(id)sender{
    if ([self.delegate respondsToSelector:@selector(cellShouldBeRemoved:)]) {
        [self.delegate cellShouldBeRemoved:self];
    }
}


- (void)layoutSubviews{
    [super layoutSubviews];
    self.imageView.centerX = self.width * .5f;
    self.titleLabel.width = self.width;
    self.titleLabel.bottom = self.height;
    [self.roleImageView sizeToFit];
    self.roleImageView.bottom = self.imageView.bottom;
    self.roleImageView.right  = self.imageView.right;
    self.removeBtn.right = self.width;
    
}

@end
