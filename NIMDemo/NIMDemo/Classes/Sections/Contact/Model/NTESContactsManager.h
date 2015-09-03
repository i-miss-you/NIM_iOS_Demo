//
//  NTESContactsManager.h
//  NIM
//
//  Created by Xuhui on 15/3/7.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NTESService.h"
#import "NTESContactDataItem.h"


@interface NTESContactsManager : NTESService


@property (nonatomic, readonly, getter=isUpdating) BOOL updating;

- (NSArray *)allMyFriendsIds;

- (NSArray *)allMyFriends;

- (NSArray *)myBlackList;

- (void)queryContactByUsrId:(NSString *)usrId completion:(void (^) (ContactDataMember *member))completion;

- (ContactDataMember *)localContactByUsrId:(NSString *)usrId;

- (void)update;

//根据用户名关键字查找用户信息，返回uid列表
- (NSArray *)searchUsersByKeyword:(NSString *)keyword users:(NSArray *)users;

- (ContactDataMember *)me;

@end
