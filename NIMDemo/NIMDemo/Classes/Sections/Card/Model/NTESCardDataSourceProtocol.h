//
//  NTESCardDataSourceProtocol.h
//  NIM
//
//  Created by chris on 15/3/5.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, NTESCardHeaderOpeator){
    CardHeaderOpeatorNone,
    CardHeaderOpeatorAdd,
    CardHeaderOpeatorRemove,
};

typedef NS_ENUM(NSInteger, NTESTeamCardRowItemType) {
    TeamCardRowItemTypeCommon,
    TeamCardRowItemTypeTeamMember,
    TeamCardRowItemTypeRedButton,
    TeamCardRowItemTypeBlueButton,
    TeamCardRowItemTypeSwitch,
};


@protocol NTESCardHeaderData <NSObject>

- (UIImage*)imageNormal;

- (UIImage*)imageHighLight;

- (NSString*)title;

@optional
- (NSString*)memberId;

- (NTESCardHeaderOpeator)opera;

@end



@protocol NTESCardBodyData <NSObject>

- (NSString*)title;

- (NTESTeamCardRowItemType)type;

- (CGFloat)rowHeight;

@optional
- (NSString*)subTitle;

- (SEL)action;

- (BOOL)actionDisabled;

- (BOOL)switchOn;

@end