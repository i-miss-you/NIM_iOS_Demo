//
//  NTESContactViewController.m
//  NIMDemo
//
//  Created by chris on 15/2/2.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NTESContactViewController.h"
#import "NIMSDK.h"
#import "NTESSessionUtil.h"
#import "NTESSessionViewController.h"
#import "NTESContactDataItem.h"
#import "NTESContactUtilItem.h"
#import "NTESContactDefines.h"
#import "NTESGroupedContacts.h"
#import "NTESContactsManager.h"
#import "UIView+Toast.h"
#import "NTESCustomNotificationDB.h"
#import "NTESNotificationCenter.h"
#import "UIActionSheet+NTESBlock.h"
#import "NTESCreateNormalTeamCardViewController.h"
#import "NTESCreateRegularTeamCardViewController.h"
#import "NTESSearchTeamViewController.h"
#import "NTESContactAddFriendViewController.h"
#import "NTESPersonCardViewController.h"
#import "UIAlertView+NTESBlock.h"
#import "SVProgressHUD.h"

@interface NTESContactViewController ()
<NTESGroupedContactsDelegate,
NIMSystemNotificationManagerDelegate,
NIMLoginManagerDelegate,
NIMUserManagerDelegate
> {
    UIRefreshControl *_refreshControl;
    NTESGroupedContacts *_contacts;
}

@property (nonatomic,strong) NSArray * datas;

@end

@implementation NTESContactViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onInfoUpdate:) name:NIMKitUserInfoHasUpdatedNotification object:nil];
    }
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[[NIMSDK sharedSDK] systemNotificationManager] removeDelegate:self];
    [[[NIMSDK sharedSDK] loginManager] removeDelegate:self];
    [[[NIMSDK sharedSDK] userManager] removeDelegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate       = self;
    self.tableView.dataSource     = self;
    UIEdgeInsets separatorInset   = self.tableView.separatorInset;
    separatorInset.right          = 0;
    self.tableView.separatorInset = separatorInset;
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self prepareData];
    [[[NIMSDK sharedSDK] systemNotificationManager] addDelegate:self];
    [[[NIMSDK sharedSDK] loginManager] addDelegate:self];
    [[[NIMSDK sharedSDK] userManager] addDelegate:self];
}

- (void)setUpNavItem{
    UIButton *teamBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [teamBtn addTarget:self action:@selector(onOpera:) forControlEvents:UIControlEventTouchUpInside];
    [teamBtn setImage:[UIImage imageNamed:@"icon_tinfo_normal"] forState:UIControlStateNormal];
    [teamBtn setImage:[UIImage imageNamed:@"icon_tinfo_pressed"] forState:UIControlStateHighlighted];
    [teamBtn sizeToFit];
    UIBarButtonItem *teamItem = [[UIBarButtonItem alloc] initWithCustomView:teamBtn];
    self.navigationItem.rightBarButtonItem = teamItem;
}

- (void)prepareData{
    _contacts = [[NTESGroupedContacts alloc] init];
    _contacts.delegate = self;
    _contacts.dataSource = [NTESContactsManager sharedInstance];

    NSString *contactCellUtilIcon   = @"icon";
    NSString *contactCellUtilVC     = @"vc";
    NSString *contactCellUtilBadge  = @"badge";
    NSString *contactCellUtilTitle  = @"title";
    NSString *contactCellUtilUid    = @"uid";
//原始数据
    
    NSInteger systemCount = [[[NIMSDK sharedSDK] systemNotificationManager] allUnreadCount];
    NSMutableArray *utils =
            [@[
              @{
                  contactCellUtilIcon:@"icon_notification_normal",
                  contactCellUtilTitle:@"验证消息",
                  contactCellUtilVC:@"NTESSystemNotificationViewController",
                  contactCellUtilBadge:@(systemCount)
               },
              @{
                  contactCellUtilIcon:@"icon_team_advance_normal",
                  contactCellUtilTitle:@"高级群",
                  contactCellUtilVC:@"NTESAdvancedTeamListViewController"
               },
              @{
                  contactCellUtilIcon:@"icon_team_normal_normal",
                  contactCellUtilTitle:@"普通群",
                  contactCellUtilVC:@"NTESNormalTeamListViewController"
                },
              @{
                  contactCellUtilIcon:@"icon_blacklist_normal",
                  contactCellUtilTitle:@"黑名单",
                  contactCellUtilVC:@"NTESBlackListViewController"
                  },
              @{
                  contactCellUtilIcon:@"icon_computer_normal",
                  contactCellUtilTitle:@"我的电脑",
                  contactCellUtilUid:[NIMSDK sharedSDK].loginManager.currentAccount
                },
              ] mutableCopy];
    
    self.navigationItem.title = @"通讯录";
    [self setUpNavItem];
    
    //构造显示的数据模型
    NTESContactUtilItem *contactUtil = [[NTESContactUtilItem alloc] init];
    NSMutableArray * members = [[NSMutableArray alloc] init];
    for (NSDictionary *item in utils) {
        NTESContactUtilMember *utilItem = [[NTESContactUtilMember alloc] init];
        utilItem.nick              = item[contactCellUtilTitle];
        utilItem.iconId            = item[contactCellUtilIcon];
        utilItem.vcName            = item[contactCellUtilVC];
        utilItem.badge             = [item[contactCellUtilBadge] stringValue];
        utilItem.usrId             = item[contactCellUtilUid];
        [members addObject:utilItem];
    }
    contactUtil.members = members;
    
    [_contacts addGroupAboveWithTitle:@"" members:contactUtil.members];
}


