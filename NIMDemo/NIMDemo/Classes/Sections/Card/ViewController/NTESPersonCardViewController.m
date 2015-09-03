//
//  NTESPersonCardViewController.m
//  NIM
//
//  Created by chris on 15/8/18.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NTESPersonCardViewController.h"
#import "NTESCommonTableDelegate.h"
#import "NTESCommonTableData.h"
#import "NTESContactsManager.h"
#import "UIView+Toast.h"
#import "SVProgressHUD.h"
#import "NTESColorButtonCell.h"
#import "UIView+NTES.h"
#import "NTESSessionViewController.h"
#import "NTESBundleSetting.h"
#import "UIAlertView+NTESBlock.h"

@interface NTESPersonCardViewController ()

@property (nonatomic,strong) NTESCommonTableDelegate *delegator;

@property (nonatomic,copy  ) NSArray                 *data;

@property (nonatomic,strong) ContactDataMember       *user;

@property (nonatomic,strong) NTESColorButton         *chatButton;

@property (nonatomic,strong) NTESColorButton         *deleteFriendButton;

@property (nonatomic,strong) NTESColorButton         *addFriendButton;

@end

@implementation NTESPersonCardViewController

- (instancetype)initWithUserId:(NSString *)userId{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _user = [[ContactDataMember alloc] init];
        _user.usrId = userId;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"个人名片";
    __weak typeof(self) wself = self;
    self.delegator = [[NTESCommonTableDelegate alloc] initWithTableData:^NSArray *{
        return wself.data;
    }];
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    [self.view addSubview:self.tableView];
    self.tableView.backgroundColor = UIColorFromRGB(0xe3e6ea);
    self.tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate   = self.delegator;
    self.tableView.dataSource = self.delegator;
    self.tableView.scrollEnabled = NO;
    self.chatButton         = [self makeButton:@"聊天" style:ColorButtonCellStyleBlue action:@selector(chat)];
    self.deleteFriendButton = [self makeButton:@"删除好友" style:ColorButtonCellStyleRed action:@selector(deleteFriend)];
    self.addFriendButton    = [self makeButton:@"添加好友" style:ColorButtonCellStyleBlue action:@selector(addFriend)];
    [self refresh];
    [[NTESContactsManager sharedInstance] queryContactByUsrId:self.user.usrId completion:^(ContactDataMember *member) {
        if (member) {
            wself.user = member;
            [wself refresh];
        }
    }];

    
    
    
}

- (void)refresh{
    [self buildData];
    [self.tableView reloadData];
    BOOL isMyFriend                = self.user.isFriend;
    BOOL isMe = [self.user.usrId isEqualToString:[NIMSDK sharedSDK].loginManager.currentAccount];
    self.chatButton.hidden         = isMe;
    self.deleteFriendButton.hidden = !isMyFriend || isMe;
    self.addFriendButton.hidden    = isMyFriend  || isMe;
    [self.view setNeedsLayout];
}


- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    CGFloat deleteButtonBottom    = 13.f;
    CGFloat chatButtonBottom      = 68.f;
    CGFloat addFriendButtonBottom = 13.f;
    [self layoutButton:self.deleteFriendButton bottom:deleteButtonBottom];
    [self layoutButton:self.chatButton bottom:chatButtonBottom];
    [self layoutButton:self.addFriendButton bottom:addFriendButtonBottom];
}


- (void)buildData{
    BOOL isMe = [self.user.usrId isEqualToString:[NIMSDK sharedSDK].loginManager.currentAccount];
    BOOL isInBlackList = [[NIMSDK sharedSDK].userManager isUserInBlackList:self.user.usrId];
    BOOL needNotify = [[NIMSDK sharedSDK].userManager notifyForNewMsg:self.user.usrId];
    NSArray *data = @[
                        @{
                          HeaderTitle:@"",
                          RowContent :@[
                                           @{
                                              ExtraInfo     : self.user ? self.user : [NSNull null],
                                              CellClass     : @"NTESSettingPortraitCell",
                                              RowHeight     : @(100),
                                            },
                                       ],
                          FooterTitle:@""
                          },
                         @{
                            HeaderTitle:@"",
                            RowContent :@[
                                    @{
                                        Title        : @"消息提醒",
                                        CellClass    : @"NTESSettingSwitcherCell",
                                        CellAction   : @"onActionNeedNotifyValueChange:",
                                        ExtraInfo    : @(needNotify),
                                        Disable      : @(isMe),
                                        ForbidSelect : @(YES)
                                        },
                                    ],
                            FooterTitle:@""
                            },
                          @{
                            HeaderTitle:@"",
                            RowContent :@[
                                           @{
                                                Title        : @"黑名单",
                                                CellClass    : @"NTESSettingSwitcherCell",
                                                CellAction   : @"onActionBlackListValueChange:",
                                                ExtraInfo    : @(isInBlackList),
                                                Disable      : @(isMe),
                                                ForbidSelect : @(YES)
                                            },
                                    ],
                            FooterTitle:@""
                            },
                      ];
    self.data = [NTESCommonTableSection sectionsWithData:data];
}

