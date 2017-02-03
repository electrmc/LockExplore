//
//  PThreadExplore.m
//  LockExplore
//
//  Created by MiaoChao on 17/1/12.
//  Copyright © 2017年 MiaoChao. All rights reserved.
//

#import "ThreadExplore.h"
#import <pthread.h>

@interface ThreadObject : NSObject
- (void)receiveMsg:(id)object;
@end
@implementation ThreadObject
- (void)receiveMsg:(id)object {
    NSLog(@"%@,param : %@",[NSThread currentThread],object);
}
@end

@interface ThreadExplore()
@end

@implementation ThreadExplore

// 不正确的runloop开启方式和不正确的runloop推出方式会导致NSThread内存泄漏
- (void)startNSThread {
    for (int i=0; i<1000; i++) {
        NSThread *thread = [[NSThread alloc]initWithTarget:self selector:@selector(nsthreadOperation) object:nil];
        [thread setName:[NSString stringWithFormat:@"thread %d",i]];
        [thread start];
    }
}

- (void)detachNewThread {
    [NSThread detachNewThreadSelector:@selector(receiveMsg:) toTarget:[ThreadObject new] withObject:@{@"123":@"abc"}];
}

- (void)nsthreadOperation {
    NSLog(@"%@",[NSThread currentThread]);
}

#pragma mark - pthread
- (void)startpThread {
    pthread_t thread;
    pthread_create(&thread, NULL, start, NULL);
}

void *start (void *data)
{
    NSLog(@"%@",[NSThread currentThread]);
    return NULL;
}

@end

