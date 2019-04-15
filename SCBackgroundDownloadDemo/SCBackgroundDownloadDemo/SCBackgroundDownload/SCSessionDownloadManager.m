//
//  SCSessionDownloadManager.m
//  SCBackgroundDownloadDemo
//
//  Created by SuoChenhe on 15/12/17.
//  Copyright © 2015年 AndLiSoft. All rights reserved.
//

#import "SCSessionDownloadManager.h"
#import "SCDownloadFileTool.h"
#import "SCDownloadConfig.h"
#import "AppDelegate.h"
@interface SCSessionDownloadManager ()<NSURLSessionDelegate,NSURLSessionDownloadDelegate>

@property(nonatomic,strong)NSURLSession *urlSession;
@property(nonatomic,strong)NSMutableArray<SCSessionDownloadTask *> *downloadTaskArray;
@end
@implementation SCSessionDownloadManager

+ (instancetype)instance{
    static SCSessionDownloadManager *instance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc]init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [SCDownloadFileTool configAllDirectory];
        self.sessionConfigurationIdentifier = SCSessionConfigurationIdentifier;
        _downloadTaskArray = [NSMutableArray array];
        
    }
    return self;
}

- (void)setSessionConfigurationIdentifier:(NSString *)sessionConfigurationIdentifier{
    _sessionConfigurationIdentifier = sessionConfigurationIdentifier;
    NSURLSessionConfiguration *config ;

    config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:sessionConfigurationIdentifier];
    config.discretionary = YES;
    config.HTTPMaximumConnectionsPerHost = 2;//经测试最多三个同时下载
//    config.timeoutIntervalForResource = 20.f;
    _urlSession = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
}


- (SCSessionDownloadTask *)downloadWithUrlStr:(NSString *)urlStr fileId:(NSString *)fileId title:(NSString *)title downloadDirectory:(NSString *)downloadDirectory delegate:(id<SCSessionDownloadTaskDelegate>)delegate{
    SCSessionDownloadTask *sc_downloadTask = [self fileIsDownloadingWithFileId:fileId];
    if (sc_downloadTask) {
        if (sc_downloadTask.task.state == NSURLSessionTaskStateSuspended) {//没有做suspend的操作，全是cancell（两行代码无用）
            [sc_downloadTask.task resume];
        }
        __autoreleasing NSError * error = [NSError errorWithDomain:SCDownloadDomain code:SCDownloadErrorCode userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"%@ 正在下载中",title]}];
        if ([sc_downloadTask.delegate respondsToSelector:@selector(sc_sessionDownloadTask:start:error:)]) {
            [sc_downloadTask.delegate sc_sessionDownloadTask:sc_downloadTask start:NO error:error];
        }
        return sc_downloadTask;
    }
    
    sc_downloadTask = [SCSessionDownloadTask new];
    SCDownloadModel *downloadInfo = sc_downloadTask.downloadInfo;
    downloadInfo.fileId = fileId;
    downloadInfo.fileName = title;
    downloadInfo.downloadUrlStr = urlStr;
    downloadInfo.downloadDirectory = downloadDirectory;
    
    sc_downloadTask.delegate = delegate;
    
    BOOL hasDownload = [SCDownloadFileTool fileExistsAtPath:downloadInfo.filePath];
    if (hasDownload) {
        __autoreleasing NSError * error = [NSError errorWithDomain:SCDownloadDomain code:SCDownloadErrorCode userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"%@ 已经下载",title]}];
        if ([sc_downloadTask.delegate respondsToSelector:@selector(sc_sessionDownloadTask:start:error:)]) {
            [sc_downloadTask.delegate sc_sessionDownloadTask:sc_downloadTask start:NO error:error];
        }
        return sc_downloadTask;
    }

    [self startDownload:sc_downloadTask];
    
    return sc_downloadTask;
}

