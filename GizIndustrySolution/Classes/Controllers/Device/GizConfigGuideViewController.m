//
//  GizConfigGuideViewController.m
//  GizIndustrySolution
//
//  Created by Minus🍀 on 16/9/18.
//  Copyright © 2016年 Gizwits. All rights reserved.
//

#import <GizWifiSDK/GizWifiSDK.h>

#import "UIImageView+PlayGIF.h"

#import "GizConfigGuideViewController.h"
#import "GizScanCodeViewController.h"
#import "GizUserInfoViewController.h"
#import "GizDiscoverFailViewController.h"
#import "GizAddDeviceGuideViewController.h"
#import "GizMainViewController.h"

@interface GizConfigGuideViewController () <GizWifiSDKDelegate, GizWifiDeviceDelegate>
{
    NSTimer *loginTimer;
    NSTimer *discoverTimer;
    NSTimer *subscribeTimer;
    
    // 用于判断搜索设备的方法是否回调过
    // 15秒内搜索不到设备，回调过则跳转到无设备界面，没有回调过则跳转超时界面
    BOOL hasCallbackDiscover;
}

@property (weak, nonatomic) IBOutlet UIImageView *searchImageView;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;

@property (weak, nonatomic) IBOutlet UIImageView *addDeviceImageView;
@property (weak, nonatomic) IBOutlet UILabel *noDeviceTipLabel;

@property (weak, nonatomic) IBOutlet GizButton *addNewDeviceButton;
@property (weak, nonatomic) IBOutlet UIButton *scanButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *userInfoBarButtonItem;

@end

@implementation GizConfigGuideViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [GizWifiSDK sharedInstance].delegate = self;
    
    // 用户未登录，则先登录
    if (!GizUserId || !GizUserToken)
    {
        [self startLoginUser];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!loginTimer && !discoverTimer && GizUserId && GizUserToken)
    {
        [self startDiscoverDevices];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (self.searchImageView.isGIFPlaying)
    {
        [self.searchImageView stopGIF];
    }
}

// override
- (void)initializeUI
{
    [super initializeUI];
    
    self.title = [NSString stringWithFormat:@"加载%@", GizProductName];
    
    UIColor *textColor = GizBaseTextColor;
    UIColor *iconColor = GizBaseIconColor;
    
    self.tipLabel.textColor = textColor;
    self.tipLabel.text = [NSString stringWithFormat:@"正在加载已添加的%@", GizProductName];
    
    self.noDeviceTipLabel.textColor = textColor;
    self.noDeviceTipLabel.text = [NSString stringWithFormat:@"未发现已添加的%@，一起开启体验之旅吧~", GizProductName];
    
    self.noDeviceTipLabel.hidden = YES;
    self.addDeviceImageView.hidden = YES;
    
    [self setupAppearanceForButton:self.addNewDeviceButton];
    [self.addNewDeviceButton setTitle:[NSString stringWithFormat:@"添加%@", GizProductName] forState:UIControlStateNormal];
    
    NSDictionary *attributes = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle),
                                 NSForegroundColorAttributeName: textColor};
    NSAttributedString *underlineString = [[NSAttributedString alloc] initWithString:@"扫码绑定设备" attributes:attributes];
    [self.scanButton setAttributedTitle:underlineString forState:UIControlStateNormal];
    
    self.addDeviceImageView.tintColor = iconColor;
    self.addDeviceImageView.image = [self.addDeviceImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    self.searchImageView.tintColor = iconColor;
    self.searchImageView.gifPath = [[NSBundle mainBundle] pathForResource:@"search" ofType:@"gif"];
}

#pragma mark - Actions

