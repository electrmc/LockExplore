//
//  SemaphoreExplore.h
//  LockExplore
//
//  Created by MiaoChao on 2016/12/13.
//  Copyright © 2016年 MiaoChao. All rights reserved.
//

#import <Foundation/Foundation.h>

// Serial Dispatch Queue和dispatch_barrier_async都是大粒度的排他控制
// dispatch_semaphore是更小粒度的排他控制
// 这里就设计到一个问题：线程安全设计时加锁的范围是多大？
// 一般带有dispatch_creat都是对象，应该有strong和release
// 在MRC中应该使用dispatch_retain和dispatch_release来操作。

@interface SemaphoreExplore : NSObject
- (instancetype)initWithTickets:(NSUInteger)tickets;
- (void)safeSaleTickets;
@end
