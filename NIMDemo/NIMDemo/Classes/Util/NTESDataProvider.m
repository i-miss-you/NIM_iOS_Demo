//
//  NTESUserDataProvider.m
//  NIM
//
//  Created by amao on 8/13/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "NTESDataProvider.h"
#import "NTESContactsManager.h"

@implementation NTESDataProvider

- (NIMKitInfo *)infoByUser:(NSString *)userId{
    ContactDataMember *member = [[NTESContactsManager sharedInstance] localContactByUsrId:userId];
    if (member) {
        //如果本地有数据则直接返回
        NIMKitInfo *info = [[NIMKitInfo alloc] init];
        info.showName    = member.nick;
        info.avatarImage = [UIImage imageNamed:member.iconId];
        info.avatarImage = info.avatarImage?: [UIImage imageNamed:@"DefaultAvatar"];
        return info;
    }else{
        //如果本地没有数据则去自己的应用服务器请求数据
        [[NTESContactsManager sharedInstance] queryContactByUsrId:userId completion:^(ContactDataMember *member) {
            if (member) {
                //请求成功后调用通知接口刷新
                [[NIMKit sharedKit] notfiyUserInfoChanged:member.usrId];
            }
        }];
        //先返回一个默认数据,以供网络请求没回来的时候界面可以有东西展示
        NIMKitInfo *info = [[NIMKitInfo alloc] init];
        info.showName    = userId; //本地没有昵称，拿userId代替
        info.avatarImage = [UIImage imageNamed:@"DefaultAvatar"]; //默认占位头像
        return info;
    }
}

- (NIMKitInfo *)infoByTeam:(NSString *)teamId{
    NIMTeam *team    = [[NIMSDK sharedSDK].teamManager teamById:teamId];
    NIMKitInfo *info = [[NIMKitInfo alloc] init];
    info.showName    = team.teamName;
    info.avatarImage = [UIImage imageNamed:@"avatar_team"];
    return info;
}



@end
