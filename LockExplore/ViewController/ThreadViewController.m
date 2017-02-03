//
//  ThreadViewController.m
//  LockExplore
//
//  Created by MiaoChao on 2017/1/24.
//  Copyright © 2017年 MiaoChao. All rights reserved.
//

#import "ThreadViewController.h"
#import "NSRunloopExplore.h"
#import "NSOperationExplore.h"
#import "ThreadExplore.h"

@interface ThreadViewController ()

@end

@implementation ThreadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

#pragma mark - NSOperationQueue
- (IBAction)invocationOperation:(id)sender {
    NSOperationExplore *oe = [NSOperationExplore new];
    [oe startInvocationOperation];
}
- (IBAction)blockOperation:(id)sender {
    NSOperationExplore *oe = [NSOperationExplore new];
    [oe startBlockOperation];
}
- (IBAction)operationQueue:(id)sender {
    NSOperationExplore *oe = [NSOperationExplore new];
    [oe startOperationQueue];
}
- (IBAction)dependecyQueue:(id)sender {
    NSOperationExplore *oe = [NSOperationExplore new];
    [oe dependencyOperation];
}

#pragma mark - simple thread
- (IBAction)startPThread:(id)sender {
    ThreadExplore *oe = [ThreadExplore new];
    [oe startpThread];
}
- (IBAction)startNSThread:(id)sender {
    ThreadExplore *oe = [ThreadExplore new];
    [oe startNSThread];
}
- (IBAction)detachNSThread:(id)sender {
    ThreadExplore *oe = [ThreadExplore new];
    [oe detachNewThread];
}
@end
