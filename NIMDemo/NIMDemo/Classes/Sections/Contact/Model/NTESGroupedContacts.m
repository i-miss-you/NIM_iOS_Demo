//
//  NTESGroupedContacts.m
//  NIM
//
//  Created by Xuhui on 15/3/2.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NTESGroupedContacts.h"
#import "NTESContactDataItem.h"
#import "NTESContactsManager.h"

@interface NTESGroupedContacts () 

@end

@implementation NTESGroupedContacts

- (instancetype)init
{
    self = [super init];
    if(self) {
        self.groupTitleComparator = ^NSComparisonResult(NSString *title1, NSString *title2) {
            if ([title1 isEqualToString:@"#"]) {
                return NSOrderedDescending;
            }
            if ([title2 isEqualToString:@"#"]) {
                return NSOrderedAscending;
            }
            return [title1 compare:title2];
        };
        self.groupMemberComparator = ^NSComparisonResult(NSString *key1, NSString *key2) {
            return [key1 compare:key2];
        };
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onContactsUpdateFnished:) name:NIMKitUserInfoHasUpdatedNotification object:nil];
    }
    return self;
}

- (instancetype)initWithContacts:(NSArray *)contacts {
    self = [self init];
    if(self) {
        self.members = contacts;
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setDataSource:(NTESContactsManager *)dataSource {
    _dataSource = dataSource;
    self.members = _dataSource.allMyFriends;
}

- (void)update {
    if(_dataSource) [_dataSource update];
}

- (void)onContactsUpdateFnished:(NSNotification *)note {
    NSMutableArray *contacts = [NSMutableArray array];
    for (ContactDataMember *item in _dataSource.allMyFriends) {
        ContactDataMember *contact = [[ContactDataMember alloc] init];
        contact.usrId = item.usrId;
        contact.nick = item.nick;
        contact.iconId = item.iconId;
        [contacts addObject:contact];
    }
    [self setMembers:contacts];
    if([_delegate respondsToSelector:@selector(didFinishedContactsUpdate)]) {
        [_delegate didFinishedContactsUpdate];
    }
}

@end
