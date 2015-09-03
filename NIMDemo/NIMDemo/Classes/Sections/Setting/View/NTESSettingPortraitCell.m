//
//  NTESSettingPortraitCell.m
//  NIM
//
//  Created by chris on 15/6/26.
//  Copyright © 2015年 Netease. All rights reserved.
//

#import "NTESSettingPortraitCell.h"
#import "NTESCommonTableData.h"
#import "NTESAvatarImageView.h"
#import "NTESContactDataItem.h"
#import "UIView+NTES.h"
#import "NTESSessionUtil.h"
@interface NTESSettingPortraitCell()

@property (nonatomic,strong) NTESAvatarImageView *avatar;

@property (nonatomic,strong) UILabel *nameLabel;

@property (nonatomic,strong) UILabel *accountLabel;

@end

@implementation NTESSettingPortraitCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _avatar = [NTESAvatarImageView demoInstanceTeamCardHeader];
        [self addSubview:_avatar];
        _nameLabel      = [[UILabel alloc] initWithFrame:CGRectZero];
        _nameLabel.font = [UIFont systemFontOfSize:18.f];
        [self addSubview:_nameLabel];
        _accountLabel   = [[UILabel alloc] initWithFrame:CGRectZero];
        _accountLabel.font = [UIFont systemFontOfSize:14.f];
        _accountLabel.textColor = [UIColor grayColor];
        [self addSubview:_accountLabel];
    }
    return self;
}

- (void)refreshData:(NTESCommonTableRow *)rowData tableView:(UITableView *)tableView{
    self.textLabel.text       = rowData.title;
    self.detailTextLabel.text = rowData.detailTitle;
    ContactDataMember *member = rowData.extraInfo;
    NSString *imageName;
    if ([member isKindOfClass:[ContactDataMember class]]) {
       imageName = member.iconId;
       self.nameLabel.text   = [NTESSessionUtil showNick:member.usrId inSession:nil] ;
       [self.nameLabel sizeToFit];
       self.accountLabel.text = [NSString stringWithFormat:@"帐号：%@",member.usrId];
       [self.accountLabel sizeToFit];
    }
    UIImage * image = [UIImage imageNamed:imageName];
    if (image) {
        self.avatar.image = image;
    }else{
        self.avatar.image = [UIImage imageNamed:@"DefaultAvatar"];
    }
}


#define AvatarLeft 30
#define TitleAndAvatarSpacing 12
#define TitleTop 22
#define AccountBottom 22

- (void)layoutSubviews{
    [super layoutSubviews];
    self.avatar.left    = AvatarLeft;
    self.avatar.centerY = self.height * .5f;
    self.nameLabel.left = self.avatar.right + TitleAndAvatarSpacing;
    self.nameLabel.top  = TitleTop;
    self.accountLabel.left    = self.nameLabel.left;
    self.accountLabel.bottom  = self.height - AccountBottom;
}




@end
