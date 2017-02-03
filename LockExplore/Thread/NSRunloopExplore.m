//
//  NSRunloopExplore.m
//  LockExplore
//
//  Created by MiaoChao on 2017/1/24.
//  Copyright © 2017年 MiaoChao. All rights reserved.
//

#import "NSRunloopExplore.h"

@implementation NSRunloopExplore

- (void)initThread {
    _thread = [[NSThread alloc]initWithTarget:self selector:@selector(initloop) object:nil];
    [_thread setName:@"runloopExplore"];
    [_thread start];
}

- (void)initloop {
    @autoreleasepool {
        NSRunLoop *runloop = [[NSRunLoop alloc]init];
        NSMachPort *dummpy = [[NSMachPort alloc]init];
        [runloop addPort:dummpy forMode:NSDefaultRunLoopMode];
        [runloop run];
    }
}

- (void)stopRunloop {
    CFRunLoopStop(CFRunLoopGetCurrent());
    [_thread cancel];
}

- (void)executeSomething {
    [self performSelector:@selector(methondInThread) onThread:_thread withObject:nil waitUntilDone:NO];
}

- (void)methondInThread {
    [self threadStatus:[NSThread currentThread]];
}

- (void)threadStatus:(NSThread*)thread {
    NSLog(@"%@",thread);
    if ([thread isCancelled]) {
        NSLog(@"thread is cancelled");
    }
    if ([thread isFinished]) {
        NSLog(@"thread is finished");
    }
    if ([thread isExecuting]) {
        NSLog(@"thread is executing");
    }
}

@end