- (IBAction)actionShowUserInfo:(id)sender
{
    NSLog(@"显示用户个人信息，忽略设备搜索结果...");
    
    if (discoverTimer)
    {
        [discoverTimer invalidate];
        discoverTimer = nil;
        [self.searchImageView stopGIF];
    }
    
    GizUserInfoViewController *viewController = [UIStoryboard mi_instantiateViewControllerWithIdentifier:@"GizUserInfoViewController" storyboard:@"User"];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)actionScanCode:(id)sender
{
    NSLog(@"扫描二维码，忽略设备搜索结果...");
    
    if (discoverTimer)
    {
        [discoverTimer invalidate];
        discoverTimer = nil;
        [self.searchImageView stopGIF];
    }
    
    GizScanCodeViewController *viewController = [[GizScanCodeViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)actionAddNewDevice:(id)sender
{
    NSLog(@"配置新的设备，忽略设备搜索结果...");
    
    if (discoverTimer)
    {
        [discoverTimer invalidate];
        discoverTimer = nil;
        [self.searchImageView stopGIF];
    }
    
    GizAddDeviceGuideViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"GizAddDeviceGuideViewController"];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - Transactions

- (void)startLoginUser
{
    NSLog(@"用户未登录，开始登录...");
    
    [self.userInfoBarButtonItem setEnabled:NO];
    
    NSString *account = [GizCommon getArchiveAccount];
    NSString *password = [GizCommon getArchivePassword];
    
    [GizWifiSDK sharedInstance].delegate = self;
    
    if (!self.searchImageView.isGIFPlaying)
    {
        [self.searchImageView startGIF];
    }
    
    loginTimer = [NSTimer scheduledTimerWithTimeInterval:GizTimeoutSeconds target:self selector:@selector(loginTimeout) userInfo:nil repeats:NO];
    
    [[GizWifiSDK sharedInstance] userLogin:account password:password];
}

- (void)startDiscoverDevices
{
    if (discoverTimer) {
        return;
    }
    
    NSLog(@"开始搜索设备...");
    
    [GizWifiSDK sharedInstance].delegate = self;
    
    self.title = [NSString stringWithFormat:@"加载%@", GizProductName];
    self.searchImageView.hidden = NO;
    self.tipLabel.hidden = NO;
    
    self.addDeviceImageView.hidden = YES;
    self.noDeviceTipLabel.hidden = YES;
    
    if (!self.searchImageView.isGIFPlaying)
    {
        [self.searchImageView startGIF];
    }
    
    hasCallbackDiscover = NO;
    
    // 搜索 已绑定 的设备列表
    [[GizWifiSDK sharedInstance] getBoundDevices:GizUserId token:GizUserToken specialProductKeys:GizProductKeys];
    // 15秒超时
    discoverTimer = [NSTimer scheduledTimerWithTimeInterval:GizTimeoutSeconds target:self selector:@selector(discoverBoundDevicesTimeOut) userInfo:nil repeats:NO];
}

// 登录超时
- (void)loginTimeout
{
    NSLog(@"用户登录超时...");
    
    loginTimer = nil;
    
    [self.searchImageView stopGIF];
    
    GizDiscoverFailViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"GizDiscoverFailViewController"];
    
    @weakify(self);
    [viewController setRetryBlock:^{
        
        @strongify(self);
        [self startLoginUser];
    }];
    [self.navigationController pushViewController:viewController animated:YES];
}

// 搜索超时
- (void)discoverBoundDevicesTimeOut
{
    NSLog(@"搜索设备超时...");
    
    discoverTimer = nil;
    [self.searchImageView stopGIF];
    
    // 15秒搜索超时，如果SDK有回调过didDiscovered方法，但这些设备用户都没有绑定过的，则跳转【无设备】界面
    if (hasCallbackDiscover)
    {
        NSLog(@"没有绑定过设备");
        
        self.title = [NSString stringWithFormat:@"添加%@", GizProductName];
        self.searchImageView.hidden = YES;
        self.tipLabel.hidden = YES;
        
        self.addDeviceImageView.hidden = NO;
        self.noDeviceTipLabel.hidden = NO;
    }
    else    // 跳转【超时】界面
    {
        GizDiscoverFailViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"GizDiscoverFailViewController"];
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

// 自动订阅设备
- (void)subscribeDevives:(NSArray<GizWifiDevice *> *)deviceArray
{
    NSLog(@"开始订阅设备...");
    
    // 设备订阅中，不能进入【用户信息】
    [self.userInfoBarButtonItem setEnabled:NO];
    
    subscribeTimer = [NSTimer scheduledTimerWithTimeInterval:GizTimeoutSeconds target:self selector:@selector(subscribeTimeout) userInfo:nil repeats:NO];
    
    for (GizWifiDevice *device in deviceArray)
    {
        NSLog(@"订阅设备 mac: %@, did: %@", device.macAddress, device.did);
        
        device.delegate = self;
        [device setSubscribe:GizProductSecret subscribed:YES];
    }
}
// 订阅设备超时
- (void)subscribeTimeout
{
    NSLog(@"订阅设备超时...");
    
    subscribeTimer = nil;
    
    for (GizWifiDevice *device in [GizCommon sharedInstance].boundDeviceArray)
    {
        if (device.isSubscribed)
        {
            [self pushToMainViewController];
            
            return;
        }
    }
    
    [self discoverBoundDevicesTimeOut];
}

- (void)pushToMainViewController
{
    [self.userInfoBarButtonItem setEnabled:YES];
    
    [self.searchImageView stopGIF];
    
    GizMainViewController *viewController = [UIStoryboard mi_instantiateViewControllerWithIdentifier:@"GizMainViewController" storyboard:@"Main"];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - GizWifiSDKDelegate

- (void)wifiSDK:(GizWifiSDK *)wifiSDK didUserLogin:(NSError *)result uid:(NSString *)uid token:(NSString *)token
{
    // 15s 超时后，抛弃 SDK 的回调
    if (loginTimer && loginTimer.isValid)
    {
        if (result.code == GIZ_SDK_SUCCESS)
        {
            NSLog(@"用户登录成功...");
            
            [GizCommon sharedInstance].uid = uid;
            [GizCommon sharedInstance].token = token;
            
            [[GizWifiSDK sharedInstance] getUserInfo:GizUserToken];
        }
        else if (result.code == GIZ_OPENAPI_USERNAME_PASSWORD_ERROR)
        {
            [loginTimer invalidate];
            loginTimer = nil;
            
            [self.searchImageView stopGIF];
            
            [self alertWithTitle:@"密码错误" message:@"请重新登录" cancel:nil confirm:@"确定" confirmBlock:^{
                [GizCommon clearUserPassword];
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }
        else
        {
            NSLog(@"用户登录失败... %@", result);
            
            [GizCommon sharedInstance].uid = nil;
            [GizCommon sharedInstance].token = nil;
            
            [loginTimer invalidate];
            loginTimer = nil;
            
            [self.searchImageView stopGIF];
            
            GizDiscoverFailViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"GizDiscoverFailViewController"];
            
            @weakify(self);
            [viewController setRetryBlock:^{
                
                @strongify(self);
                [self startLoginUser];
            }];
            [self.navigationController pushViewController:viewController animated:YES];
        }
    }
}

- (void)wifiSDK:(GizWifiSDK *)wifiSDK didGetUserInfo:(NSError *)result userInfo:(GizUserInfo *)userInfo
{
    if (loginTimer && loginTimer.isValid)
    {
        [loginTimer invalidate];
        loginTimer = nil;
        
        if (result.code == GIZ_SDK_SUCCESS)
        {
            NSLog(@"获取用户信息成功...");
            
            [GizCommon sharedInstance].userInfo = userInfo;
            
            [self.userInfoBarButtonItem setEnabled:YES];
            
            [self startDiscoverDevices];
        }
        else
        {
            NSLog(@"获取用户信息失败... %@", result);
            
            [GizCommon sharedInstance].uid = nil;
            [GizCommon sharedInstance].token = nil;
            
            [self.searchImageView stopGIF];
            
            GizDiscoverFailViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"GizDiscoverFailViewController"];
            
            @weakify(self);
            [viewController setRetryBlock:^{
                
                @strongify(self);
                [self startLoginUser];
            }];
            [self.navigationController pushViewController:viewController animated:YES];
        }
    }
}

- (void)wifiSDK:(GizWifiSDK *)wifiSDK didDiscovered:(NSError *)result deviceList:(NSArray *)deviceList
{
    // 15秒超时后，忽略搜索结果回调
    if (discoverTimer && discoverTimer.isValid)
    {
        if (result.code == GIZ_SDK_SUCCESS)
        {
            NSLog(@"发现设备 %@", deviceList);
            
            hasCallbackDiscover = YES;
            
            NSMutableArray<GizWifiDevice *> *boundDeviceArray = [GizCommon sharedInstance].boundDeviceArray;
            
            for (GizWifiDevice *device in deviceList)
            {
                if (device.isBind && ![boundDeviceArray containsObject:device])
                {
                    [boundDeviceArray addObject:device];
                }
            }
            
            if ([boundDeviceArray count] > 0)
            {
                [discoverTimer invalidate];
                discoverTimer = nil;
                
                // 自动订阅设备
                [self subscribeDevives:boundDeviceArray];
            }
            else
            {
                NSLog(@"以上设备都没有绑定过");
            }
        }
        else
        {
            NSLog(@"发现设备出错 %@", result);
        }
    }
    else
    {
        // 设备订阅过程中，发现了新的设备 (在主界面订阅这些新的设备)
        if (result.code == GIZ_SDK_SUCCESS && subscribeTimer && subscribeTimer.isValid)
        {
            NSMutableArray<GizWifiDevice *> *boundDeviceArray = [GizCommon sharedInstance].boundDeviceArray;
            
            for (GizWifiDevice *device in deviceList)
            {
                if (device.isBind && ![boundDeviceArray containsObject:device])
                {
                    [boundDeviceArray addObject:device];
                }
            }
        }
        else
        {
            NSLog(@"忽略 发现设备 %@", deviceList);
        }
    }
}

#pragma mark - GizWifiDeviceDelegate

- (void)device:(GizWifiDevice *)device didSetSubscribe:(NSError *)result isSubscribed:(BOOL)isSubscribed
{
    // 15秒内，只要有一台设备订阅成功，就进入【主控】界面，然后忽略后面的回调
    if (result.code == GIZ_SDK_SUCCESS && isSubscribed && subscribeTimer && subscribeTimer.isValid)
    {
        NSLog(@"设备订阅成功 mac: %@, did: %@", device.macAddress, device.did);
        
        [subscribeTimer invalidate];
        subscribeTimer = nil;
        
        [self pushToMainViewController];
    }
}

@end
