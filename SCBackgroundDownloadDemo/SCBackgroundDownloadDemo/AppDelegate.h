//
//  AppDelegate.h
//  SCBackgroundDownloadDemo
//
//  Created by SuoChenhe on 15/12/17.
//  Copyright © 2015年 AndLiSoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCSessionDownloadTask.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate,SCSessionDownloadTaskDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, copy) void (^backgroundSessionCompletionHandler)(void);

@end

