//
//  NSLockExplore.m
//  LockExplore
//
//  Created by MiaoChao on 2016/12/7.
//  Copyright © 2016年 MiaoChao. All rights reserved.
//

#import "NSLockExplore.h"

@interface NSLockExplore ()
@property (nonatomic, assign) NSUInteger tickets;
@property (nonatomic, strong) NSLock *mutexLock;
@property (nonatomic, strong) dispatch_queue_t concurrentQueue;
@end

@implementation NSLockExplore

- (instancetype)init {
    return [self initWithTickets:100];
}

- (instancetype)initWithTickets:(NSUInteger)tickets {
    self = [super init];
    if (self) {
        self.tickets = tickets;
        self.mutexLock = [[NSLock alloc]init];
        self.concurrentQueue = dispatch_queue_create("NSLockExplore", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (void)safeSaleTickets {
    for (int i=0; i<5; i++) {
        dispatch_async(self.concurrentQueue, ^{
            [self safeSale];
        });
    }
}

- (void)safeSale {
    while (1) {
        [NSThread sleepForTimeInterval:0.5];
        /******************************************
         * NSLock *lockTemp = [[NSLock alloc]init];
         * [lockTemp lock];
         * .......
         * [lockTemp unlock];
         * 如果此处这样的话相当于没加锁
        ******************************************/
        [_mutexLock lock];
        if (self.tickets > 0) {
            self.tickets--;
            NSLog(@"剩余票数= %ld, Thread:%@",_tickets,[NSThread currentThread]);
        } else {
            NSLog(@"票买完了 Thread:%@",[NSThread currentThread]);
            break;
        }
        [_mutexLock unlock];
    }
}

@end