- (void)startDownload:(SCSessionDownloadTask *)downloadTask{
    NSURLSessionDownloadTask *task = nil;
    NSData * resumeData = [SCDownloadFileTool getResumeDataWithFileId:downloadTask.downloadInfo.fileId];
    if (resumeData){
        task = [_urlSession downloadTaskWithResumeData:resumeData];
        
        [SCDownloadFileTool deleteResumeDataWithFileId:downloadTask.downloadInfo.fileId];
        SCDownloadModel *downloadInfo = [[SCDownloadFileTool instance] getModelWithFileId:downloadTask.downloadInfo.fileId];
        downloadInfo.downloadState = SCDownloadStateDownloading;
        downloadTask.downloadInfo = downloadInfo;
    }else {
        NSString *encodeUrlStr = [downloadTask.downloadInfo.downloadUrlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        NSURL *url = [NSURL URLWithString:encodeUrlStr];
        task = [_urlSession downloadTaskWithURL:url];
        [[SCDownloadFileTool instance]insertModel:downloadTask.downloadInfo];
        [[SCDownloadFileTool instance]save];
    }
    task.taskDescription = downloadTask.downloadInfo.fileId;//为了处理正在下载，退出程序，下次进入接受complete消息
    downloadTask.task = task;
    [downloadTask.task resume];
    [_downloadTaskArray insertObject:downloadTask atIndex:0];
    NSLog(@"开始下载: %@ , resumData: %@",downloadTask.downloadInfo.fileName,@(resumeData != nil));
    if ([downloadTask.delegate respondsToSelector:@selector(sc_sessionDownloadTask:start:error:)]) {
        [downloadTask.delegate sc_sessionDownloadTask:downloadTask start:YES error:nil];
    }
}

#pragma mark - 替换delegate
- (SCSessionDownloadTask *)replaceDownloadTaskDelegateWithfileId:(NSString *)fileId delegate:(id<SCSessionDownloadTaskDelegate>)delegate{
    SCSessionDownloadTask *sc_downloadTask = [self fileIsDownloadingWithFileId:fileId];
    if (sc_downloadTask) {
        sc_downloadTask.delegate = delegate;
    }
    return sc_downloadTask;
}

- (void)replaceAllDownloadTaskDelegate:(id<SCSessionDownloadTaskDelegate>)delegate{
    for (SCSessionDownloadTask *tempDownloadTask in _downloadTaskArray) {
        tempDownloadTask.delegate = delegate;
    }
}
#pragma mark - 根据文件id获取task
- (SCSessionDownloadTask *)fileIsDownloadingWithFileId:(NSString *)fileId{
    SCSessionDownloadTask *downloadTask = nil;
    for (SCSessionDownloadTask *tempDownloadTask in _downloadTaskArray) {
        SCDownloadModel *tempDownloadInfo = tempDownloadTask.downloadInfo;
        if ([tempDownloadInfo.fileId isEqualToString:fileId]) {
            downloadTask = tempDownloadTask;
            break;
        }
    }
    return downloadTask;
}
#pragma mark - private
- (SCSessionDownloadTask *)getCurrentDownloadTask:(NSURLSessionDownloadTask *)task {
    SCSessionDownloadTask * downloadTask = nil;
    for (SCSessionDownloadTask * tempDownloadTask in _downloadTaskArray) {
        if ([tempDownloadTask.task isEqual:task]) {
            downloadTask = tempDownloadTask;
            break;
        }
    }
    return downloadTask;
}

- (void)removeDownloadTask:(SCSessionDownloadTask *)downloadTask {
    [downloadTask remove];
    [_downloadTaskArray removeObject:downloadTask];
}


#pragma mark - NSURLSessionDelegate
- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    NSLog(@"URLSessionDidFinishEventsForBackgroundURLSession");
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //Other Operation....
    
    if (appDelegate.backgroundSessionCompletionHandler) {
        NSLog(@"%@",appDelegate.backgroundSessionCompletionHandler);
        void (^completionHandler)(void) = appDelegate.backgroundSessionCompletionHandler;
        
        appDelegate.backgroundSessionCompletionHandler = nil;
        
        completionHandler();
        
    }

}
#pragma mark - NSURLSessionTaskDelegate
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error{
    SCSessionDownloadTask *sc_downloadTask = [self getCurrentDownloadTask:(NSURLSessionDownloadTask *)task];
    NSLog(@"didCompleteWithError filename: %@ ,error:%@",sc_downloadTask.downloadInfo.fileName,error);

    dispatch_async(dispatch_get_main_queue(), ^{
        BOOL success = YES;
        if (error) {
            success = NO;
            //NSURLErrorBackgroundTaskCancelledReasonKey=0,退出程序，下次进入的时候
            NSLog(@"taskDescription %@",task.taskDescription);
            SCDownloadModel *downloadInfo = [[SCDownloadFileTool instance] getModelWithFileId:task.taskDescription];
            downloadInfo.downloadState = SCDownloadStatePause;//暂停状态
            
            NSData *resumeData = error.userInfo[NSURLSessionDownloadTaskResumeData];//两种取消，只有一种有data
            if (resumeData) {
                [SCDownloadFileTool saveResumeData:resumeData fileId:task.taskDescription];
                
                if (downloadInfo) {
                    downloadInfo.expectedTotalBytes = task.countOfBytesExpectedToReceive;
                    downloadInfo.writtenTotalBytes = task.countOfBytesReceived;
                }
            }
//            else{//没有resumeData，并且是cancelled要删除记录
//                if ([error.userInfo[NSLocalizedDescriptionKey] isEqualToString:@"cancelled"]) {//timeout
//                    [[SCDownloadFileTool instance]deleteModelWithFileId:task.taskDescription];
//                }else{
////                    downloadInfo.downloadState = SCDownloadStateError;//error状态
//                }
//            }
        }
        
        if (sc_downloadTask) {
            if ([sc_downloadTask.delegate respondsToSelector:@selector(sc_sessionDownloadTask:didCompleteSuccess:error:)]) {
                [sc_downloadTask.delegate sc_sessionDownloadTask:sc_downloadTask didCompleteSuccess:success error:error];
            }
            [self removeDownloadTask:sc_downloadTask];

        }
        [[SCDownloadFileTool instance]save];
        
    });
}

