//
//  ContactsData.m
//  NIM
//
//  Created by Xuhui on 15/3/7.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NTESContactsManager.h"
#import "NTESHttpRequest.h"
#import "NTESContactDataItem.h"
#import "NTESSessionUtil.h"
#import "NSString+NTES.h"
#import "NTESDemoConfig.h"
#import "NTESFileLocationHelper.h"
#import "NTESAppTokenManager.h"

@interface NTESContactsManager ()
{
    NSString *_cachePath;
    NSMutableDictionary *_contactDict;
}

@property (nonatomic,strong) NSMutableDictionary *requestPool;   // { uid , array<block> }

@end

@implementation NTESContactsManager

- (instancetype)init {
    self = [super init];
    if(self) {
        _cachePath = [[NTESFileLocationHelper userDirectory] stringByAppendingPathComponent:@"nim_demo_contact_cache"];
        _contactDict = [NSMutableDictionary dictionary];
        NSDictionary *dict = [NSKeyedUnarchiver unarchiveObjectWithFile:_cachePath];
        [self saveDictionaryToUsers:dict];
        _requestPool = [[NSMutableDictionary alloc] init];
    }
    return self;
}

#pragma mark - 查询用户
- (void)queryContactByUsrId:(NSString *)usrId completion:(void (^) (ContactDataMember *member))completion{
    if (!usrId.length) {
        dispatch_async_main_safe(^{completion(nil);});
        return;
    }
    ContactDataMember *member = [_contactDict objectForKey:usrId];
    if (member)
    {
        dispatch_async_main_safe(^{
            completion(member);
        });
    }
    else
    {
        NSMutableArray *blocks = self.requestPool[usrId];
        if (!blocks) {
            blocks = [[NSMutableArray alloc] init];
            self.requestPool[usrId] = blocks;
        }
        if (completion) {
            [blocks addObject:completion];
        }
        [self check];
    }
}

- (void)check{
    if (self.isUpdating || ![NTESAppTokenManager sharedManager].appToken) {
        return;
    }
    NSArray *uids = self.requestPool.allKeys;
    if (!uids.count) {
        [self setUpdating:NO];
        return;
    }
    [self setUpdating:YES];
    [self remoteFetchUsers:uids completion:^(NSArray *members) {
        for (NSString *uid in uids) {
            ContactDataMember *member;
            for (ContactDataMember *item in members) {
                if ([item.usrId isEqualToString:uid]) {
                    member = item;
                    break;
                }
            }
            NSArray *blocks = self.requestPool[uid];
            for (void (^block) (ContactDataMember *) in blocks) {
                dispatch_async_main_safe(^{block(member);});
            }
            [self.requestPool removeObjectForKey:uid];
        }
        _updating = NO;
        [self check];
    }];
}

- (ContactDataMember *)localContactByUsrId:(NSString *)usrId{
    return [_contactDict objectForKey:usrId];
}


- (NSArray *)searchUsersByKeyword:(NSString *)keyword users:(NSArray *)users{
    NSMutableArray *data = [[NSMutableArray alloc] init];
    for (NSString *uid in users) {
        ContactDataMember *member = [_contactDict objectForKey:uid];
        [data addObject:member];
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"SELF.nick CONTAINS[cd] %@",keyword];
    NSArray *array = [data filteredArrayUsingPredicate:predicate];
    NSMutableArray *output = [[NSMutableArray alloc] init];
    for (ContactDataMember *member in array) {
        [output addObject:member.usrId];
    }
    return output;
}

- (void)setUpdating:(BOOL)updating {
    _updating = updating;
    if(!_updating) {
        [[NIMKit sharedKit] notfiyUserInfoChanged:nil];
    }
}

- (void)update {
    if(![self isUpdating]) {
        NSArray *friends = [NIMSDK sharedSDK].userManager.myFriends;
        NSMutableDictionary *ids = [[NSMutableDictionary alloc] init];
        for (NIMUser *user in friends) {
            [ids setObject:[NSNull null] forKey:user.userId];
        }
        NSArray *blackList = [NIMSDK sharedSDK].userManager.myBlackList;
        for (NIMUser *user in blackList) {
            [ids setObject:[NSNull null] forKey:user.userId];
        }
        NSString *account = [[NIMSDK sharedSDK].loginManager currentAccount];
        [ids setObject:[NSNull null] forKey:account];
        [self remoteFetchUsers:ids.allKeys completion:^(NSArray *members) {
            _updating = NO;
            [self check];//看看有没有单独id扔进来的
        }];
    }
}


