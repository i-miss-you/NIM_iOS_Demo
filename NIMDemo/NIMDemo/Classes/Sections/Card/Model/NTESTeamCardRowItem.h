//
//  TeamCardRowItem.h
//  NIM
//
//  Created by chris on 15/3/5.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NTESCardDataSourceProtocol.h"

@interface NTESTeamCardRowItem : NSObject<NTESCardBodyData>

@property(nonatomic,copy) NSString *title;

@property(nonatomic,copy) NSString *subTitle;

@property(nonatomic,assign) CGFloat rowHeight;

@property(nonatomic,assign) SEL action;

@property(nonatomic,assign) BOOL actionDisabled;

@property(nonatomic,assign) NTESTeamCardRowItemType type;

@property(nonatomic,assign) BOOL switchOn;

@end