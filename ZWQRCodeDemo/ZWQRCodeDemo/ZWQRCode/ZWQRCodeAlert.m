//
//  ZWQRCodeAlert.m
//  ZWQRCodeDemo
//
//  Created by 郑亚伟 on 2017/2/21.
//  Copyright © 2017年 zhengyawei. All rights reserved.
//

#import "ZWQRCodeAlert.h"


@interface ZWQRCodeAlert ()
/** 1.文本框 */
@property(nonatomic, strong)UILabel *labelTitle ;
@end

@implementation ZWQRCodeAlert
- (instancetype)init{
    self = [super init];
    if (self) {
        self.bounds = [UIScreen mainScreen].bounds;
        //随父视图变化
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        //设置蒙版颜色
        //self.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.8];
        [self addSubview:self.labelTitle];
    }
    return self;
}
- (void)layoutSubviews{
    [super layoutSubviews];
    CGRect bounds = [UIScreen mainScreen].bounds;
    [self.labelTitle setCenter:CGPointMake(CGRectGetWidth(bounds)/2, CGRectGetHeight(bounds)/2)];
}

#pragma mark- public
+ (void)showWithTitle:(NSString *)title{
    ZWQRCodeAlert *alertView = [[ZWQRCodeAlert alloc]init];
    [alertView.labelTitle setText:title];
    [alertView.labelTitle sizeToFit];
    CGSize size = alertView.labelTitle.frame.size;
    alertView.labelTitle.frame = CGRectMake(0, 0, size.width + 12, size.height+16);
    [alertView show];
}
#pragma mark - private
- (void)show{
    [self.labelTitle.layer setOpacity:0];
    //父视图直接设置为UIWindow
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [self setCenter:[UIApplication sharedApplication].keyWindow.center];
    [[UIApplication sharedApplication].keyWindow bringSubviewToFront:self];
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.labelTitle.layer setOpacity:1.0];
    } completion:^(BOOL finished) {
        [self performSelector:@selector(remove) withObject:self afterDelay:1];
    }];
}

- (void)remove{
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.labelTitle.layer setOpacity:0.0];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark-懒加载
- (UILabel *)labelTitle
{
    if (!_labelTitle) {
        _labelTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 0)];
        [_labelTitle setTextColor:[UIColor whiteColor]];
        [_labelTitle setTextAlignment:NSTextAlignmentCenter];
        [_labelTitle setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.7]];
        [_labelTitle setFont:[UIFont systemFontOfSize:15]];
        [_labelTitle.layer setCornerRadius:4];
        [_labelTitle setNumberOfLines:0];
        [_labelTitle.layer setMasksToBounds:YES];
    }
    return _labelTitle;
}

@end
