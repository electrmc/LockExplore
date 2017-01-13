//
//  PThreadExplore.m
//  LockExplore
//
//  Created by MiaoChao on 17/1/12.
//  Copyright © 2017年 MiaoChao. All rights reserved.
//

#import "PThreadExplore.h"
#import <pthread.h>

@implementation PThreadExplore

// 该方法中的NSThread并没有销毁
- (void)startNSThread {
    NSDictionary *dic = @{@"a":@"1"};
    NSThread *thread = [[NSThread alloc]initWithTarget:self selector:@selector(nsthreadMethod:) object:dic];
    [thread start];
}

- (void)nsthreadMethod:(id)object {
    NSLog(@"thread:%@, param : %@",[NSThread currentThread],object);
}

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
