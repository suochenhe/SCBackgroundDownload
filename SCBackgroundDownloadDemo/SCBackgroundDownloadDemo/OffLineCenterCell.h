//
//  OffLineCenterCell.h
//  SCBackgroundDownloadDemo
//
//  Created by Selen on 15/12/19.
//  Copyright © 2015年 AndLiSoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCDownloadModel.h"
#import "SCSessionDownloadTask.h"
@interface OffLineCenterCell : UITableViewCell<SCSessionDownloadTaskDelegate>
@property(nonatomic,strong)SCDownloadModel *model;
@property (nonatomic,strong)SCSessionDownloadTask* downloadTask;

+ (CGFloat)cellHeight;
+ (NSString *)cellIdentifier;
+ (instancetype)dequeueReusableCellWithTableView:(UITableView *)tableView;
@end
