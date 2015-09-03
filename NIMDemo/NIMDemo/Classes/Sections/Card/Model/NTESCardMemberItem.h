//
//  NTESTeamCardMemberItem.h
//  NIM
//
//  Created by chris on 15/3/5.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NTESCardDataSourceProtocol.h"
#import "NTESContactDataItem.h"

@class NTESUsrInfo;

@interface NTESUserCardMemberItem : NSObject<NTESCardHeaderData>

- (instancetype)initWithMember:(ContactDataMember*)member;

@end

@interface NTESTeamCardMemberItem : NSObject<NTESCardHeaderData>

@property (nonatomic, assign) NIMTeamMemberType type;
@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, strong) NIMTeam *team;

- (instancetype)initWithMember:(NIMTeamMember*)member;

@end
