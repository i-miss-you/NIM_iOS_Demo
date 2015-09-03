//
//  NTESNormalTeamCardViewController.m
//  NIM
//
//  Created by chris on 15/3/10.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NTESNormalTeamCardViewController.h"
#import "NTESCardMemberItem.h"
#import "NTESTeamCardOperationItem.h"
#import "UIAlertView+NTESBlock.h"
#import "UIActionSheet+NTESBlock.h"
#import "NIMTeam.h"
#import "UIView+Toast.h"
#import "NTESTeamCardRowItem.h"
#import "NTESTeamCardHeaderCell.h"
#import "NTESTeamMemberCardViewController.h"
#import "NTESUsrInfoData.h"
#import "NTESSessionLocalHistoryViewController.h"
#import "NTESBundleSetting.h"

@interface NTESNormalTeamCardViewController ()<NIMTeamManagerDelegate, NTESTeamMemberCardActionDelegate>

@property (nonatomic,strong) NIMTeam *team;

@property (nonatomic,strong) NIMTeamMember *myTeamInfo;

@property (nonatomic,copy) NSArray *teamMembers;

@end

@implementation NTESNormalTeamCardViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NIMSDK sharedSDK].teamManager addDelegate:self];
    }
    return self;
}


- (instancetype)initWithTeam:(NIMTeam *)team{
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        DDLogWarn(@"init with team id:%@" ,team.teamId);
        _team = team;
    }
    return self;
}

- (void)dealloc{
    [[NIMSDK sharedSDK].teamManager removeDelegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    __weak typeof(self) wself = self;
    [self requestData:^(NSError *error, NSArray *data) {
        NSArray * operaData = [wself buildOpearationData];
        if (operaData) {
            data = [data arrayByAddingObjectsFromArray:operaData];
        }
        [wself refreshWithMembers:data];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSString*)title{
    return self.team.teamName;
}


#pragma mark - Data
- (void)requestData:(void(^)(NSError *error,NSArray *data)) handler{
    __weak typeof(self) wself = self;
    [[NIMSDK sharedSDK].teamManager fetchTeamMembers:self.team.teamId completion:^(NSError *error, NSArray *members) {
        NSMutableArray *array = nil;
        if (!error) {
            NSString *myAccount = [[NIMSDK sharedSDK].loginManager currentAccount];
            for (NIMTeamMember *item in members) {
                if ([item.userId isEqualToString:myAccount]) {
                    wself.myTeamInfo = item;
                }
            }
            array = [[NSMutableArray alloc]init];
            for (NIMTeamMember *member in members) {
                NTESTeamCardMemberItem *item = [[NTESTeamCardMemberItem alloc] initWithMember:member];
                [array addObject:item];
            }
            wself.teamMembers = members;
        }else if(error.code == NIMRemoteErrorCodeTeamNotMember){
            [wself.view makeToast:@"你已经不在群里"];
        }else{
            [wself.view makeToast:@"拉好友失败"];
        }
        handler(error,array);
    }];
}

- (NSArray*)buildOpearationData{
    NIMTeam *team = [[NIMSDK sharedSDK].teamManager teamById:self.team.teamId];
    //加号
    NTESTeamCardOperationItem *add = [[NTESTeamCardOperationItem alloc] initWithOperation:CardHeaderOpeatorAdd];
    //减号
    NTESTeamCardOperationItem *remove = [[NTESTeamCardOperationItem alloc] initWithOperation:CardHeaderOpeatorRemove];
    NSString *uid = [NIMSDK sharedSDK].loginManager.currentAccount;
    NIMTeamMember *member = [[NIMSDK sharedSDK].teamManager teamMember:uid inTeam:team.teamId];
    if (member.type == NIMTeamMemberTypeOwner) {
        return @[add,remove];
    }
    return @[add];
}

- (NSArray*)buildBodyData{
    
    NTESTeamCardRowItem *itemName = [[NTESTeamCardRowItem alloc] init];
    itemName.title            = @"群名称";
    itemName.subTitle         = [self title];
    itemName.action           = @selector(updateTeamInfoName);
    itemName.rowHeight        = 50.f;
    itemName.type             = TeamCardRowItemTypeCommon;
    
    NTESTeamCardRowItem *teamNotify = [[NTESTeamCardRowItem alloc] init];
    teamNotify.title            = @"消息提醒";
    teamNotify.switchOn         = [self.team notifyForNewMsg];
    teamNotify.rowHeight        = 50.f;
    teamNotify.type             = TeamCardRowItemTypeSwitch;
    
    NTESTeamCardRowItem *searchLocal = [[NTESTeamCardRowItem alloc] init];
    searchLocal.title            = @"查看聊天内容";
    searchLocal.rowHeight        = 50.f;
    searchLocal.action           = @selector(searchLocal);
    searchLocal.type             = TeamCardRowItemTypeCommon;
    
    NTESTeamCardRowItem *delLocal = [[NTESTeamCardRowItem alloc] init];
    delLocal.title                = @"清空本地聊天记录";
    delLocal.rowHeight            = 50.f;
    delLocal.action               = @selector(delLocalMsg);
    delLocal.type                 = TeamCardRowItemTypeCommon;

    

    NTESTeamCardRowItem *itemQuit = [[NTESTeamCardRowItem alloc] init];
    itemQuit.title            = @"退出群聊";
    itemQuit.action           = @selector(quitTeam);
    itemQuit.rowHeight        = 60.f;
    itemQuit.type             = TeamCardRowItemTypeRedButton;
    
    return @[@[itemName,teamNotify,searchLocal,delLocal],@[itemQuit]];
}


- (void)addHeaderDatas:(NSArray*)members{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (NIMTeamMember *member in members) {
        NTESTeamCardMemberItem* item = [[NTESTeamCardMemberItem alloc] initWithMember:member];
        [array addObject:item];
    }
    [self addMembers:array];
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
                if (name.length) {
                    [[NIMSDK sharedSDK].teamManager updateTeamName:name teamId:wself.team.teamId completion:^(NSError *error) {
                        if (!error) {
                            wself.team = [[[NIMSDK sharedSDK] teamManager] teamById:wself.team.teamId];
                            [wself.view makeToast:@"修改成功"];
                            [wself refreshTableBody];
                            [wself refreshTitle];
                        }else{
                            [wself.view makeToast:@"修改失败"];
                        }
                    }];
                }
                break;
            }
            default:
                break;
        }
    }];
}

