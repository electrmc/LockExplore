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
- (instancetype)initWithTickets:(NSUInteger)tickets {
    self = [super init];
    if (self) {
        self.tickets = tickets;
        self.mutexLock = [[NSLock alloc]init];
        self.concurrentQueue = dispatch_queue_create("synchronized", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (void)safeSaleTickets {
    dispatch_async(self.concurrentQueue, ^{
        [self safeSale];
    });
    dispatch_async(self.concurrentQueue, ^{
        [self safeSale];
    });
    dispatch_async(self.concurrentQueue, ^{
        [self safeSale];
    });
    dispatch_async(self.concurrentQueue, ^{
        [self safeSale];
    });
    dispatch_async(self.concurrentQueue, ^{
        [self safeSale];
    });
    dispatch_async(self.concurrentQueue, ^{
        [self safeSale];
    });
}

- (void)safeSale {
    while (1) {
        [NSThread sleepForTimeInterval:0.5];
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
