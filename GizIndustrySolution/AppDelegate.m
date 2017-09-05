//
//  AppDelegate.m
//  GizIndustrySolution
//
//  Created by Minus🍀 on 16/9/1.
//  Copyright © 2016年 Gizwits. All rights reserved.
//

#import "AppDelegate.h"
#import "GizCommon.h"

#import <GizWifiSDK/GizWifiSDK.h>

#import "GizLoginViewController.h"
#import "GizConfigGuideViewController.h"
#import "GizMainViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[GizCommon sharedInstance] loadConfiguration];
    [[GizCommon sharedInstance] configureNavigationBarAttributes];
    
    [GizWifiSDK startWithAppID:GizAppId appSecret:GizAppSecret specialProductKeys:GizProductKeys cloudServiceInfo:nil autoSetDeviceDomain:NO];
    [GizWifiSDK setLogLevel:GizLogPrintAll];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkReachabilityDidChange:) name:kReachabilityChangedNotification object:nil];
    
    self.networkReachability = [Reachability reachabilityForInternetConnection];
    [self.networkReachability startNotifier];
    
    if ([GizCommon shouldAutoLogin])
    {
        // 自动登录，跳过登录界面，直接进入设备搜索界面，先进行用户登录，再开始搜索
        
        GizLoginViewController *loginViewController = [UIStoryboard mi_instantiateViewControllerWithIdentifier:@"GizLoginViewController" storyboard:@"Login"];
        
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
        
        GizConfigGuideViewController *configGuideViewController = [UIStoryboard mi_instantiateViewControllerWithIdentifier:@"GizConfigGuideViewController" storyboard:@"DeviceConfig"];
        
        [navigationController pushViewController:configGuideViewController animated:NO];
        
        UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        window.rootViewController = navigationController;
        self.window = window;
        [window makeKeyAndVisible];
    }
    
    return YES;
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
}

- (void)networkReachabilityDidChange:(NSNotification *)notification
{
    Reachability *reach = notification.object;
    
    NetworkStatus status = [reach currentReachabilityStatus];
    
    switch (status) {
        case NotReachable:
            NSLog(@"=================== 网络状态变更: 网络不可达");
            break;
            
        case ReachableViaWWAN:
            NSLog(@"=================== 网络状态变更: 无线广域网");
            break;
            
        case ReachableViaWiFi:
            NSLog(@"=================== 网络状态变更: WiFi");
            break;
    }
}

+ (BOOL)isNetworkReachable
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NetworkStatus status = [appDelegate.networkReachability currentReachabilityStatus];
    return status != NotReachable;
}

@end
