//
//  ViewController.m
//  SCBackgroundDownloadDemo
//
//  Created by SuoChenhe on 15/12/17.
//  Copyright © 2015年 AndLiSoft. All rights reserved.
//

#import "SingleDownloadViewController.h"
#import "OffLineCenterController.h"
#import "SCBackgroundDownload.h"

@interface SingleDownloadViewController ()<SCSessionDownloadTaskDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *fielPathlabel;
@property (weak, nonatomic) IBOutlet UILabel *urlLabel;
@property (weak, nonatomic) IBOutlet UILabel *speedLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progress;
- (IBAction)download:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)remove:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;

@property(nonatomic,weak)SCSessionDownloadTask *task;

@end

@implementation SingleDownloadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}



- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    ViewController1 *cx = [ViewController1 new];
//    [self.navigationController pushViewController:cx animated:YES];
}

- (IBAction)download:(id)sender {
//   _task = [[SCSessionDownloadManager instance]downloadWithUrlStr:APPDownLoad fileId:@"56216" title:@"一个app" downloadDirectory:SCDownloadDirectory delegate:self];
    
    _task = [[SCSessionDownloadManager instance]downloadWithUrlStr:MP3DownLoad fileId:@"56217" title:@"一个mp3" downloadDirectory:SCDownloadDirectory delegate:self];
}

- (IBAction)cancel:(id)sender {
    [_task cancel:NO];
}

- (IBAction)remove:(id)sender {
    [_task cancel:YES];
}

#pragma mark - SCSessionDownloadTaskDelegate
- (void)sc_sessionDownloadTask:(SCSessionDownloadTask *)downloadTask didCompleteSuccess:(BOOL)success error:(NSError *)error{
    NSLog(@"success :%d ,error :%@",success,error);
    if (success) {
        _errorLabel.text = @"成功";
    }else{
        _errorLabel.text = error.localizedDescription;
    }

}

- (void)sc_sessionDownloadTask:(SCSessionDownloadTask *)downloadTask received:(int64_t)received total:(int64_t)total speed:(NSString *)speed{
    SCDownloadModel *info = downloadTask.downloadInfo;
    _titleLabel.text = info.fileName;
    _fielPathlabel.text = info.filePath;
    _urlLabel.text = info.downloadUrlStr;
    
    CGFloat progress = received / (CGFloat)total;
    _progress.progress = progress;
    _speedLabel.text = [NSString stringWithFormat:@"%@/%@  %@",info.downloadSize,info.fileSize,speed];
    NSLog(@"%@",_speedLabel.text);
    
    NSLog(@"%lld  / %lld",received,total);
    
}

- (void)canRotate{}
@end
