//
//  ViewController.m
//  SCBackgroundDownloadDemo
//
//  Created by Selen on 15/12/19.
//  Copyright © 2015年 AndLiSoft. All rights reserved.
//

#import "ViewController.h"
#import "SCBackgroundDownload.h"
#import "AppDelegate.h"


@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,weak)UITableView *tableView;
@property(nonatomic,strong)NSMutableArray *dataSource;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UITableView *tableView = [[UITableView alloc]initWithFrame:self.view.bounds];
    tableView.backgroundColor = [UIColor clearColor];
    tableView.tableFooterView = [UIView new];
    tableView.dataSource = self;
    tableView.delegate = self;
//    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.rowHeight = 44;
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:tableView];
    _tableView = tableView;
    
    [self loadData];
    
}

- (void)loadData{
    _dataSource = [NSMutableArray array];
    for (NSInteger i = 0; i < 10; i ++) {
        SCDownloadModel *model = [SCDownloadModel new];
        model.fileId = [NSString stringWithFormat:@"100%ld",i];
        model.fileName = [NSString stringWithFormat:@"文件%ld",i];
        model.downloadDirectory = SCDownloadDirectory;
        model.downloadUrlStr = PNGDownLoad;
        [_dataSource addObject:model];
    }
}

#pragma mark - UITableViewDataSource,UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataSource.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"SCViewControllerCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        
    }
    SCDownloadModel *model = _dataSource[indexPath.row];
    cell.textLabel.text = model.fileName;
    cell.detailTextLabel.text = model.fileId;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SCDownloadModel *model = _dataSource[indexPath.row];
    [[SCSessionDownloadManager instance]downloadWithUrlStr:model.downloadUrlStr fileId:model.fileId title:model.fileName downloadDirectory:model.downloadDirectory delegate:(AppDelegate *)[UIApplication sharedApplication].delegate];
    
}

//屏幕旋转
//- (void)canRotate{}



@end
