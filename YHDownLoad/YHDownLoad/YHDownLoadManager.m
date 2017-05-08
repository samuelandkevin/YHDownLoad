//
//  YHDownLoadManager.m
//  YHDownLoad
//
//  Created by YHIOS002 on 2017/5/3.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "YHDownLoadManager.h"
#import "YHDownLoadModel.h"


#define kAddProgress 10 //进度条增量

@interface YHDownLoadManager()

@property (nonatomic,strong)NSMutableArray <YHDownLoadModel *>*downLoadQueue;//所有任务
@property (nonatomic,strong)NSMutableArray <YHDownLoadModel *>*pausedTasks;//暂停的任务
@property (nonatomic,strong)NSMutableArray <YHDownLoadModel *>*downLoadingTasks;//进行中的任务
@property (nonatomic,strong)NSMutableArray <YHDownLoadModel *>*waitingTasks;
//等待中的任务


/******实际开发可以替换******/
@property (nonatomic,strong)NSMutableArray <NSTimer *>*timerArray;//所有定时器数组,模拟下载任务

@end

@implementation YHDownLoadManager

#pragma mark - Getter
-(NSMutableArray <NSTimer *>*)timerArray{
    if (!_timerArray) {
        _timerArray = [NSMutableArray new];
    }
    return _timerArray;
}

- (NSMutableArray <YHDownLoadModel *>*)downLoadQueue{
    if (!_downLoadQueue) {
        _downLoadQueue = [NSMutableArray new];
    }
    return _downLoadQueue;
}

- (NSMutableArray<YHDownLoadModel *> *)pausedTasks{
    if (!_pausedTasks) {
        _pausedTasks = [NSMutableArray new];
    }
    return _pausedTasks;
}

- (NSMutableArray<YHDownLoadModel *> *)downLoadingTasks{
    if (!_downLoadingTasks) {
        _downLoadingTasks = [NSMutableArray new];
    }
    return _downLoadingTasks;
}

-(NSMutableArray<YHDownLoadModel *> *)waitingTasks{
    if (!_waitingTasks) {
        _waitingTasks = [NSMutableArray new];
    }
    return _waitingTasks;
}

#pragma mark - Public
+ (YHDownLoadManager *)sharedInstance {
    static YHDownLoadManager  *g_sharedInstance = nil;
    static dispatch_once_t pre = 0;
    dispatch_once(&pre, ^{
        g_sharedInstance = [[YHDownLoadManager alloc] init];
        g_sharedInstance.maxConcurrentCount = 1;
    });
    
    return g_sharedInstance;
}

//下载
- (Status)downLoadWithModel:(YHDownLoadModel *)model complete:(void (^)(BOOL success,id obj,NSIndexPath *indexPath,NSArray <NSNumber *>*nextTasks))complete progress:(void(^)(float downLoadProgress,NSIndexPath *indexPath))progress{
    
    NSString *const diskPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:model.url];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:diskPath]){
        complete(YES,diskPath,model.indexPath,nil);
        progress(0,model.indexPath);
        return Status_isDownLoaded;
    }
    
    __weak typeof(self)weakSelf = self;
    
    BOOL taskIsExisted = NO;
    for(YHDownLoadModel *aModel in _downLoadQueue){
        if ([aModel.url isEqualToString:model.url]) {
            taskIsExisted = YES;
            break;
        }
    }
    
    if (!taskIsExisted) {
        model.progress = progress;
        model.complete = complete;
        [self.downLoadQueue addObject:model];
        
        
        NSTimer *timer =  [NSTimer scheduledTimerWithTimeInterval:1 target:weakSelf selector:@selector(updateProgress:) userInfo:@{@"id":model.url} repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        model.timer = timer;
        
        /**实际开发在此把代码替换掉,现在用定时器模拟下载进度值**/
        if (self.timerArray.count < self.maxConcurrentCount) {
            //开启定时器
            [timer setFireDate:[NSDate distantPast]];
            model.status = Status_isDownLoading;
            
            [self.downLoadingTasks addObject:model];
        }else{
            //暂停定时器
            [timer setFireDate:[NSDate distantFuture]];
            model.status = Status_isWaiting;
            
            [self.waitingTasks addObject:model];
        }
        [self.timerArray addObject:timer];
        
        
    }
    return model.status;
    
}

//暂停下载
- (NSNumber *)pauseDownLoadWithModel:(YHDownLoadModel *)model{
    for(NSTimer *timer in _timerArray){
        if (timer == model.timer) {
            [timer setFireDate:[NSDate distantFuture]];


            //进行中任务最后一个下标
            NSUInteger indexLastDownLoading = 0;
            for (YHDownLoadModel *aModel in self.downLoadingTasks) {
                if (aModel.indexPath.row > indexLastDownLoading) {
                    indexLastDownLoading = aModel.indexPath.row;
                }
            }
            
            //移除下载中的任务
            [self.downLoadingTasks removeObject:model];
            

            //最大并发量限制
            if (self.downLoadingTasks.count  < self.maxConcurrentCount) {
               
                //开启下一个任务
                NSUInteger nextTaskIndex = indexLastDownLoading+1;
                
                if (nextTaskIndex < _downLoadQueue.count) {
                    YHDownLoadModel *nextModel = _downLoadQueue[nextTaskIndex];
                    if (nextTaskIndex < _timerArray.count && nextModel.status ==  Status_isWaiting) {
                        NSTimer *timer = _timerArray[nextTaskIndex];
                        [timer setFireDate:[NSDate distantPast]];
                        [self.downLoadingTasks addObject:nextModel];
                        return @(nextTaskIndex);
                    }

                }
                
                
                
            }
            return @(-1);
            break;
        }
    }
    return @(-1);
}

