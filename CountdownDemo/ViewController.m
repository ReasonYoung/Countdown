//
//  ViewController.m
//  CountdownDemo
//
//  Created by RWY on 16/7/25.
//  Copyright © 2016年 rwy. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    int secondsCountDown; //倒计时总时长
    NSTimer *countDownTimer;
    UILabel *labelText;
}

@property (strong, nonatomic) IBOutlet UIButton *countDownBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //创建UILabel 添加到当前view
    labelText=[[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2-60, 120, 120, 36)];
    [self.view addSubview:labelText];
    
    //设置倒计时总时长
    secondsCountDown = 30;//60秒倒计时
    
    
    /**
     * Label开始倒计时
     *
     *  @param scheduledTimerWithTimeInterval 设置倒计时多少时间（以秒计算）调用 timeFireMethod 方法；
     *
     *  @repeats 是否重复触发（为YES时，每隔一定的延时时间就会触发方法，为NO时，从现在开始间隔一定的延时时间就会触发，但只触发一次）
     */
    countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeFireMethod) userInfo:nil repeats:YES]; //启动倒计时后会每秒钟调用一次方法 timeFireMethod
    
    
    //设置倒计时显示的时间
    labelText.text=[NSString stringWithFormat:@"%d秒后重发",secondsCountDown];

}

// 实现每秒钟执行的方法
-(void)timeFireMethod{
    //倒计时-1
    secondsCountDown--;
    //修改倒计时标签现实内容
    labelText.text=[NSString stringWithFormat:@"%d秒后重发",secondsCountDown];
    //当倒计时到0时，做需要的操作，比如验证码过期不能提交
    if(secondsCountDown==0){
        [countDownTimer invalidate];
        labelText.text=[NSString stringWithFormat:@"点击获取"];
        //        [labelText removeFromSuperview];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)countDown:(id)sender {
    __block int timeout= 30;
    // 创建queue 队列
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    // 创建dispatch源，这里使用加法来合并dispatch源数据，最后一个参数是指定dispatch队列
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    // dispatch源还支持其它一些系统源，包括定时器、监控文件的读写、监控文件系统、监控信号或进程等，基本上调用的方式原理和上面相同，只是有可能是系统自动触发事件。比如dispatch定时器：
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        //设置响应dispatch源事件的block，在dispatch源指定的队列上运行；这段代码实现的是定时处理
        if(timeout<=0){ //倒计时结束，关闭
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.countDownBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
                self.countDownBtn.userInteractionEnabled = YES;
            });
        }else{
            int seconds = timeout % 60;
            NSString *strTime = [NSString stringWithFormat:@"%.2d", seconds];
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIView beginAnimations:nil context:nil];
                [UIView setAnimationDuration:1];
                [self.countDownBtn setTitle:[NSString stringWithFormat:@"%@秒后重发",strTime] forState:UIControlStateNormal];
                [UIView commitAnimations];
                self.countDownBtn.userInteractionEnabled = NO;
            });
            timeout--;
        }
    });
    dispatch_resume(_timer);
}

@end
