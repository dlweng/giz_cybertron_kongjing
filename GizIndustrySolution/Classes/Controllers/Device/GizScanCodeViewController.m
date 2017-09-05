//
//  GizScanCodeViewController.m
//  GizIndustrySolution
//
//  Created by Minus🍀 on 16/9/19.
//  Copyright © 2016年 Gizwits. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "GizScanCodeViewController.h"
#import "GizMainViewController.h"

@interface GizScanCodeViewController () <AVCaptureMetadataOutputObjectsDelegate, GizWifiSDKDelegate, GizWifiDeviceDelegate, GizDeviceSharingDelegate>
{
    AVCaptureSession *session;
    
    UIImageView *lineImageView;
    
    BOOL isDiscovering;     // 设备配置过程中，忽略设备列表的回调
    BOOL isDiscoveringSharedDevice;   // 绑定别人分享的设备
    
    NSTimer *bindTimer;     // 绑定设备，15s 超时
    NSTimer *discoverTimer; // 搜索设备，15s 超时
    NSTimer *subscribeTimer;// 订阅设备，15s 超时
}

@property (nonatomic, strong) NSString *currentDid;

@end

@implementation GizScanCodeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"扫码添加";
    
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    if (status == AVAuthorizationStatusDenied || status == AVAuthorizationStatusRestricted)
    {
        self.view.backgroundColor = [UIColor blackColor];
        [self setOverlayPickerView];
        
        [self alertWithTitle:@"提示" message:@"相机访问被拒绝" confirm:@"确定"];
    }
    else
    {
        [self createScanViews];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if ([session isRunning])
    {
        [session stopRunning];
    }
    [GizWifiSDK sharedInstance].delegate = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    if (session && !session.running)
    {
        [session startRunning];
    }
    [GizWifiSDK sharedInstance].delegate = self;
}


- (void)dealloc
{
    [session removeObserver:self forKeyPath:@"running"];
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([object isKindOfClass:[AVCaptureSession class]])
    {
        BOOL isRunning = ((AVCaptureSession *)object).isRunning;
        if (isRunning)
        {
            [self addAnimation];
        }
        else
        {
            [self removeAnimation];
        }
    }
}

- (void)createScanViews
{
    //获取摄像设备
    AVCaptureDevice * device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //创建输入流
    AVCaptureDeviceInput * input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    //创建输出流
    AVCaptureMetadataOutput * output = [[AVCaptureMetadataOutput alloc] init];
    //设置代理 在主线程里刷新
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    //初始化链接对象
    session = [[AVCaptureSession alloc] init];
    //高质量采集率
    [session setSessionPreset:AVCaptureSessionPresetHigh];
    if (input && [session canAddInput:input]) {
        [session addInput:input];
    }
    if (output && [session canAddOutput:output]) {
        [session addOutput:output];
        //设置扫码支持的编码格式(如下设置条形码和二维码兼容)
        NSMutableArray *a = [[NSMutableArray alloc] init];
        if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeQRCode]) {
            [a addObject:AVMetadataObjectTypeQRCode];
        }
        if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeEAN13Code]) {
            [a addObject:AVMetadataObjectTypeEAN13Code];
        }
        if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeEAN8Code]) {
            [a addObject:AVMetadataObjectTypeEAN8Code];
        }
        if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeCode128Code]) {
            [a addObject:AVMetadataObjectTypeCode128Code];
        }
        output.metadataObjectTypes=a;
    }
    AVCaptureVideoPreviewLayer * layer = [AVCaptureVideoPreviewLayer layerWithSession:session];
    layer.videoGravity=AVLayerVideoGravityResizeAspectFill;
    layer.frame=self.view.layer.bounds;
    [self.view.layer insertSublayer:layer atIndex:0];
    
    [self setOverlayPickerView];
    
    [session addObserver:self forKeyPath:@"running" options:NSKeyValueObservingOptionNew context:nil];
    
    //开始捕获
    [session startRunning];
}