//恢复下载
- (NSNumber *)resumeDownLoadWithModel:(YHDownLoadModel *)model{
    for(NSTimer *timer in _timerArray){
        if (timer == model.timer) {
            [timer setFireDate:[NSDate distantPast]];

            //添加进行中任务
            NSUInteger index = [_timerArray indexOfObject:timer];
            YHDownLoadModel *addModel = [self.downLoadQueue objectAtIndex:index];
            [self.downLoadingTasks addObject:addModel];
            
            //进行中任务最后一个下标
            NSUInteger indexLastDownLoading = 0;
            for (YHDownLoadModel *aModel in self.downLoadingTasks) {
                if (aModel.indexPath.row > indexLastDownLoading) {
                    indexLastDownLoading = aModel.indexPath.row;
                }
            }
            

            //最大并发数量限制
            if(self.downLoadingTasks.count > self.maxConcurrentCount){
                
                //进行中的第一个任务暂停
                NSInteger indexOfFirstTask = MAXFLOAT;
                for (YHDownLoadModel *aModel in self.downLoadingTasks) {
                    if (aModel.indexPath.row < indexOfFirstTask && model.indexPath.row != aModel.indexPath.row) {
                        indexOfFirstTask = aModel.indexPath.row;
                    }
                }
                
                
                //定时器暂停
                if (indexOfFirstTask < _timerArray.count) {
                    NSTimer *pauseTimer = [_timerArray objectAtIndex:indexOfFirstTask];
                    [pauseTimer setFireDate:[NSDate distantFuture]];
                }
               
                
                //移除进行中任务
                if (indexOfFirstTask < self.downLoadingTasks.count) {
                    [self.downLoadingTasks removeObjectAtIndex:indexOfFirstTask];
                }
                return @(indexOfFirstTask);
            }
            
            break;
        }
    }
    return @(-1);
}


//取消所有任务
- (void)cancelAllTasks{
    for (int i= 0; i< _timerArray.count ; i++) {
        NSTimer *timer =  self.timerArray[i];
        [timer invalidate];
        timer = nil;
    }
    [_timerArray removeAllObjects];
    _timerArray     = nil;
    [_downLoadQueue removeAllObjects];
    _downLoadQueue  = nil;
    [_pausedTasks  removeAllObjects];
    _pausedTasks    = nil;
    [_downLoadingTasks removeAllObjects];
    _downLoadingTasks = nil;
    [_waitingTasks removeAllObjects];
    _waitingTasks   = nil;
}

#pragma mark - Private
//模拟更新进度,定时器触发的
- (void)updateProgress:(NSNotification *)aNoti{
    NSString *url = aNoti.userInfo[@"id"];
    __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        for (YHDownLoadModel *model in _downLoadQueue) {
            if ([model.url isEqualToString:url]) {
                //进度值增量
                model.bytesWritten += kAddProgress;
                
                //进度值（0-1）
                float progress = 0;
                if (model.totalBytesWritten > 0){
                    progress = model.bytesWritten/model.totalBytesWritten;
                }
                model.downLoadProgress = progress;
                NSLog(@"更新下载任务%@进度",model.url);
                
                
                if (model.bytesWritten >= model.totalBytesWritten) {
                    
                    //更新进度
                    model.bytesWritten = model.totalBytesWritten;
                    model.progress(progress,model.indexPath);
                    model.status = Status_isDownLoaded;
                   
                    
                    //当前任务下标
                    NSUInteger curTaskIndex = [weakSelf.timerArray indexOfObject:model.timer];

                
                    //开启下一个任务 (如果下一个任务是暂停的就跳过)
                    
                    NSMutableArray <NSNumber *>*nextTasks = [NSMutableArray new];
                    for(int i = 0;i< weakSelf.maxConcurrentCount; i++){
                        //下一个任务下标
                        NSUInteger nextTaskIndex = curTaskIndex + i+1;
                        
                        if (nextTaskIndex < weakSelf.timerArray.count) {
                            
                            NSTimer *timer = [weakSelf.timerArray objectAtIndex:nextTaskIndex];
                
                            YHDownLoadModel *nextModel = [weakSelf.downLoadQueue objectAtIndex:nextTaskIndex];
                            
                            if (nextModel.status == Status_isWaiting) {
                                [nextTasks addObject:@(model.indexPath.row+i+1)];
                                [timer setFireDate:[NSDate distantPast]];
                                [self.downLoadingTasks addObject:nextModel];
                            }
                            
                        }
                    }
                    
                    //回调下载成功
                    model.complete(YES, model.url,model.indexPath,nextTasks);
                    
                    
                    //从队列中移除已完成任务
//                    [weakSelf.downLoadQueue removeObject:model];
//                    [weakSelf.timerArray removeObject:model.timer];
                    
                    for (YHDownLoadModel *downLoading in weakSelf.downLoadingTasks) {
                        if ([downLoading.url isEqualToString:model.url]) {
                            [weakSelf.downLoadingTasks removeObject:downLoading];
                            break;
                        }
                    }
                    
                    [model.timer invalidate];
                     model.timer = nil;


                }else{
                    //更新进度
                    model.progress(progress,model.indexPath);
                }
                
                break;
            }
        }
        
    });
}
@end