#pragma mark - NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location{
    
    SCSessionDownloadTask *sc_downloadTask = [self getCurrentDownloadTask:downloadTask];
    NSLog(@"didFinishDownloadingToURL: %@",sc_downloadTask.downloadInfo.fileName);
    if (sc_downloadTask == nil) {
        return;
    }
    SCDownloadModel *downloadInfo = sc_downloadTask.downloadInfo;
    downloadInfo.expectedTotalBytes = downloadTask.countOfBytesExpectedToReceive;
    downloadInfo.writtenTotalBytes = downloadTask.countOfBytesReceived;
    downloadInfo.downloadState = SCDownloadStateFinished;
    
    [SCDownloadFileTool copyTempFileAtURL:location toDestination:[NSURL fileURLWithPath:downloadInfo.filePath]];
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([sc_downloadTask.delegate respondsToSelector:@selector(sc_sessionDownloadTask:received:total:speed:)]) {
            [sc_downloadTask.delegate sc_sessionDownloadTask:sc_downloadTask received:downloadTask.countOfBytesReceived total:downloadTask.countOfBytesExpectedToReceive speed:@""];
        }
    });
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
//    NSLog(@"%@",[NSThread currentThread]);
    SCSessionDownloadTask *sc_downloadTask = [self getCurrentDownloadTask:downloadTask];
    if (sc_downloadTask == nil) {
        return;
    }
    SCDownloadModel *downloadInfo = sc_downloadTask.downloadInfo;
    downloadInfo.expectedTotalBytes = totalBytesExpectedToWrite;
    downloadInfo.writtenTotalBytes = totalBytesWritten;
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([sc_downloadTask.delegate respondsToSelector:@selector(sc_sessionDownloadTask:received:total:speed:)]) {
            [sc_downloadTask.delegate sc_sessionDownloadTask:sc_downloadTask received:totalBytesWritten total:totalBytesExpectedToWrite speed:sc_downloadTask.downloadSpeed];
        }
    });

}

//用不到，舍弃了suspend方法
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes{
    NSLog(@"didResumeAtOffset");
    SCSessionDownloadTask *sc_downloadTask = [self getCurrentDownloadTask:downloadTask];
    if (sc_downloadTask == nil) {
        return;
    }
    SCDownloadModel *downloadInfo = sc_downloadTask.downloadInfo;
    downloadInfo.expectedTotalBytes = expectedTotalBytes;
    downloadInfo.writtenTotalBytes = fileOffset;
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([sc_downloadTask.delegate respondsToSelector:@selector(sc_sessionDownloadTask:received:total:speed:)]) {
            [sc_downloadTask.delegate sc_sessionDownloadTask:sc_downloadTask received:fileOffset total:expectedTotalBytes speed:sc_downloadTask.downloadSpeed];
        }
    });
}

@end