#pragma mark - Action
- (void)onOpera:(id)sender{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"添加好友",@"创建高级群",@"创建普通群",@"搜索高级群", nil];
    __weak typeof(self) wself = self;
    [sheet showInView:self.view completionHandler:^(NSInteger index) {
        UIViewController *vc;
        switch (index) {
            case 0:
                vc = [[NTESContactAddFriendViewController alloc] initWithNibName:nil bundle:nil];
                break;
            case 1:  //创建高级群
                vc = [[NTESCreateRegularTeamCardViewController alloc] initWithNibName:nil bundle:nil];
                break;
            case 2: //创建普通群
                vc = [[NTESCreateNormalTeamCardViewController alloc] initWithNibName:nil bundle:nil];
                break;
            case 3:
                vc = [[NTESSearchTeamViewController alloc] initWithNibName:nil bundle:nil];
                break;
            default:
                break;
        }
        if (vc) {
            [wself.navigationController pushViewController:vc animated:YES];
        }
    }];
}

#pragma mark - GroupedContactsDelegate

- (void)didFinishedContactsUpdate {
    [_refreshControl endRefreshing];
    [self prepareData];
    [_tableView reloadData];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    id<NTESContactItem> contactItem = (id<NTESContactItem>)[_contacts memberOfIndex:indexPath];
    if (contactItem.vcName.length) {
        Class clazz = NSClassFromString(contactItem.vcName);
        UIViewController * vc = [[clazz alloc] initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:vc animated:YES];
    }else if([contactItem respondsToSelector:@selector(usrId)]){
        NSString * friendId   = contactItem.usrId;
        NIMSession * session  = [NIMSession session:friendId type:NIMSessionTypeP2P];
        NTESSessionViewController * vc = [[NTESSessionViewController alloc] initWithSession:session];
        [self.navigationController pushViewController:vc animated:YES];
    }

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    id<NTESContactItem> contactItem = (id<NTESContactItem>)[_contacts memberOfIndex:indexPath];
    return contactItem.uiHeight;
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_contacts memberCountOfGroup:section];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [_contacts groupCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    id<NTESContactItem> contactItem = (id<NTESContactItem>)[_contacts memberOfIndex:indexPath];
    NSString * cellId = contactItem.reuseId;
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        Class cellClazz = NSClassFromString(contactItem.cellName);
        cell = [[cellClazz alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    if (contactItem.showAccessoryView) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    id<NTESContactCell> myCell = (id<NTESContactCell>)cell;
    [myCell refreshWithContactItem:contactItem];
    [myCell addDelegate:self];
    return cell;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [_contacts titleOfGroup:section];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return _contacts.sortedGroupTitles;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return index + 1;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    id<NTESContactItem> contactItem = (id<NTESContactItem>)[_contacts memberOfIndex:indexPath];
    return [contactItem usrId].length;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"删除好友" message:@"删除好友后，将同时解除双方的好友关系" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert showAlertWithCompletionHandler:^(NSInteger index) {
            if (index == 1) {
                [SVProgressHUD show];
                id<NTESContactItem,NTESGroupMemberProtocol> contactItem = (id<NTESContactItem,NTESGroupMemberProtocol>)[_contacts memberOfIndex:indexPath];
                NSString *userId = [contactItem usrId];
                __weak typeof(self) wself = self;
                [[NIMSDK sharedSDK].userManager deleteFriend:userId completion:^(NSError *error) {
                    [SVProgressHUD dismiss];
                    if (!error) {
                        [_contacts removeGroupMember:contactItem];
                    }else{
                        [wself.view makeToast:@"删除失败"duration:2.0f position:CSToastPositionCenter];
                    }
                }];
            }
        }];
    }
}

#pragma mark - Notification
- (void)onInfoUpdate:(NSNotification *)notfication{
    [self prepareData];
    [self.tableView reloadData];
}

#pragma mark - NTESContactDataCellDelegate
- (void)onPressUserAvatar:(NSString *)uid{
    NTESPersonCardViewController *vc = [[NTESPersonCardViewController alloc] initWithUserId:uid];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - NTESContactUtilCellDelegate
- (void)onPressUtilImage:(NSString *)content{
    [self.view makeToast:[NSString stringWithFormat:@"点我干嘛 我是<%@>",content] duration:2.0 position:CSToastPositionCenter];
}

#pragma mark - NIMSDK Delegate
- (void)onSystemNotificationCountChanged:(NSInteger)unreadCount
{
    [self prepareData];
    [self.tableView reloadData];
}

- (void)onLogin:(NIMLoginStep)step
{
    if (step == NIMLoginStepSyncOK) {
        [self prepareData];
        [self.tableView reloadData];
    }
}

- (void)onFriendChanged:(NIMUser *)user
{
    __weak typeof(self) wself = self;
    [[NTESContactsManager sharedInstance] queryContactByUsrId:user.userId completion:^(ContactDataMember *member) {
        [wself prepareData];
        [wself.tableView reloadData];
    }];
}

- (void)onBlackListChanged{
    [self prepareData];
    [self.tableView reloadData];
}

@end
