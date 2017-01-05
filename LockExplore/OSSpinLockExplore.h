//
//  OSSpinLockExplore.h
//  LockExplore
//
//  Created by MiaoChao on 2016/12/7.
//  Copyright © 2016年 MiaoChao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OSSpinLockExplore : NSObject
- (instancetype)initWithTickets:(NSUInteger)tickets;
- (void)safeSaleTickets;
@end
