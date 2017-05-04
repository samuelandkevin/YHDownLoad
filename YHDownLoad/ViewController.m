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

#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#define RGB16(rgbValue)\
\
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 \
alpha:1.0]
#define kBlueColor  RGB16(0x0e92dd)          //蓝色

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
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
    UILabel *lb = [[UILabel alloc] init];
    lb.text = @"  设置并发数量—>:";
    [self.view addSubview:lb];
    
    UITextField *tf = [[UITextField alloc] init];
    tf.placeholder = @"并发数量";
    tf.tag = 1001;
    tf.text = @"20";
    [tf becomeFirstResponder];
    [self.view addSubview:tf];
    
    __weak typeof(self)weakSelf = self;
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(weakSelf.view);
        make.height.mas_equalTo(100);
    }];
    
    [lb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.view);
        make.centerY.equalTo(tf.mas_centerY);
    }];
    
    [tf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(lb.mas_right).offset(5);
        make.top.equalTo(weakSelf.tableView.mas_bottom);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(30);
    }];
    
    
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
        SimulateDownLoadVC *vc = [SimulateDownLoadVC new];
        vc.aTitle = @"YHDownLoad->模拟下载";
        UITextField *tf = [self.view viewWithTag:1001];
        vc.taskCount = [tf.text integerValue];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
