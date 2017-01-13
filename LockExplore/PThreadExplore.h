//
//  PThreadExplore.h
//  LockExplore
//
//  Created by MiaoChao on 17/1/12.
//  Copyright © 2017年 MiaoChao. All rights reserved.
//

#import <Foundation/Foundation.h>

// pthread 是C语言的方法，在swift中不好用，其次要手动管理线程的生命周期，比较麻烦。
@interface PThreadExplore : NSObject

- (void)startNSThread;
- (void)startpThread;

@end
