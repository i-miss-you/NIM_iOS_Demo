//
//  NTESRegularTeamCardViewController.m
//  NIM
//
//  Created by chris on 15/3/25.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NTESRegularTeamCardViewController.h"
#import "NTESTeamCardRowItem.h"
#import "UIView+NTES.h"
#import "NTESColorButtonCell.h"
#import "NTESRegularTeamMemberCell.h"
#import "UIView+Toast.h"

#import "NTESTeamMemberCardViewController.h"
#import "NTESCardMemberItem.h"
#import "UIAlertView+NTESBlock.h"
#import "UIActionSheet+NTESBlock.h"
#import "NTESContactSelectViewController.h"
#import "NTESContactsManager.h"
#import "NTESGroupedUsrInfo.h"
#import "NTESTeamMemberListViewController.h"
#import "NTESTeamAnnouncementListViewController.h"
#import "NTESSessionUtil.h"
#import "NTESTeamSwitchTableViewCell.h"
#import "NTESCommonTableData.h"
#import "NTESSessionLocalHistoryViewController.h"
#import "NTESBundleSetting.h"

#pragma mark - Team Header View
#define CardHeaderHeight 89
@interface RegularTeamCardHeaderView : UIView

@property (nonatomic,strong) UIImageView *avatar;

@property (nonatomic,strong) UILabel *titleLabel;

@property (nonatomic,strong) UILabel *numberLabel;

@property (nonatomic,strong) UILabel *createTimeLabel;

@property (nonatomic,strong) NIMTeam *team;

@end

@implementation RegularTeamCardHeaderView

- (instancetype)initWithTeam:(NIMTeam*)team{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _team = team;
        _avatar          = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"avatar_team"]];
        _titleLabel                      = [[UILabel alloc]initWithFrame:CGRectZero];
        _titleLabel.backgroundColor      = [UIColor clearColor];
        _titleLabel.font                 = [UIFont systemFontOfSize:17.f];
        _titleLabel.textColor            = UIColorFromRGB(0x333333);
        _numberLabel                     = [[UILabel alloc]initWithFrame:CGRectZero];
        _numberLabel.backgroundColor     = [UIColor clearColor];
        _numberLabel.font                = [UIFont systemFontOfSize:14.f];
        _numberLabel.textColor           = UIColorFromRGB(0x999999);
        _createTimeLabel                 = [[UILabel alloc]initWithFrame:CGRectZero];
        _createTimeLabel.backgroundColor = [UIColor clearColor];
        _createTimeLabel.font            = [UIFont systemFontOfSize:14.f];
        _createTimeLabel.textColor       = UIColorFromRGB(0x999999);
        [self addSubview:_avatar];
        [self addSubview:_titleLabel];
        [self addSubview:_numberLabel];
        [self addSubview:_createTimeLabel];
        
        self.backgroundColor = UIColorFromRGB(0xecf1f5);
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size{
    return CGSizeMake(UIScreenWidth, CardHeaderHeight);
}

- (NSString*)formartCreateTime{
    NSTimeInterval timestamp = self.team.createTime;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd"];
    NSString *dateString = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timestamp]];
    if (!dateString.length) {
        return @"未知时间创建";
    }
    return [NSString stringWithFormat:@"于%@创建",dateString];
}


#define AvatarLeft 20
#define AvatarTop  25
#define TitleAndAvatarSpacing 10
#define NumberAndTimeSpacing  10
#define MaxTitleLabelWidth 200
- (void)layoutSubviews{
    [super layoutSubviews];
    _titleLabel.text  = self.team.teamName;
    _numberLabel.text = self.team.teamId;
    _createTimeLabel.text  = [self formartCreateTime];
    [_titleLabel sizeToFit];
    [_createTimeLabel sizeToFit];
    [_numberLabel sizeToFit];

    self.titleLabel.width = self.titleLabel.width > MaxTitleLabelWidth ? MaxTitleLabelWidth : self.titleLabel.width;
    self.avatar.left = AvatarLeft;
    self.avatar.top  = AvatarTop;
    self.titleLabel.left = self.avatar.right + TitleAndAvatarSpacing;
    self.titleLabel.top  = self.avatar.top;
    self.numberLabel.left   = self.titleLabel.left;
    self.numberLabel.bottom = self.avatar.bottom;
    self.createTimeLabel.left   = self.numberLabel.right + NumberAndTimeSpacing;
    self.createTimeLabel.bottom = self.numberLabel.bottom;
}