#pragma mark - Action
- (void)onActionBlackListValueChange:(id)sender{
    UISwitch *switcher = sender;
    [SVProgressHUD show];
    __weak typeof(self) wself = self;
    if (switcher.on) {
        [[NIMSDK sharedSDK].userManager addToBlackList:self.user.usrId completion:^(NSError *error) {
            [SVProgressHUD dismiss];
            if (!error) {
                [wself.view makeToast:@"拉黑成功"duration:2.0f position:CSToastPositionCenter];
            }else{
                [wself.view makeToast:@"拉黑失败"duration:2.0f position:CSToastPositionCenter];
            }
        }];
    }else{
        [[NIMSDK sharedSDK].userManager removeFromBlackBlackList:self.user.usrId completion:^(NSError *error) {
            [SVProgressHUD dismiss];
            if (!error) {
                [wself.view makeToast:@"移除黑名单成功"duration:2.0f position:CSToastPositionCenter];
            }else{
                [wself.view makeToast:@"移除黑名单失败"duration:2.0f position:CSToastPositionCenter];
            }
        }];
    }
}

- (void)onActionNeedNotifyValueChange:(id)sender{
    UISwitch *switcher = sender;
    [SVProgressHUD show];
    __weak typeof(self) wself = self;
    [[NIMSDK sharedSDK].userManager updateNotifyState:switcher.on forUser:self.user.usrId completion:^(NSError *error) {            [SVProgressHUD dismiss];
        if (error) {
            [wself.view makeToast:@"操作失败"duration:2.0f position:CSToastPositionCenter];
        }
    }];
}


- (void)chat{
    UINavigationController *nav = self.navigationController;
    NIMSession *session = [NIMSession session:self.user.usrId type:NIMSessionTypeP2P];
    NTESSessionViewController *vc = [[NTESSessionViewController alloc] initWithSession:session];
    [nav pushViewController:vc animated:YES];
    UIViewController *root = nav.viewControllers[0];
    nav.viewControllers = @[root,vc];
}

- (void)addFriend{
    NIMUserRequest *request = [[NIMUserRequest alloc] init];
    request.userId = self.user.usrId;
    request.operation = NIMUserOperationAdd;
    if ([[NTESBundleSetting sharedConfig] needVerifyForFriend]) {
        request.operation = NIMUserOperationRequest;
        request.message = @"跪求通过";
    }
    NSString *successText = request.operation == NIMUserOperationAdd ? @"添加成功" : @"请求成功";
    NSString *failedText =  request.operation == NIMUserOperationAdd ? @"添加失败" : @"请求失败";
    
    __weak typeof(self) wself = self;
    [SVProgressHUD show];
    [[NIMSDK sharedSDK].userManager requestFriend:request completion:^(NSError *error) {
        [SVProgressHUD dismiss];
        if (!error) {
            [wself.view makeToast:successText
                         duration:2.0f
                         position:CSToastPositionCenter];
            [wself refresh];
        }else{
            [wself.view makeToast:failedText
                         duration:2.0f
                         position:CSToastPositionCenter];
        }
    }];
}

- (void)deleteFriend{
    __weak typeof(self) wself = self;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"删除好友" message:@"删除好友后，将同时解除双方的好友关系" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert showAlertWithCompletionHandler:^(NSInteger index) {
        if (index == 1) {
            [SVProgressHUD show];
            [[NIMSDK sharedSDK].userManager deleteFriend:wself.user.usrId completion:^(NSError *error) {
                [SVProgressHUD dismiss];
                if (!error) {
                    [wself.view makeToast:@"删除成功"duration:2.0f position:CSToastPositionCenter];
                    [wself refresh];
                }else{
                    [wself.view makeToast:@"删除失败"duration:2.0f position:CSToastPositionCenter];
                }
            }];
        }
    }];
}


#pragma mark - Private
- (NTESColorButton *)makeButton:(NSString *)title style:(ColorButtonCellStyle)style action:(SEL)action{
    NTESColorButton *button = [[NTESColorButton alloc] initWithFrame:CGRectZero];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:title forState:UIControlStateNormal];
    button.style = style;
    [self.view addSubview:button];
    button.hidden = YES;
    return button;
}

- (void)layoutButton:(UIButton *)button bottom:(CGFloat)bottom{
    button.size = [button sizeThatFits:CGSizeMake(self.view.width, CGFLOAT_MAX)];
    button.bottom = self.view.height - bottom;
    button.centerX = self.view.width * .5f;
}

@end
