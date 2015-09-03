//
//  CreateNormalTeamCardViewController.m
//  NIM
//
//  Created by chris on 15/3/11.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NTESCreateNormalTeamCardViewController.h"
#import "NTESContactsManager.h"
#import "NTESCardMemberItem.h"
#import "NTESTeamCardOperationItem.h"
#import "NTESTeamCardRowItem.h"
#import "UIAlertView+NTESBlock.h"
#import "UIView+Toast.h"
#import "NTESSessionViewController.h"
#import "NTESSessionLocalHistoryViewController.h"
#import "UIActionSheet+NTESBlock.h"
#import "NTESBundleSetting.h"

@interface NTESCreateNormalTeamCardViewController ()

@property (nonatomic,copy)   NTESUserCardMemberItem *user;

@property (nonatomic,copy)   NSString *teamName;

@property (nonatomic,strong) NSMutableArray *teamMembers;

@end

@implementation NTESCreateNormalTeamCardViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSString *currentUserID = [[[NIMSDK sharedSDK] loginManager] currentAccount];
        _teamMembers = [@[currentUserID] mutableCopy];
    }
    return self;
}


- (instancetype)initWithUser:(NSString*)userId{
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        DDLogWarn(@"init with initWithUser id:%@" ,userId);
        ContactDataMember *contactMember = [[NTESContactsManager sharedInstance] localContactByUsrId:userId];
        if(!contactMember){
            contactMember = [[ContactDataMember alloc] init];
            contactMember.usrId = userId;
            DDLogError(@"user info error!");
        }
        _user = [[NTESUserCardMemberItem alloc] initWithMember:contactMember];
        [_teamMembers addObject:_user.memberId];

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSArray *opearData = [self buildOpearationData];
    NSString *currentUserID = [[[NIMSDK sharedSDK] loginManager] currentAccount];
    ContactDataMember *member = [[NTESContactsManager sharedInstance] localContactByUsrId:currentUserID];
    NTESUserCardMemberItem *me = [[NTESUserCardMemberItem alloc] initWithMember:member];
    NSArray *users;
    if (self.user) {
        users = @[self.user,me];
    }else{
        users = @[me];
    }
    NSArray *members   = [users arrayByAddingObjectsFromArray:opearData];
    [self refreshWithMembers:members];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSString*)title{
    if (self.user.memberId.length) {
        return @"聊天信息";
    }
    return @"创建普通群";
}

#pragma mark - Data

- (NSArray*)buildOpearationData{
    //加号
    NTESTeamCardOperationItem *add = [[NTESTeamCardOperationItem alloc] initWithOperation:CardHeaderOpeatorAdd];
    //减号
    NTESTeamCardOperationItem *remove = [[NTESTeamCardOperationItem alloc] initWithOperation:CardHeaderOpeatorRemove];
    return @[add,remove];
}

- (NSArray*)buildBodyData{
    NTESTeamCardRowItem *teamName = [[NTESTeamCardRowItem alloc] init];
    teamName.title             = @"群名称";
    teamName.subTitle          = self.teamName.length ? self.teamName : @"";
    teamName.action            = @selector(updateTeamInfoName);
    teamName.rowHeight         = 50.f;
    teamName.type              = TeamCardRowItemTypeCommon;
    
    NTESTeamCardRowItem *localHistory = [[NTESTeamCardRowItem alloc] init];
    localHistory.title                = @"查看聊天内容";
    localHistory.action               = @selector(onActionLocalMsgHistory);
    localHistory.rowHeight            = 50.f;
    localHistory.type                 = TeamCardRowItemTypeCommon;

    NTESTeamCardRowItem *delLocalMessage = [[NTESTeamCardRowItem alloc] init];
    delLocalMessage.title                   = @"删除本地聊天记录";
    delLocalMessage.action                  = @selector(onActionDelLocalMsg);
    delLocalMessage.rowHeight               = 50.f;
    delLocalMessage.type                    = TeamCardRowItemTypeCommon;

    NTESTeamCardRowItem *addTeam = [[NTESTeamCardRowItem alloc] init];
    addTeam.title             = @"创建普通群组";
    addTeam.action            = @selector(addTeamMember);
    addTeam.rowHeight         = 60.f;
    addTeam.type              = TeamCardRowItemTypeBlueButton;
    
    if (self.user.memberId.length) {
        BOOL needNotify             = [[NIMSDK sharedSDK].userManager notifyForNewMsg:self.user.memberId];
        NTESTeamCardRowItem *notify = [[NTESTeamCardRowItem alloc] init];
        notify.title                = @"消息提醒";
        notify.rowHeight            = 50.f;
        notify.switchOn             = needNotify;
        notify.type                 = TeamCardRowItemTypeSwitch;
        
        return @[
                 @[teamName,notify,localHistory,delLocalMessage],
                 @[addTeam]
                 ];
    }
    return @[
               @[teamName],
               @[addTeam]
            ];
}


