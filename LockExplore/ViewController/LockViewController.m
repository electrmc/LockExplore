//
//  LockViewController.m
//  LockExplore
//
//  Created by MiaoChao on 2017/1/24.
//  Copyright © 2017年 MiaoChao. All rights reserved.
//

#import "LockViewController.h"
#import "SynchronizedLock.h"
#import "NSLockExplore.h"
#import "OSSpinLockExplore.h"
#import "SemaphoreExplore.h"

@interface LockViewController ()

@end

@implementation LockViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)dangerThread:(id)sender {
    SynchronizedLock *sl = [[SynchronizedLock alloc]init];
    [sl dangerSaleTickets];
}

- (IBAction)synchronizedToken:(id)sender {
    SynchronizedLock *sl = [[SynchronizedLock alloc]init];
    [sl safeSaleTickets];
}

- (IBAction)synchronizedNil:(id)sender {
    SynchronizedLock *sl = [[SynchronizedLock alloc]init];
    [sl unknownSecuritySaleTickets];
}

- (IBAction)semaphore:(id)sender {
    OSSpinLockExplore *sl = [[OSSpinLockExplore alloc]init];
    [sl safeSaleTickets];
}

- (IBAction)nslock:(id)sender {
    NSLockExplore *nl = [[NSLockExplore alloc]init];
    [nl safeSaleTickets];
}

- (IBAction)spinlock:(id)sender {
    SemaphoreExplore *sl = [[SemaphoreExplore alloc]init];
    [sl safeSaleTickets];
}
@end
