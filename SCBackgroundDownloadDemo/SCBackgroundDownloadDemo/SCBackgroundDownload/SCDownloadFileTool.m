//
//  SCDownloadFileTool.m
//  SCBackgroundDownloadDemo
//
//  Created by SuoChenhe on 15/12/17.
//  Copyright © 2015年 AndLiSoft. All rights reserved.
//

#import "SCDownloadFileTool.h"
#import "SCDownloadConfig.h"
#import "SCBackgroundDownload.h"
#define defaultFileManager [NSFileManager defaultManager]
@interface SCDownloadFileTool ()

@end

@implementation SCDownloadFileTool

+ (instancetype)instance{
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc]init];
        [self configAllDirectory];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _downloadList = [NSKeyedUnarchiver unarchiveObjectWithFile:SCDownloadArchive];
        if (_downloadList == nil) {
            _downloadList = [NSMutableArray array];
        }else{
            for (SCDownloadModel *model in _downloadList) {
                if (model.downloadState == SCDownloadStateDownloading) {
                    model.downloadState = SCDownloadStatePause;
                }
            }
        }
    }
    return self;
}

- (void)save{
    BOOL success = [NSKeyedArchiver archiveRootObject:_downloadList toFile:SCDownloadArchive];
    NSLog(@"archive success: %d",success);
}

- (void)replaceModel:(SCDownloadModel *)model{
    NSInteger index = [self indexWithFileId:model.fileId];
    if (index != NSNotFound) {
        [_downloadList replaceObjectAtIndex:index withObject:model];
    }else{
        [_downloadList insertObject:model atIndex:0];
    }
}

- (void)insertModel:(SCDownloadModel *)model{//无remuseData的不一定没有开始下载过，可能开始了，在等待（一点数据没有接收到）
    [self replaceModel:model];
}

- (void)deleteModelWithFileId:(NSString *)fileId{
    for (SCDownloadModel *tempModel in _downloadList) {
        if ([tempModel.fileId isEqualToString:fileId]) {
            //取消正在下载
            SCSessionDownloadTask *downloadTask = [[SCSessionDownloadManager instance]fileIsDownloadingWithFileId:fileId];
            if (downloadTask) {
                [downloadTask cancel:YES];
            }
            //删除resumeData
            [SCDownloadFileTool deleteResumeDataWithFileId:fileId];
            //删除下载文件
            [defaultFileManager removeItemAtPath:tempModel.filePath error:NULL];
            //删除记录
            [_downloadList removeObject:tempModel];
            //保存下载列表
            [self save];
            break;
        }
    }
}

- (SCDownloadModel *)getModelWithFileId:(NSString *)fileId{
    SCDownloadModel *model = nil;
    for (SCDownloadModel *tempModel in _downloadList) {
        if ([tempModel.fileId isEqualToString:fileId]) {
            model = tempModel;
            break;
        }
    }
    return model;
}

- (NSInteger)indexWithFileId:(NSString *)fileId{
    NSInteger index = NSNotFound;
    for (NSInteger i = 0 ;i < _downloadList.count ; i++) {
        SCDownloadModel *tempModel = _downloadList[i];
        if ([tempModel.fileId isEqualToString:fileId]) {
            index = i;
            break;
        }
    }
    return index;
}


#pragma mark - 工具方法
+ (void)configAllDirectory{
    [self configDirectory:SCDownloadDirectory];
    [self configDirectory:SCResumeDataDirectory];
}

+ (BOOL)configDirectory:(nonnull NSString *)directory {
    BOOL  result = YES;
    if(directory != nil && directory.length > 0){
        
        if(![defaultFileManager fileExistsAtPath:directory]){
            __autoreleasing NSError *error = nil;
            [defaultFileManager createDirectoryAtPath:directory
                          withIntermediateDirectories:YES
                                           attributes:@{NSFileProtectionKey : NSFileProtectionNone}
                                                error:&error];
            if(error){
                NSLog(@"configDirectory %@",error);
                result = NO;
            }
        }
    }else{
        result = NO;
    }
    return result;
}

+ (NSString *)fileExistsWithDownLoadUrl:(NSString *)downLoadUrl{
    NSString *filePath = nil;
    for (SCDownloadModel *model in [SCDownloadFileTool instance].downloadList) {
        if ([downLoadUrl isEqualToString:model.downloadUrlStr]) {
            filePath = model.filePath;
            break;
        }
    }
    return filePath;
}


+ (BOOL)fileExistsAtPath:(NSString *)filePath{
    
    return [defaultFileManager fileExistsAtPath:filePath];
}

+ (NSData *)getResumeDataWithFileId:(NSString *)fileId{
    NSData * resumeData = nil;
    NSString *resumeDataFilePath = [self generateResumeDataFilePathWithFileId:fileId];
    if (resumeDataFilePath && [defaultFileManager fileExistsAtPath:resumeDataFilePath]) {
        resumeData = [NSData dataWithContentsOfFile:resumeDataFilePath];
    }
    return resumeData;
}

+ (BOOL)saveResumeData:(NSData *)resumeData fileId:(NSString *)fileId{
    NSString *resumeDataFilePath = [self generateResumeDataFilePathWithFileId:fileId];
    if (resumeData) {
        BOOL saved = [resumeData writeToFile:resumeDataFilePath atomically:YES];
        NSLog(@"saveresumedata success: %d",saved);
        return saved;
    }else{
        return NO;
    }
}

+ (BOOL)deleteResumeDataWithFileId:(NSString *)fileId{
    NSString *resumeDataFilePath = [self generateResumeDataFilePathWithFileId:fileId];
    NSError *error;
    if ([defaultFileManager fileExistsAtPath:resumeDataFilePath]) {
        [defaultFileManager removeItemAtPath:resumeDataFilePath error:&error];
    }
    if (error == nil) {
        NSLog(@"deleteResumeData success");
        return true;
    }else{
        NSLog(@"deleteResumeData error：%@",error);
        return false;
    }
}

//根据fileId ResumeDataFilePath
+ (NSString *)generateResumeDataFilePathWithFileId:(NSString *)fileId{
    return [SCResumeDataDirectory stringByAppendingPathComponent:fileId];
}

//把文件拷贝到指定路径
+ (BOOL)copyTempFileAtURL:(NSURL *)location toDestination:(NSURL *)destination
{
    
    NSError *error;
    [defaultFileManager removeItemAtURL:destination error:NULL];
    [defaultFileManager copyItemAtURL:location toURL:destination error:&error];
    if (error == nil) {
        NSLog(@"copyTempFileAtURL  success");
        return true;
    }else{
        NSLog(@"%@",location);
        NSLog(@"copyTempFileAtURL  %@",error);
        return false;
    }
}

@end