- (void)addHeaderDatas:(NSArray*)members{
    [self addMembers:members];
    
}

- (void)removeHeaderDatas:(NSArray*)datas{
    [self removeMembers:datas];
}


#pragma mark - UITableViewAction
- (void)updateTeamInfoName{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"修改群名称" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    __block typeof(self) wself = self;
    [alert showAlertWithCompletionHandler:^(NSInteger index) {
        switch (index) {
            case 0://取消
                break;
            case 1:{
                NSString *name = [alert textFieldAtIndex:0].text;
                wself.teamName = name;
                [wself refreshTableBody];
                break;
            }
            default:
                break;
        }
    }];
}

- (void)addTeamMember{
    if (!self.teamMembers) {
        [self.view makeToast:@"群成员数据有误"];
        return;
    }
    __weak typeof(self) wself = self;
    NIMCreateTeamOption *option = [[NIMCreateTeamOption alloc] init];
    option.name = self.teamName.length ? self.teamName : @"普通群";
    option.type = NIMTeamTypeNormal;
    
    [[NIMSDK sharedSDK].teamManager createTeam:option
                                         users:self.teamMembers
                                    completion:^(NSError *error, NSString *teamId) {
        if (!error) {
            UINavigationController *nav = wself.navigationController;
            [nav popToRootViewControllerAnimated:NO];
            NIMSession *session = [NIMSession session:teamId type:NIMSessionTypeTeam];
            NTESSessionViewController *vc = [[NTESSessionViewController alloc] initWithSession:session];
            [nav pushViewController:vc animated:YES];
        }else{
            [wself.view makeToast:@"创建失败"];
        }
    }];
}

- (void)onActionLocalMsgHistory{
    NIMSession *session = [NIMSession session:self.user.memberId type:NIMSessionTypeP2P];
    NTESSessionLocalHistoryViewController *vc = [[NTESSessionLocalHistoryViewController alloc] initWithSession:session];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onActionDelLocalMsg{
    NIMSession *session = [NIMSession session:self.user.memberId type:NIMSessionTypeP2P];
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"确定清空聊天记录？" delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定" otherButtonTitles:nil, nil];
    __weak UIActionSheet *wSheet;
    [sheet showInView:self.view completionHandler:^(NSInteger index) {
        if (index == wSheet.destructiveButtonIndex) {
            BOOL removeRecentSession = [NTESBundleSetting sharedConfig].removeSessionWheDeleteMessages;
            [[NIMSDK sharedSDK].conversationManager deleteAllmessagesInSession:session removeRecentSession:removeRecentSession];
        }
    }];
}

#pragma mark - TeamSwitchProtocol
- (void)onStateChanged:(BOOL)on
{
    __weak typeof(self) weakSelf = self;
    [[NIMSDK sharedSDK].userManager updateNotifyState:on forUser:self.user.memberId completion:^(NSError *error) {
        if (error) {
            [weakSelf.view makeToast:@"修改失败"];
        }
        [weakSelf refreshTableBody];
    }];
}


#pragma mark - ContactSelectDelegate

- (void)didFinishedSelect:(NSArray *)selectedContacts{
    NSMutableArray *array = [[NSMutableArray alloc]init];
    for (NSString *uid in selectedContacts) {
        ContactDataMember *contactMember = [[NTESContactsManager sharedInstance] localContactByUsrId:uid];
        NTESUserCardMemberItem *item = [[NTESUserCardMemberItem alloc] initWithMember:contactMember];
        [array addObject:item];
    }
    switch (self.currentOpera) {
        case CardHeaderOpeatorAdd:{
            [self.teamMembers addObjectsFromArray:selectedContacts];
            [self addHeaderDatas:array];
            break;
        }
        case CardHeaderOpeatorRemove:{
            [self.teamMembers removeObjectsInArray:selectedContacts];
            [self removeHeaderDatas:array];
            break;
        }
        default:
            break;
    }
}

- (void)didCancelledSelect{
    self.currentOpera = CardHeaderOpeatorNone;
}

@end
