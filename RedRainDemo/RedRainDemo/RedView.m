//
//  RedView.m
//  RedRainDemo
//
//  Created by ZTF on 16/10/17.
//  Copyright © 2016年 JiuXianTuan. All rights reserved.
//

#import "RedView.h"

#define KSCReenWidth  [UIScreen mainScreen].bounds.size.width
#define KSCReenHeight  [UIScreen mainScreen].bounds.size.height

@interface RedView ()

@property (nonatomic, assign) NSInteger itemDis;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation RedView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setImage:[UIImage imageNamed:@"hb.png"] forState:UIControlStateNormal];
        [self setImage:[UIImage imageNamed:@"snow.png"] forState:UIControlStateSelected];
    }
    return self;
}
#pragma mark - Private

- (void)startAnimationDuration:(CGFloat)duration {
    // 移动总距离, 当设置 frame 的时候就设置到屏幕正上方, 刚好不在屏幕上出现
    CGFloat distance = KSCReenHeight + self.frame.size.height * 2;
    // 设置变化500次 好走出屏幕
    NSInteger count = 500;
    
    // 每次变化的距离
    CGFloat itemDis = distance / count;
    _itemDis = itemDis;
    
    // 间隔多少秒动一次
    double itemTime = duration * 1.0 / count;
    // 添加定时器
    _timer = [NSTimer scheduledTimerWithTimeInterval:itemTime target:self selector:@selector(changeFrame:) userInfo:nil repeats:YES];
    [_timer fire];
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)changeFrame:(NSTimer *)timer
{
    CGFloat y_go = self.frame.origin.y + _itemDis;
    CGFloat x = self.frame.origin.x;
    CGFloat w = self.frame.size.width;
    CGFloat h = self.frame.size.height;
    self.frame = CGRectMake(x, y_go, w, h);
    if (y_go - _itemDis > KSCReenHeight) {
        if (self.clickBlock) {
            self.clickBlock(-1);
        }
        [self removeFromSuperview];
        [_timer invalidate];
    }
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (self.clickBlock) {
        self.clickBlock(self.tag);
    }
    // 设置动画
    //    [UIView transitionWithView:self.imageView1 duration:0.2 options:UIViewAnimationOptionTransitionFlipFromTop animations:^{
    //        self.imageView1.image = [UIImage imageNamed:@"hb"];
    //    } completion:^(BOOL finished) {
    //
    //        [self removeFromSuperview];
    //        [_timer invalidate];
    //    }];
    [self removeFromSuperview];
    [_timer invalidate];
    
}
@end
