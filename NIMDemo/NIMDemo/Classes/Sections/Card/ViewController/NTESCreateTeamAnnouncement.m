//
//  NTESCreateTeamAnnouncement.m
//  NIM
//
//  Created by Xuhui on 15/3/31.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NTESCreateTeamAnnouncement.h"
#import "UIAlertView+NTESBlock.h"

@interface NTESCreateTeamAnnouncement () <UITextFieldDelegate, UITextViewDelegate>
@property (strong, nonatomic) IBOutlet UITextField *titleTextField;
@property (strong, nonatomic) IBOutlet UITextView *contentTextView;

@end

@implementation NTESCreateTeamAnnouncement

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(onSave:)];
    self.titleTextField.delegate = self;
    self.contentTextView.delegate = self;
    self.titleTextField.text  = self.defaultTitle;
    self.contentTextView.text = self.defaultContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.titleTextField endEditing:YES];
    [self.contentTextView endEditing:YES];
}

- (void)onSave:(id)sender {
    [self.titleTextField endEditing:YES];
    [self.contentTextView endEditing:YES];
    NSString *title = [self.titleTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *content = [self.contentTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if(title.length <= 0 || content.length  <= 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"标题或者内容不能为空" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    [self.navigationController popViewControllerAnimated:YES];
    if([self.delegate respondsToSelector:@selector(createTeamAnnouncementCompleteWithTitle:content:)]) {
        [self.delegate createTeamAnnouncementCompleteWithTitle:title content:content];
    }
}

#pragma mark - UITextFieldDelegate

#pragma mark - UITextViewDelegate

@end
