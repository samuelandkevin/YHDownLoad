//
//  YHCellProgress.h
//  YHDownLoad
//
//  Created by YHIOS002 on 2017/5/3.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "YHDownLoadModel.h"

@protocol YHCellProgressDelegate <NSObject>

//下载成功 (indexPath:路径)
- (void)downLoadSuccess:(BOOL)success atIndexPath:(NSIndexPath *)indexPath nextTasks:(NSArray <NSNumber *>*)nextTasks;
//更新进度 (indexPath:路径)
- (void)updateProgress:(float)progress atIndexPath:(NSIndexPath *)indexPath ;
//暂停下载 (indexPath:路径)
- (void)pauseDownLoad:(BOOL)pause atIndexPath:(NSIndexPath *)indexPath nextTask:(NSNumber *)nextTask;
@end

@interface YHCellProgress : UITableViewCell

@property (nonatomic,strong) YHDownLoadModel *model;
@property (nonatomic,weak) id<YHCellProgressDelegate>delegate;
@property (nonatomic) NSIndexPath *indexPath;
//更新进度条
- (void)updateProgress:(float)progress;
//根据下载状态更新UI
- (void)updateUIWithStatus:(Status)status;
@end

