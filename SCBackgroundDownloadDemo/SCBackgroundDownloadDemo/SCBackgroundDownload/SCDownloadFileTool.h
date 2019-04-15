//
//  SCDownloadFileTool.h
//  SCBackgroundDownloadDemo
//
//  Created by SuoChenhe on 15/12/17.
//  Copyright © 2015年 AndLiSoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCDownloadModel.h"
@interface SCDownloadFileTool : NSObject

@property (nonatomic,strong) NSMutableArray<SCDownloadModel *> *downloadList;
+ (instancetype)instance;
- (void)save;

- (SCDownloadModel *)getModelWithFileId:(NSString *)fileId;
- (void)deleteModelWithFileId:(NSString *)fileId;

- (void)insertModel:(SCDownloadModel *)model;




#pragma mark - 工具方法
+ (void)configAllDirectory;
+ (BOOL)configDirectory:(NSString *)directory;

+ (NSString *)fileExistsWithDownLoadUrl:(NSString *)downLoadUrl;
+ (BOOL)fileExistsAtPath:(NSString *)filePath;

+ (BOOL)copyTempFileAtURL:(NSURL *)location toDestination:(NSURL *)destination;

+ (NSString *)generateResumeDataFilePathWithFileId:(NSString *)fileId;
+ (BOOL)saveResumeData:(NSData *)resumeData fileId:(NSString *)fileId;
+ (BOOL)deleteResumeDataWithFileId:(NSString *)fileId;
+ (NSData *)getResumeDataWithFileId:(NSString *)fileId;
@end
