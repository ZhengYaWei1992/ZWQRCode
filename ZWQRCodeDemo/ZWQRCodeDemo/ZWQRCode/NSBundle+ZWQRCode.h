//
//  NSBundle+ZWQRCode.h
//  ZWQRCodeDemo
//
//  Created by 郑亚伟 on 2017/2/21.
//  Copyright © 2017年 zhengyawei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface NSBundle (ZWQRCode)

+ (instancetype)zw_qrCodeBundle;
+ (UIImage *)zw_qrCodeImageWithName:(NSString *)name;
@end
