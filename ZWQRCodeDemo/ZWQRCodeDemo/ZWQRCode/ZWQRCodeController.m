//
//  ZWQRCodeController.m
//  ZWQRCodeDemo
//
//  Created by 郑亚伟 on 2017/2/21.
//  Copyright © 2017年 zhengyawei. All rights reserved.
//

#import "ZWQRCodeController.h"
#import "ZWQRCodeReaderView.h"
#import "ZWQRCodeAlert.h"
#import "NSBundle+ZWQRCode.h"

#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface ZWQRCodeController ()<AVCaptureMetadataOutputObjectsDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIAlertViewDelegate,ZWQRCodeReaderViewDelegate>
/** 1.读取二维码界面 */
@property(nonatomic, strong)ZWQRCodeReaderView *readview;
/** 2.图片探测器 */
@property(nonatomic, strong)CIDetector *detector;
@end

@implementation ZWQRCodeController

#pragma mark - lifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"二维码";
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    if ([UIDevice currentDevice].systemVersion.intValue >= 8) {
        UIBarButtonItem * rightItem = [[UIBarButtonItem alloc]initWithTitle:@"相册" style:UIBarButtonItemStyleDone target:self action:@selector(alumbEvent)];
        self.navigationItem.rightBarButtonItem = rightItem;
    }
    
    UIBarButtonItem * leftItem = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:self action:@selector(backEvent)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    [self.view addSubview:self.readview];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self authorizationStatus];
}
#pragma mark- ZWQRCodeReaderViewDelegate
//ZWQRCodeReaderView扫描视图扫描到结果后，会回调用这个代理方法
- (void)qrcodeReaderView:(ZWQRCodeReaderView *)qrcodeReaderView readerScanResult:(NSString *)readerScanResult{
    // 1.播放提示音
    SystemSoundID soundID;
    NSString *strSoundFile = [[NSBundle zw_qrCodeBundle] pathForResource:@"noticeMusic" ofType:@"wav"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:strSoundFile],&soundID);
    AudioServicesPlaySystemSound(soundID);
    
    // 2.显示扫描结果信息
    //    [ZWQRCodeAlert showWithTitle:readerScanResult];
    if ([self.delegate respondsToSelector:@selector(qrcodeController:readerScanResult:type:)]) {
        [self.delegate qrcodeController:self readerScanResult:readerScanResult type:ZWQRCodeResultTypeSuccess];
        [self dismissViewControllerAnimated:YES completion:^{}];
    }
    [self.readview performSelector:@selector(startScan) withObject:nil afterDelay:2];
}


#pragma mark -Action
- (void)backEvent{
    [self dismissViewControllerAnimated:YES completion:^{}];
}
- (void)alumbEvent{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) { //判断设备是否支持相册
        [ZWQRCodeAlert showWithTitle:@"未开启访问相册权限，请在设置中开始"];
    }else {
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePickerController.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
        imagePickerController.allowsEditing = YES;
        imagePickerController.delegate = self;
        [self presentViewController:imagePickerController animated:YES completion:^{
            [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleDefault];
        }];
    }
}

#pragma mark- public


#pragma mark - private
- (void)authorizationStatus{
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if (authStatus == AVAuthorizationStatusAuthorized) {//授权
        [self.readview startScan];
    }else if(authStatus == AVAuthorizationStatusNotDetermined){
        //如果之前还没决定，就设置定时器监控授权权限，如果授权了，立即开始扫描二维码
        [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(observeAuthrizationStatusChange:) userInfo:nil repeats:YES];
    }else{//未授权
        [ZWQRCodeAlert showWithTitle:@"请在设置中开启摄像头权限"];
        [self.readview stopScan];
    }
}
- (void)observeAuthrizationStatusChange:(NSTimer *)sender{
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if (authStatus == AVAuthorizationStatusAuthorized) {
        [sender invalidate];
        [self.readview startScan];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    // 1.获取图片信息
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    if (!image){
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    
    // 2.退出图片控制器
    [picker dismissViewControllerAnimated:YES completion:^{
        
        [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent];
        
        NSArray *features = [self.detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
        if (features.count) { // 1.识别到二维码
            // 1.播放提示音
            SystemSoundID soundID;
            NSString *strSoundFile = [[NSBundle zw_qrCodeBundle] pathForResource:@"noticeMusic" ofType:@"wav"];
            AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:strSoundFile],&soundID);
            AudioServicesPlaySystemSound(soundID);
            
            // 2.显示扫描结果信息
            CIQRCodeFeature *feature = [features objectAtIndex:0];
            //            [ZWQRCodeAlert showWithTitle:feature.messageString];
            
            if ([self.delegate respondsToSelector:@selector(qrcodeController:readerScanResult:type:)]) {
                [self.delegate qrcodeController:self readerScanResult:feature.messageString type:ZWQRCodeResultTypeSuccess];
                //扫描到结果后，直接返回，不要设置动画返回
                [self dismissViewControllerAnimated:YES completion:^{}];
            }
        }else {
            [ZWQRCodeAlert showWithTitle:@"没有识别到二维码信息"];
//            if ([self.delegate respondsToSelector:@selector(qrcodeController:rea derScanResult:type:)]) {
//                [self.delegate qrcodeController:self readerScanResult:nil type:ZWQRCodeResultTypeNoInfo];
//                //[self dismissViewControllerAnimated:YES completion:^{}];
//            }
        }
    }];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent];
    }];
}





#pragma mark -getter方法
- (ZWQRCodeReaderView *)readview
{
    if (!_readview) {
        _readview = [[ZWQRCodeReaderView alloc]init];
        _readview.delegate = self;
    }
    return _readview;
}
- (CIDetector *)detector
{
    if (!_detector) {
        _detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{ CIDetectorAccuracy : CIDetectorAccuracyHigh }];
    }
    return _detector;
}





@end
