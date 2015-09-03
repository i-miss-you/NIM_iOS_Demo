//
//  NTESCardMemberItem.m
//  NIM
//
//  Created by chris on 15/3/5.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NTESCardMemberItem.h"
#import "NTESContactsManager.h"
#import "NTESContactDataItem.h"
#import "NTESUsrInfoData.h"
#import "NTESSessionUtil.h"

@interface NTESTeamCardMemberItem()
@property (nonatomic,strong) NIMTeamMember *member;
@property (nonatomic,copy)   NSString      *userId;
@end;

@implementation NTESTeamCardMemberItem

- (instancetype)initWithMember:(NIMTeamMember*)member{
    self = [self init];
    if (self) {
        _member  = member;
        _userId  = member.userId;
    }
    return self;
}

- (BOOL)isEqual:(id)object{
    if (![object isKindOfClass:[NTESTeamCardMemberItem class]]) {
        return NO;
    }
    NTESTeamCardMemberItem *obj = (NTESTeamCardMemberItem*)object;
    return [obj.memberId isEqualToString:self.memberId];
}

- (NIMTeamMemberType)type {
    return _member.type;
}

- (void)setType:(NIMTeamMemberType)type {
    _member.type = type;
}

- (NSString *)title {
    NIMSession *session = [NIMSession session:self.member.teamId type:NIMSessionTypeTeam];
    return [NTESSessionUtil showNick:self.member.userId inSession:session];
}

- (NIMTeam *)team {
    return [[NIMSDK sharedSDK].teamManager teamById:_member.teamId];
}

#pragma mark - TeamCardHeaderData

- (UIImage*)imageNormal{
     NIMKitInfo *info = [[NIMKit sharedKit] infoByUser:self.member.userId];
    return info.avatarImage;
}

- (UIImage*)imageHighLight{
    NIMKitInfo *info = [[NIMKit sharedKit] infoByUser:self.member.userId];
    return info.avatarImage;
}

- (NSString*)memberId{
    return self.member.userId;
}

- (NTESCardHeaderOpeator)opera{
    return CardHeaderOpeatorNone;
}

@end



@interface NTESUserCardMemberItem()
@property (nonatomic,strong) ContactDataMember *member;
@end;

@implementation NTESUserCardMemberItem

- (instancetype)initWithMember:(ContactDataMember*)member{
    self = [self init];
    if (self) {
        _member = member;
    }
    return self;
}

- (BOOL)isEqual:(id)object{
    if (![object isKindOfClass:[NTESUserCardMemberItem class]]) {
        return NO;
    }
    NTESUserCardMemberItem *obj = (NTESUserCardMemberItem*)object;
    return [obj.memberId isEqualToString:self.memberId];
}

#pragma mark - TeamCardHeaderData

- (UIImage*)imageNormal{
    NSString *imageName = self.member.iconId;
    UIImage * image = [UIImage imageNamed:imageName];
    if (image) {
        return image;
    }else{
        return [UIImage imageNamed:@"DefaultAvatar"];
    }
}

- (UIImage*)imageHighLight{
    NSString *imageName = self.member.iconId;
    UIImage * image = [UIImage imageNamed:imageName];
    if (image) {
        return image;
    }else{
        return [UIImage imageNamed:@"DefaultAvatar"];
    }
}

- (NSString*)title{
    return self.member.nick.length ? self.member.nick : self.member.usrId;
}

- (NSString*)memberId{
    return self.member.usrId;
}

- (NTESCardHeaderOpeator)opera{
    return CardHeaderOpeatorNone;
}

@end
