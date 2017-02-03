//
//  NSOperationExplore.h
//  LockExplore
//
//  Created by MiaoChao on 17/1/13.
//  Copyright © 2017年 MiaoChao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSOperationExplore : NSObject

- (void)startInvocationOperation;
- (void)startBlockOperation;
- (void)startOperationQueue;
- (void)dependencyOperation;
@end
