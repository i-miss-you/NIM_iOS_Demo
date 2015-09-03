//
//  NTESContactSelectViewController.h
//  NIM
//
//  Created by Xuhui on 15/3/2.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^ContactSelectFinishBlock)(NSArray *);
typedef void(^ContactSelectCancelBlock)(void);

@class NTESGroupedDataCollection;

@protocol NTESContactSelectDelegate <NSObject>

- (void)didFinishedSelect:(NSArray *)selectedContacts; // 返回userID

@optional
- (void)didCancelledSelect;

@end

@interface NTESContactSelectViewController : UIViewController


@property (nonatomic, weak) id<NTESContactSelectDelegate> delegate;
@property (nonatomic, strong) NTESGroupedDataCollection *dataCollection;
@property (nonatomic, assign) NSInteger maxSelectCount;
@property (nonatomic, copy) ContactSelectFinishBlock finshBlock;
@property (nonatomic, copy) ContactSelectCancelBlock cancelBlock;


@end


@interface NTESContactSelectViewController(Initialize)
//常规联系人选择器，选择除了自己以外的所有好友。
- (instancetype)initCommonContactSelector;

//群组选择器
- (instancetype)initTeamSelector;

//自定义联系人选择器，传入所需要显示的Id
- (instancetype)initContactSeleorWithMembers:(NSArray *)members;

//自定义群联系人选择器，传入所需要显示的Id，会显示群昵称(如果没有则是常规昵称)
- (instancetype)initTeamContactSeleorWithMembers:(NSArray *)members teamId:(NSString *)teamId;

@end
