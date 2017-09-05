//
//  GizConfiguringDeviceViewController.m
//  GizIndustrySolution
//
//  Created by Minus🍀 on 16/9/18.
//  Copyright © 2016年 Gizwits. All rights reserved.
//

#import <GizWifiSDK/GizWifiSDK.h>

#import "UIImageView+PlayGIF.h"
#import "UIView+i7Rotate360.h"

#import "GizConfiguringDeviceViewController.h"
#import "GizConfigResultViewController.h"

@interface GizConfiguringDeviceViewController () <GizWifiSDKDelegate, GizWifiDeviceDelegate>
{
    BOOL shouldPushVC;
    
    BOOL isDiscovering;     // 设备配置过程中，忽略设备列表的回调
    
    NSTimer *configTimer;   // 60s 配置超时
    NSTimer *bindTimer;     // 绑定设备，15s 超时
    NSTimer *discoverTimer; // 搜索设备，15s 超时
    NSTimer *subscribeTimer;// 订阅设备，15s 超时
}

@property (weak, nonatomic) IBOutlet UIImageView *configuringImageView;
@property (weak, nonatomic) IBOutlet UILabel *ssidLabel;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;

@property (nonatomic, strong) NSString *currentDid;
@property (nonatomic, strong) NSString *currentMac;

@end

@implementation GizConfiguringDeviceViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.ssidLabel.text = self.ssid;
    
    shouldPushVC = YES;
    
    [GizWifiSDK sharedInstance].delegate = self;
    
    [self startConfigureDevice];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.configuringImageView stopRotating];
}

- (void)dealloc
{
    [GizWifiSDK sharedInstance].delegate = nil;
}

