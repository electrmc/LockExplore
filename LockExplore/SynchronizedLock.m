//
//  SynchronizedLock.m
//  LockExplore
//
//  Created by MiaoChao on 2016/12/6.
//  Copyright © 2016年 MiaoChao. All rights reserved.
//

#import "SynchronizedLock.h"
@interface SynchronizedLock()
@property (nonatomic, assign) NSUInteger tickets;
@property (nonatomic, strong) dispatch_queue_t concurrentQueue;
@end

@implementation SynchronizedLock
- (instancetype)initWithTickets:(NSUInteger)tickets {
    self = [super init];
    if (self) {
        self.tickets = tickets;
        self.concurrentQueue = dispatch_queue_create("synchronized", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (void)dangerSaleTickets {
    for (int i=0; i<5; i++) {
        dispatch_async(self.concurrentQueue, ^{
            [self dangerSale];
        });
    }
}

- (void)safeSaleTickets {
    for (int i=0; i<5; i++) {
        dispatch_async(self.concurrentQueue, ^{
            [self safeSale];
        });
    }
}

- (void)dangerSale {
    while (1) {
        [NSThread sleepForTimeInterval:0.5];
        if (self.tickets > 0) {
            self.tickets--;
            NSLog(@"剩余票数= %ld, Thread:%@",_tickets,[NSThread currentThread]);
        } else {
            NSLog(@"票买完了 Thread:%@",[NSThread currentThread]);
            break;
        }
        
    }
}

- (void)safeSale {
    while (1) {
        [NSThread sleepForTimeInterval:0.5];
        @synchronized (self) {
            if (self.tickets > 0) {
                self.tickets--;
                NSLog(@"剩余票数= %ld, Thread:%@",_tickets,[NSThread currentThread]);
            } else {
                NSLog(@"票买完了 Thread:%@",[NSThread currentThread]);
                break;
            }
        }
    }
}

@end
