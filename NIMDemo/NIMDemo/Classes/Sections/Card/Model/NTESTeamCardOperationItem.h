//
//  TeamCardOperationItem.h
//  NIM
//
//  Created by chris on 15/3/5.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NTESCardDataSourceProtocol.h"

@interface NTESTeamCardOperationItem : NSObject<NTESCardHeaderData>

- (instancetype)initWithOperation:(NTESCardHeaderOpeator)opera;

@end
