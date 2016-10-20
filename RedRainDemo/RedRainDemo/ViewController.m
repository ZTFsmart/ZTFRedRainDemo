//
//  ViewController.m
//  RedRainDemo
//
//  Created by ZTF on 16/10/13.
//  Copyright © 2016年 JiuXianTuan. All rights reserved.
//

#import "ViewController.h"

#define KSCReenWidth  [UIScreen mainScreen].bounds.size.width
#define KSCReenHeight  [UIScreen mainScreen].bounds.size.height

@interface ViewController ()<CAAnimationDelegate>

@property (nonatomic, strong) NSTimer  *timer;//定时器

@property (weak, nonatomic) IBOutlet UITextField *screenNumberText;
@property (weak, nonatomic) IBOutlet UITextField *secondText;
@property (weak, nonatomic) IBOutlet UITextField *numberText;
@property (weak, nonatomic) IBOutlet UIButton *startBtn;
@property (weak, nonatomic) IBOutlet UILabel *selectedLabel;
@property (weak, nonatomic) IBOutlet UILabel *selectedLabelBottom;

@property (assign, nonatomic) double second; //多少秒
@property (assign, nonatomic) double num;    //多少个红包
@property (assign, nonatomic) double screenNum;//每屏幕多少个红包
@property (assign, nonatomic) double number;
@property (assign, nonatomic) NSInteger imageNumber;
@property (assign, nonatomic) NSInteger selectedNumber;//选中的红包
@property (weak, nonatomic) IBOutlet UIButton *stop;


@property (nonatomic,strong) NSMutableArray * imageArray;//未用的图层数组
@property (nonatomic,strong) NSMutableArray * usedImageArray;//已经使用的图层数组

@property (assign ,nonatomic) BOOL isStop;

@end

@implementation ViewController
#pragma mark - Filecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configCustomView];
}
#pragma mark - CustomAccessors
- (void)configCustomView {
    //初始化数组
    _imageArray = [NSMutableArray array];
    _usedImageArray = [NSMutableArray array];

    [self.stop addTarget:self action:@selector(stopAnimation) forControlEvents:UIControlEventTouchUpInside];
    [self.startBtn addTarget:self action:@selector(start) forControlEvents:UIControlEventTouchUpInside];
}

- (NSMutableArray *)imageArray{
    if (!_imageArray) {
        _imageArray = [NSMutableArray array];
    }
    return _imageArray;
}

- (NSMutableArray *)usedImageArray {
    if (!_usedImageArray) {
        _usedImageArray = [NSMutableArray array];
    }
    return _usedImageArray;
}
#pragma mark - Private
//开始红包雨
- (void)start {
    self.isStop = NO;
    self.imageNumber = 0;
    self.number = 0;
    self.selectedNumber = 0;
    [self.view endEditing:YES];
    if ([self.secondText.text doubleValue] && [self.numberText.text doubleValue] && [self.screenNumberText.text doubleValue]) {
        [self.startBtn setTitle:@"开始" forState:UIControlStateNormal];
        self.second = [self.secondText.text doubleValue];
        self.num = [self.numberText.text doubleValue];
        self.screenNum = [self.screenNumberText.text doubleValue];
        self.screenNum = [self.screenNumberText.text doubleValue] < self.num ? [self.screenNumberText.text doubleValue] : self.num;
    }else {
        [self.startBtn setTitle:@"不能为0或者字符" forState:UIControlStateNormal];
        return;
    }
    self.startBtn.hidden = YES;
    self.selectedLabel.hidden = YES;
    double interval = self.second / self.num;
    self.timer=[NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(creatRedRain) userInfo:nil repeats:YES];
}
//结束
- (void)stopAnimation {
    self.isStop = YES;
    [self.timer invalidate];
    self.timer = nil;

    self.selectedLabel.hidden = NO;
    self.selectedLabel.text = [NSString stringWithFormat:@"点中%ld个",self.selectedNumber];

    self.imageArray = nil;
    self.usedImageArray = nil;
    double interval = self.second / self.num;
    double second = interval * self.screenNum;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(second * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.startBtn.hidden = NO;
    });

}


