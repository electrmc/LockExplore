//
//  RunloopViewController.m
//  LockExplore
//
//  Created by MiaoChao on 2017/2/3.
//  Copyright © 2017年 MiaoChao. All rights reserved.
//

#import "RunloopViewController.h"
#import "NSRunloopExplore.h"

@interface RunloopViewController ()
@property (nonatomic, strong)NSRunloopExplore *oe;
@end

@implementation RunloopViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.oe = [NSRunloopExplore new];
}

- (IBAction)startThreadRunloop:(id)sender {
    [self.oe startThreadWithRunloop];
}
- (IBAction)executeMethod:(id)sender {
    [self.oe executeMethodInThread];
}
- (IBAction)threadStatus:(id)sender {
    [self.oe threadStatus];
}
- (IBAction)stopThread:(id)sender {
    [self.oe stopRunloop];
}

@end
