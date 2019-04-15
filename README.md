# SCBackgroundDownload
后台下载的工具类，支持断点续传


```objective-c
@interface SCSessionDownloadManager : NSObject
@property(nonatomic,copy)NSString *sessionConfigurationIdentifier;

+ (instancetype)instance;

//下载方法
- (SCSessionDownloadTask *)downloadWithUrlStr:(NSString *)urlStr fileId:(NSString *)fileId title:(NSString *)title downloadDirectory:(NSString *)downloadDirectory delegate:(id<SCSessionDownloadTaskDelegate>)delegate;

//替换delegate
- (SCSessionDownloadTask *)replaceDownloadTaskDelegateWithfileId:(NSString *)fileId delegate:(id<SCSessionDownloadTaskDelegate>)delegate;
- (void)replaceAllDownloadTaskDelegate:(id<SCSessionDownloadTaskDelegate>)delegate;


//根据文件id获取task
- (SCSessionDownloadTask *)fileIsDownloadingWithFileId:(NSString *)fileId;
@end
```

