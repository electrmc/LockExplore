//
//  SynchronizedLock.h
//  LockExplore
//
//  Created by MiaoChao on 2016/12/6.
//  Copyright © 2016年 MiaoChao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SynchronizedLock : NSObject
- (instancetype)initWithTickets:(NSUInteger)tickets;
- (void)dangerSaleTickets;
- (void)safeSaleTickets;
- (void)unknownSecuritySaleTickets;
@end
