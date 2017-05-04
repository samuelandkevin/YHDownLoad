//
//  SimulateDownLoadVC.m
//  YHDownLoad
//
//  Created by YHIOS002 on 2017/5/3.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//  模拟下载

#import "SimulateDownLoadVC.h"
#import "YHCellProgress.h"
#import "YHDownLoadManager.h"

@interface SimulateDownLoadVC ()<UITableViewDelegate,UITableViewDataSource,YHCellProgressDelegate>
@property (nonatomic,strong) UITableView* tableView;
@property (nonatomic,strong) NSMutableArray *dataArray;
@end

@implementation SimulateDownLoadVC

- (NSMutableArray *)dataArray{
    if(!_dataArray){
        _dataArray = [NSMutableArray new];
    }
    return _dataArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    //navigationBar
    if (_aTitle) {
        self.title = _aTitle;
    }
    self.navigationController.navigationBar.translucent = NO;
    //leftItem
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(-10, 0, 40, 40)];
    backBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [backBtn setTitle:@"返回" forState:UIControlStateNormal];
    [backBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(onBack:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = leftItem;

    
    //tableView
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-64) style:UITableViewStylePlain];
    self.tableView.delegate   = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    [self.tableView registerClass:[YHCellProgress class] forCellReuseIdentifier:NSStringFromClass([YHCellProgress class])];
    
    
    if (!_taskCount || _taskCount < 0 || _taskCount > 999) {
        _taskCount = 20;
    }
    
    //模拟下载任务
    for(int i=0;i< _taskCount; i++){
        YHDownLoadModel *model = [YHDownLoadModel new];
        model.status = Status_UnDownLoaded;
        model.url = [NSString stringWithFormat:@"downTask%d",i];
        model.bytesWritten = 0;
        model.totalBytesWritten = 100 + arc4random()%100;
        [self.dataArray addObject:model];
    }
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    YHCellProgress *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([YHCellProgress class])];
    cell.delegate  = self;
    cell.model     = self.dataArray[indexPath.row];
    cell.model.indexPath = indexPath;
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    YHDownLoadModel *model = self.dataArray[indexPath.row];
    NSLog(@"%ld",(long)model.indexPath.row);
}

#pragma mark - Action
- (void)onBack:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - YHCellProgressDelegate

- (void)downLoadSuccess:(BOOL)success atIndexPath:(NSIndexPath *)indexPath nextTasks:(NSArray <NSNumber *>*)nextTasks{
    YHDownLoadModel *model = self.dataArray[indexPath.row];
    YHCellProgress *cell   = [self.tableView cellForRowAtIndexPath:indexPath];
    if (success) {
        //更新当前任务UI
        model.status = Status_isDownLoaded;
        [cell updateUIWithStatus:Status_isDownLoaded];
        
        //更新下一批任务UI
        for (NSNumber *nextTask in nextTasks) {
            NSIndexPath *nextInextPath = [NSIndexPath indexPathForRow:[nextTask integerValue] inSection:indexPath.section];
            YHDownLoadModel *nextModel = self.dataArray[[nextTask integerValue]];
            if (nextModel.status != Status_isDownLoaded) {
                nextModel.status = Status_isDownLoading;
                YHCellProgress *nextCell   = [self.tableView cellForRowAtIndexPath:nextInextPath];
                [nextCell updateUIWithStatus:Status_isDownLoading];
            }
            
        }
    }else{
        model.status = Status_UnDownLoaded;
        [cell updateUIWithStatus:Status_UnDownLoaded];
    }
}

- (void)updateProgress:(float)progress atIndexPath:(NSIndexPath *)indexPath{
    
    YHDownLoadModel *model = self.dataArray[indexPath.row];
    YHCellProgress *cell   = [self.tableView cellForRowAtIndexPath:indexPath];
    if (progress>=1) {
        model.status = Status_isDownLoaded;
        [cell updateUIWithStatus:Status_isDownLoaded];
    }else{
        [cell updateProgress:progress];
    }
    
}

- (void)pauseDownLoad:(BOOL)pause atIndexPath:(NSIndexPath *)indexPath nextTask:(NSNumber *)nextTask{
    NSIndexPath *nextInextPath = [NSIndexPath indexPathForRow:[nextTask integerValue] inSection:indexPath.section];
    YHCellProgress *nextCell = [self.tableView cellForRowAtIndexPath:nextInextPath];
    if(nextInextPath.row < self.dataArray.count){
        YHDownLoadModel *nextModel = self.dataArray[nextInextPath.row];
        nextModel.status = Status_isDownLoading;
        [nextCell updateUIWithStatus:Status_isDownLoading];
    }
    
}



#pragma mark - Life
- (void)dealloc{
     NSLog(@"ViewController is dealloc");
   
}

- (void)viewDidDisappear:(BOOL)animated{
     [super viewDidDisappear:animated];
     [[YHDownLoadManager sharedInstance] cancelAllTasks];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