@end

#pragma mark - Card VC
#define TableCellReuseId        @"tableCell"
#define TableButtonCellReuseId  @"tableButtonCell"
#define TableMemberCellReuseId  @"tableMemberCell"
#define TableSwitchReuseId      @"tableSwitchCell"

@interface NTESRegularTeamCardViewController ()<NTESRegularTeamMemberCellActionDelegate,NTESContactSelectDelegate,NTESTeamSwitchProtocol>

@property(nonatomic,strong) NIMTeam *team;

@property(nonatomic,strong) NIMTeamMember *myTeamInfo;

@property(nonatomic,copy) NSArray *bodyData;

@property(nonatomic,copy) NSArray *memberData;

@end

@implementation NTESRegularTeamCardViewController

- (instancetype)initWithTeam:(NIMTeam*)team{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _team = team;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    RegularTeamCardHeaderView *headerView = [[RegularTeamCardHeaderView alloc] initWithTeam:self.team];
    [headerView sizeToFit];
    self.navigationItem.title = self.team.teamName;
    self.tableView.tableHeaderView = headerView;
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = UIColorFromRGB(0xecf1f5);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    __weak typeof(self) wself = self;
    [self requestData:^(NSError *error) {
        if (!error) {
            [wself reloadData];
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadData];
}

- (void)reloadData{
    self.myTeamInfo = [[NIMSDK sharedSDK].teamManager teamMember:self.myTeamInfo.userId inTeam:self.myTeamInfo.teamId];
    [self buildBodyData];
    [self.tableView reloadData];
    RegularTeamCardHeaderView *headerView = (RegularTeamCardHeaderView*)self.tableView.tableHeaderView;
    headerView.titleLabel.text = self.team.teamName;;
    self.navigationItem.title  = self.team.teamName;
    if (self.myTeamInfo.type == NIMTeamMemberTypeOwner) {
        UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(onMore:)];
        self.navigationItem.rightBarButtonItem = buttonItem;
    }else{
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)requestData:(void(^)(NSError *error)) handler{
    __weak typeof(self) wself = self;
    [[NIMSDK sharedSDK].teamManager fetchTeamMembers:self.team.teamId completion:^(NSError *error, NSArray *members) {
        if (!error) {
            for (NIMTeamMember *member in members) {
                if ([member.userId isEqualToString:[NIMSDK sharedSDK].loginManager.currentAccount]) {
                    wself.myTeamInfo = member;
                    break;
                }
            }
            wself.memberData = members;
        }else if(error.code == NIMRemoteErrorCodeTeamNotMember){
            [wself.view makeToast:@"你已经不在群里"];
        }else{
            [wself.view makeToast:@"拉好友失败"];
        }
        handler(error);
    }];
}

- (void)buildBodyData{
    BOOL isManager = self.myTeamInfo.type == NIMTeamMemberTypeManager || self.myTeamInfo.type == NIMTeamMemberTypeOwner;
    BOOL isOwner   = self.myTeamInfo.type == NIMTeamMemberTypeOwner;
    
    NTESTeamCardRowItem *teamMember = [[NTESTeamCardRowItem alloc] init];
    teamMember.title  = @"群成员";
    teamMember.rowHeight = 111.f;
    teamMember.action = @selector(enterMemberCard);
    teamMember.type   = TeamCardRowItemTypeTeamMember;
    
    NTESTeamCardRowItem *teamName = [[NTESTeamCardRowItem alloc] init];
    teamName.title = @"群名称";
    teamName.subTitle = self.team.teamName;
    teamName.action = @selector(updateTeamName);
    teamName.rowHeight = 50.f;
    teamName.type   = TeamCardRowItemTypeCommon;
    teamName.actionDisabled = !isManager;
    
    NTESTeamCardRowItem *teamNick = [[NTESTeamCardRowItem alloc] init];
    teamNick.title = @"群昵称";
    teamNick.subTitle = self.myTeamInfo.nickname;
    teamNick.action = @selector(updateTeamNick);
    teamNick.rowHeight = 50.f;
    teamNick.type   = TeamCardRowItemTypeCommon;

    
    NTESTeamCardRowItem *teamIntro = [[NTESTeamCardRowItem alloc] init];
    teamIntro.title = @"群介绍";
    teamIntro.subTitle = self.team.intro.length ? self.team.intro : (isManager ? @"点击填写群介绍" : @"");
    teamIntro.action = @selector(updateTeamIntro);
    teamIntro.rowHeight = 50.f;
    teamIntro.type   = TeamCardRowItemTypeCommon;
    teamIntro.actionDisabled = !isManager;
    
    NTESTeamCardRowItem *teamAnnouncement = [[NTESTeamCardRowItem alloc] init];
    teamAnnouncement.title = @"群公告";
    teamAnnouncement.subTitle = @"点击查看群公告";//self.team.announcement.length ? self.team.announcement : (isManager ? @"点击填写群公告" : @"");
    teamAnnouncement.action = @selector(updateTeamAnnouncement);
    teamAnnouncement.rowHeight = 50.f;
    teamAnnouncement.type   = TeamCardRowItemTypeCommon;
    
    
    NTESTeamCardRowItem *teamNotify = [[NTESTeamCardRowItem alloc] init];
    teamNotify.title  = @"消息提醒";
    teamNotify.switchOn = [self.team notifyForNewMsg];
    teamNotify.rowHeight = 50.f;
    teamNotify.type   = TeamCardRowItemTypeSwitch;

    NTESTeamCardRowItem *itemQuit = [[NTESTeamCardRowItem alloc] init];
    itemQuit.title = @"退出高级群";
    itemQuit.action = @selector(quitTeam);
    itemQuit.rowHeight = 60.f;
    itemQuit.type   = TeamCardRowItemTypeRedButton;
    
    NTESTeamCardRowItem *itemDismiss = [[NTESTeamCardRowItem alloc] init];
    itemDismiss.title  = @"解散群聊";
    itemDismiss.action = @selector(dismissTeam);
    itemDismiss.rowHeight = 60.f;
    itemDismiss.type   = TeamCardRowItemTypeRedButton;
    
    
    NTESTeamCardRowItem *itemAuth = [[NTESTeamCardRowItem alloc] init];
    itemAuth.title  = @"身份验证";
    itemAuth.subTitle = [self joinModeText:self.team.joinMode];
    itemAuth.action = @selector(changeAuthMode);
    itemAuth.actionDisabled = !isManager;
    itemAuth.rowHeight = 60.f;
    itemAuth.type   = TeamCardRowItemTypeCommon;
    
    
    NTESTeamCardRowItem *searchLocal = [[NTESTeamCardRowItem alloc] init];
    searchLocal.title  = @"查看聊天内容";
    searchLocal.action = @selector(searchLocal);
    searchLocal.rowHeight = 50.f;
    searchLocal.type   = TeamCardRowItemTypeCommon;

    NTESTeamCardRowItem *delLocal = [[NTESTeamCardRowItem alloc] init];
    delLocal.title                = @"清空本地聊天记录";
    delLocal.rowHeight            = 50.f;
    delLocal.action               = @selector(delLocalMsg);
    delLocal.type                 = TeamCardRowItemTypeCommon;

    
    if (isOwner) {
        self.bodyData = @[
                  @[teamMember],
                  @[teamName,teamNick,teamIntro,teamAnnouncement,searchLocal,delLocal,teamNotify],
                  @[itemAuth],
                  @[itemDismiss]
                 ];
    }else{
        self.bodyData = @[
                 @[teamMember],
                 @[teamName,teamNick,teamIntro,teamAnnouncement,searchLocal,delLocal,teamNotify],
                 @[itemAuth],
                 @[itemQuit]
                 ];
    }
}

- (id<NTESCardBodyData>)bodyDataAtIndexPath:(NSIndexPath*)indexpath{
    NSArray *sectionData = self.bodyData[indexpath.section];
    return sectionData[indexpath.row];
}

- (NSIndexPath *)cellIndexPathByTitle:(NSString *)title {
    __block NSInteger section = 0;
    __block NSInteger row = 0;
    [self.bodyData enumerateObjectsUsingBlock:^(NSArray *rows, NSUInteger s, BOOL *stop) {
        __block BOOL stopped = NO;
        [rows enumerateObjectsUsingBlock:^(NTESTeamCardRowItem *item, NSUInteger r, BOOL *stop) {
            if([item.title isEqualToString:title]) {
                section = s;
                row = r;
                *stop = YES;
                stopped = YES;
            }
        }];
        *stop = stopped;
    }];
    return [NSIndexPath indexPathForRow:row inSection:section];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    id<NTESCardBodyData> bodyData = [self bodyDataAtIndexPath:indexPath];
    if ([bodyData respondsToSelector:@selector(actionDisabled)] && bodyData.actionDisabled) {
        return;
    }
    if ([bodyData respondsToSelector:@selector(action)]) {
        if (bodyData.action) {
            SuppressPerformSelectorLeakWarning([self performSelector:bodyData.action]);
        }
    }
}

#pragma mark - UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    id<NTESCardBodyData> bodyData = [self bodyDataAtIndexPath:indexPath];
    return bodyData.rowHeight;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.bodyData.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *sectionData = self.bodyData[section];
    return sectionData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    id<NTESCardBodyData> bodyData = [self bodyDataAtIndexPath:indexPath];
    UITableViewCell * cell;
    NTESTeamCardRowItemType type = bodyData.type;
    switch (type) {
        case TeamCardRowItemTypeCommon:
            cell = [self builidCommonCell:bodyData];
            break;
        case TeamCardRowItemTypeRedButton:
            cell = [self builidRedButtonCell:bodyData];
            break;
        case TeamCardRowItemTypeTeamMember:
            cell = [self builidTeamMemberCell:bodyData];
            break;
        case TeamCardRowItemTypeSwitch:
            cell = [self buildTeamSwitchCell:bodyData];
            break;
        default:
            break;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 0.0f;
    }
    return 20.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    view.backgroundColor = UIColorFromRGB(0xecf1f5);
    return view;
}


- (UITableViewCell*)builidCommonCell:(id<NTESCardBodyData>) bodyData{
    UITableViewCell * cell = [self.tableView dequeueReusableCellWithIdentifier:TableCellReuseId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:TableCellReuseId];
        CGFloat left = 15.f;
        UIView *sep = [[UIView alloc] initWithFrame:CGRectMake(left, cell.height-1, cell.width, 1.f)];
        sep.backgroundColor = UIColorFromRGB(0xebebeb);
        [cell addSubview:sep];
        sep.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    }
    cell.textLabel.text = bodyData.title;
    if ([bodyData respondsToSelector:@selector(subTitle)]) {
        cell.detailTextLabel.text = bodyData.subTitle;
    }
    
    if ([bodyData respondsToSelector:@selector(actionDisabled)] && bodyData.actionDisabled) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }else{
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
    
}

