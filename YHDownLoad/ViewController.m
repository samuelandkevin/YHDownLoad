//
//  ViewController.m
//  YHDownLoad
//
//  Created by YHIOS002 on 2017/5/3.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import "ViewController.h"
#import "SimulateDownLoadVC.h"
#import "Masonry.h"



@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
@property (nonatomic,strong) UITableView *tableView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = kBlueColor;
    
    self.title = @"YHDownLoad";
    self.view.backgroundColor = RGBCOLOR(196, 197, 198);
    [self initUI];
}

- (void)initUI{
    
    //tableview
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    self.tableView.scrollEnabled = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor orangeColor];
    
    //control panel
    //下载任务数量
    UILabel *lbTotalTasks = [[UILabel alloc] init];
    lbTotalTasks.text = @"  下载任务数量—>:";
    [self.view addSubview:lbTotalTasks];
    
    UITextField *tfTotalTasks = [[UITextField alloc] init];
    tfTotalTasks.placeholder = @"下载任务数量";
    tfTotalTasks.tag = 1001;
    tfTotalTasks.text = @"20";
    tfTotalTasks.delegate = self;
    [tfTotalTasks becomeFirstResponder];
    [self.view addSubview:tfTotalTasks];
    
    //并发数量
    UILabel *lbConcurrentCount = [[UILabel alloc] init];
    lbConcurrentCount.text = @"  并发任务数量—>:";
    [self.view addSubview:lbConcurrentCount];
    
    UITextField *tfConcurrentCount = [[UITextField alloc] init];
    tfConcurrentCount.placeholder = @"并发任务数量";
    tfConcurrentCount.tag = 1002;
    tfConcurrentCount.text = @"2";
    tfConcurrentCount.delegate = self;
    [tfConcurrentCount becomeFirstResponder];
    [self.view addSubview:tfConcurrentCount];
    
    
    __weak typeof(self)weakSelf = self;
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(weakSelf.view);
        make.height.mas_equalTo(100);
    }];
    
    [lbTotalTasks mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.view);
        make.centerY.equalTo(tfTotalTasks.mas_centerY);
    }];
    
    [tfTotalTasks mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(lbTotalTasks.mas_right).offset(5);
        make.top.equalTo(weakSelf.tableView.mas_bottom);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(30);
    }];
    
    [lbConcurrentCount mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.view);
        make.centerY.equalTo(tfConcurrentCount.mas_centerY);
    }];
    
    [tfConcurrentCount mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(lbConcurrentCount.mas_right).offset(5);
        make.top.equalTo(tfTotalTasks.mas_bottom);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(30);
    }];
    
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self _pushVC];
    return YES;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.contentView.backgroundColor = [UIColor orangeColor];
    cell.textLabel.text = @"模拟下载—>点我试试";
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        [self _pushVC];
    }
}

- (void)_pushVC{
    SimulateDownLoadVC *vc = [SimulateDownLoadVC new];
    vc.aTitle = @"YHDownLoad->模拟下载";
    UITextField *tf1 = [self.view viewWithTag:1001];
    vc.taskCount     = [tf1.text integerValue];
    UITextField *tf2 = [self.view viewWithTag:1002];
    vc.concurrentCount = [tf2.text integerValue];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
