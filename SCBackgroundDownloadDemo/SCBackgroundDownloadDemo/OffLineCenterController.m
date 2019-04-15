//
//  ViewController1.m
//  SCBackgroundDownloadDemo
//
//  Created by SuoChenhe on 15/12/18.
//  Copyright © 2015年 AndLiSoft. All rights reserved.
//

#define CellH  100

#import "OffLineCenterController.h"
#import "OffLineCenterCell.h"
#import "SCBackgroundDownload.h"
#import "AppDelegate.h"
@interface OffLineCenterController ()
@property(nonatomic,strong)NSMutableArray *dataSource;
@end

@implementation OffLineCenterController

- (void)dealloc{
    NSLog(@"delloc %@",self);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _dataSource = [SCDownloadFileTool instance].downloadList;

}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[SCSessionDownloadManager instance]replaceAllDownloadTaskDelegate:(AppDelegate *)[UIApplication sharedApplication].delegate];
}

#pragma mark - UITableViewDataSource,UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataSource.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    OffLineCenterCell *cell = [OffLineCenterCell dequeueReusableCellWithTableView:tableView];
    SCDownloadModel *model = _dataSource[indexPath.row];
    
    cell.model = model;
    cell.downloadTask = [[SCSessionDownloadManager instance]replaceDownloadTaskDelegateWithfileId:model.fileId delegate:cell];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SCDownloadModel *model = _dataSource[indexPath.row];
    [[SCSessionDownloadManager instance]downloadWithUrlStr:model.downloadUrlStr fileId:model.fileId title:model.fileName downloadDirectory:model.downloadDirectory delegate:nil];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [OffLineCenterCell cellHeight];
}

- (void)canRotate{}

@end