- (void)initializeUI
{
    [super initializeUI];
    
    UIColor *textColor = GizBaseTextColor;
    UIColor *iconColor = GizBaseIconColor;
    
    self.ssidLabel.textColor = textColor;
    self.tipLabel.textColor = textColor;
    
    self.tipLabel.text = [NSString stringWithFormat:@"正在配置%@", GizProductName];
    
    self.configuringImageView.tintColor = iconColor;
    self.configuringImageView.image = [[UIImage imageNamed:@"connecting"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

- (void)startConfigureDevice
{
    NSLog(@"开始配置设备...");
    
    isDiscovering = NO;
    
    [self.configuringImageView rotate360EndlessLoopWithDuration:1.0];
    
    configTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(configTimeout) userInfo:nil repeats:NO];
    
    [[GizWifiSDK sharedInstance] setDeviceOnboarding:self.ssid key:self.password configMode:GizWifiAirLink softAPSSIDPrefix:nil timeout:60 wifiGAgentType:@[@(GizGAgentESP)]];
}

- (void)startDiscoverDevice
{
    NSLog(@"开始搜索设备...");
    
    isDiscovering = YES;
    
    [[GizWifiSDK sharedInstance] getBoundDevices:GizUserId token:GizUserToken specialProductKeys:GizProductKeys];
    discoverTimer = [NSTimer scheduledTimerWithTimeInterval:GizTimeoutSeconds target:self selector:@selector(discoverTimeout) userInfo:nil repeats:NO];
}
/// 配置超时
- (void)configTimeout
{
    configTimer = nil;
    
    [self configureSuccess:NO];
}
/// 绑定超时
- (void)bindDeviceTimeout
{
    bindTimer = nil;
    
    [self configureSuccess:NO];
}
/// 搜索超时
- (void)discoverTimeout
{
    discoverTimer = nil;
    
    [self configureSuccess:NO];
}

- (void)subscribeTimeour
{
    subscribeTimer = nil;
    
    [self configureSuccess:YES];
}

- (void)configureSuccess:(BOOL)success
{
    @synchronized (self)
    {
        if (!shouldPushVC)
        {
            return;
        }
        
        shouldPushVC = NO;
        
        [GizWifiSDK sharedInstance].delegate = nil;
        
        // * ➔ addDevice ➔ selectWifi ➔ configuring
        
        GizConfigResultViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"GizConfigResultViewController"];
        
        viewController.success = success;
        
        NSMutableArray<__kindof UIViewController *> *viewControllers = [self.navigationController.viewControllers mutableCopy];
        [viewControllers removeLastObject];
        [viewControllers addObject:viewController];
        
        [self.navigationController setViewControllers:viewControllers animated:YES];
    }
}

#pragma mark - GizWifiSDKDelegate

- (void)wifiSDK:(GizWifiSDK *)wifiSDK didSetDeviceOnboarding:(NSError *)result mac:(NSString *)mac did:(NSString *)did productKey:(NSString *)productKey
{
    if (configTimer && configTimer.isValid)
    {
        if (result.code == GIZ_SDK_SUCCESS)
        {
            NSLog(@"设备配置成功 mac: %@, did: %@, productKey: %@", mac, did, productKey);
            
            self.currentMac = mac;
            self.currentDid = did;
            
            NSLog(@"开始绑定设备...");
            
            NSArray<NSString *> *productKeys = [GizCommon sharedInstance].productKeys;
            
            // 如果周围有其他产品的设备，SDK 也可以将其配上网，从而导致 SDK 获取的设备不正确
            // 因此用 productKey 来过滤，productKey 不正确的，就不进入绑定流程
            // 60秒内，没有本产品的设备配置成功的回调，就当作配置失败
            if ([productKeys containsObject:productKey])
            {
                [configTimer invalidate];
                configTimer = nil;
                
                [[GizWifiSDK sharedInstance] bindRemoteDevice:GizUserId token:GizUserToken mac:mac productKey:productKey productSecret:GizProductSecret];
                bindTimer = [NSTimer scheduledTimerWithTimeInterval:GizTimeoutSeconds target:self selector:@selector(bindDeviceTimeout) userInfo:nil repeats:NO];
            }
            else
            {
                NSLog(@"%@ product key 不正确，不绑定设备...", productKey);
            }
        }
        else if (result.code == GIZ_SDK_DEVICE_CONFIG_IS_RUNNING)
        {
            NSLog(@"设备配置中... %@", result);
        }
        else
        {
            NSLog(@"设备配置失败... %@", result);
            
            [configTimer invalidate];
            configTimer = nil;
            [self configureSuccess:NO];
        }
    }
}

- (void)wifiSDK:(GizWifiSDK *)wifiSDK didBindDevice:(NSError *)result did:(NSString *)did
{
    if (bindTimer && bindTimer.isValid)
    {
        [bindTimer invalidate];
        bindTimer = nil;
        
        if (result.code == GIZ_SDK_SUCCESS)
        {
            NSLog(@"绑定设备成功...");
            [self startDiscoverDevice];
        }
        else
        {
            NSLog(@"绑定设备失败... %@", result);
            [self configureSuccess:NO];
        }
    }
}

- (void)wifiSDK:(GizWifiSDK *)wifiSDK didDiscovered:(NSError *)result deviceList:(NSArray *)deviceList
{
    if (!isDiscovering)
    {
        NSLog(@"设备配置中，忽略设备列表回调... %@", deviceList);
        return;
    }
    
    if (!discoverTimer) {
        NSLog(@"搜索已超时，忽略设备列表回调... %@", deviceList);
        return;
    }
    
    if (result.code == GIZ_SDK_SUCCESS)
    {
        NSLog(@"搜索设备回调...");
        for (GizWifiDevice *device in deviceList)
        {
            if ([device.macAddress isEqualToString:self.currentMac] && !device.isDisabled && ![[GizCommon sharedInstance].boundDeviceArray containsObject:device])
            {
                isDiscovering = NO;
                
                // 重复配置同一台设备的时候，原来的 GizWifiDevice 会被注销掉，变为不可用，
                // 因此用新的 GizWifiDevice 替换掉旧的。
                NSArray<NSString *> *macArray = [[GizCommon sharedInstance].boundDeviceArray valueForKey:@"macAddress"];
                
                if ([macArray containsObject:device.macAddress]) {
                    NSUInteger index = [macArray indexOfObject:device.macAddress];
                    [GizCommon sharedInstance].boundDeviceArray[index] = device;
                } else {
                    [[GizCommon sharedInstance].boundDeviceArray addObject:device];
                }
                
                NSLog(@"找到设备，开始订阅设备...");
                [discoverTimer invalidate];
                discoverTimer = nil;
                
                subscribeTimer = [NSTimer scheduledTimerWithTimeInterval:GizTimeoutSeconds target:self selector:@selector(subscribeTimeour) userInfo:nil repeats:NO];
                
                device.delegate = self;
                [device setSubscribe:GizProductSecret subscribed:YES];
                return;
            }
        }
    }
    else
    {
        NSLog(@"搜索设备失败... %@", result);
    }
}

#pragma mark - GizWifiDeviceDelegate

- (void)device:(GizWifiDevice *)device didSetSubscribe:(NSError *)result isSubscribed:(BOOL)isSubscribed
{
    if (!subscribeTimer) {
        NSLog(@"设备订阅超时，忽略该回调...");
        return;
    }
    
    [subscribeTimer invalidate];
    subscribeTimer = nil;
    
    if (result.code == GIZ_SDK_SUCCESS)
    {
        NSLog(@"设备订阅成功...");
    }
    else
    {
        NSLog(@"设备订阅失败... %@", result);
    }
    
    [self configureSuccess:YES];
}

@end
