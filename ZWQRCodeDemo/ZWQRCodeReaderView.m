//
//  ZWQRCodeReaderView.m
//  ZWQRCodeDemo
//
//  Created by 郑亚伟 on 2017/2/21.
//  Copyright © 2017年 zhengyawei. All rights reserved.
//

#import "ZWQRCodeReaderView.h"
#import <AVFoundation/AVFoundation.h>

#import "NSBundle+ZWQRCode.h"
#import "ZWQRCodeConst.h"

@interface ZWQRCodeReaderView ()<AVCaptureMetadataOutputObjectsDelegate>
/** 1.中间扫描图片  带有四个角的图片*/
@property(nonatomic, strong)UIImageView *imageScanZone;
/** 2.扫描的尺寸 */
@property(nonatomic, assign)CGRect rectScanZone;
/** 3.获取会话 */
@property(nonatomic, strong)AVCaptureSession *captureSession;
/** 4.遮罩视图 */
@property(nonatomic, strong)UIView *viewMask;
/** 5.开启闪光灯 */
@property(nonatomic, strong)UIButton *buttonTurn;
/** 6.移动的图片 */
@property(nonatomic, strong)UIImageView *imageMove;
/** 7.提示语 */
@property(nonatomic, strong)UILabel *labelAlert;



@end

@implementation ZWQRCodeReaderView
- (instancetype)init{
    self = [super init];
    if (self) {
        [self setupDefault];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupDefault];
    }
    return self;
}
- (void)layoutSubviews{
    [super layoutSubviews];
    self.imageScanZone.frame = self.rectScanZone;
    self.buttonTurn.center = CGPointMake(self.imageScanZone.center.x, CGRectGetMaxY(self.imageScanZone.frame) + 100);
    //self.buttonTurn.center = CGPointMake(100, 200);
    self.labelAlert.center = CGPointMake(self.imageScanZone.center.x, CGRectGetMaxY(self.imageScanZone.frame) + 20);
}
#pragma mark -AVCaptureMetadataOutputObjectsDelegate
//扫描到结果后回调的代理方法
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    if (metadataObjects && metadataObjects.count > 0 ) {
        AVMetadataMachineReadableCodeObject * metadataObject = metadataObjects[0];
        //输出扫描字符串
        if (self.delegate && [self.delegate respondsToSelector:@selector(qrcodeReaderView:readerScanResult:)]) {
            [self.delegate qrcodeReaderView:self readerScanResult:metadataObject.stringValue];
        }
    }
    
    [self stopScan];
}

#pragma mark- Action
//闪光灯按钮点击事件
- (void)turnTorchEvent:(UIButton *)button{
    button.selected = !button.selected;
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (captureDeviceClass != nil) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([device hasTorch] && [device hasFlash]){
            
            [device lockForConfiguration:nil];
            if (button.selected) {
                [device setTorchMode:AVCaptureTorchModeOn];
                [device setFlashMode:AVCaptureFlashModeOn];
            } else {
                [device setTorchMode:AVCaptureTorchModeOff];
                [device setFlashMode:AVCaptureFlashModeOff];
            }
            [device unlockForConfiguration];
        }
    }
}

#pragma mark- public
//开始扫描
- (void)startScan{
    [self.captureSession startRunning];
    [self startAnimation];
}
//停止扫描
- (void)stopScan{
    [self.captureSession stopRunning];
    [self stopAnimation];
}

#pragma mark- private私有方法
- (void)setupDefault{
    // 1.基本属性
    [self setFrame:CGRectMake(0, 0, ZW_QRCODE_ScreenWidth, ZW_QRCODE_ScreenHeight)];
    [self setBackgroundColor:[UIColor blackColor]];
    [self addSubview:self.viewMask];
    [self addSubview:self.imageMove];
    [self addSubview:self.imageScanZone];
    [self addSubview:self.buttonTurn];
    [self addSubview:self.labelAlert];
    
    // 2.采样的区域
    AVCaptureVideoPreviewLayer * layer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
    layer.videoGravity=AVLayerVideoGravityResizeAspectFill;
    layer.frame=self.layer.bounds;
    [self.layer insertSublayer:layer atIndex:0];
    
    // 3.如果不支持闪光灯，不显示闪光灯按钮
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    self.buttonTurn.hidden = !device.hasTorch;
}

//设置扫描区域
-(CGRect)getScanCrop:(CGRect)rect readerViewBounds:(CGRect)readerViewBounds{
    CGFloat x,y,width,height;
    x = (CGRectGetHeight(readerViewBounds)-CGRectGetHeight(rect))/2/CGRectGetHeight(readerViewBounds);
    y = (CGRectGetWidth(readerViewBounds)-CGRectGetWidth(rect))/2/CGRectGetWidth(readerViewBounds);
    width = CGRectGetHeight(rect)/CGRectGetHeight(readerViewBounds);
    height = CGRectGetWidth(rect)/CGRectGetWidth(readerViewBounds);
    return CGRectMake(x, y, width, height);
}
//开始扫描动画
- (void)startAnimation{
    CGFloat viewW = 200*ZW_QRCODE_WidthRate;
    CGFloat viewH = 3;
    CGFloat viewX = (ZW_QRCODE_ScreenWidth - viewW)/2;
    __block CGFloat viewY = (ZW_QRCODE_ScreenHeight- viewW)/2;
    __block CGRect rect = CGRectMake(viewX, viewY, viewW, viewH);
    [UIView animateWithDuration:1.5 delay:0 options:UIViewAnimationOptionRepeat animations:^{
        viewY = (ZW_QRCODE_ScreenHeight- viewW)/2 + 200*ZW_QRCODE_WidthRate - 5;
        rect = CGRectMake(viewX, viewY, viewW, viewH);
        self.imageMove.frame = rect;
    } completion:^(BOOL finished) {
        viewY = (ZW_QRCODE_ScreenHeight- viewW)/2;
        rect = CGRectMake(viewX, viewY, viewW, viewH);
        self.imageMove.frame = rect;
    }];
}
//关闭扫描动画
- (void)stopAnimation{
    CGFloat viewW = 200*ZW_QRCODE_WidthRate;
    CGFloat viewH = 3;
    CGFloat viewX = (ZW_QRCODE_ScreenWidth - viewW)/2;
    __block CGFloat viewY = (ZW_QRCODE_ScreenHeight- viewW)/2;
    __block CGRect rect = CGRectMake(viewX, viewY, viewW, viewH);
    [UIView animateWithDuration:0.01 animations:^{
        self.imageMove.frame = rect;
    }];
}
#pragma mark -getter方法
//设置有效扫描区域
- (CGRect)rectScanZone{
    //因为总共是320  左边空出60 右边空出60  中间是200 200+60+60=320
    return CGRectMake(60*ZW_QRCODE_WidthRate, (ZW_QRCODE_ScreenHeight-200*ZW_QRCODE_WidthRate)/2, 200*ZW_QRCODE_WidthRate, 200*ZW_QRCODE_WidthRate);
}


