//
//  NTESContactDefines.h
//  NIM
//
//  Created by chris on 15/2/26.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#ifndef NIM_NTESContactDefines_h
#define NIM_NTESContactDefines_h

#import "NTESUsrInfoData.h"

@protocol NTESContactItemCollection <NSObject>
@required
//显示的title名
- (NSString*)title;

//返回集合里的成员
- (NSArray*)members;

//重用id
- (NSString*)reuseId;

//需要构造的cell类名
- (NSString*)cellName;

@end

@protocol NTESContactItem <NTESMemberInfoProtocol>
@required
//userId和Vcname必有一个有值，根据有值的状态push进不同的页面
- (NSString*)vcName;

//返回行高
- (CGFloat)uiHeight;

//重用id
- (NSString*)reuseId;

//需要构造的cell类名
- (NSString*)cellName;

//badge
- (NSString *)badge;

//accessoryView
- (BOOL)showAccessoryView;


@end

@protocol NTESContactCell <NSObject>

- (void)refreshWithContactItem:(id<NTESContactItem>)item;

- (void)addDelegate:(id)delegate;

@end

#endif


#ifndef NIM_NTESContactCellLayoutConstant_h
#define NIM_NTESContactCellLayoutConstant_h
static const CGFloat   NTESContactUtilRowHeight             = 57;//util类Cell行高
static const CGFloat   NTESContactDataRowHeight             = 50;//data类Cell行高
static const NSInteger NTESContactAccessoryLeft             = 10;//选择框到左边的距离
static const NSInteger NTESContactAvatarLeft                = 10;//没有选择框的时候，头像到左边的距离
static const NSInteger NTESContactAvatarAndAccessorySpacing = 10;//头像和选择框之间的距离
static const NSInteger NTESContactAvatarAndTitleSpacing     = 20;//头像和文字之间的间距

#endif

