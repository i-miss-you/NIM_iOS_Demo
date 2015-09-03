//
//  NTESUsrInfoData.h
//  NIM
//
//  Created by Xuhui on 15/3/19.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NTESService.h"
#import "NTESGroupedDataCollection.h"

@protocol NTESMemberInfoProtocol <NSObject>

@property (nonatomic, copy) NSString *usrId;
@property (nonatomic, copy) NSString *iconId;
@property (nonatomic, copy) NSString *nick;

@end

@interface NTESUsrInfo : NSObject <NTESMemberInfoProtocol, NTESGroupMemberProtocol>

@property (nonatomic, copy) NSString *usrId;
@property (nonatomic, copy) NSString *iconId;
@property (nonatomic, copy) NSString *nick;
@property (nonatomic, assign) BOOL isFriend;

@end

@interface NTESUsrInfoData : NTESService

- (NTESUsrInfo *)queryUsrInfoById:(NSString *)usrId needRemoteFetch:(BOOL)needFetch fetchCompleteHandler:(void(^)(NTESUsrInfo *info))handler;
- (NSArray *)queryUsrInfoByIds:(NSArray *)usrIds needRemoteFetch:(BOOL)needFetch fetchCompleteHandler:(void(^)(NSArray *infos))handler;

@end
