//
//  UsrInfoData.m
//  NIM
//
//  Created by Xuhui on 15/3/19.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NTESUsrInfoData.h"
#import "NTESHttpRequest.h"
#import "NTESSessionUtil.h"
#import "NTESContactsManager.h"
#import "NSString+NTES.h"
#import "NTESGroupedDataCollection.h"
#import "NTESSpellingCenter.h"
#import "NTESDemoConfig.h"

#define kUsrInfoKeyId @"kUsrInfoKeyId"
#define kUsrInfoKeyNick @"kUsrInfoKeyNick"
#define kUsrInfoKeyIconUrl @"kUsrInfoKeyIconUrl"

@implementation NTESUsrInfo

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if(self) {
        _usrId = [aDecoder decodeObjectForKey:kUsrInfoKeyId];
        _nick = [aDecoder decodeObjectForKey:kUsrInfoKeyNick];
        _iconId = [aDecoder decodeObjectForKey:kUsrInfoKeyIconUrl];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_usrId forKey:kUsrInfoKeyId];
    [aCoder encodeObject:_nick forKey:kUsrInfoKeyNick];
    [aCoder encodeObject:_iconId forKey:kUsrInfoKeyIconUrl];
}

- (BOOL)isFriend {
    NSArray *friends = [NIMSDK sharedSDK].userManager.myFriends;
    for (NIMUser *user in friends) {
        if ([user.userId isEqualToString:self.usrId]) {
            return YES;
        }
    }
    return NO;
}

- (NSString *)groupTitle {
    NSString *title = [[NTESSpellingCenter sharedCenter] firstLetter:self.nick].capitalizedString;
    unichar character = [title characterAtIndex:0];
    if (character >= 'A' && character <= 'Z') {
        return title;
    }else{
        return @"#";
    }
}

- (NSString *)memberId{
    return self.usrId;
}

- (id)sortKey {
    return [[NTESSpellingCenter sharedCenter] spellingForString:self.nick].shortSpelling;
}

@end

@interface NTESUsrInfoData () {
    NSString *_cachePath;
}

@property (nonatomic, strong) NSMutableDictionary *infoDict;

@end

@implementation NTESUsrInfoData

- (instancetype)init {
    self = [super init];
    if(self) {
        NSArray *dirs = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        _cachePath = [NSString stringWithFormat:@"%@/usrinfo_cache_%@", [dirs objectAtIndex:0], [[[[NIMSDK sharedSDK] loginManager] currentAccount] MD5String]];
        _infoDict = [NSKeyedUnarchiver unarchiveObjectWithFile:_cachePath];
    }
    return self;
}

- (NSMutableDictionary *)infoDict {
    if(!_infoDict) {
        _infoDict = [NSMutableDictionary dictionary];
    }
    return _infoDict;
}

- (NSArray *)queryUsrInfoByIds:(NSArray *)usrIds needRemoteFetch:(BOOL)needFetch fetchCompleteHandler:(void (^)(NSArray *))handler {
    NSMutableArray *infos = [NSMutableArray array];
    for (NSString *uid in usrIds) {
        NTESUsrInfo *info = nil;
        ContactDataMember *contact = [[NTESContactsManager sharedInstance] localContactByUsrId:uid];
        if(contact) {
            info = [[NTESUsrInfo alloc] init];
            info.usrId = contact.usrId;
            info.nick = contact.nick;
            info.iconId = contact.iconId;
        } else {
            info = [self.infoDict objectForKey:uid];
        }
        if(info) {
            [infos addObject:info];
        }
    }
    if(needFetch) {
        [self updateUsrInfoByIds:usrIds completion:^(NSArray *tmp) {
            if(handler) {
                handler(tmp);
            }
        }];
    }
    return infos.count ? infos : nil;
}

- (NTESUsrInfo *)queryUsrInfoById:(NSString *)usrId needRemoteFetch:(BOOL)needFetch fetchCompleteHandler:(void (^)(NTESUsrInfo *))handler {
    if(usrId.length <= 0) return nil;
    NSArray *infos = [self queryUsrInfoByIds:@[usrId] needRemoteFetch:needFetch fetchCompleteHandler:^(NSArray *infos) {
        if(handler) {
            handler([infos firstObject]);
        }
    }];
    return infos.firstObject;
}

- (void)updateUsrInfo:(NTESUsrInfo *)info {
    [self.infoDict setObject:info forKey:info.usrId];
}

- (void)updateUsrInfoByIds:(NSArray *)usrIds completion:(void (^)(NSArray *))handler {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [[NTESDemoConfig sharedConfig] apiURL], @"getUserInfo"]];
    NTESHttpRequest *request = [NTESHttpRequest requestWithURL:url];
    NSMutableArray *tmp = [NSMutableArray array];
    for (NSString *uid in usrIds) {
        [tmp addObject:@{@"uid": uid}];
    }
    NSData *data = [NSJSONSerialization dataWithJSONObject:tmp options:0 error:0];
    [request setPostJsonData:data];
    [request startAsyncWithComplete:^(NSInteger responseCode, NSDictionary *responseData) {
        NSMutableArray *infos = nil;
        if(responseCode == kNIMHttpRequestCodeSuccess && responseData) {
            NSArray *tmp = [responseData objectForKey:@"list"];
            infos = [NSMutableArray array];
            for (NSDictionary *dict in tmp) {
                NTESUsrInfo *info = [[NTESUsrInfo alloc] init];
                info.usrId = [dict objectForKey:@"uid"] ? : @"";
                info.nick = [dict objectForKey:@"name"] ? : @"";
                info.iconId = [dict objectForKey:@"icon"] ? : @"";
                [infos addObject:info];
            }
        }
        if(handler) {
            handler(infos.count ? infos : nil);
        }
        for (NTESUsrInfo *info in infos) {
            [self updateUsrInfo:info];
        }
    }];

}

- (void)onCleanData {
    if(_infoDict.count <= 0) return;
    dispatch_async(dispatch_get_global_queue(0, 0), ^(){
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_infoDict];
        [data writeToFile:_cachePath atomically:YES];
    });
}

@end