//创建红包
- (void)creatRedRain {
    
    self.number++;//每创建一个红包增加一次,到固定次数后停止
    double interval = self.second / self.num;
    double second = interval * self.screenNum * ((self.num * 2 - self.number) / self.num / 2);
    if (self.number > self.num) {
        [self.timer invalidate];
        self.timer = nil;
        //最后一个后,需要让最后一个到最下边后再完全停止
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(second * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.startBtn.hidden = NO;
            self.selectedLabel.hidden = NO;
            self.selectedLabel.text = [NSString stringWithFormat:@"点中%ld个",self.selectedNumber];
            self.imageArray = nil;
            self.usedImageArray = nil;
        });
        return;
    }

    //NSLog(@"第%f个,间隔为%f,降落时间为%f",self.number,interval,second);
    if (self.imageArray.count) {
        //如果存有imageview就复用
        UIImageView *imageView = [self.imageArray objectAtIndex:0];
        [self.imageArray removeObjectAtIndex:0];
        [self animationWithImageView:imageView andSecond:second];
        
    }else {
        //没有的话就创建
        self.imageNumber++;
        UIImageView * imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"redPaper.png"]];
        imageView.tag = self.imageNumber;
        [self animationWithImageView:imageView andSecond:second];
    }

}
//开始动画
- (void)animationWithImageView:(UIImageView *)imageView andSecond:(double)second{
    [self.usedImageArray addObject:imageView];
    //NSLog(@"tag=%ld",imageView.tag);
    int x = arc4random() % (int)([UIScreen mainScreen].bounds.size.width - 70);
    imageView.frame = CGRectMake(x, -70, 70, 70);
    [self.view addSubview:imageView];
    
    //下落动画
    [UIView beginAnimations:[NSString stringWithFormat:@"%li",(long)imageView.tag] context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:second];
    [UIView setAnimationDelegate:self];
    imageView.frame = CGRectMake(imageView.frame.origin.x, KSCReenHeight, imageView.frame.size.width, imageView.frame.size.height);
    [imageView setTransform:CGAffineTransformRotate(imageView.transform, M_PI * 0.3)];
    
    [UIView commitAnimations];
    
    [UIView beginAnimations:@"rotationAnimation" context:NULL];
    [UIView setAnimationDuration:second / 8];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationRepeatCount:4];
    [UIView setAnimationRepeatAutoreverses:YES];
    CGAffineTransform tranform= CGAffineTransformMakeRotation(-M_PI * 0.2);
    [imageView setTransform:CGAffineTransformRotate(tranform, M_PI * 0.2)];
    [UIView setAnimationDelegate:self];
    [UIView commitAnimations];

    
}
//动画停止
- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context{
    
    if (![animationID isEqualToString:@"rotationAnimation"]) {
        UIImageView *imageView = (UIImageView *)[self.view viewWithTag:[animationID intValue]];
        if ([self.imageArray containsObject:imageView]) {
            return;
        }
        if (!imageView) {
            return;
        }
        [imageView.layer removeAllAnimations];
        [imageView removeFromSuperview];
        if (!self.isStop) {
            [self.imageArray addObject:imageView];
            [self.usedImageArray removeObject:imageView];
        }

    }
    
}




//触摸view
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
    NSLog(@"点了");
    UITouch *touch = touches.anyObject;
    CGPoint point = [touch locationInView:self.view];
    for (UIImageView * imgView in _usedImageArray) {
        //便利显示的图片的layer,看触摸点在哪个里边
        if ([imgView.layer.presentationLayer hitTest:point]) {
            self.selectedNumber++;
            self.selectedLabelBottom.text = [NSString stringWithFormat:@"%ld",(long)self.selectedNumber];
            NSLog(@"点中了,第%ld个",(long)self.selectedNumber);
            [imgView.layer removeAllAnimations];
            imgView.center = point;
            if ([self.imageArray containsObject:imgView]) {
                return;
            }
            if (!imgView) {
                return;
            }

            
            [self showAddCartAnmationSview:self.view imageView:imgView starPoin:imgView.center endPoint:CGPointMake(KSCReenWidth - 20 - 25, KSCReenHeight - 20 - 15) dismissTime:1.0];
            
            
            [imgView removeFromSuperview];
            [self.imageArray addObject:imgView];
            [self.usedImageArray removeObject:imgView];
            return;
        }
    }
}

//点中后动画
- (void)showAddCartAnmationSview:(UIView *)sview
                       imageView:(UIImageView *)imageView
                        starPoin:(CGPoint)startPoint
                        endPoint:(CGPoint)endpoint
                     dismissTime:(float)dismissTime
{
    __block CALayer *layer;
    layer                               = [[CALayer alloc]init];
    layer.contents                      = imageView.layer.contents;
    layer.frame                         = imageView.frame;
    layer.opacity                       = 1;
    [sview.layer addSublayer:layer];
    UIBezierPath *path                  = [UIBezierPath bezierPath];
    [path moveToPoint:startPoint];
    //贝塞尔曲线控制点
    float sx                            = startPoint.x;
    float sy                            = startPoint.y;
    float ex                            = endpoint.x;
    float ey                            = endpoint.y;
    float x                             = sx + (ex - sx) / 3;
    float y                             = sy + (ey - sy) * 0.5 - 400;
    CGPoint centerPoint                 = CGPointMake(x, y);
    [path addQuadCurveToPoint:endpoint controlPoint:centerPoint];
    //设置位置动画
    CAKeyframeAnimation *animation=[CAKeyframeAnimation animationWithKeyPath:@"position"];
    animation.path                      = path.CGPath;
    animation.removedOnCompletion       = NO;
    //设置大小动画
    CGSize finalSize                    = CGSizeMake(imageView.image.size.height*0.1, imageView.image.size.width*0.1);
    CABasicAnimation *resizeAnimation   = [CABasicAnimation animationWithKeyPath:@"bounds.size"];
    resizeAnimation.removedOnCompletion = NO;
    [resizeAnimation setToValue:[NSValue valueWithCGSize:finalSize]];
    //旋转
    CABasicAnimation* rotationAnimation;
    rotationAnimation                   = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue           = [NSNumber numberWithFloat: M_PI * 2.0 ];
    rotationAnimation.cumulative        = YES;
    rotationAnimation.duration          = 0.3;
    rotationAnimation.repeatCount       = 1000;
    //动画组
    CAAnimationGroup * animationGroup   = [[CAAnimationGroup alloc] init];
    animationGroup.animations           = @[animation,resizeAnimation,rotationAnimation];
    animationGroup.delegate             = self;
    animationGroup.duration             = 0.6;
    animationGroup.removedOnCompletion  = NO;
    animationGroup.fillMode             = kCAFillModeForwards;
    animationGroup.autoreverses         = NO;
    animationGroup.timingFunction       = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    [layer addAnimation:animationGroup forKey:@"buy"];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(dismissTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [layer removeFromSuperlayer];
        layer = nil;
    });
}

@end
