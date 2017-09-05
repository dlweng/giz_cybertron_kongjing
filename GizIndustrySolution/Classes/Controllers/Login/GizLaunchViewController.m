//
//  GizLaunchViewController.m
//  GizIndustrySolution
//
//  Created by Minus🍀 on 2016/9/23.
//  Copyright © 2016年 Gizwits. All rights reserved.
//

#import <GizWifiSDK/GizWifiSDK.h>

#import "GizLaunchViewController.h"
#import "GizConfigGuideViewController.h"

@interface GizLaunchViewController () <GizWifiSDKDelegate>

@end

@implementation GizLaunchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = YES;
    
    NSString *account = [GizCommon getArchiveAccount];
    NSString *password = [GizCommon getArchivePassword];
    
    [GizWifiSDK sharedInstance].delegate = self;
    [[GizWifiSDK sharedInstance] userLogin:account password:password];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - GizWifiSDKDelegate

- (void)wifiSDK:(GizWifiSDK *)wifiSDK didUserLogin:(NSError *)result uid:(NSString *)uid token:(NSString *)token
{
    if (result.code == GIZ_SDK_SUCCESS)
    {
        [GizCommon sharedInstance].uid = uid;
        [GizCommon sharedInstance].token = token;
    }
    
    GizConfigGuideViewController *viewController = [UIStoryboard mi_instantiateViewControllerWithIdentifier:@"GizConfigGuideViewController" storyboard:@"DeviceConfig"];
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
