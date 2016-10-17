//
//  RedView.h
//  RedRainDemo
//
//  Created by ZTF on 16/10/17.
//  Copyright © 2016年 JiuXianTuan. All rights reserved.
//

#import <UIKit/UIKit.h>

// view 的点击
typedef void(^AnimationViewClickBlock)(NSInteger tag);// tag= -1时正常走完 没有点击

@interface RedView : UIButton

// 开始动画 时间
- (void)startAnimationDuration:(CGFloat)duration;


@property (nonatomic, copy) AnimationViewClickBlock  clickBlock;
- (void)setClickBlock:(AnimationViewClickBlock)clickBlock;

@end
