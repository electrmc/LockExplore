//
//  NSRunloopExplore.h
//  LockExplore
//
//  Created by MiaoChao on 2017/1/24.
//  Copyright © 2017年 MiaoChao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSRunloopExplore : NSObject

@property (nonatomic, strong) NSThread *thread;

- (void)startThreadWithRunloop;
- (void)executeMethodInThread;
- (void)threadStatus;
- (void)stopRunloop;
@end
