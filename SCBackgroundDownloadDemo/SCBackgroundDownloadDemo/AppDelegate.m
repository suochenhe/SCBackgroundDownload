//
//  AppDelegate.m
//  SCBackgroundDownloadDemo
//
//  Created by SuoChenhe on 15/12/17.
//  Copyright © 2015年 AndLiSoft. All rights reserved.
//

#import "AppDelegate.h"
#import "SCBackgroundDownload.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(nonnull NSString *)identifier completionHandler:(nonnull void (^)(void))completionHandler{
    //backgroundSessionCompletionHandler是自定义的一个属性
    NSLog(@"appdelegate handleEventsForBackgroundURLSession");
    self.backgroundSessionCompletionHandler = completionHandler;
    
}



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [SCSessionDownloadManager instance];
    return YES;
}

#pragma mark - SCSessionDownloadTaskDelegate
- (void)sc_sessionDownloadTask:(SCSessionDownloadTask *)downloadTask start:(BOOL)success error:(NSError *)error{
    NSLog(@"appdelegate  start:%d error:%@",success,error);
    NSString *message = error.localizedDescription;
    if (success) {
        message = [NSString stringWithFormat:@"%@ 开始下载",downloadTask.downloadInfo.fileName];
    }

}

- (void)sc_sessionDownloadTask:(SCSessionDownloadTask *)downloadTask didCompleteSuccess:(BOOL)success error:(NSError *)error{
    NSLog(@"appdelegate  success:%d error:%@",success,error);
    NSString *message = error.localizedDescription;
    if (success) {
        message = [NSString stringWithFormat:@"%@ 下载完成",downloadTask.downloadInfo.fileName];
    }
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.

//    [[SCSessionDownloadManager instance]pauseAllDownloadTask];
    [[SCDownloadFileTool instance]save];
    
}

@end