- (UITableViewCell*)builidRedButtonCell:(id<NTESCardBodyData>) bodyData{
    NTESColorButtonCell * cell = [self.tableView dequeueReusableCellWithIdentifier:TableButtonCellReuseId];
    if (!cell) {
        cell = [[NTESColorButtonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TableButtonCellReuseId];
    }
    NTESCommonTableRow *row = [[NTESCommonTableRow alloc] initWithDict:@{
                                                                 Title:bodyData.title,
                                                                 ExtraInfo:@(ColorButtonCellStyleRed),
                                                                 }];
    [cell refreshData:row tableView:self.tableView];
    return cell;
}

- (UITableViewCell*)builidTeamMemberCell:(id<NTESCardBodyData>) bodyData{
    NTESRegularTeamMemberCell * cell = [self.tableView dequeueReusableCellWithIdentifier:TableMemberCellReuseId];
    if (!cell) {
        cell = [[NTESRegularTeamMemberCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:TableMemberCellReuseId];
        cell.delegate = self;
    }
    [cell rereshWithTeam:self.team members:self.memberData];
    cell.textLabel.text = bodyData.title;
    cell.detailTextLabel.text = bodyData.subTitle;
    if ([bodyData respondsToSelector:@selector(actionDisabled)] && bodyData.actionDisabled) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }else{
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

- (UITableViewCell *)buildTeamSwitchCell:(id<NTESCardBodyData>)bodyData
{
    NTESTeamSwitchTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:TableSwitchReuseId];
    if (!cell) {
        cell = (NTESTeamSwitchTableViewCell *)[[[NSBundle mainBundle] loadNibNamed:@"NTESTeamSwitchTableViewCell"
                                                                         owner:nil
                                                                       options:nil] firstObject];
    }
    cell.switchLabel.text = bodyData.title;
    cell.switcher.on = bodyData.switchOn;
    cell.switchDelegate = self;
    
    return cell;
}

#pragma mark - Action
- (void)onMore:(id)sender{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"转让群",@"转让群并退出",nil];
    [sheet showInView:self.view completionHandler:^(NSInteger index) {
        BOOL isLeave = NO;
        switch (index) {
            case 0:{
                isLeave = NO;
                break;
            case 1:
                isLeave = YES;
                break;
            }
            default:
                return;
                break;
        }
        __weak typeof(self) wself = self;
        __block ContactSelectFinishBlock finishBlock =  ^(NSArray * memeber){
            [[NIMSDK sharedSDK].teamManager transferManagerWithTeam:wself.team.teamId newOwnerId:memeber.firstObject isLeave:isLeave completion:^(NSError *error) {
                if (!error) {
                    [wself.view makeToast:@"转移成功！" duration:2.0 position:CSToastPositionCenter];
                    if (isLeave) {
                        [wself.navigationController popToRootViewControllerAnimated:YES];
                    }else{
                        [wself reloadData];
                    }
                }else{
                    [wself.view makeToast:@"转移失败！" duration:2.0 position:CSToastPositionCenter];
                }
            }];
        };
        NSMutableArray *users = [[NSMutableArray alloc] init];
        for (NIMTeamMember *member in self.memberData) {
            [users addObject:member.userId];
        }
        NSString *currentUserID = [[[NIMSDK sharedSDK] loginManager] currentAccount];
        [users removeObject:currentUserID];
        NTESContactSelectViewController *vc = [[NTESContactSelectViewController alloc] initTeamContactSeleorWithMembers:users teamId:self.team.teamId];
        vc.maxSelectCount = 1;
        vc.finshBlock = finishBlock;
        [self presentViewController:[[UINavigationController alloc] initWithRootViewController:vc] animated:YES completion:nil];
    }];
    
}

- (void)updateTeamName{
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
                            wself.team.teamName = name;
                            [wself.view makeToast:@"修改成功"];
                            [wself reloadData];
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

- (void)updateTeamNick{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"修改群昵称" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    __block typeof(self) wself = self;
    [alert showAlertWithCompletionHandler:^(NSInteger index) {
        switch (index) {
            case 0://取消
                break;
            case 1:{
                NSString *name = [alert textFieldAtIndex:0].text;
                if (name.length) {
                    NSString *currentUserId = [NIMSDK sharedSDK].loginManager.currentAccount;
                    [[NIMSDK sharedSDK].teamManager updateUserNick:currentUserId newNick:name inTeam:self.team.teamId completion:^(NSError *error) {
                        if (!error) {
                            wself.myTeamInfo.nickname = name;
                            [wself.view makeToast:@"修改成功"];
                            [wself reloadData];
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

- (void)updateTeamIntro{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"修改群介绍" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    __block typeof(self) wself = self;
    [alert showAlertWithCompletionHandler:^(NSInteger index) {
        switch (index) {
            case 0://取消
                break;
            case 1:{
                NSString *intro = [alert textFieldAtIndex:0].text;
                if (intro.length) {
                    
                    [[NIMSDK sharedSDK].teamManager updateTeamIntro:intro teamId:wself.team.teamId completion:^(NSError *error) {
                        if (!error) {
                            wself.team.intro = intro;
                            [wself.view makeToast:@"修改成功"];
                            [wself reloadData];
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

- (void)updateTeamAnnouncement{
    BOOL isManager = self.myTeamInfo.type == NIMTeamMemberTypeManager || self.myTeamInfo.type == NIMTeamMemberTypeOwner;
    NTESTeamAnnouncementListViewController *vc = [[NTESTeamAnnouncementListViewController alloc] initWithNibName:nil bundle:nil];
    vc.team = self.team;
    vc.canCreateAnnouncement = isManager;
    [self.navigationController pushViewController:vc animated:YES];
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


- (void)changeAuthMode{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"更改验证方式" delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"允许任何人",@"需要验证",@"拒绝任何人", nil];
    __block typeof(self) wself = self;
    NSInteger cancelIndex = sheet.cancelButtonIndex;
    [sheet showInView:self.view completionHandler:^(NSInteger index) {
        if (index == cancelIndex) {
            return;
        }
        [[NIMSDK sharedSDK].teamManager updateTeamJoinMode:index teamId:wself.team.teamId completion:^(NSError *error) {
            if (!error) {
                wself.team.joinMode = index;
                [wself.view makeToast:@"修改成功"];
                [wself reloadData];
            }else{
                [wself.view makeToast:@"修改失败"];
            }

        }];
    }];
}

- (NSString*)joinModeText:(NIMTeamJoinMode)mode{
    switch (mode) {
        case NIMTeamJoinModeNoAuth:
            return @"允许任何人";
        case NIMTeamJoinModeNeedAuth:
            return @"需要验证";
        case NIMTeamJoinModeRejectAll:
            return @"拒绝任何人";
        default:
            break;
    }
}

- (void)enterMemberCard{
    NTESTeamMemberListViewController *vc = [[NTESTeamMemberListViewController alloc] initTeam:self.team members:self.memberData];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onStateChanged:(BOOL)on
{
    __weak typeof(self) weakSelf = self;
    [[[NIMSDK sharedSDK] teamManager] updateNotifyState:on
                                                 inTeam:[_team teamId]
                                             completion:^(NSError *error) {
                                                 if (error) {
                                                     [weakSelf.view makeToast:@"修改失败"];
                                                 }
                                                 [weakSelf reloadData];
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

#pragma mark - RegularTeamMemberCellActionDelegate

- (void)didSelectAddOpeartor{
    NSMutableArray *users = [[[NTESContactsManager sharedInstance] allMyFriendsIds] mutableCopy];
    for (NIMTeamMember *member in self.memberData) {
        [users removeObject:member.userId];
    }
    NSString *currentUserID = [[[NIMSDK sharedSDK] loginManager] currentAccount];
    [users removeObject:currentUserID];
    NTESContactSelectViewController *vc = [[NTESContactSelectViewController alloc] initContactSeleorWithMembers:users];
    vc.delegate = self;
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:vc] animated:YES completion:nil];
}


#pragma mark - ContactSelectDelegate
- (void)didFinishedSelect:(NSArray *)selectedContacts{
    if (!selectedContacts.count) {
        return;
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"邀请附言" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    __weak typeof(self)wself = self;
    [alert showAlertWithCompletionHandler:^(NSInteger index) {
        switch (index) {
            case 0://取消
                break;
            case 1:{
                NSString *postscript = [alert textFieldAtIndex:0].text;
                [[NIMSDK sharedSDK].teamManager addUsers:selectedContacts toTeam:self.team.teamId postscript:postscript completion:^(NSError *error, NSArray *members) {
                    if (!error) {
                        [wself.view makeToast:@"邀请成功"];
                    }else{
                        [wself.view makeToast:@"邀请失败"];
                    }
                }];
            }
                break;
            default:
                break;
        }
    }];
}

- (void)didCancelledSelect{
    
}



@end


