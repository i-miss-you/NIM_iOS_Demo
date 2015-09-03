//
//  TeamAnnouncementListCell.m
//  NIM
//
//  Created by Xuhui on 15/3/31.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NTESTeamAnnouncementListCell.h"
#import "NTESUsrInfoData.h"
#import "NTESSessionUtil.h"

@interface NTESTeamAnnouncementListCell ()
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *infoLabel;
@property (strong, nonatomic) IBOutlet UIView *line;
@property (strong, nonatomic) IBOutlet UILabel *contentLabel;

@end

@implementation NTESTeamAnnouncementListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _infoLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _line.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _contentLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)refreshData:(NSDictionary *)data team:(NIMTeam *)team{
    NSString *title = [data objectForKey:@"title"];
    _titleLabel.text = title;
    NSString *content = [data objectForKey:@"content"];
    _contentLabel.text = content;
    NSString *creatorId = [data objectForKey:@"creator"];
    NSNumber *time = [data objectForKey:@"time"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM-dd HH:mm"];
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:time.integerValue];
    NIMSession *session = [NIMSession session:team.teamId type:NIMSessionTypeTeam];
    NSString *nick = [NTESSessionUtil showNick:creatorId inSession:session];
    _infoLabel.text = [NSString stringWithFormat:@"%@ %@", nick, [dateFormatter stringFromDate:date]];
}

@end
