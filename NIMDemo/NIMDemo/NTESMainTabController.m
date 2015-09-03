//
//  MainTabController.m
//  NIMDemo
//
//  Created by chris on 15/2/2.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NTESMainTabController.h"
#import "NTESAppDelegate.h"
#import "NTESSessionListViewController.h"
#import "NTESContactViewController.h"
#import "NIMSDK.h"
#import "UIImage+NTESColor.h"
#import "NTESCustomNotificationDB.h"
#import "NTESNotificationCenter.h"

#define TabbarVC    @"vc"
#define TabbarTitle @"title"
#define TabbarImage @"image"
#define TabbarSelectedImage @"selectedImage"
#define TabbarItemBadgeValue @"badgeValue"

@interface NTESMainTabController ()<NIMSystemNotificationManagerDelegate,NIMConversationManagerDelegate,UINavigationControllerDelegate>

@property (nonatomic,assign) NSInteger sessionUnreadCount;

@property (nonatomic,assign) NSInteger systemUnreadCount;

@property (nonatomic,assign) NSInteger customSystemUnreadCount;

@end

@implementation NTESMainTabController

+ (instancetype)instance{
    NTESAppDelegate *delegete = (NTESAppDelegate *)[UIApplication sharedApplication].delegate;
    UIViewController *vc = delegete.window.rootViewController;
    if ([vc isKindOfClass:[NTESMainTabController class]]) {
        return (NTESMainTabController *)vc;
    }else{
        return nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpSubNav];
    [[NIMSDK sharedSDK].systemNotificationManager addDelegate:self];
    [[NIMSDK sharedSDK].conversationManager addDelegate:self];
    extern NSString *NTESCustomNotificationCountChanged;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCustomNotifyChanged:) name:NTESCustomNotificationCountChanged object:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setUpStatusBar];
}

-(void)viewWillLayoutSubviews
{
    self.view.frame = [UIScreen mainScreen].bounds;
}


- (void)dealloc{
    [[NIMSDK sharedSDK].systemNotificationManager removeDelegate:self];
    [[NIMSDK sharedSDK].conversationManager removeDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSArray*)tabbars{
    self.sessionUnreadCount  = [NIMSDK sharedSDK].conversationManager.allUnreadCount;
    self.systemUnreadCount   = [NIMSDK sharedSDK].systemNotificationManager.allUnreadCount;
    self.customSystemUnreadCount = [[NTESCustomNotificationDB sharedInstance] unreadCount];
    NSArray *item = @[
                      @{
                          TabbarVC           : @"NTESSessionListViewController",
                          TabbarTitle        : @"云信",
                          TabbarImage        : @"icon_message_normal",
                          TabbarSelectedImage: @"icon_message_pressed",
                          TabbarItemBadgeValue: @(self.sessionUnreadCount)
                          },
                      @{
                          TabbarVC           : @"NTESContactViewController",
                          TabbarTitle        : @"通讯录",
                          TabbarImage        : @"icon_contact_normal",
                          TabbarSelectedImage: @"icon_contact_pressed",
                          TabbarItemBadgeValue: @(self.systemUnreadCount)
                          },
                      @{
                          TabbarVC           : @"NTESSettingViewController",
                          TabbarTitle        : @"设置",
                          TabbarImage        : @"icon_setting_normal",
                          TabbarSelectedImage: @"icon_setting_pressed",
                          TabbarItemBadgeValue: @(self.customSystemUnreadCount)
                          },

                      ];
     return item;
}


- (void)setUpSubNav{
    NSMutableArray * array = [[NSMutableArray alloc] init];
    [self.tabbars enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary * item = obj;
        NSString * vcName = item[TabbarVC];
        NSString * title  = item[TabbarTitle];
        NSString * imageName = item[TabbarImage];
        NSString * imageSelected = item[TabbarSelectedImage];
        Class clazz = NSClassFromString(vcName);
        UIViewController * vc = [[clazz alloc] initWithNibName:nil bundle:nil];
        vc.hidesBottomBarWhenPushed = NO;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        nav.delegate = self;
        nav.tabBarItem = [[UITabBarItem alloc] initWithTitle:title
                                                       image:[UIImage imageNamed:imageName]
                                               selectedImage:[UIImage imageNamed:imageSelected]];
        nav.tabBarItem.tag = idx;
        NSInteger badge = [item[TabbarItemBadgeValue] integerValue];
        if (badge) {
            nav.tabBarItem.badgeValue = [NSString stringWithFormat:@"%zd",badge];
        }
        [array addObject:nav];
    }];
    self.viewControllers = array;
}


- (void)setUpStatusBar{
    UIStatusBarStyle style = UIStatusBarStyleDefault;
    [[UIApplication sharedApplication] setStatusBarStyle:style
                                                animated:NO];
}

#pragma mark - NIMConversationManagerDelegate
- (void)didAddRecentSession:(NIMRecentSession *)recentSession
           totalUnreadCount:(NSInteger)totalUnreadCount{
    self.sessionUnreadCount = totalUnreadCount;
    [self refreshSessionBadge];
}


- (void)didUpdateRecentSession:(NIMRecentSession *)recentSession
              totalUnreadCount:(NSInteger)totalUnreadCount{
    self.sessionUnreadCount = totalUnreadCount;
    [self refreshSessionBadge];
}


- (void)didRemoveRecentSession:(NIMRecentSession *)recentSession totalUnreadCount:(NSInteger)totalUnreadCount{
    self.sessionUnreadCount = totalUnreadCount;
    [self refreshSessionBadge];
}

- (void)messagesDeletedInSession:(NIMSession *)session{
    self.sessionUnreadCount = [NIMSDK sharedSDK].conversationManager.allUnreadCount;
    [self refreshSessionBadge];
}

- (void)allMessagesDeleted{
    self.sessionUnreadCount = 0;
    [self refreshSessionBadge];
}

#pragma mark - NIMSystemNotificationManagerDelegate
- (void)onSystemNotificationCountChanged:(NSInteger)unreadCount
{
    self.systemUnreadCount = unreadCount;
    [self refreshContactBadge];
}

#pragma mark - Notification
- (void)onCustomNotifyChanged:(NSNotification *)notification
{
    NTESCustomNotificationDB *db = [NTESCustomNotificationDB sharedInstance];
    self.customSystemUnreadCount = db.unreadCount;
    [self refreshSettingBadge];
}



- (void)refreshSessionBadge{
    UINavigationController *nav = self.viewControllers[0];
    nav.tabBarItem.badgeValue = self.sessionUnreadCount ? @(self.sessionUnreadCount).stringValue : nil;
}

- (void)refreshContactBadge{
    UINavigationController *nav = self.viewControllers[1];
    NSInteger badge = self.systemUnreadCount;
    nav.tabBarItem.badgeValue = badge ? @(badge).stringValue : nil;
}

- (void)refreshSettingBadge{
    UINavigationController *nav = self.viewControllers[2];
    NSInteger badge = self.customSystemUnreadCount;
    nav.tabBarItem.badgeValue = badge ? @(badge).stringValue : nil;
}


- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}


@end