- (void)remoteFetchUsers:(NSArray *)uids completion:(void (^)(NSArray *members))completion{
    if (!uids.count) {
        dispatch_async_main_safe(^{completion(nil);});
        return;
    }
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [[NTESDemoConfig sharedConfig] apiURL], @"getUserInfo"]];
    NTESHttpRequest *request = [NTESHttpRequest requestWithURL:url];
    NSMutableArray *tmp = [NSMutableArray array];
    for (NSString *uid in uids) {
        [tmp addObject:@{@"uid": uid}];
    }
    NSData *data = [NSJSONSerialization dataWithJSONObject:tmp options:0 error:0];
    [request setPostJsonData:data];
    [request startAsyncWithComplete:^(NSInteger responseCode, NSDictionary *responseData) {
        NSArray *members = nil;
        if(responseCode == kNIMHttpRequestCodeSuccess && responseData) {
            members = [self saveDictionaryToUsers:responseData];
        }
        if(completion) {
            dispatch_async_main_safe(^{completion(members);});
        }
    }];
}

- (ContactDataMember *)me
{
    NSString *account = [[[NIMSDK sharedSDK] loginManager] currentAccount];
    ContactDataMember *member = [_contactDict objectForKey:account];
    return member;
}


- (NSArray *)saveDictionaryToUsers:(NSDictionary *)dict
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (NSDictionary *item in [dict objectForKey:@"list"]){
        
        NSString *uid = [item objectForKey:@"uid"];
        NSString *name = [item objectForKey:@"name"];
        NSString *icon = [item objectForKey:@"icon"];
        ContactDataMember *member = [[ContactDataMember alloc] init];
        member.usrId = uid;
        member.nick = name;
        member.iconId = icon;
        [_contactDict setObject:member forKey:uid];
        [array addObject:member];
    }
    return array;
}


- (NSDictionary *)usersToSaveDictionary:(NSArray *)users{
    NSMutableArray *list = [[NSMutableArray alloc] init];
    for (ContactDataMember *member in users) {
        NSString *uid  = member.usrId.length ? member.usrId : @"";
        NSString *name = member.nick.length ? member.nick : @"";
        NSString *icon = member.iconId.length ? member.iconId : @"";
        NSDictionary *dict = @{@"uid":uid,@"name":name,@"icon":icon};
        [list addObject:dict];
    }
    return @{@"list":list};
}

- (ContactDataMember *)memberByUser:(NIMUser *)user
{
    ContactDataMember *member = nil;
    NSString *userId = user.userId;
    if (userId) {
        member = [_contactDict objectForKey:userId];
    }
    if (member == nil) {
        member = [[ContactDataMember alloc] init];
        member.usrId = userId;
    }
    return member;
}


#pragma mark - 获取好友
- (NSArray *)allMyFriends {
    NSArray *friends = [[[NIMSDK sharedSDK] userManager] myFriends];
    NSMutableArray *results = [NSMutableArray array];
    for (NIMUser *user in friends) {
        if ([[NIMSDK sharedSDK].userManager isUserInBlackList:user.userId]) {
            continue;
        }
        ContactDataMember *info = [self memberByUser:user];
        [results addObject:info];
    }
    return results;
}

- (NSArray *)myBlackList{
    NSArray *list = [[[NIMSDK sharedSDK] userManager] myBlackList];
    NSMutableArray *results = [NSMutableArray array];
    for (NIMUser *user in list) {
        ContactDataMember *info = [self memberByUser:user];
        [results addObject:info];
    }
    return results;
}

- (NSArray*)allMyFriendsIds{
    NSArray *friends = [[[NIMSDK sharedSDK] userManager] myFriends];
    NSMutableArray *results = [NSMutableArray array];
    for (NIMUser *user in friends) {
        if ([[NIMSDK sharedSDK].userManager isUserInBlackList:user.userId]) {
            continue;
        }
        [results addObject:user.userId];
    }
    return results;
    
}



#pragma mark - Private
- (void)onEnterBackground{
    [self save];
}

- (void)onAppWillTerminate{
    [self save];
}

- (void)save{
    NSDictionary *users = [self usersToSaveDictionary:[_contactDict allValues]];
    dispatch_async(dispatch_get_global_queue(0, 0), ^(){
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:users];
        [data writeToFile:_cachePath atomically:YES];
    });
}

@end
