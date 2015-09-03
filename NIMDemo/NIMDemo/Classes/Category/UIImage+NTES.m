//
//  UIImage+NTESm
//  NIM
//
//  Created by chris on 15/7/13.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "UIImage+NTES.h"
#define EmojiCatalog                @"default"
#define EmoticonPath                @"Emoticon"
#define ChartletChartletCatalogPath @"Chartlet"
#define ChartletChartletCatalogContentPath @"content"
#define ChartletChartletCatalogIconPath    @"icon"
#define ChartletChartletCatalogIconsSuffixNormal    @"normal"
#define ChartletChartletCatalogIconsSuffixHighLight @"highlighted"

@implementation UIImage (NTES)
+ (UIImage *)fetchImage:(NSString *)imageNameOrPath{
    UIImage *image = [UIImage imageNamed:imageNameOrPath];
    if (!image) {
        image = [UIImage imageWithContentsOfFile:imageNameOrPath];
    }
    return image;
}


+ (UIImage *)fetchChartlet:(NSString *)imageName chartletId:(NSString *)chartletId{
    if ([chartletId isEqualToString:EmojiCatalog]) {
        return [UIImage imageNamed:imageName];
    }
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"NIMKitResouce" ofType:@"bundle"];

    NSString *subDirectory = [NSString stringWithFormat:@"%@/%@/%@/%@",EmoticonPath,ChartletChartletCatalogPath,chartletId,ChartletChartletCatalogContentPath];
    //先拿2倍图
    NSString *doubleImage  = [imageName stringByAppendingString:@"@2x"];
    NSString *tribleImage  = [imageName stringByAppendingString:@"@3x"];
    NSString *sourcePath   = [bundlePath stringByAppendingPathComponent:subDirectory];
    NSString *path = nil;
    
    NSArray *array = [NSBundle pathsForResourcesOfType:nil inDirectory:sourcePath];
    NSString *fileExt = [[array.firstObject lastPathComponent] pathExtension];
    if ([UIScreen mainScreen].scale == 3.0) {
        path = [NSBundle pathForResource:tribleImage ofType:fileExt inDirectory:sourcePath];
    }
    path = path ? path : [NSBundle pathForResource:doubleImage ofType:fileExt inDirectory:sourcePath]; //取二倍图
    path = path ? path : [NSBundle pathForResource:imageName ofType:fileExt inDirectory:sourcePath]; //实在没了就去取一倍图
    return [UIImage imageWithContentsOfFile:path];
}

@end
