//
//  NTESContactSelectViewController.m
//  NIM
//
//  Created by Xuhui on 15/3/2.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NTESContactSelectViewController.h"
#import "NTESGroupedContacts.h"
#import "NTESContactDataItem.h"
#import "NTESContactPickedView.h"
#import "NTESUsrInfoData.h"
#import "NTESContactDataCell.h"
#import "NTESGroupedUsrInfo.h"
#import "NTESSessionUtil.h"
#import "NTESContactsManager.h"
@interface NTESContactSelectViewController () <UITableViewDataSource, UITableViewDelegate, NTESContactPickedViewDelegate> {
    NSMutableArray *_selectecContacts;
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet NTESContactPickedView *selectIndicatorView;

@end

@implementation NTESContactSelectViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) {
        _maxSelectCount = NSIntegerMax;
        _selectecContacts = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _tableView.dataSource = self;
    _tableView.delegate = self;
    self.navigationItem.title = @"选择联系人";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(onCancelBtnClick:)];
    _selectIndicatorView.delegate = self;
    for (NSString *selectId in _selectecContacts) {
        id member = [_dataCollection memberOfId:selectId];
        [_selectIndicatorView addUser:member];
    }
}



- (void)onCancelBtnClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^() {
        if (self.cancelBlock) {
            self.cancelBlock();
            self.cancelBlock = nil;
        }
        if([_delegate respondsToSelector:@selector(didCancelledSelect)]) {
            [_delegate didCancelledSelect];
        }
    }];
}
                                              
- (IBAction)onDoneBtnClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^() {
        if (self.finshBlock) {
            self.finshBlock(_selectecContacts);
            self.finshBlock = nil;
        }
        if([_delegate respondsToSelector:@selector(didFinishedSelect:)]) {
            [_delegate didFinishedSelect:_selectecContacts];
        }
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_dataCollection groupCount];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataCollection memberCountOfGroup:section];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [_dataCollection titleOfGroup:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id contactItem = [_dataCollection memberOfIndex:indexPath];
    NTESContactDataCell * cell = [tableView dequeueReusableCellWithIdentifier:@"SelectContactCellID"];
    if (cell == nil) {
        cell = [[NTESContactDataCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SelectContactCellID"];
    }
    cell.accessoryBtn.hidden = NO;
    cell.accessoryBtn.selected = [_selectecContacts containsObject:[(id<NTESMemberInfoProtocol>)contactItem usrId]];
    [cell refreshWithContactItem:contactItem];
    return cell;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [_dataCollection sortedGroupTitles];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NTESContactDataRowHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id member = [_dataCollection memberOfIndex:indexPath];
    NSString *usrID = [(id<NTESMemberInfoProtocol>)member usrId];
    NTESContactDataCell *cell = (NTESContactDataCell *)[tableView cellForRowAtIndexPath:indexPath];
    if([_selectecContacts containsObject:usrID]) {
        [_selectecContacts removeObject:usrID];
        cell.accessoryBtn.selected = NO;
        [_selectIndicatorView removeUser:usrID];
    } else if(_selectecContacts.count >= _maxSelectCount) {
        cell.accessoryBtn.selected = NO;
    } else {
        [_selectecContacts addObject:usrID];
        cell.accessoryBtn.selected = YES;
        [_selectIndicatorView addUser:member];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - ContactPickedViewDelegate

- (void)removeUser:(NSString *)userId {
    [_selectecContacts removeObject:userId];
    [_tableView reloadData];
}

@end


@implementation NTESContactSelectViewController(Initialize)

- (instancetype)initCommonContactSelector{
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        NSMutableArray *users = [[[NTESContactsManager sharedInstance] allMyFriendsIds] mutableCopy];
        NSString *currentUserID = [[[NIMSDK sharedSDK] loginManager] currentAccount];
        [users removeObject:currentUserID];
        NSMutableArray *infos = [[NSMutableArray alloc] init];
        for (NSString *uid in users) {
            NTESUsrInfo *member = [[NTESUsrInfoData sharedInstance] queryUsrInfoById:uid needRemoteFetch:NO fetchCompleteHandler:nil];
            [infos addObject:member];
        }
        NTESGroupedUsrInfo *groupedInfo = [[NTESGroupedUsrInfo alloc] initWithContacts:infos];
        _dataCollection = groupedInfo;
    }
    return self;
}

- (instancetype)initTeamSelector{
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        NSArray *teams = [NIMSDK sharedSDK].teamManager.allMyTeams;
        NTESGroupedTeamInfo *groupedInfo = [[NTESGroupedTeamInfo alloc] initWithTeams:teams];
        _dataCollection = groupedInfo;
    }
    return self;
}

- (instancetype) initContactSeleorWithMembers:(NSArray *)members{
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        NSMutableArray *infos = [[NSMutableArray alloc] init];
        for (NSString *uid in members) {
            NTESUsrInfo *member = [[NTESUsrInfoData sharedInstance] queryUsrInfoById:uid needRemoteFetch:NO fetchCompleteHandler:nil];
            [infos addObject:member];
        }
        NTESGroupedUsrInfo *groupedInfo = [[NTESGroupedUsrInfo alloc] initWithContacts:infos];
        _dataCollection = groupedInfo;
    }
    return self;
}

- (instancetype)initTeamContactSeleorWithMembers:(NSArray *)members teamId:(NSString *)teamId{
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        NSMutableArray *infos = [[NSMutableArray alloc] init];
        for (NSString *uid in members) {
            NTESUsrInfo *member = [[NTESUsrInfoData sharedInstance] queryUsrInfoById:uid needRemoteFetch:NO fetchCompleteHandler:nil];
            
            NIMSession *session = [NIMSession session:teamId type:NIMSessionTypeTeam];
            member.nick = [NTESSessionUtil showNick:member.usrId inSession:session];
            
            [infos addObject:member];
        }
        NTESGroupedUsrInfo *groupedInfo = [[NTESGroupedUsrInfo alloc] initWithContacts:infos];
        _dataCollection = groupedInfo;
    }
    return self;
}

@end
