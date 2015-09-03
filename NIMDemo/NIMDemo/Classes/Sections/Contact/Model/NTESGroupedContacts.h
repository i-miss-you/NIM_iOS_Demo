//
//  NTESGroupedContacts.h
//  NIM
//
//  Created by Xuhui on 15/3/2.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NTESGroupedDataCollection.h"

@protocol NTESGroupedContactsDelegate <NSObject>

- (void)didFinishedContactsUpdate;

@end

@class NTESContactsManager;

@interface NTESGroupedContacts : NTESGroupedDataCollection

@property (nonatomic, weak) id<NTESGroupedContactsDelegate> delegate;
@property (nonatomic, strong) NTESContactsManager *dataSource;

- (instancetype)initWithContacts:(NSArray *)contacts;

- (void)update;

@end