- (void)quitTeam{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"确认退出群聊?" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
    __block typeof(self) wself = self;
    [alert showAlertWithCompletionHandler:^(NSInteger index) {
        switch (index) {
            case 0://取消
                break;
            case 1:{
                [[NIMSDK sharedSDK].teamManager quitTeam:self.team.teamId completion:^(NSError *error) {
                    if (!error) {
                        [wself.navigationController popToRootViewControllerAnimated:YES];
                    }else{
                        [wself.view makeToast:@"退出失败"];
                    }
                }];
                break;
            }
            default:
                break;
        }
    }];
}

- (void)dismissTeam{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"确认解散群聊?" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
    __block typeof(self) wself = self;
    [alert showAlertWithCompletionHandler:^(NSInteger index) {
        switch (index) {
            case 0://取消
                break;
            case 1:{
                [[NIMSDK sharedSDK].teamManager dismissTeam:self.team.teamId completion:^(NSError *error) {
                    if (!error) {
                        [wself.navigationController popToRootViewControllerAnimated:YES];
                    }else{
                        [wself.view makeToast:@"解散失败"];
                    }
                }];
                break;
            }
            default:
                break;
        }
    }];
}


- (void)searchLocal{
    NIMSession *session = [NIMSession session:self.team.teamId type:NIMSessionTypeTeam];
    NTESSessionLocalHistoryViewController *vc = [[NTESSessionLocalHistoryViewController alloc] initWithSession:session];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)delLocalMsg{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"确定清空聊天记录？" delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定" otherButtonTitles:nil, nil];
    __weak UIActionSheet *wSheet;
    [sheet showInView:self.view completionHandler:^(NSInteger index) {
        if (index == wSheet.destructiveButtonIndex) {
            BOOL removeRecentSession = [NTESBundleSetting sharedConfig].removeSessionWheDeleteMessages;
            NIMSession *session = [NIMSession session:self.team.teamId type:NIMSessionTypeTeam];
            [[NIMSDK sharedSDK].conversationManager deleteAllmessagesInSession:session removeRecentSession:removeRecentSession];
        }
    }];
}

#pragma mark - ContactSelectDelegate

