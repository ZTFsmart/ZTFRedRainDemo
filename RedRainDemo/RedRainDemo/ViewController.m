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

@interface ViewController ()

@property (nonatomic, strong) NSTimer  *timer;//定时器

@property (weak, nonatomic) IBOutlet UITextField *screenNumberText;
@property (weak, nonatomic) IBOutlet UITextField *secondText;
@property (weak, nonatomic) IBOutlet UITextField *numberText;
@property (weak, nonatomic) IBOutlet UIButton *startBtn;
@property (weak, nonatomic) IBOutlet UILabel *selectedLabel;

@property (assign, nonatomic) double second; //多少秒
@property (assign, nonatomic) double num;    //多少个红包
@property (assign, nonatomic) double screenNum;//每屏幕多少个红包
@property (assign, nonatomic) double number;
@property (assign, nonatomic) NSInteger imageNumber;
@property (assign, nonatomic) NSInteger selectedNumber;//选中的红包


@property (nonatomic,strong) NSMutableArray * imageArray;//未用的图层数组
@property (nonatomic,strong) NSMutableArray * usedImageArray;//已经使用的图层数组

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
//创建红包
- (void)creatRedRain {
    
    self.number++;//每创建一个红包增加一次,到固定次数后停止
    double interval = self.second / self.num;
    double second = interval * self.screenNum;
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
    if (_imageArray.count) {
        //如果存有imageview就复用
        UIImageView *imageView = [_imageArray objectAtIndex:0];
        [_imageArray removeObjectAtIndex:0];
        [self animationWithImageView:imageView andSecond:second];
        
    }else {
        //没有的话就创建
        self.imageNumber++;
        UIImageView * imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"hb.png"]];
        imageView.tag = self.imageNumber;
        [self animationWithImageView:imageView andSecond:second];
    }

}
//开始动画
- (void)animationWithImageView:(UIImageView *)imageView andSecond:(double)second{
    [_usedImageArray addObject:imageView];
    //NSLog(@"tag=%ld",imageView.tag);
    int x = arc4random() % (int)([UIScreen mainScreen].bounds.size.width - 79);
    imageView.frame = CGRectMake(x, -95, 79, 95);
    [self.view addSubview:imageView];
    
    //下落动画
    [UIView beginAnimations:[NSString stringWithFormat:@"%li",(long)imageView.tag] context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:second];
    [UIView setAnimationDelegate:self];
    imageView.frame = CGRectMake(imageView.frame.origin.x, KSCReenHeight, imageView.frame.size.width, imageView.frame.size.height);
    [UIView commitAnimations];

}
//动画停止
- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    UIImageView *imageView = (UIImageView *)[self.view viewWithTag:[animationID intValue]];
    if ([_imageArray containsObject:imageView]) {
        return;
    }
    if (!imageView) {
        return;
    }
    [imageView removeFromSuperview];
    [_imageArray addObject:imageView];
    [_usedImageArray removeObject:imageView];
}

//触摸view
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {

    UITouch *touch = touches.anyObject;
    CGPoint point = [touch locationInView:self.view];
    for (UIImageView * imgView in _usedImageArray) {
        //便利显示的图片的layer,看触摸点在哪个里边
        if ([imgView.layer.presentationLayer hitTest:point]) {
            self.selectedNumber++;
            NSLog(@"点中了");
            [imgView.layer removeAllAnimations];
            if ([_imageArray containsObject:imgView]) {
                return;
            }
            if (!imgView) {
                return;
            }
            [imgView removeFromSuperview];
            [_imageArray addObject:imgView];
            [_usedImageArray removeObject:imgView];
            
            return;
        }
    }
}


@end
