//
//  ViewController.m
//  LockExplore
//
//  Created by MiaoChao on 2017/1/24.
//  Copyright © 2017年 MiaoChao. All rights reserved.
//

#import "ViewController.h"
#import "LockViewController.h"
#import "ThreadViewController.h"
#import "RunloopViewController.h"

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) NSArray *titles;
@property (strong, nonatomic) NSArray *vcNames;
@property (weak, nonatomic) IBOutlet UITableView *tableview;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"thread program";
    self.titles = @[@"lock in iOS",@"thread in iOS", @"runloop"];
    self.vcNames = @[@"LockViewController", @"ThreadViewController", @"RunloopViewController"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.titles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.textLabel.text = self.titles[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *className = self.vcNames[indexPath.row];
    UIViewController *vc = [[NSClassFromString(className) alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
