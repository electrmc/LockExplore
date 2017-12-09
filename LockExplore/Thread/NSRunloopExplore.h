//
//  NSRunloopExplore.h
//  LockExplore
//
//  Created by MiaoChao on 2017/1/24.
//  Copyright © 2017年 MiaoChao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSRunloopExplore : NSObject

@property (nonatomic, strong) NSThread *thread;

- (void)startThreadWithRunloop;
- (void)executeMethodInThread;
- (void)threadStatus;
- (void)stopRunloop;

#pragma mark - 探究observer监听runloop的状态
- (void)addObserverToThread;
- (void)addObserverToMainThread;

#pragma mark - 探究runloop mode的结构
- (void)addSourceToThread;
- (void)addSourceToMainRunloop;

- (void)getMainRunloopStructure;
- (void)getThreadRunLoopStructure;
@end
