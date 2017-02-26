//
//  ViewController.m
//  ZWQRCodeDemo
//
//  Created by 郑亚伟 on 2017/2/21.
//  Copyright © 2017年 zhengyawei. All rights reserved.
//

#import "ViewController.h"
#import "ZWQRCodeController.h"
#import "ZWQRCodeAlert.h"
@interface ViewController ()<ZWQRCodeControllerDelegate>
@property(nonatomic, strong)UIButton *buttonGoQR;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.buttonGoQR];
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [ZWQRCodeAlert showWithTitle:@"hello"];
}

#pragma mark -Action
- (void)gotoQR {
    ZWQRCodeController *codeVC = [[ZWQRCodeController alloc]init];
    codeVC.delegate = self;
    UINavigationController *navVC = [[UINavigationController alloc]initWithRootViewController:codeVC];
    [self presentViewController:navVC animated:YES completion:nil];

}
#pragma mark -ZWQRCodeControllerDelegate
//模仿微信一般是扫描成功后，会从当前页面跳转过去，所以一般会设置一个代理
- (void)qrcodeController:(ZWQRCodeController *)qrcodeController readerScanResult:(NSString *)readerScanResult type:(ZWQRCodeResultType)resultType{
    /*
     ZWQRCodeResultTypeSuccess = 0, // 1.成功获取图片中的二维码信息
     ZWQRCodeResultTypeNoInfo = 1,  // 2.识别的图片没有二维码信息
     ZWQRCodeResultTypeError = 2   // 3.其他错误
     */
    if (resultType == ZWQRCodeResultTypeSuccess) {
        NSLog(@"%@",readerScanResult);
        if ([readerScanResult hasPrefix:@"http"]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:readerScanResult]];
        }
    }
}


- (UIButton *)buttonGoQR{
    if (!_buttonGoQR) {
        _buttonGoQR = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 200, 44)];
        [_buttonGoQR setTitle:@"跳转到二维码界面" forState:UIControlStateNormal];
        [_buttonGoQR setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_buttonGoQR setBackgroundColor:[UIColor redColor]];
        _buttonGoQR.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
        [_buttonGoQR addTarget:self action:@selector(gotoQR) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonGoQR;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
