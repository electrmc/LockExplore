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
@property (weak, nonatomic) IBOutlet UIScrollView *scrollview;
@property (nonatomic, strong)NSRunloopExplore *oe;
@end

@implementation RunloopViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.oe = [[NSRunloopExplore alloc]init];
    self.scrollview.contentSize = CGSizeMake(500, 500);
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

#pragma mark - runloop mode structure

- (IBAction)addSourceToMainThread:(id)sender {
    [self.oe addSourceToMainRunloop];
}

- (IBAction)addSourceToThread:(id)sender {
    [self.oe addSourceToThread];
}

- (IBAction)autoreleasePoolObserver:(id)sender {
    [self.oe addAutoReleasePoolObserver];
}

- (IBAction)mainRunloopModeSturcture:(id)sender {
    [self.oe getMainRunloopStructure];
}

- (IBAction)threadRunloopModeStructure:(id)sender {
    [self.oe getThreadRunLoopStructure];
}

#pragma mark - add observer
- (IBAction)addObserverToThread:(id)sender {
    [self.oe addObserverToThread];
}

- (IBAction)addObserverToMain:(id)sender {
    [self.oe addObserverToMainThread];
}
- (IBAction)perform2:(id)sender {
    [self.oe executeMethod2];
}

- (void)dealloc {
    NSLog(@"%s",__func__);
}
@end
