//
//  ZWQRCodeReaderView.h
//  ZWQRCodeDemo
//
//  Created by 郑亚伟 on 2017/2/21.
//  Copyright © 2017年 zhengyawei. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZWQRCodeReaderView;

@protocol ZWQRCodeReaderViewDelegate <NSObject>
- (void)qrcodeReaderView:(ZWQRCodeReaderView *)qrcodeReaderView readerScanResult:(NSString *)readerScanResult;
@end

@interface ZWQRCodeReaderView : UIView

@property (nonatomic, weak) id<ZWQRCodeReaderViewDelegate> delegate;

/** 开启扫描 */
- (void)startScan;

/** 关闭扫描 */
- (void)stopScan;
@end

