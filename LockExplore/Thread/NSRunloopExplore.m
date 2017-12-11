//
//  NSRunloopExplore.m
//  LockExplore
//
//  Created by MiaoChao on 2017/1/24.
//  Copyright © 2017年 MiaoChao. All rights reserved.
//

#import "NSRunloopExplore.h"
#import "RunLoop-SourceCode.h"

BOOL shouldKeepRunning = YES;

@implementation NSRunloopExplore

- (void)dealloc {
    NSLog(@"%s",__func__);
}

- (void)startThreadWithRunloop {
    _thread = [[NSThread alloc]initWithTarget:self selector:@selector(initloop) object:nil];
    [_thread setName:@"runloopExplore"];
    [_thread start];
}

- (void)initloop {
    @autoreleasepool {
        /*
         * 执行performSelector:方法会把线程中原有的runloop返回
         * [self performSelector:@selector(executeMethodInThread) withObject:nil afterDelay:2.0];
         * [self performSelector:@selector(threadStatus:) onThread:_thread withObject:_thread waitUntilDone:NO];
         */

        NSRunLoop *runloop = [NSRunLoop currentRunLoop];
        NSMachPort *dummpy = [[NSMachPort alloc]init];
        [runloop addPort:dummpy forMode:NSDefaultRunLoopMode];
        
        /*
         * 调用[runloop run]方法，线程中的runloop是无法停止的。
         *
         * 下面while不会无限调用与下面的NSLog(@"runloop is finished!!")不会立即执行的原因是：
         * runMode:beforDate:处卡住了，一直在等待。直到该方法返回。目前该方法何时返回还不清楚
         * 如果把shouldKeepRunning写死为1，就是[runloop run]的实现
         * 同时需要注意的是：[thread isCancelled]和[thread isExecuting]可以同时返回YES
         */
        [runloop run];
        NSLog(@"fds");
        while (shouldKeepRunning) {
            NSLog(@"---> 开始一个新的runloop");
            [runloop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
            NSLog(@"running!!!!");
            NSLog(@"---> 一个runloop结束");
        }
    }
    /*
     * 此处不会立即执行！！
     * 当执行到此处时说明NSThread已经结束，系统开始回收NSThread，但是不会立即回收回去。
     */
    NSLog(@"runloop is finished!!");
    [self threadStatus];
}

- (void)stopRunloop {
    [self threadStatus];
    CFRunLoopStop(CFRunLoopGetCurrent());
    [_thread cancel];
    shouldKeepRunning = NO;
    [self threadStatus];
}

- (void)executeMethodInThread {
    NSLog(@"%s \r\n thread : %@",__func__,[NSThread currentThread]);
    // 执行这个方法会把线程中原有的runloop给打断
    [self performSelector:@selector(threadStatus) onThread:_thread withObject:nil waitUntilDone:NO];
}

- (void)threadStatus {
    NSLog(@"argument : %@",_thread);
    if ([_thread isCancelled]) {
        NSLog(@"thread is cancelled");
    }
    if ([_thread isFinished]) {
        NSLog(@"thread is finished");
    }
    if ([_thread isExecuting]) {
        NSLog(@"thread is executing");
    }
}


/**
 向runloop中添加observer，观察其状态
 */
static void runLoopObserverCallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info) {
    CFRunLoopRef runloop = observer->_runLoop;
    NSLog(@"current runloop name : %@, info: %s",runloop->_currentMode->_name,info);
    switch (activity) {
        case kCFRunLoopEntry:
            NSLog(@"进入 runloop");
            break;
        case kCFRunLoopBeforeTimers:
            NSLog(@"开始处理timer");
            break;
        case kCFRunLoopBeforeSources:
            NSLog(@"开始处理source");
            break;
        case kCFRunLoopBeforeWaiting:
            NSLog(@"开始等待");
            break;
        case kCFRunLoopAfterWaiting:
            NSLog(@"结束等待");
            break;
        case kCFRunLoopExit:
            NSLog(@"runloop exit");
            break;
        default:
            break;
    }
}

- (void)addObserverToThread {
    [self performSelector:@selector(addObserver) onThread:_thread withObject:nil waitUntilDone:NO modes:@[NSRunLoopCommonModes]];
}

- (void)addObserver {
    // 注册RunLoop状态观察
    CFRunLoopObserverContext context = {0,(__bridge void*)self,NULL,NULL};
    CFRunLoopObserverRef observer = CFRunLoopObserverCreate(kCFAllocatorDefault,
                                                            kCFRunLoopAllActivities,
                                                            YES,
                                                            0,
                                                            &runLoopObserverCallBack,
                                                            &context);
    CFRunLoopRef runloop = CFRunLoopGetCurrent();
    CFRunLoopAddObserver(runloop, observer, kCFRunLoopCommonModes);
}

/**
 加入的main runloop 中的observer不会随着NSRunloopExplore对象的消失而停止
 因为该observer和NSRunloopExplore没关系，它被main runloop持有，并且回调是一个C方法，而不是一个OC对象方法
 */
