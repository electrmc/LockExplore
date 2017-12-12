//
//  DispatchTimeViewController.m
//  LockExplore
//
//  Created by MiaoChao on 2017/12/11.
//  Copyright © 2017年 MiaoChao. All rights reserved.
//

#import "DispatchTimeViewController.h"

@interface DispatchTimeViewController ()
@property (nonatomic, strong) dispatch_source_t timer1;
@property (nonatomic, strong) dispatch_source_t timer2;
@property (nonatomic, strong) dispatch_queue_t queue;
@end

@implementation DispatchTimeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.queue = dispatch_queue_create("timer queue", DISPATCH_QUEUE_CONCURRENT);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)dispatchTimer:(id)sender {
    [self creatDispatchTimer];
}
- (IBAction)dispatchtimer2:(id)sender {
    [self runloopDispatchTimer];
}
- (IBAction)suspend:(id)sender {
    if (self.timer1) {
        dispatch_suspend(self.timer1);
    }
    if (self.timer2) {
        dispatch_suspend(self.timer2);
    }
}

- (IBAction)resume:(id)sender {
    if (self.timer1) {
        dispatch_resume(self.timer1);
    }
    if (self.timer2) {
        dispatch_resume(self.timer2);
    }
}

- (IBAction)cancelTimer:(id)sender {
    if (self.timer1) {
//        dispatch_source_cancel(self.timer2);
        dispatch_cancel(self.timer1);
    }
    if (self.timer2) {
        dispatch_cancel(self.timer2);
    }
}

- (void)creatDispatchTimer {
    
    self.timer1 = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, _queue);    
    // 开始时间
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, 3.0*NSEC_PER_SEC);
    
    // 间隔时间
    uint64_t interval = 2.0 * NSEC_PER_SEC;
    
    dispatch_source_set_timer(self.timer1, start, interval, 0);
    dispatch_source_set_event_handler(self.timer1, ^{
        NSLog(@"timer running");
        NSLog(@"%@",self);
    });
    dispatch_resume(self.timer1);
}

#pragma mark - dispatch timer handler
void __timeoutHandle(void *arg) {
    NSLog(@"%s%s",__func__,arg);
}

void __cancelTimer(void *arg) {
    NSLog(@"%s%s",__func__,arg);
}

- (void)runloopDispatchTimer {
    _timer2 = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, _queue);    
    dispatch_set_context(_timer2, "timer2");
    dispatch_source_set_event_handler_f(_timer2, __timeoutHandle);
    dispatch_source_set_cancel_handler_f(_timer2, __cancelTimer);
    
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, 3.0*NSEC_PER_SEC);
    dispatch_time_t interval = 1.0*NSEC_PER_SEC;
    // 设置timer的开始时间，触发间隔，容错时间；时间单位都是纳秒
    dispatch_source_set_timer(_timer2, start, interval, 1000ULL);
    
    // 定时器开始执行
    dispatch_resume(_timer2);
}

- (void)dealloc {
    NSLog(@"%s",__func__);
}

@end
