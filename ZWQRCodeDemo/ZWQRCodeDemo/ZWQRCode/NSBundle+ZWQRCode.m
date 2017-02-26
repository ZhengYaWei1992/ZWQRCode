//
//  NSBundle+ZWQRCode.m
//  ZWQRCodeDemo
//
//  Created by 郑亚伟 on 2017/2/21.
//  Copyright © 2017年 zhengyawei. All rights reserved.
//

#import "NSBundle+ZWQRCode.h"
#import "ZWQRCodeController.h"

@implementation NSBundle (ZWQRCode)
+ (instancetype)zw_qrCodeBundle{
    static NSBundle *bundle = nil;
    bundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[ZWQRCodeController class]] pathForResource:@"ZWQRCodeController" ofType:@"bundle"]];
    return bundle;
}
+ (UIImage *)zw_qrCodeImageWithName:(NSString *)name{
    static UIImage *image = nil;
    image = [[UIImage imageWithContentsOfFile:[[self zw_qrCodeBundle] pathForResource:name ofType:@"png"]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    return image;
}

@end
