//
//  SCDownloadModel.h
//  SCBackgroundDownloadDemo
//
//  Created by SuoChenhe on 15/12/17.
//  Copyright © 2015年 AndLiSoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, SCDownloadState) {
    SCDownloadStateDownloading = 1,
    SCDownloadStatePause,
    SCDownloadStateFinished,
    SCDownloadStateError,//无用
    SCDownloadStateWatting,//无用
    
};

@interface SCDownloadModel : NSObject<NSCoding>
/** 文件Id */
@property(nonatomic,copy)NSString *fileId;
/** 文件名 */
@property(nonatomic,copy)NSString *fileName;
/** 下载目录 */
@property(nonatomic,copy)NSString *downloadDirectory;
/** 下载链接 */
@property(nonatomic,copy)NSString *downloadUrlStr;

/** 状态 */
@property(nonatomic,assign)SCDownloadState downloadState;
/** 总字节数 */
@property(nonatomic,assign)int64_t expectedTotalBytes;
/** 已下载字节数 */
@property(nonatomic,assign)int64_t writtenTotalBytes;

//用于显示
/** 文件总大小（xx M） */
@property(nonatomic,copy,readonly)NSString *fileSize;
/** 已下载大小（xx M） */
@property(nonatomic,copy,readonly)NSString *downloadSize;
/** 文件路径 */
@property(nonatomic,copy,readonly)NSString *filePath;


- (instancetype)initWithDictionary:(NSDictionary *)dic;

@end
