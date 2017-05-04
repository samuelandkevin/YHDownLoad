//
//  YHCellProgress.m
//  YHDownLoad
//
//  Created by YHIOS002 on 2017/5/3.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import "YHCellProgress.h"
#import "Masonry.h"
#import "YHDownLoadManager.h"

@interface YHCellProgress()
@property (nonatomic,strong) UIProgressView *progressV;
@property (nonatomic,strong) UIImageView *imgvAvatar;
@property (nonatomic,strong) UILabel *lbTitle;
@property (nonatomic,strong) UIButton *btnDownLoad;
@end

@implementation YHCellProgress

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _imgvAvatar = [UIImageView new];
        _imgvAvatar.image = [UIImage imageNamed:@"qq"];
        [self.contentView addSubview:_imgvAvatar];
        
        _lbTitle = [UILabel new];
        _lbTitle.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:_lbTitle];
        
        _progressV = [UIProgressView new];
        _progressV.progressTintColor = [UIColor blueColor];;
        _progressV.backgroundColor   = [UIColor grayColor];
        [self.contentView addSubview:_progressV];
        
        _btnDownLoad = [UIButton new];
        _btnDownLoad.titleLabel.font = [UIFont systemFontOfSize:14.0];
        _btnDownLoad.backgroundColor = [UIColor orangeColor];
        [_btnDownLoad addTarget:self action:@selector(onDownLoad:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_btnDownLoad];
        
        __weak typeof(self)weakSelf = self;
        [_imgvAvatar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(weakSelf.contentView).offset(10);
            make.centerY.equalTo(weakSelf.contentView.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(40, 40));
        }];
        
        [_lbTitle mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(weakSelf.imgvAvatar.mas_right).offset(10);
            make.top.equalTo(weakSelf.contentView).offset(10);
            make.right.lessThanOrEqualTo(weakSelf.contentView.mas_right).offset(-10);
        }];
        
        [_progressV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(weakSelf.imgvAvatar.mas_right).offset(10);
            make.centerY.equalTo(weakSelf.contentView.mas_centerY).offset(5);
            make.right.equalTo(weakSelf.btnDownLoad.mas_left).offset(-10);
        }];
        
        [_btnDownLoad mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(60, 40));
            make.centerY.equalTo(weakSelf.contentView);
            make.right.equalTo(weakSelf.contentView).offset(-3);
        }];

    }
    return self;
}

#pragma mark - Action
- (void)onDownLoad:(UIButton *)sender{
    if (_model.status == Status_isPaused) {
        _model.status = Status_isDownLoading;
        [[YHDownLoadManager sharedInstance] resumeDownLoadWithModel:_model];
    }else if(_model.status == Status_isDownLoading){
        _model.status = Status_isPaused;
        NSNumber *nextTaskIndex = [[YHDownLoadManager sharedInstance] pauseDownLoadWithModel:_model];
        if ([nextTaskIndex unsignedIntegerValue] && _delegate && [_delegate respondsToSelector:@selector(pauseDownLoad:atIndexPath:nextTask:)]) {
            [_delegate pauseDownLoad:YES atIndexPath:_model.indexPath nextTask:nextTaskIndex];
        }
        
    }else if (_model.status == Status_UnDownLoaded){
        _model.status = Status_isDownLoading;
        
    }else if (_model.status == Status_isDownLoaded){
        _model.status = Status_isDownLoaded;
        
    }
    [self _setupBtnDownLoadWithStatus:_model.status];
}

#pragma mark - Private
- (void)_setupBtnDownLoadWithStatus:(Status)status{
    switch (status) {
        case Status_UnDownLoaded:
        {
            [_btnDownLoad setTitle:@"未开始" forState:UIControlStateNormal];
        }
            break;
        case Status_isWaiting:
        {
            [_btnDownLoad setTitle:@"等待中" forState:UIControlStateNormal];
        }
            break;
        case Status_isPaused:
        {
            [_btnDownLoad setTitle:@"暂停" forState:UIControlStateNormal];
        }
            break;
        case Status_isDownLoading:
        {
            [_btnDownLoad setTitle:@"下载中" forState:UIControlStateNormal];
        }
            break;
        case Status_isDownLoaded:
        {
            [_btnDownLoad setTitle:@"已完成" forState:UIControlStateNormal];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - Setter
- (void)setModel:(YHDownLoadModel *)model{
    _model = model;
    _lbTitle.text = _model.url;
 
    _progressV.hidden = NO;
    
    if (_model.status == Status_isDownLoaded) {
        //已下载
        _progressV.hidden    = YES;
        _progressV.progress  = 0;
        
    }else if (_model.status == Status_UnDownLoaded){
        //未开始
        _progressV.hidden   = NO;
        _progressV.progress = 0;
        
        __weak typeof(self)weakSelf = self;
        
        
        [YHDownLoadManager sharedInstance].maxConcurrentCount = 2;
        _model.status = [[YHDownLoadManager sharedInstance] downLoadWithModel:_model complete:^(BOOL success, id obj,NSIndexPath *indexPath,NSArray <NSNumber *>*nextTasks) {
            if(weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(downLoadSuccess:atIndexPath:nextTasks:)]){
                [weakSelf.delegate downLoadSuccess:success atIndexPath:indexPath nextTasks:nextTasks];
            }
        } progress:^(float downLoadProgress,NSIndexPath *indexPath) {
            
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(updateProgress:atIndexPath:)]) {
                [weakSelf.delegate updateProgress:downLoadProgress atIndexPath:indexPath];
            }
        }];
        
        
        
    }
//    else if(_model.status == Status_isDownLoading){
//        //进行中
//        _progressV.hidden       = NO;
//        [self.progressV setProgress:_model.downLoadProgress];
//        
//    }else if(_model.status == Status_isPaused){
//        //暂停
//        _progressV.hidden       = NO;
//        [self.progressV setProgress:_model.downLoadProgress];
//        
//    }
    else{
        _progressV.hidden       = NO;
        [self.progressV setProgress:_model.downLoadProgress];
    }
    
    //设置按钮状态
    [self _setupBtnDownLoadWithStatus:_model.status];
}

#pragma mark - Public
- (void)updateProgress:(float)progress{
    self.progressV.hidden = NO;
    [self.progressV setProgress:progress animated:YES];
}

- (void)updateUIWithStatus:(Status)status{
    if (status == Status_isDownLoaded) {
         self.progressV.hidden = YES;
         self.progressV.progress = 0;
        
    }else if(status == Status_isDownLoaded){
    
    }else if(status == Status_UnDownLoaded){
        self.progressV.hidden = NO;
    }
    [self _setupBtnDownLoadWithStatus:status];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