- (void)setOverlayPickerView
{
    CGFloat width = GizScreenWidth - 100.0;
    
    UIImageView *frameImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, width)];
    frameImageView.tintColor = GizButtonBgColor;
    frameImageView.image = [[UIImage imageNamed:@"scan_frame"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    frameImageView.center = self.view.center;
    frameImageView.centerY -= 40;
    [self.view addSubview:frameImageView];
    
    lineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, 3)];
    lineImageView.tintColor = GizButtonBgColor;
    lineImageView.image = [[UIImage imageNamed:@"scan_line"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    lineImageView.centerX = frameImageView.centerX;
    lineImageView.top = frameImageView.top;
    lineImageView.hidden = YES;
    [self.view addSubview:lineImageView];
}

- (void)addAnimation
{
    lineImageView.hidden = NO;
    CABasicAnimation *animation = [self moveYTime:2 fromY:@5 toY:@(GizScreenWidth-100.0-5.0)];
    [lineImageView.layer addAnimation:animation forKey:@"LineAnimation"];
}

- (CABasicAnimation *)moveYTime:(CGFloat)time fromY:(NSNumber *)fromY toY:(NSNumber *)toY
{
    CABasicAnimation *animationMove = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    [animationMove setFromValue:fromY];
    [animationMove setToValue:toY];
    animationMove.duration = time;
    //animationMove.delegate = self;
    animationMove.repeatCount  = INFINITY;
    animationMove.fillMode = kCAFillModeForwards;
    animationMove.removedOnCompletion = NO;
    animationMove.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    return animationMove;
}

- (void)removeAnimation
{
    [lineImageView.layer removeAnimationForKey:@"LineAnimation"];
    lineImageView.hidden = YES;
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    NSString *stringValue;
    
    if ([metadataObjects count] > 0)
    {
        AVMetadataMachineReadableCodeObject *object = [metadataObjects firstObject];
        
        stringValue = object.stringValue;
        
        NSLog(@"扫描到的二维码: %@", stringValue);
    }
    
    [self dealWithQRCode:stringValue];
    
    [session stopRunning];
}

- (void)dealWithQRCode:(NSString *)qrCode
{
    if (!qrCode && qrCode.length == 0) {
        [self showQRCodeError];
        return;
    }
    
    // 绑定别人通过二维码分享的设备
    if ([qrCode.lowercaseString hasPrefix:@"type=share&code="]) {
        
        NSString *code = [qrCode componentsSeparatedByString:@"="].lastObject;
        [GizDeviceSharing setDelegate:self];
        
        [self showLoading:@"绑定设备中"];
        bindTimer = [NSTimer scheduledTimerWithTimeInterval:GizTimeoutSeconds target:self selector:@selector(bindDeviceTimeout) userInfo:nil repeats:NO];
        
        [GizDeviceSharing acceptDeviceSharingByQRCode:GizUserToken QRCode:code];
        
    } else if ([qrCode hasPrefix:@"http"]) {
        
        NSArray *strs = [qrCode componentsSeparatedByString:@"="];
        if (strs.count == 4)
        {
            // did 的方式
            NSDictionary *dict = [self getScanResult:qrCode];
            if (dict != nil) {
                NSString *did = [dict valueForKey:@"did"];
                NSString *passcode = [dict valueForKey:@"passcode"];
                NSString *productkey = [dict valueForKey:@"product_key"];
                
                //这里，要通过did，passcode，productkey获取一个设备
                if (did.length > 0 && passcode.length > 0 && productkey > 0) {
                    NSString *uid = GizUserId;
                    NSString *token = GizUserToken;
                    
                    [self showLoading:@"绑定设备中"];
                    bindTimer = [NSTimer scheduledTimerWithTimeInterval:GizTimeoutSeconds target:self selector:@selector(bindDeviceTimeout) userInfo:nil repeats:NO];
                    
                    [GizWifiSDK sharedInstance].delegate = self;
                    [[GizWifiSDK sharedInstance] bindDeviceWithUid:uid token:token did:did passCode:passcode remark:nil];
                } else {
                    [self showQRCodeError];
                }
            } else {
                [self showQRCodeError];
            }
            
        }
        else
        {
            NSString *mac = strs[2];
            for (GizWifiDevice *device in [GizCommon sharedInstance].boundDeviceArray)
            {
                if ([device.macAddress isEqualToString:mac])
                {
                    // 该设备已经绑定
                    [self showSuccess:@"绑定成功" complete:^{
                        [self pushToMainController];
                    }];
                    return;
                }
            }
            NSLog(@"mac = %@", mac);
            NSArray *productKeys = [GizCommon sharedInstance].productKeys;
            if (productKeys > 0)
            {
                bindTimer = [NSTimer scheduledTimerWithTimeInterval:GizTimeoutSeconds target:self selector:@selector(bindDeviceTimeout) userInfo:nil repeats:NO];
                [[GizWifiSDK sharedInstance] bindRemoteDevice:[GizCommon sharedInstance].uid token:[GizCommon sharedInstance].token mac:mac productKey:productKeys[0] productSecret:[GizCommon sharedInstance].productSecret];
                [GizWifiSDK sharedInstance].delegate = self;
            }

        }
        
        
    } else {
        
        [self showLoading:@"绑定设备中"];
        bindTimer = [NSTimer scheduledTimerWithTimeInterval:GizTimeoutSeconds target:self selector:@selector(bindDeviceTimeout) userInfo:nil repeats:NO];
        [GizWifiSDK sharedInstance].delegate = self;
        [[GizWifiSDK sharedInstance] bindDeviceByQRCode:GizUserId token:GizUserToken QRContent:qrCode];
    }
}

- (NSDictionary *)getScanResult:(NSString *)result
{
    NSArray *arr1 = [result componentsSeparatedByString:@"?"];
    if(arr1.count != 2)
        return nil;
    NSMutableDictionary *mdict = [NSMutableDictionary dictionary];
    NSArray *arr2 = [arr1[1] componentsSeparatedByString:@"&"];
    for(NSString *str in arr2)
    {
        NSArray *keyValue = [str componentsSeparatedByString:@"="];
        if(keyValue.count != 2)
            continue;
        
        NSString *key = keyValue[0];
        NSString *value = keyValue[1];
        [mdict setValue:value forKeyPath:key];
    }
    return mdict;
}

- (void)showQRCodeError
{
    @weakify(self);
    [self alertWithTitle:@"提示" message:@"二维码不正确" cancel:nil confirm:@"确定" confirmBlock:^{
        @strongify(self);
        [self->session startRunning];
    }];
}

- (void)startDiscoverDevice
{
    NSLog(@"开始搜索设备...");
    
    isDiscovering = YES;
    
    [GizWifiSDK sharedInstance].delegate = self;
    discoverTimer = [NSTimer scheduledTimerWithTimeInterval:GizTimeoutSeconds target:self selector:@selector(discoverTimeout) userInfo:nil repeats:NO];
    [[GizWifiSDK sharedInstance] getBoundDevices:GizUserId token:GizUserToken specialProductKeys:GizProductKeys];
}

/// 绑定超时
- (void)bindDeviceTimeout
{
    bindTimer = nil;
    
    [self hideLoading];
    
    [self bindDeviceFail:nil];
}
/// 搜索超时
- (void)discoverTimeout
{
    discoverTimer = nil;
    
    [self hideLoading];
    
    [self bindDeviceFail:@"没有找到设备"];
}

- (void)subscribeTimeour
{
    subscribeTimer = nil;
    
    [self hideLoading];
    
    [self pushToMainController];
}

- (void)bindDeviceFail:(NSString *)message
{
    @weakify(self);
    [self alertWithTitle:@"绑定失败" message:message cancel:nil confirm:@"确定" confirmBlock:^{
        @strongify(self);
//        [GizWifiSDK sharedInstance].delegate = nil;
        [self->session startRunning];
    }];
}

- (void)pushToMainController
{
//    [GizWifiSDK sharedInstance].delegate = nil;
    
    // 跳转到主控
    // navi ➔ login ➔ configGuide ➔ (addDevice ➔ ) scanQRCode
    // navi ➔ login ➔ configGuide ➔ main ➔ addDevice ➔ scanQRCode
    for (UIViewController *viewController in self.navigationController.viewControllers)
    {
        if ([viewController isKindOfClass:[GizMainViewController class]])
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:GizDidBindDeviceNotification object:nil];
            [self.navigationController popToViewController:viewController animated:YES];
            return;
        }
    }
    
    GizMainViewController *viewController = [UIStoryboard mi_instantiateViewControllerWithIdentifier:@"GizMainViewController" storyboard:@"Main"];
    
    NSMutableArray<__kindof UIViewController *> *viewControllers = [self.navigationController.viewControllers mutableCopy];
    [viewControllers removeObjectsInRange:NSMakeRange(2, viewControllers.count-2)];
    [viewControllers addObject:viewController];
    [self.navigationController setViewControllers:viewControllers animated:YES];
}

