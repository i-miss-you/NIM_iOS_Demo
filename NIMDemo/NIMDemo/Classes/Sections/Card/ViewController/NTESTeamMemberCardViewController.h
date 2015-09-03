//
//  TeamMemberCardViewController.h
//  NIM
//
//  Created by Xuhui on 15/3/19.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NTESTeamCardMemberItem;

@protocol NTESTeamMemberCardActionDelegate <NSObject>
@optional

- (void)onTeamMemberKicked:(NTESTeamCardMemberItem *)member;
- (void)onTeamMemberInfoChaneged:(NTESTeamCardMemberItem *)member;

@end

@interface NTESTeamMemberCardViewController : UIViewController

@property (nonatomic, strong) id<NTESTeamMemberCardActionDelegate> delegate;
@property (nonatomic, strong) NTESTeamCardMemberItem *member;
@property (nonatomic, strong) NTESTeamCardMemberItem *viewer;

@end
