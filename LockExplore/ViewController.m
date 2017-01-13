//
//  ViewController.m
//  LockExplore
//
//  Created by MiaoChao on 2016/12/6.
//  Copyright © 2016年 MiaoChao. All rights reserved.
//

#import "ViewController.h"
#import "SynchronizedLock.h"
#import "NSLockExplore.h"
#import "OSSpinLockExplore.h"
#import "SemaphoreExplore.h"

#import "PThreadExplore.h"
#import "NSOperationExplore.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)safeSale:(id)sender {
    SynchronizedLock *sl = [[SynchronizedLock alloc]initWithTickets:100];
    [sl safeSaleTickets];
}

- (IBAction)dangerSale:(id)sender {
    SynchronizedLock *sl = [[SynchronizedLock alloc]initWithTickets:100];
    [sl dangerSaleTickets];
}

- (IBAction)synchronizedNil:(id)sender {
    SynchronizedLock *sl = [[SynchronizedLock alloc]initWithTickets:100];
    [sl unknownSecuritySaleTickets];
}

- (IBAction)nslockSafe:(id)sender {
    NSLockExplore *le = [[NSLockExplore alloc]initWithTickets:100];
    [le safeSaleTickets];
}

- (IBAction)spinlockSafe:(id)sender {
    OSSpinLockExplore *spin = [[OSSpinLockExplore alloc]initWithTickets:100];
    [spin safeSaleTickets];
}

- (IBAction)semaphoreSafe:(id)sender {
    SemaphoreExplore *se = [[SemaphoreExplore alloc]initWithTickets:100];
    [se safeSaleTickets];
}

- (IBAction)pThread:(id)sender {
    PThreadExplore *pe = [[PThreadExplore alloc] init];
    [pe startpThread];
}

- (IBAction)nsthread:(id)sender {
    PThreadExplore *pe = [[PThreadExplore alloc] init];
    [pe startNSThread];
}

- (IBAction)invocationOperation:(id)sender {
    NSOperationExplore *ope = [NSOperationExplore new];
    [ope startInvocationOperation];
}

- (IBAction)blockOperation:(id)sender {
    NSOperationExplore *ope = [NSOperationExplore new];
    [ope startBlockOperation];
}

- (IBAction)operationQueue:(id)sender {
    NSOperationExplore *ope = [NSOperationExplore new];
    [ope startOperationQueue];
}

- (IBAction)dependecyOperation:(id)sender {
    NSOperationExplore *ope = [NSOperationExplore new];
    [ope dependencyOperation];
}

@end
