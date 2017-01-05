//
//  NSLockExplore.h
//  LockExplore
//
//  Created by MiaoChao on 2016/12/7.
//  Copyright © 2016年 MiaoChao. All rights reserved.
//

#import <Foundation/Foundation.h>

// NSLock是一个对象，因此在使用时需要一个对象对它进行持有才可以
// 这就限制了它不能在一些底层或C方法中使用
@interface NSLockExplore : NSObject
- (instancetype)initWithTickets:(NSUInteger)tickets;
- (void)safeSaleTickets;
@end
