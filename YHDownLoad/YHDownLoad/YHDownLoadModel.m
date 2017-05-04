//
//  DownLoadModel.m
//  YHDownLoad
//
//  Created by YHIOS002 on 2017/5/3.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import "YHDownLoadModel.h"

@implementation YHDownLoadModel

- (void)dealloc{
    [_timer invalidate];
    _timer = nil;
    NSLog(@"%s is dealloc",__func__);
}

@end
