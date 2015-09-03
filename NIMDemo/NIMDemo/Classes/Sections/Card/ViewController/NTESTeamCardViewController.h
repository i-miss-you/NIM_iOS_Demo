//
//  NTESTeamCardViewController.h
//  NIM
//
//  Created by chris on 15/3/4.
//  Copyright (c) 2015年 Netease. All rights reserved.
//
#import "NTESCardDataSourceProtocol.h"
#import "NTESTeamCardHeaderCell.h"
@interface NTESTeamCardViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UITableViewDataSource,UITableViewDelegate,TeamCardHeaderCellDelegate>

@property (nonatomic,strong) UITableView *tableView;

@property (nonatomic,assign) NTESCardHeaderOpeator currentOpera;

- (void)reloadMembers:(NSArray*)members;

- (void)addMembers:(NSArray*)members;

- (void)removeMembers:(NSArray*)members;

@end

@interface NTESTeamCardViewController (Override)

- (NSString*)title;

- (NSArray*)buildBodyData;

@end


@interface NTESTeamCardViewController (Refresh)

- (void)refreshTitle;
- (void)refreshWithMembers:(NSArray*)members;
- (void)refreshTableHeader;
- (void)refreshTableBody;

@end