#pragma mark - GizWifiSDKDelegate

- (void)wifiSDK:(GizWifiSDK *)wifiSDK didBindDevice:(NSError *)result did:(NSString *)did
{
    if (bindTimer && bindTimer.isValid)
    {
        [bindTimer invalidate];
        bindTimer = nil;
        
        if (result.code == GIZ_SDK_SUCCESS)
        {
            NSLog(@"绑定设备成功，开始搜索设备...");
            self.currentDid = did;
            [self startDiscoverDevice];
//            [self showSuccess:@"绑定成功" complete:^{
//                [self pushToMainController];
//            }];
        }
        else
        {
            NSLog(@"绑定设备失败... %@", result);
            
            [self hideLoading];
            
            NSString *errorMessage = [[GizCommon sharedInstance] errorMsgForCode:result.code];
            [self bindDeviceFail:errorMessage];
        }
    }
}

- (void)wifiSDK:(GizWifiSDK *)wifiSDK didDiscovered:(NSError *)result deviceList:(NSArray *)deviceList
{
    if (!isDiscovering)
    {
        NSLog(@"没有开启设备搜索，忽略设备列表回调... %@", deviceList);
        return;
    }
    
    if (!discoverTimer) {
        NSLog(@"搜索已超时，忽略设备列表回调... %@", deviceList);
        return;
    }
    
    if (result.code == GIZ_SDK_SUCCESS)
    {
        NSLog(@"搜索设备回调... %@", deviceList);
        for (GizWifiDevice *device in deviceList)
        {
            if (device.isBind) {
                
                if (isDiscoveringSharedDevice && ![[GizCommon sharedInstance].boundDeviceArray containsObject:device]) {
                    
                    isDiscoveringSharedDevice = NO;
                    NSLog(@"找到设备，开始订阅设备...");
                    [discoverTimer invalidate];
                    discoverTimer = nil;
                    isDiscovering = NO;
                    
                    [[GizCommon sharedInstance].boundDeviceArray addObject:device];
                    
                    subscribeTimer = [NSTimer scheduledTimerWithTimeInterval:GizTimeoutSeconds target:self selector:@selector(subscribeTimeour) userInfo:nil repeats:NO];
                    
                    device.delegate = self;
                    [device setSubscribe:GizProductSecret subscribed:YES];
                    return;
                }
                
                if ([device.did isEqualToString:self.currentDid]) {
                    NSLog(@"找到设备，开始订阅设备...");
                    [discoverTimer invalidate];
                    discoverTimer = nil;
                    isDiscovering = NO;
                    
                    [[GizCommon sharedInstance].boundDeviceArray addObject:device];
                    
                    subscribeTimer = [NSTimer scheduledTimerWithTimeInterval:GizTimeoutSeconds target:self selector:@selector(subscribeTimeour) userInfo:nil repeats:NO];
                    
                    device.delegate = self;
                    [device setSubscribe:GizProductSecret subscribed:YES];
                    return;
                }
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
    
    [self hideLoading];
    
    if (result.code == GIZ_SDK_SUCCESS)
    {
        NSLog(@"设备订阅成功...");
    }
    else
    {
        NSLog(@"设备订阅失败... %@", result);
    }
    
    [self showSuccess:@"绑定成功" complete:^{
        [self pushToMainController];
    }];
}

#pragma mark - GizDeviceSharingDelegate

- (void)didAcceptDeviceSharingByQRCode:(NSError *)result {
    
    [bindTimer invalidate];
    bindTimer = nil;
    
    [self hideLoading];
    
    if (result.code == GIZ_SDK_SUCCESS)
    {
        NSLog(@"绑定设备成功...");
        
        isDiscoveringSharedDevice = YES;
        [self startDiscoverDevice];
    }
    else
    {
        NSLog(@"绑定设备失败... %@", result);
        
        NSString *errorMessage = [[GizCommon sharedInstance] errorMsgForCode:result.code];
        [self bindDeviceFail:errorMessage];
    }
}


@end
