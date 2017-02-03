//
//  NSRunloopExplore.m
//  LockExplore
//
//  Created by MiaoChao on 2017/1/24.
//  Copyright © 2017年 MiaoChao. All rights reserved.
//

#import "NSRunloopExplore.h"

BOOL shouldKeepRunning = YES;

@implementation NSRunloopExplore

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
        while (shouldKeepRunning) {
            [runloop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
            NSLog(@"running!!!!");
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
    [self performSelector:@selector(threadStatus) onThread:_thread withObject:_thread waitUntilDone:NO];
}

- (void)threadStatus {
    NSLog(@"%@",_thread);
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
@end