- (void)addObserverToMainThread {
    // 注册RunLoop状态观察
    CFRunLoopObserverContext context = {0,"kCFRunLoopCommonModes",NULL,NULL};
    CFRunLoopObserverRef observer = CFRunLoopObserverCreate(kCFAllocatorDefault,
                                                            kCFRunLoopAllActivities,
                                                            YES,
                                                            0,
                                                            &runLoopObserverCallBack,
                                                            &context);
    CFRunLoopAddObserver(CFRunLoopGetMain(), observer, kCFRunLoopCommonModes);
    
    // GSEventReceiveRunLoopMode不知道什么时候接受消息
    // 在此mode下的observer，点击屏幕，摇晃手机，前后台，锁屏都没收到消息
    CFRunLoopObserverContext context1 = {0,"GSEventReceiveRunLoopMode",NULL,NULL};
    CFRunLoopObserverRef observer1 = CFRunLoopObserverCreate(kCFAllocatorDefault,
                                                            kCFRunLoopAllActivities,
                                                            YES,
                                                            0,
                                                            &runLoopObserverCallBack,
                                                            &context1);
    NSString *string = @"GSEventReceiveRunLoopMode";
    CFRunLoopAddObserver(CFRunLoopGetMain(), observer1, (__bridge CFStringRef)string);
}

#pragma mark - Runloop中Modes关系

/*
  探究主线程以及线程中的CommonMode是否真实存在
 */
- (void)addSourceToMainRunloop {
    NSRunLoop *mainLoop = [NSRunLoop mainRunLoop];
    NSTimer *timerx = [NSTimer timerWithTimeInterval:5.0 target:self selector:@selector(timerTest:) userInfo:@"trackingTimer" repeats:YES];
    [mainLoop addTimer:timerx forMode:UITrackingRunLoopMode];
    NSTimer *timerx1 = [NSTimer timerWithTimeInterval:6.0 target:self selector:@selector(timerTest:) userInfo:@"defaultTimer" repeats:YES];
    [mainLoop addTimer:timerx1 forMode:NSDefaultRunLoopMode];
    NSTimer *timerx2 = [NSTimer timerWithTimeInterval:7.0 target:self selector:@selector(timerTest:) userInfo:@"commonTimer" repeats:YES];
    [mainLoop addTimer:timerx2 forMode:NSRunLoopCommonModes];
    NSTimer *timerx3 = [NSTimer timerWithTimeInterval:8.0 target:self selector:@selector(timerTest:) userInfo:@"customTimer" repeats:YES];
    [mainLoop addTimer:timerx3 forMode:@"CustomMode"];
}

- (void)addSourceToThread{
    [self performSelector:@selector(addSourceToRunloop) onThread:_thread withObject:nil waitUntilDone:NO];
}

- (void)addSourceToRunloop {
    NSRunLoop *runloop = [NSRunLoop currentRunLoop];
    NSTimer *timer = [NSTimer timerWithTimeInterval:5.0 target:self selector:@selector(timerTest:) userInfo:@"timer0" repeats:YES];
    [runloop addTimer:timer forMode:NSRunLoopCommonModes];
    
    NSTimer *timer1 = [NSTimer timerWithTimeInterval:6.0 target:self selector:@selector(timerTest:) userInfo:@"timer1" repeats:YES];
    [runloop addTimer:timer1 forMode:NSDefaultRunLoopMode];
    
    NSTimer *timer2 = [NSTimer timerWithTimeInterval:7.0 target:self selector:@selector(timerTest:) userInfo:@"timer2" repeats:YES];
    [runloop addTimer:timer2 forMode:@"CustomMode"];
    
    NSTimer *timer3 = [NSTimer timerWithTimeInterval:8.0 target:self selector:@selector(timerTest:) userInfo:@"timer3" repeats:YES];
    [runloop addTimer:timer3 forMode:@"CustomMode"];
}

- (void)getMainRunloopStructure {
    NSRunLoop *runloop = [NSRunLoop currentRunLoop]; 
    CFRunLoopRef cfrunloop2 = [runloop getCFRunLoop];
    NSLog(@"%@",cfrunloop2);
}

- (void)getThreadRunLoopStructure {
    [self performSelector:@selector(runloopModeStructure) onThread:_thread withObject:nil waitUntilDone:NO];
}

- (void)runloopModeStructure {
    CFRunLoopRef currentRunloop = CFRunLoopGetCurrent();
    NSRunLoop *runloop = [NSRunLoop currentRunLoop]; 
    CFRunLoopRef cfrunloop2 = [runloop getCFRunLoop];
    NSLog(@"%@,%@,%@",currentRunloop,runloop,cfrunloop2);
}

- (void)timerTest:(NSTimer*)timer{
    NSLog(@"%@",timer.userInfo);
}
#pragma mark - 探究autorelease

@end
