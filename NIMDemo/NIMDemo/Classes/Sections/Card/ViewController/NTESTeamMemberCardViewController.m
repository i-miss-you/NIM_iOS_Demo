//
//  TeamMemberCardViewController.m
//  NIM
//
//  Created by Xuhui on 15/3/19.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NTESTeamMemberCardViewController.h"
#import "NTESAvatarImageView.h"
#import "NTESCardMemberItem.h"
#import "NTESUsrInfoData.h"
#import "NTESSessionUtil.h"
#import "UIAlertView+NTESBlock.h"
#import "UIActionSheet+NTESBlock.h"
#import "UIView+Toast.h"
#import "UIView+NTES.h"
#import "UIAlertView+NTESBlock.h"

typedef NS_ENUM(NSInteger, TeamMemberCardSectionType) {
    TeamMemberCardSectionHead,
    TeamMemberCardSectionNick,
    TeamMemberCardSectionMemberType,
    TeamMemberCardSectionAction,
    TeamMemberCardSectionCount
};

@interface NTESTeamMemberCardViewController () <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet NTESAvatarImageView *avatarImageView;
@property (strong, nonatomic) IBOutlet UITableViewCell *headCell;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;

@property (strong, nonatomic) IBOutlet UITableViewCell *nickCell;

@property (strong, nonatomic) IBOutlet UITableViewCell *memberTypeCell;

@property (strong, nonatomic) IBOutlet UITableViewCell *btnCell;
@property (strong, nonatomic) IBOutlet UIButton *kickBtn;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NTESUsrInfo *usrInfo;
@end

@implementation NTESTeamMemberCardViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) {

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"群名片";
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    __weak typeof(self) weakSelf = self;
    self.usrInfo = [[NTESUsrInfoData sharedInstance] queryUsrInfoById:[self.member memberId] needRemoteFetch:YES fetchCompleteHandler:^(NTESUsrInfo *info) {
        if(info) {
            weakSelf.usrInfo = info;
            [weakSelf.tableView reloadData];
        }
        
    }];
}