#pragma mark -setter方法
- (AVCaptureSession *)captureSession{
    if (!_captureSession) {
        //获取摄像设备
        AVCaptureDevice * device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        //创建输入流
        AVCaptureDeviceInput * input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
        //创建输出流
        AVCaptureMetadataOutput * output = [[AVCaptureMetadataOutput alloc]init];
        //设置代理 在主线程里刷新
        [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        CGRect scanCrop=[self getScanCrop:self.rectScanZone readerViewBounds:self.frame];
        output.rectOfInterest = scanCrop;
        
        //初始化链接对象
        _captureSession = [[AVCaptureSession alloc]init];
        //高质量采集率
        [_captureSession setSessionPreset:AVCaptureSessionPresetHigh];
        if (input) {
            [_captureSession addInput:input];
        }
        if (output) {
            [_captureSession addOutput:output];
            //设置扫码支持的编码格式(如下设置条形码和二维码兼容)
            NSMutableArray *array = [[NSMutableArray alloc] init];
            if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeQRCode]) {
                [array addObject:AVMetadataObjectTypeQRCode];
            }
            if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeEAN13Code]) {
                [array addObject:AVMetadataObjectTypeEAN13Code];
            }
            if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeEAN8Code]) {
                [array addObject:AVMetadataObjectTypeEAN8Code];
            }
            if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeCode128Code]) {
                [array addObject:AVMetadataObjectTypeCode128Code];
            }
            output.metadataObjectTypes = array;
        }
    }
    return _captureSession;
}
- (UIView *)viewMask{
    if (!_viewMask) {
        _viewMask = [[UIView alloc]initWithFrame:self.bounds];
        [_viewMask setBackgroundColor:[UIColor blackColor]];
        //设置透明度
        [_viewMask setAlpha:0.6];
        
        //=======================================
        //绘制 --->使扫描区域完全透明，不显示遮罩效果
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path appendPath:[UIBezierPath bezierPathWithRect:_viewMask.bounds]];
        //有效扫描区的图片显示和全透明区域完全重合
        //如果将.bezierPathByReversingPath则不会产生中间全透明部分
        [path appendPath:[UIBezierPath bezierPathWithRect:self.rectScanZone].bezierPathByReversingPath];
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.path = path.CGPath;
        _viewMask.layer.mask = maskLayer;
    }
    return _viewMask;
}

- (UIImageView *)imageScanZone{
    if (!_imageScanZone) {
        _imageScanZone = [[UIImageView alloc]initWithImage:[NSBundle zw_qrCodeImageWithName:@"scanBackground@2x"]];
    }
    return _imageScanZone;
}


- (UIImageView *)imageMove{
    if (!_imageMove) {
        CGFloat viewW = 200*ZW_QRCODE_WidthRate;
        CGFloat viewH = 3;
        CGFloat viewX = (ZW_QRCODE_ScreenWidth - viewW)/2;
        CGFloat viewY = (ZW_QRCODE_ScreenHeight- viewW)/2;
        _imageMove = [[UIImageView alloc]initWithFrame:CGRectMake(viewX, viewY, viewW, viewH)];
        _imageMove.image = [NSBundle zw_qrCodeImageWithName:@"scanLine@2x"];
    }
    return _imageMove;
}
- (UIButton *)buttonTurn{
    if (!_buttonTurn) {
        _buttonTurn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_buttonTurn setBackgroundImage:[NSBundle zw_qrCodeImageWithName:@"lightSelect@2x"] forState:UIControlStateNormal];
        [_buttonTurn setBackgroundImage:[NSBundle zw_qrCodeImageWithName:@"lightNormal@2x"] forState:UIControlStateSelected];
        [_buttonTurn sizeToFit];
        [_buttonTurn addTarget:self action:@selector(turnTorchEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonTurn;
}

- (UILabel *)labelAlert{
    if (!_labelAlert) {
        CGFloat viewW = ZW_QRCODE_ScreenWidth;
        CGFloat viewH = 17;
        CGFloat viewX = 0;
        CGFloat viewY = 0;
        _labelAlert = [[UILabel alloc]initWithFrame:CGRectMake(viewX, viewY, viewW, viewH)];
        [_labelAlert setText:@"将二维码/条形码放置框内，即开始扫描"];
        [_labelAlert setTextColor:[UIColor whiteColor]];
        [_labelAlert setFont:[UIFont systemFontOfSize:15]];
        [_labelAlert setTextAlignment:NSTextAlignmentCenter];
    }
    return _labelAlert;
}


@end
