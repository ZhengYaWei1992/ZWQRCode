//
//  ZWQRCodeController.h
//  ZWQRCodeDemo
//
//  Created by 郑亚伟 on 2017/2/21.
//  Copyright © 2017年 zhengyawei. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ZWQRCodeResultType) {
    ZWQRCodeResultTypeSuccess = 0, // 1.成功获取图片中的二维码信息
    ZWQRCodeResultTypeNoInfo = 1,  // 2.识别的图片没有二维码信息
    ZWQRCodeResultTypeError = 2   // 3.其他错误
};

@class ZWQRCodeController;
@protocol ZWQRCodeControllerDelegate <NSObject>
//扫面后的回调
- (void)qrcodeController:(ZWQRCodeController *)qrcodeController readerScanResult:(NSString *)readerScanResult type:(ZWQRCodeResultType)resultType;
@end

@interface ZWQRCodeController : UIViewController
@property(nonatomic, weak)id<ZWQRCodeControllerDelegate>delegate;

@end
