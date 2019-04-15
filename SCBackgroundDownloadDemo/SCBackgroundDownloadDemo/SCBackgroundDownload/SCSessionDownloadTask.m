//
//  SCSessionDownloadTask.m
//  SCBackgroundDownloadDemo
//
//  Created by SuoChenhe on 15/12/17.
//  Copyright © 2015年 AndLiSoft. All rights reserved.
//
#define NetSpeedCalculateDuring 1.f
#import "SCSessionDownloadTask.h"
#import "SCDownloadModel.h"

@interface SCSessionDownloadTask ()
@property(nonatomic,strong)NSTimer *timer;
@property(nonatomic,assign)int64_t lastSecondRecived;
@end
@implementation SCSessionDownloadTask
- (void)dealloc{
    NSLog(@"delloc %@",self);
}

#pragma mark - Public
- (void)remove{
//    _downloadInfo = nil;
//    _delegate = nil;
//    _task = nil;
    [_timer invalidate];
}

- (void)cancel:(BOOL)isDelete{
    if (!isDelete) {
        [_task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
            // 存储恢复下载数据在didCompleteWithError处理
        }];
    }else {
        [_task cancel];
    }
}

- (instancetype)init{
    self = [super init];
    if (self) {
        _downloadSpeed = @"1.00k/s";
        _timer = [NSTimer scheduledTimerWithTimeInterval:NetSpeedCalculateDuring target:self selector:@selector(calculateNetSpeed) userInfo:nil repeats:YES];
    }
    return self;
}

#pragma mark - Action
- (void)calculateNetSpeed{
//    if (_lastSecondRecived > 0) {
        int64_t changeBytes = _task.countOfBytesReceived - _lastSecondRecived;
        CGFloat speed = changeBytes / 1024.f / NetSpeedCalculateDuring;
        if (speed < 1024.f) {
            _downloadSpeed = [NSString stringWithFormat:@"%.1fK/s",speed];
        }else{
            speed = speed / 1024.f;
            _downloadSpeed = [NSString stringWithFormat:@"%.1fM/s",speed];
        }
//    }
    _lastSecondRecived = _task.countOfBytesReceived;
}

#pragma mark - getter
- (SCDownloadModel *)downloadInfo{
    if (_downloadInfo == nil) {
        _downloadInfo = [SCDownloadModel new];
    }
    
    return _downloadInfo;
}

@end
