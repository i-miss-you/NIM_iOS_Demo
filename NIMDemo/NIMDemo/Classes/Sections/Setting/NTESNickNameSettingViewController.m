//
//  NTESNickNameSettingViewController.m
//  NIM
//
//  Created by chris on 15/8/18.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NTESNickNameSettingViewController.h"
#import "NTESCommonTableDelegate.h"
#import "NTESCommonTableData.h"
#import "NTESContactsManager.h"

@interface NTESNickNameSettingViewController ()

@property (nonatomic,strong) NTESCommonTableDelegate *delegator;

@property (nonatomic,copy  ) NSArray                 *data;

@property (nonatomic,assign) NSInteger               inputLimit;

@end

@implementation NTESNickNameSettingViewController


- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"设置昵称";
    __weak typeof(self) wself = self;
    [self buildData];
    self.delegator = [[NTESCommonTableDelegate alloc] initWithTableData:^NSArray *{
        return wself.data;
    }];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    [self.view addSubview:self.tableView];
    self.tableView.backgroundColor = UIColorFromRGB(0xe3e6ea);
    self.tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate   = self.delegator;
    self.tableView.dataSource = self.delegator;
}


- (void)buildData{
    ContactDataMember *me = [[NTESContactsManager sharedInstance] me];
    NSArray *data = @[
                      @{
                          HeaderTitle:@"",
                          RowContent :@[
                                  @{
                                      ExtraInfo     : [me nick],
                                      CellClass     : @"NTESTextSettingCell",
                                      RowHeight     : @(50),
                                      },
                                  ],
                          FooterTitle:@"好的昵称可以让你的朋友更容易记住你"
                          },
                      ];
    self.data = [NTESCommonTableSection sectionsWithData:data];
}


#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    return YES;
}


@end
