//
//  NTESContactDataItem.m
//  NIM
//
//  Created by chris on 15/2/26.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NTESContactDataItem.h"
#import "NTESSpellingCenter.h"
#import "NTESUsrInfoData.h"

@implementation NTESContactDataItem

- (NSString*)reuseId{
    return @"NTESContactDataItem";
}

- (NSString*)cellName{
    return @"NTESContactDataCell";
}

@end


@implementation ContactDataMember
@synthesize usrId = _usrId;
@synthesize iconId = _iconUrl;
@synthesize nick = _nick;

- (CGFloat)uiHeight{
    return NTESContactDataRowHeight;
}

//userId和Vcname必有一个有值，根据有值的状态push进不同的页面

- (NSString *)vcName{
    return nil;
}

- (NSString *)reuseId{
    return @"NTESContactDataItem";
}

- (NSString *)cellName{
    return @"NTESContactDataCell";
}

- (NSString *)badge{
    return @"";
}

- (NSString *)groupTitle {
    NSString *title = [[NTESSpellingCenter sharedCenter] firstLetter:self.nick].capitalizedString;
    unichar character = [title characterAtIndex:0];
    if (character >= 'A' && character <= 'Z') {
        return title;
    }else{
        return @"#";
    }
}

- (NSString *)memberId{
    return self.usrId;
}

- (BOOL)showAccessoryView{
    return NO;
}

- (id)sortKey {
    return [[NTESSpellingCenter sharedCenter] spellingForString:self.nick].shortSpelling;
}

- (BOOL)isEqual:(id)object{
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    return [self.usrId isEqualToString:[object usrId]];
}

@end