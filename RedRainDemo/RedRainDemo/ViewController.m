//
//  ViewController.m
//  RedRainDemo
//
//  Created by ZTF on 16/10/13.
//  Copyright © 2016年 JiuXianTuan. All rights reserved.
//

#import "ViewController.h"
#import "RedView.h"

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

@end

@implementation ViewController
#pragma mark - Filecycle
- (void)viewDidLoad {
    [super viewDidLoad];

    [self configCustomView];
    
}
#pragma mark - CustomAccessors
- (void)configCustomView {
    [self.startBtn addTarget:self action:@selector(start) forControlEvents:UIControlEventTouchUpInside];

}
#pragma mark - Private

- (void)start {
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
    double second = interval * self.screenNum;
    NSLog(@"间隔为%f,降落时间为%f",interval,second);
    self.timer=[NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(configRedView) userInfo:nil repeats:YES];
}

- (void)configRedView {
    
    double interval = self.second / self.num;
    double second = interval * self.screenNum;
    NSInteger x = arc4random() % (int)(KSCReenWidth - 79);
    RedView *redView = [[RedView alloc] initWithFrame:CGRectMake(x, -95, 79, 95)];
    [self.view addSubview:redView];
    [redView startAnimationDuration:second];
    
}


- (void)redRain {
    self.number++;
    NSLog(@"第%ld个",(long)self.number);
    NSDate *date=[NSDate date];
    NSDateFormatter *format1=[[NSDateFormatter alloc] init];
    [format1 setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSString *dateStr;
    dateStr=[format1 stringFromDate:date];
    NSLog(@"%@",dateStr);
    if (self.number > self.num) {
        [self.timer invalidate];
        self.timer = nil;
        self.startBtn.hidden = NO;
    }
    //制造红包雨
    double interval = self.second / self.num;
    double second = interval * self.screenNum;
    [self redRainSecond:second];
}


- (void)redRainSecond:(double)second{

    UIButton *redRainView = [[UIButton alloc]init];
    [redRainView setImage:[UIImage imageNamed:@"hb.png"] forState:UIControlStateNormal];
    [redRainView setImage:[UIImage imageNamed:@"redPaper.jpg"] forState:UIControlStateSelected];
    [redRainView addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    int x = arc4random() % (int)([UIScreen mainScreen].bounds.size.width - 79);
    redRainView.frame = CGRectMake(x, -95, 79, 95);
    [self.view addSubview:redRainView];
    
    [UIView animateWithDuration:second animations:^{
        
        redRainView.transform = CGAffineTransformMakeTranslation(0, [UIScreen mainScreen].bounds.size.height + 95);
        
    }completion:^(BOOL finished) {
        if (redRainView) {
            [redRainView removeFromSuperview];
        }
    }];
    
}

- (void)click:(UIButton *)btn {
    if (!btn.selected) {
        btn.selected = YES;
        [btn removeFromSuperview];
    }
    
    
}

@end
