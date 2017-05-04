//
//  DownLoadModel.h
//  YHDownLoad
//
//  Created by YHIOS002 on 2017/5/3.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import <Foundation/Foundation.h>

//下载状态
typedef NS_ENUM(int,Status){
    Status_UnDownLoaded = 0,  //未开始
    Status_isDownLoading,     //下载中
    Status_isPaused,          //暂停
    Status_isWaiting,         //等待中
    Status_isDownLoaded       //已下载
};

@interface YHDownLoadModel : NSObject

@property (nonatomic,copy)  NSString *url;   //下载的URL
@property (nonatomic,copy)  NSString *title;  //名字(可选)
@property (nonatomic,assign)Status   status;  //下载状态
@property (nonatomic,assign)Float64  downLoadProgress;//下载进度值
@property (nonatomic)    NSIndexPath *indexPath;//当前Cell的位置
@property (nonatomic,copy) void (^complete)(BOOL success,id obj,NSIndexPath *indexPath,NSArray <NSNumber *>*nextTasks);//下载回调结果
@property (nonatomic,copy) void (^progress)(float downLoadProgress,NSIndexPath *indexPath);//进度的回调结果

/******************************************************************/
/**
 * Note:以下是定时器模拟的配置属性,实际开发可以删除去
 */
@property (nonatomic,assign) Float64 bytesWritten;
@property (nonatomic,assign) Float64 totalBytesWritten;
@property (nonatomic,strong) NSTimer *timer;

@end
