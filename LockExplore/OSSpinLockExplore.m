//
//  OSSpinLockExplore.m
//  LockExplore
//
//  Created by MiaoChao on 2016/12/7.
//  Copyright © 2016年 MiaoChao. All rights reserved.
//

#import "OSSpinLockExplore.h"
#include <libkern/OSAtomic.h>

@interface OSSpinLockExplore ()
@property (nonatomic, assign) NSUInteger tickets;
@property (nonatomic, assign) OSSpinLock spinlock;
@property (nonatomic, strong) dispatch_queue_t concurrentQueue;
@end

@implementation OSSpinLockExplore
- (instancetype)initWithTickets:(NSUInteger)tickets {
    self = [super init];
    if (self) {
        self.tickets = tickets;
        _spinlock = OS_SPINLOCK_INIT;
        self.concurrentQueue = dispatch_queue_create("OSSpinLock", DISPATCH_QUEUE_CONCURRENT);
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
        OSSpinLockLock(&_spinlock);
        if (self.tickets > 0) {
            self.tickets--;
            NSLog(@"剩余票数= %ld, Thread:%@",_tickets,[NSThread currentThread]);
        } else {
            NSLog(@"票买完了 Thread:%@",[NSThread currentThread]);
            break;
        }
        OSSpinLockUnlock(&_spinlock);
    }
}


@end
