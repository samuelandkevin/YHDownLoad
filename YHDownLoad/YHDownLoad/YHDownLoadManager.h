//
//  YHDownLoadManager.h
//  YHDownLoad
//
//  Created by YHIOS002 on 2017/5/3.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YHDownLoadModel.h"

@interface YHDownLoadManager : NSObject

//最大的并发数量 (默认是:1)
@property (nonatomic,assign)NSUInteger maxConcurrentCount;

//单例
+ (YHDownLoadManager *)sharedInstance;

//下载
- (Status)downLoadWithModel:(YHDownLoadModel *)model complete:(void (^)(BOOL success,id obj,NSIndexPath *indexPath,NSArray <NSNumber *>*nextTasks))complete progress:(void(^)(float downLoadProgress,NSIndexPath *indexPath))progress;
//暂停下载 ,返回下一个任务下标,-1代表没有下一个任务
- (NSNumber *)pauseDownLoadWithModel:(YHDownLoadModel *)model;
//恢复下载
- (void)resumeDownLoadWithModel:(YHDownLoadModel *)model;

/******************************************************************/
/**
 * Note:以下是定时器模拟的配置属性,实际开发可以删除去
 */
- (void)cancelAllTasks;
@end
