//
//  OffLineCenterCell.m
//  SCBackgroundDownloadDemo
//
//  Created by Selen on 15/12/19.
//  Copyright © 2015年 AndLiSoft. All rights reserved.
//

#import "OffLineCenterCell.h"
#import "SCBackgroundDownload.h"

@interface OffLineCenterCell ()
@property (nonatomic,weak) UIProgressView* progress;
@property (nonatomic,weak) UIButton* stateBtn;
@end
@implementation OffLineCenterCell
+ (CGFloat)cellHeight{
    return 80;
}

+ (NSString *)cellIdentifier{
    return @"OffLineCenterCell";
}

+ (instancetype)dequeueReusableCellWithTableView:(UITableView *)tableView{
    OffLineCenterCell *cell = [tableView dequeueReusableCellWithIdentifier:[self cellIdentifier]];
    if (cell == nil) {
        cell = [[OffLineCenterCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:[self cellIdentifier]];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.detailTextLabel.backgroundColor = [UIColor clearColor];
        
        UIProgressView *progress = [UIProgressView new];
        [self.contentView addSubview:progress];
        _progress = progress;
        
        UIButton *stateButton = [UIButton new];
        [self.contentView addSubview:stateButton];
        [stateButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [stateButton addTarget:self action:@selector(stateBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        _stateBtn = stateButton;
    }
    
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.textLabel.frame = CGRectMake(0.f, 0.f, self.frame.size.width, 20);
    self.detailTextLabel.frame  = CGRectMake(0.f, CGRectGetMaxY(self.textLabel.frame), self.frame.size.width, 50);
    CGRect progressRect = _progress.frame;
    progressRect.size.width  = self.frame.size.width;
    progressRect.origin.y = self.frame.size.height - progressRect.size.height - 5.f;
    _progress.frame = progressRect;
    
    CGFloat btnWH = self.frame.size.height;
    _stateBtn.frame = CGRectMake(self.frame.size.width - btnWH, 0.f, btnWH, btnWH);
//    [self bringSubviewToFront:_stateBtn];
}

- (void)setModel:(SCDownloadModel *)model{
    _model = model;
    [self updateUI];
}

- (void)updateUI{
    SCDownloadModel *model = _model;
    self.textLabel.text = [NSString stringWithFormat:@"%@    %@", model.fileId,model.fileName];
    self.detailTextLabel.text = [NSString stringWithFormat:@"%@/%@  \t%@",model.downloadSize,model.fileSize,_downloadTask.downloadSpeed];
    if (model.expectedTotalBytes == 0) {
        self.progress.progress = 0;
    }else{
        self.progress.progress = model.writtenTotalBytes / (CGFloat)model.expectedTotalBytes;
    }
    
    if (model.downloadState == SCDownloadStateDownloading) {
        [_stateBtn setTitle:@"下载中" forState:UIControlStateNormal];
        _stateBtn.tag = SCDownloadStateDownloading;
    }else if (model.downloadState == SCDownloadStatePause) {
        [_stateBtn setTitle:@"暂停" forState:UIControlStateNormal];
        _stateBtn.tag = SCDownloadStatePause;
    }else if (model.downloadState == SCDownloadStateFinished) {
        [_stateBtn setTitle:@"完成" forState:UIControlStateNormal];
        _stateBtn.tag = SCDownloadStateFinished;
    }else if (model.downloadState == SCDownloadStateWatting) {
        [_stateBtn setTitle:@"等待" forState:UIControlStateNormal];
        _stateBtn.tag = SCDownloadStateWatting;
    }else if (model.downloadState == SCDownloadStateError) {
        [_stateBtn setTitle:@"错误" forState:UIControlStateNormal];
        _stateBtn.tag = SCDownloadStateError;
    }
    

    
    if (model.downloadState == SCDownloadStatePause) {
        self.detailTextLabel.text = [NSString stringWithFormat:@"%@/%@  \t%@",model.downloadSize,model.fileSize,@"暂停"];
    }else if (model.downloadState == SCDownloadStateFinished) {
        self.detailTextLabel.text = [NSString stringWithFormat:@"%@/%@  \t%@",model.downloadSize,model.fileSize,@""];
    }else if (model.downloadState == SCDownloadStateError) {
        self.detailTextLabel.text = [NSString stringWithFormat:@"%@/%@  \t%@",model.downloadSize,model.fileSize,@"错误"];
    }
    
}

- (void)stateBtnClick:(UIButton *)sender{
    if (_model.downloadState == SCDownloadStateDownloading) {
        [_downloadTask cancel:NO];
    }else if (_model.downloadState == SCDownloadStatePause) {
        _downloadTask = [[SCSessionDownloadManager instance]downloadWithUrlStr:_model.downloadUrlStr fileId:_model.fileId title:_model.fileName downloadDirectory:_model.downloadDirectory delegate:self];
        self.model = _downloadTask.downloadInfo;
    }
    
    
}

#pragma mark - SCSessionDownloadTaskDelegate
- (void)sc_sessionDownloadTask:(SCSessionDownloadTask *)downloadTask didCompleteSuccess:(BOOL)success error:(NSError *)error{
//    NSLog(@"fielname: %@ success :%d ,error :%@",downloadTask.downloadInfo.fileName,success,error);
    [self updateUI];
    
}

- (void)sc_sessionDownloadTask:(SCSessionDownloadTask *)downloadTask received:(int64_t)received total:(int64_t)total speed:(NSString *)speed{
    [self updateUI];

//    SCDownloadModel *info = downloadTask.downloadInfo;
//    NSLog(@"%@",[NSString stringWithFormat:@"%@/%@  %@",info.downloadSize,info.fileSize,speed]);
    
//    NSLog(@"%lld  / %lld",received,total);
    
}


@end
