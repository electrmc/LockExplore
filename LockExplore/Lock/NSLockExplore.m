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
    for (int i=0; i<50; i++) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self quitsharelock];
        });
    }
}

- (void)quitsharelock {
    while (1) {
        [NSThread sleepForTimeInterval:0.5];
        [_mutexLock lock];
        if (self.tickets > 0) {
            self.tickets--;
            NSLog(@"剩余票数= %ld, Thread:%@",_tickets,[NSThread currentThread]);
            [_mutexLock unlock];
        } else {
            NSLog(@"票买完了 Thread:%@",[NSThread currentThread]);
            [_mutexLock unlock];
            break;
        }
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
         *
         * tryLock和lock的区别是，trylock不会阻塞当前线程，如果不能获得锁或立即返回NO
         * lock会阻塞当前线程，直到获得锁
        ******************************************/
        if ([_mutexLock tryLock]) {
            if (self.tickets > 0) {
                self.tickets--;
                NSLog(@"剩余票数= %ld, Thread:%@",_tickets,[NSThread currentThread]);
                [_mutexLock unlock];
            } else {
                NSLog(@"票买完了 Thread:%@",[NSThread currentThread]);
                [_mutexLock unlock];
                break;
            }
        }
    }
}

@end
