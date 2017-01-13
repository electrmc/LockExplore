//
//  NSOperationExplore.m
//  LockExplore
//
//  Created by MiaoChao on 17/1/13.
//  Copyright © 2017年 MiaoChao. All rights reserved.
//

#import "NSOperationExplore.h"

@implementation NSOperationExplore

// NSOperationQueue没有start方法，完成addOperation后就会执行
// NSOperation既可以添加operation，也可以直接添加block
// NSOperationQueue和NSOperation的不同是：queue是只在后台队列中执行，而NSOperation会优先从当前队列中执行
- (void)startOperationQueue {
    //1,创建1个队列
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    
    //2,创建NSBlockOperation对象
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"thread : %@",[NSThread currentThread]);
    }];
    
    //3,添加多个block
    for(int i=0;i<5;i++) {
        [operation addExecutionBlock:^{
            NSLog(@"thread : %@",[NSThread currentThread]);
        }];
    }
    [queue addOperation:operation];
}

// 该方法默认是在当前线程执行的，如果是主线程添加就在主线程执行。线程的生命周期不需要手动管理
- (void)startInvocationOperation {
    NSInvocationOperation *operation = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(startInvocation:) object:@{@"key":@"value"}];
    [operation start];
}

- (void)startInvocation:(id)object {
    NSLog(@"thread : %@, object : %@",[NSThread currentThread],object);
}

- (void)startBlockOperation {
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"%@",[NSThread currentThread]);
    }];
    
    // 该方式operation中的任务会并发执行，它会在主线程和其他线程执行
    // 必须在start前添加
    for (int i=0; i<5; i++) {
        [operation addExecutionBlock:^{
            NSLog(@"%d : %@",i,[NSThread currentThread]);
        }];
    }
    
    [operation start];
}

- (void)dependencyOperation {
    NSBlockOperation *operation1 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"下载图片 - %@",[NSThread currentThread]);
    }];
    NSBlockOperation *operation2 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"处理图片 - %@",[NSThread currentThread]);
    }];
    NSBlockOperation *operation3 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"返回图片 - %@",[NSThread currentThread]);
    }];
    
    // 经测试operation2依赖operation1，operation1依赖operation2这种相互依赖也不会死锁
    // 苹果内部实现必定对此种情况做了处理
    // 可以实现跨队列的依赖
    [operation2 addDependency:operation1];
    [operation3 addDependency:operation2];
    
    // 创建队列并添加任务
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    [queue addOperations:@[operation1,operation2,operation3] waitUntilFinished:NO];
}

@end