- (NSString *)memberTypeString:(NIMTeamMemberType)type {
    if(type == NIMTeamMemberTypeNormal) {
        return @"普通群员";
    } else if (type == NIMTeamMemberTypeOwner) {
        return @"群主";
    } else if (type == NIMTeamMemberTypeManager) {
        return @"管理员";
    }
    return @"";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onKickBtnClick:(id)sender {
    __weak typeof(self) wself = self;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"移出本群" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert showAlertWithCompletionHandler:^(NSInteger index) {
        if(alert.cancelButtonIndex != index) {
            [[NIMSDK sharedSDK].teamManager kickUsers:@[self.member.memberId] fromTeam:self.member.team.teamId completion:^(NSError *error) {
                if(!error) {
                    [wself.view makeToast:@"踢人成功"];
                    [wself.navigationController popViewControllerAnimated:YES];
                    if([_delegate respondsToSelector:@selector(onTeamMemberKicked:)]) {
                        [_delegate onTeamMemberKicked:wself.member];
                    }
                } else {
                    [wself.view makeToast:@"踢人失败"];
                }
            }];
        }
    }];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    switch (row) {
        case TeamMemberCardSectionHead: {
            return 222;
        } break;
        case TeamMemberCardSectionNick: {
            return 50;
        } break;
        case TeamMemberCardSectionMemberType: {
            return 50;
        } break;
        case TeamMemberCardSectionAction: {
            return 70;
        } break;
        default: {
            return 0;
        } break;
    }

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSInteger row = indexPath.row;
    if(row == TeamMemberCardSectionNick) {
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
                        [[NIMSDK sharedSDK].teamManager updateUserNick:self.member.memberId newNick:name inTeam:wself.member.team.teamId completion:^(NSError *error) {
                            if (!error) {
                                [wself.view makeToast:@"修改成功"];
                                [wself.tableView reloadData];
                                if([_delegate respondsToSelector:@selector(onTeamMemberInfoChaneged:)]) {
                                    [_delegate onTeamMemberInfoChaneged:wself.member];
                                }
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
        
    } else if (row == TeamMemberCardSectionMemberType) {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"管理员操作" delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles: self.member.type == NIMTeamMemberTypeManager ? @"取消管理员" : @"设为管理员", nil];
        __weak typeof(self) wself = self;
        [sheet showInView:self.view completionHandler:^(NSInteger index) {
            if(index == 0) {
                if (wself.member.type == NIMTeamMemberTypeManager) {
                    [wself removeManager:wself.member.memberId];
                }else{
                    [wself addManager:wself.member.memberId];
                }
            }
        }];
    }
   
}

- (void)removeManager:(NSString *)memberId{
    __block typeof(self) wself = self;
    [[NIMSDK sharedSDK].teamManager removeManagersFromTeam:self.member.team.teamId users:@[self.member.memberId] completion:^(NSError *error) {
        if (!error) {
            wself.member.type = NIMTeamMemberTypeNormal;
            [wself.view makeToast:@"修改成功"];
            [wself.tableView reloadData];
            if([_delegate respondsToSelector:@selector(onTeamMemberInfoChaneged:)]) {
                [_delegate onTeamMemberInfoChaneged:wself.member];
            }
        }else{
            [wself.view makeToast:@"修改失败"];
        }
        
    }];
}

- (void)addManager:(NSString *)memberId{
    __block typeof(self) wself = self;
    [[NIMSDK sharedSDK].teamManager addManagersToTeam:self.member.team.teamId users:@[self.member.memberId] completion:^(NSError *error) {
        if (!error) {
            wself.member.type = NIMTeamMemberTypeManager;
            [wself.view makeToast:@"修改成功"];
            [wself.tableView reloadData];
            if([_delegate respondsToSelector:@selector(onTeamMemberInfoChaneged:)]) {
                [_delegate onTeamMemberInfoChaneged:wself.member];
            }
        }else{
            [wself.view makeToast:@"修改失败"];
        }
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return TeamMemberCardSectionCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    switch (row) {
        case TeamMemberCardSectionHead: {
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TeamMemberCardHeadCell"];
            UIImage *avatar = self.usrInfo.iconId ? [UIImage imageNamed:self.usrInfo.iconId] : self.member.imageNormal;
            NTESAvatarImageView *avatarView = [[NTESAvatarImageView alloc] initWithFrame:CGRectMake(125, 52, 70, 70)];
            avatarView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
            avatarView.image = avatar;
            [cell addSubview:avatarView];
            
            UILabel *nickLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            nickLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
            nickLabel.font = [UIFont systemFontOfSize:17];
            nickLabel.textColor = [UIColor colorWithRed:51.0 / 255 green:51.0 / 255 blue:51.0 / 255 alpha:1.0];
            NIMSession *session = [NIMSession session:self.member.team.teamId type:NIMSessionTypeTeam];
            nickLabel.text = [NTESSessionUtil showNick:self.member.memberId inSession:session];
            [nickLabel sizeToFit];
            nickLabel.centerX = avatarView.centerX;
            nickLabel.top = avatarView.bottom + 10;
            [cell addSubview:nickLabel];
            cell.userInteractionEnabled = NO;
            return cell;
            
        } break;
        case TeamMemberCardSectionNick: {
            NIMTeamMember *member = [[NIMSDK sharedSDK].teamManager teamMember:self.member.memberId inTeam:self.member.team.teamId];
            if (member.nickname.length) {
                self.nickCell.detailTextLabel.text = member.nickname;
            }else{
                self.nickCell.detailTextLabel.text = @"未设置";
            }
            if(self.viewer.type == NIMTeamMemberTypeNormal && ![self.viewer.memberId isEqualToString:self.member.memberId]){
                self.nickCell.userInteractionEnabled = NO;
                self.nickCell.accessoryType = UITableViewCellAccessoryNone;
            } else {
                self.nickCell.userInteractionEnabled = YES;
                self.nickCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            return self.nickCell;
        } break;
        case TeamMemberCardSectionMemberType: {
            self.memberTypeCell.detailTextLabel.text = [self memberTypeString:self.member.type];
            if(self.viewer.type == NIMTeamMemberTypeOwner && ![self.viewer.memberId isEqualToString:self.member.memberId]) {
                self.memberTypeCell.userInteractionEnabled = YES;
                self.memberTypeCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            } else {
                self.memberTypeCell.userInteractionEnabled = NO;
                self.memberTypeCell.accessoryType = UITableViewCellAccessoryNone;
            }
            return self.memberTypeCell;
        } break;
        case TeamMemberCardSectionAction: {
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TeamMemberCardActionCell"];
            UIButton *kickBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            kickBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
            kickBtn.frame = CGRectMake(8, 25, 305, 45);
            [kickBtn setBackgroundImage:[UIImage imageNamed:@"icon_cell_red_normal"] forState:UIControlStateNormal];
            kickBtn.titleLabel.font = [UIFont systemFontOfSize:19];
            [kickBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [kickBtn setTitle:@"移出本群" forState:UIControlStateNormal];
            [kickBtn addTarget:self action:@selector(onKickBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:kickBtn];
            if(self.viewer.type == NIMTeamMemberTypeNormal || [self.viewer.memberId isEqualToString:self.member.memberId]) {
                kickBtn.hidden = YES;
                cell.userInteractionEnabled = NO;
            } else {
                kickBtn.hidden = NO;
                cell.userInteractionEnabled = YES;
            }
            return cell;
        } break;
        default: {
            return nil;
        } break;
    }
}
@end
