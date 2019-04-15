//
//  SCSessionDownloadTask.h
//  SCBackgroundDownloadDemo
//
//  Created by SuoChenhe on 15/12/17.
//  Copyright © 2015年 AndLiSoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SCDownloadModel.h"
@class SCSessionDownloadTask;
@protocol SCSessionDownloadTaskDelegate <NSObject>

@optional
- (void)sc_sessionDownloadTask:(SCSessionDownloadTask *)downloadTask start:(BOOL)success error:(NSError *)error;

- (void)sc_sessionDownloadTask:(SCSessionDownloadTask *)downloadTask didCompleteSuccess:(BOOL)success error:(NSError *)error;

- (void)sc_sessionDownloadTask:(SCSessionDownloadTask *)downloadTask received:(int64_t)received total:(int64_t)total speed:(NSString *)speed;

@end

@interface SCSessionDownloadTask : NSObject
@property(nonatomic,strong)SCDownloadModel *downloadInfo;
@property(nonatomic,strong)NSURLSessionDownloadTask *task;
@property(nonatomic,weak)id<SCSessionDownloadTaskDelegate> delegate;



/** 下载速度 */
@property(nonatomic,copy,readonly)NSString *downloadSpeed;

//
- (void)remove;

- (void)cancel:(BOOL)isDelete;
@end
