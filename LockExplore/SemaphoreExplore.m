//
//  SemaphoreExplore.m
//  LockExplore
//
//  Created by MiaoChao on 2016/12/13.
//  Copyright © 2016年 MiaoChao. All rights reserved.
//

#import "SemaphoreExplore.h"

@interface SemaphoreExplore ()
@property (nonatomic, assign) NSUInteger tickets;
@property (nonatomic, strong) dispatch_semaphore_t semaphore;
@property (nonatomic, strong) dispatch_queue_t concurrentQueue;
@end

@implementation SemaphoreExplore

- (instancetype)initWithTickets:(NSUInteger)tickets {
    self = [super init];
    if (self) {
        self.tickets = tickets;
        self.semaphore = dispatch_semaphore_create(1);
        self.concurrentQueue = dispatch_queue_create("Semaphore", DISPATCH_QUEUE_CONCURRENT);
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
        dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
        if (self.tickets > 0) {
            self.tickets--;
            NSLog(@"剩余票数= %ld, Thread:%@",_tickets,[NSThread currentThread]);
        } else {
            NSLog(@"票买完了 Thread:%@",[NSThread currentThread]);
            break;
        }
        dispatch_semaphore_signal(self.semaphore);
    }
}



@end
