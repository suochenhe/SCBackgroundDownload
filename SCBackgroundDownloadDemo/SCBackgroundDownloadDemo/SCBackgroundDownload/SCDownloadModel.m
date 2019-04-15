//
//  SCDownloadModel.m
//  SCBackgroundDownloadDemo
//
//  Created by SuoChenhe on 15/12/17.
//  Copyright © 2015年 AndLiSoft. All rights reserved.
//

#import "SCDownloadModel.h"
#import "SCDownloadConfig.h"
#import "SCDownloadFileTool.h"
@implementation SCDownloadModel
- (instancetype)initWithDictionary:(NSDictionary *)dic{
    if (self = [super init]) {
//        _fileId = dic[@"fileId"];
//        _fileName = dic[@"fileName"];
//        _downloadDirectory = dic[@"downloadDirectory"];
//        _downloadUrlStr = dic[@"downloadUrlStr"];
        
//        _downloadState = [dic[@"downloadState"] integerValue];
//        _expectedTotalBytes = [dic[@"expectedTotalBytes"] longLongValue];
//        _writtenTotalBytes = [dic[@"writtenTotalBytes"] longLongValue];
        [self setValuesForKeysWithDictionary:dic];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _downloadState = SCDownloadStateDownloading;
    }
    return self;
}

- (NSDictionary *)conventToDictonary{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"fileId"] = _fileId;
    dic[@"fileName"] = _fileName;
    dic[@"downloadDirectory"] = _downloadDirectory;
    dic[@"downloadUrlStr"] = _downloadUrlStr;
    
    dic[@"downloadState"] = @(_downloadState);
    dic[@"expectedTotalBytes"] = @(_expectedTotalBytes);
    dic[@"writtenTotalBytes"] = @(_writtenTotalBytes);
    
    return dic;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_fileId forKey:@"fileId"];
    [aCoder encodeObject:_fileName forKey:@"fileName"];
    [aCoder encodeObject:_downloadDirectory forKey:@"downloadDirectory"];
    [aCoder encodeObject:_downloadUrlStr forKey:@"downloadUrlStr"];
    
    [aCoder encodeInt32:_downloadState forKey:@"downloadState"];
    [aCoder encodeInt64:_expectedTotalBytes forKey:@"expectedTotalBytes"];
    [aCoder encodeInt64:_writtenTotalBytes forKey:@"writtenTotalBytes"];
}
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _fileId = [aDecoder decodeObjectForKey:@"fileId"];
        _fileName = [aDecoder decodeObjectForKey:@"fileName"];
        _downloadDirectory = [aDecoder decodeObjectForKey:@"downloadDirectory"];
        _downloadUrlStr = [aDecoder decodeObjectForKey:@"downloadUrlStr"];

        _downloadState = [aDecoder decodeInt32ForKey:@"downloadState"];
        _expectedTotalBytes = [aDecoder decodeInt64ForKey:@"expectedTotalBytes"];
        _writtenTotalBytes = [aDecoder decodeInt64ForKey:@"writtenTotalBytes"];

    }
    return self;
}


- (NSString *)filePath{
    NSString *fileSaveName = [self generateFileNameWithFileId:_fileId title:_fileName urlStr:_downloadUrlStr];
    return [SCDownloadDirectory stringByAppendingPathComponent:fileSaveName];
}

- (NSString *)fileSize{
    return [self calculateFileSize:_expectedTotalBytes];
}

- (NSString *)downloadSize{
    return [self calculateFileSize:_writtenTotalBytes];
}

- (NSString *)calculateFileSize:(ino64_t)bytes{
    NSString *fileSize = @"";
    if (bytes > 0) {
        CGFloat size = bytes / 1024.f;
        if (size < 1024.f) {
            fileSize = [NSString stringWithFormat:@"%.1fK",size];
        }else{
            size = size / 1024.f;
            if (size < 1024.f) {
                fileSize = [NSString stringWithFormat:@"%.1fM",size];
            }else{
                size = size / 1024.f;
                fileSize = [NSString stringWithFormat:@"%.1fG",size];
            }
            
        }
    }
    return fileSize;
}


//根据fileId ,title和url生成 （带扩展名）文件名
- (NSString *)generateFileNameWithFileId:(NSString *)fileId title:(NSString *)title urlStr:(NSString *)ulrStr{
    NSString * fileName = [NSString stringWithFormat:@"%@__%@",fileId,title];
    if(fileName){
        NSString * format = [self fileTypeWithUrl:ulrStr];
        if(format && ![format isEqualToString:[NSString stringWithFormat:@".%@",
                                               [[fileName componentsSeparatedByString:@"."] lastObject]]]){
            fileName = [NSString stringWithFormat:@"%@%@",fileName,format];
        }
    }
    return fileName;
}

//根据url获得，扩展名
- (nullable NSString *)fileTypeWithUrl:(nonnull NSString *)ulrStr {
    NSArray  * strArr = [ulrStr componentsSeparatedByString:@"."];
    if(strArr && strArr.count > 0){
        NSString * suffix = strArr.lastObject;
        if (suffix.length > 7) {
            return nil;
        }
        return [NSString stringWithFormat:@".%@",strArr.lastObject].lowercaseString;
    }else{
        return nil;
    }
}



@end