- (void)didFinishedSelect:(NSArray *)selectedContacts{
    if (selectedContacts.count) {
        __weak typeof(self) wself = self;
        switch (self.currentOpera) {
            case CardHeaderOpeatorAdd:{
                [[NIMSDK sharedSDK].teamManager addUsers:selectedContacts
                                                  toTeam:self.team.teamId
                                              postscript:@"邀请你加入群组"
                                              completion:^(NSError *error,NSArray *members) {
                    if (!error) {
                        if (self.team.type == NIMTeamTypeNormal) {
                            [wself addHeaderDatas:members];
                        }else{
                            [wself.view makeToast:@"邀请成功，等待验证" duration:2.0 position:CSToastPositionCenter];
                        }

                    }else{
                        [wself.view makeToast:@"邀请失败"];
                    }
                    wself.currentOpera = CardHeaderOpeatorNone;
                    [wself refreshTableHeader];
                    
                }];
            }
                break;
            case CardHeaderOpeatorRemove:{
                [[NIMSDK sharedSDK].teamManager kickUsers:selectedContacts fromTeam:self.team.teamId completion:^(NSError *error) {
                    if (!error) {
                        [wself removeHeaderDatas:selectedContacts];
                    }else{
                        [wself.view makeToast:@"移除失败"];
                    }
                    [wself refreshTableHeader];
                }];
            }
                break;
            default:
                break;
        }
    }
}

- (void)didCancelledSelect{
    self.currentOpera = CardHeaderOpeatorNone;
}

#pragma mark - TeamSwitchProtocol
- (void)onStateChanged:(BOOL)on
{
    __weak typeof(self) weakSelf = self;
    [[[NIMSDK sharedSDK] teamManager] updateNotifyState:on
                                                 inTeam:[_team teamId]
                                             completion:^(NSError *error) {
                                                 [weakSelf refreshTableBody];
                                             }];
    //override
}


#pragma mark - NIMTeamManagerDelegate
- (void)onTeamUpdated:(NIMTeam *)team{
    if ([team.teamId isEqualToString:self.team.teamId]) {
        self.navigationItem.title = team.teamName;
        __weak typeof(self) wself = self;
        [self requestData:^(NSError *error, NSArray *data) {
            NSArray * operaData = [wself buildOpearationData];
            if (operaData) {
                data = [data arrayByAddingObjectsFromArray:operaData];
            }
            [wself refreshWithMembers:data];
        }];
    }
}


- (void)cellDidSelected:(NTESTeamCardHeaderCell*)cell{
    [super cellDidSelected:cell];
    id<NTESCardHeaderData> data = cell.data;
    NSString *memberId;
    if ([data respondsToSelector:@selector(memberId)]) {
        memberId = data.memberId;
    }
    NSString *uid = [NIMSDK sharedSDK].loginManager.currentAccount;
    NIMTeamMember *myInfo = [self teamInfo:uid];
    
    if (memberId.length && self.team.type == NIMTeamTypeAdvanced) {
        NIMTeamMember *memberInfo = [self teamInfo:memberId];
        if((myInfo.type == NIMTeamMemberTypeOwner || myInfo.type == NIMTeamMemberTypeManager) && ![myInfo.userId isEqualToString:memberInfo.userId]) {
            NTESTeamMemberCardViewController *vc = [[NTESTeamMemberCardViewController alloc] initWithNibName:nil bundle:nil];
            vc.delegate = self;
            vc.member = [[NTESTeamCardMemberItem alloc] initWithMember:memberInfo];
            vc.viewer = [[NTESTeamCardMemberItem alloc] initWithMember:myInfo];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    
    
    
}


- (NIMTeamMember*)teamInfo:(NSString*)uid{
    for (NIMTeamMember *member in self.teamMembers) {
        if ([member.userId isEqualToString:uid]) {
            return member;
        }
    }
    return nil;
}

- (void)transferOwner:(NSString *)memberId isLeave:(BOOL)isLeave{
    __block typeof(self) wself = self;
    NIMTeamMember *memberInfo = [self teamInfo:memberId];
    [[NIMSDK sharedSDK].teamManager transferManagerWithTeam:self.team.teamId newOwnerId:memberId isLeave:isLeave completion:^(NSError *error) {
        if (!error) {
            memberInfo.type = NIMTeamMemberTypeOwner;
            [wself.view makeToast:@"修改成功"];
        }else{
            [wself.view makeToast:@"修改失败"];
        }
    }];
}

@end
