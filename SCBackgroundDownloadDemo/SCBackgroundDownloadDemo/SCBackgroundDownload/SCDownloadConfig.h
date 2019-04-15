//
//  SCDownloadConfig.h
//  SCBackgroundDownloadDemo
//
//  Created by SuoChenhe on 15/12/17.
//  Copyright © 2015年 AndLiSoft. All rights reserved.
//

#ifndef SCDownloadConfig_h
#define SCDownloadConfig_h


/** ---------------------------- SessionConfiguration配置 ------------------------------- */

#define SCSessionConfigurationIdentifier @"SC_Download_Background"


/** ---------------------------- 文件下载error配置 --------------------------------------- */

#define SCDownloadDomain @"SCDownloadDomain"
#define SCDownloadErrorCode 8001

/** ---------------------------- 文件存储目录、路径 --------------------------------------- */

//以plist形式存储下载信息存储路径
#define SCDownloadPlist [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:@"SCDownloadList.plist"]
//归档下载信息存储路径
#define SCDownloadArchive [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:@"SCDownloadList.data"]

//文件下载存储目录
#define SCDownloadDirectory [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:@"SCDownload"]
//ResumeData载存储目录
#define SCResumeDataDirectory [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:@"SCResumeData"]

/** ----------------------------- 文件下载路径（测试用）------------------------------------ */

#define APPDownLoad @"https://dldir1.qq.com/qqfile/qq/PCTIM2.3.2/21158/TIM2.3.2.21158.exe"

#define MP3DownLoad @"http://music.163.com/song/media/outer/url?id=317151.mp3"

#define PNGDownLoad @"https://github.com/suochenhe/iOS/raw/master/image/iOS触摸响应.png"

#endif /* SCDownloadConfig_h */
