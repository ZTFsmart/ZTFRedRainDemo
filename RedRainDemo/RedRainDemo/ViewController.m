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

@property (assign, nonatomic) double second; //多少秒
@property (assign, nonatomic) double num;    //多少个红包
@property (assign, nonatomic) double screenNum;//每屏幕多少个红包
@property (assign, nonatomic) double number;
@property (assign, nonatomic) double imageNumber;


@property (nonatomic,strong) NSMutableArray * imageArray;//未用的图层数组
@property (nonatomic,strong) NSMutableArray * usedImageArray;//已经使用的图层数组
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

@end

@implementation ViewController
#pragma mark - Filecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configCustomView];
}
#pragma mark - CustomAccessors
- (void)configCustomView {
    _imageArray = [NSMutableArray array];
    _usedImageArray = [NSMutableArray array];
    //手势
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(click:)];
    [self.view addGestureRecognizer:self.tapGesture];

    
    [self.startBtn addTarget:self action:@selector(start) forControlEvents:UIControlEventTouchUpInside];
}
#pragma mark - Private

//开始红包雨
- (void)start {
    self.imageNumber = 0;
    self.number = 0;
    [self.view endEditing:YES];
    if ([self.secondText.text doubleValue] && [self.numberText.text doubleValue] && [self.screenNumberText.text doubleValue]) {
        [self.startBtn setTitle:@"开始" forState:UIControlStateNormal];
        self.screenNum = [self.screenNumberText.text doubleValue];
        self.second = [self.secondText.text doubleValue];
        self.num = [self.numberText.text doubleValue];
    }else {
        [self.startBtn setTitle:@"不能为0或者字符" forState:UIControlStateNormal];
        return;
    }
    self.startBtn.hidden = YES;
    double interval = self.second / self.num;
    self.timer=[NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(creatRedRain) userInfo:nil repeats:YES];
}

- (void)creatRedRain {
    self.number++;
    if (self.number > self.num) {
        [self.timer invalidate];
        self.timer = nil;
        self.startBtn.hidden = NO;
        return;
    }
    double interval = self.second / self.num;
    double second = interval * self.screenNum;
    NSLog(@"第%f个,间隔为%f,降落时间为%f",self.number,interval,second);
    if (_imageArray.count) {
        UIImageView *imageView = [_imageArray objectAtIndex:0];
        [_imageArray removeObjectAtIndex:0];
        [self animationWithImageView:imageView andSecond:second];
        
        //[_imageArray removeObjectAtIndex:0];
    }else {
        self.imageNumber++;
        UIImageView * imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"hb.png"]];
        imageView.tag = self.imageNumber;
        [self animationWithImageView:imageView andSecond:second];
    }

}



- (void)animationWithImageView:(UIImageView *)imageView andSecond:(double)second{
    [_usedImageArray addObject:imageView];
    NSLog(@"tag=%ld",imageView.tag);
    int x = arc4random() % (int)([UIScreen mainScreen].bounds.size.width - 79);
    imageView.frame = CGRectMake(x, -95, 79, 95);
    [self.view addSubview:imageView];
    
    
    [UIView beginAnimations:[NSString stringWithFormat:@"%li",(long)imageView.tag] context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:second];
    [UIView setAnimationDelegate:self];
    imageView.frame = CGRectMake(imageView.frame.origin.x, KSCReenHeight, imageView.frame.size.width, imageView.frame.size.height);
    [UIView commitAnimations];
    
    

}

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

-(void)click:(UITapGestureRecognizer *)tapGesture {
    CGPoint touchPoint = [tapGesture locationInView:self.view];
    NSLog(@"点了");
    for (UIImageView * imgView in _usedImageArray) {
        
        if ([imgView.layer.presentationLayer hitTest:touchPoint]) {
            [imgView.layer removeAllAnimations];
            [self animationDidStop:[NSString stringWithFormat:@"%li",(long)imgView.tag] finished:nil context:nil];
            NSLog(@"点中");
            
            return;
        }
    }
}

@end
