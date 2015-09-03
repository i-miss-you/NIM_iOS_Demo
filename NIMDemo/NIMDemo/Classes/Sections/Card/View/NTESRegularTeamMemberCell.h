//
//  NTESRegularTeamMemberCell.h
//  NIM
//
//  Created by chris on 15/3/26.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NTESRegularTeamMemberCellActionDelegate <NSObject>

- (void)didSelectAddOpeartor;

@end


@interface NTESRegularTeamMemberCell : UITableViewCell

@property(nonatomic,weak) id<NTESRegularTeamMemberCellActionDelegate>delegate;

- (void)rereshWithTeam:(NIMTeam*)team
               members:(NSArray*)members;
@end
