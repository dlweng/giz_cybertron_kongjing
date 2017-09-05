//
//  GizCommon.m
//  GizIndustrySolution
//
//  Created by Minus🍀 on 16/9/8.
//  Copyright © 2016年 Gizwits. All rights reserved.
//

#import "GizCommon.h"
#import "GizAppGlobal.h"

#import <CommonCrypto/CommonCrypto.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import <GizWifiSDK/GizWifiSDK.h>

static NSString *ssidCacheKey = @"ssidKeyValuePairs";
static NSString *accountCacheKey = @"accountKey";
static NSString *passwordCacheKey = @"passwordKey";

static NSData *AES256EncryptWithKey(NSString *key, NSData *data);
static NSData *AES256DecryptWithKey(NSString *key, NSData *data);
static NSString *makeEncryptKey(Class class, NSString *ssid);


@interface GizCommon ()

@property (nonatomic, strong) NSDictionary *errorMsgDict;

@end

@implementation GizCommon

+ (instancetype)sharedInstance
{
    static GizCommon *common = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        common = [[GizCommon alloc] __init];
    });
    
    return common;
}

- (instancetype)__init
{
    self = [super init];
    
    if (self)
    {
        self.uid = nil;
        self.token = nil;
        
        self.vcBackgroundColor = [UIColor mi_colorWithHex:0x7ccaec];
        self.vcBackgroundImage = nil;
        self.baseTextColor = [UIColor whiteColor];
        
        self.navigationBarBgColor = nil;
        self.navigationBarBgImage = nil;
        self.navigationBarTitleColor = [UIColor whiteColor];
        self.navigationBarTintColor = [UIColor whiteColor];
        
        self.loginBackgroundImage = nil;
        self.loginTextColor = [UIColor whiteColor];
        self.loginHintColor = [UIColor mi_colorWithHexString:@"B2FFFFFF"];
        self.loginBtnBgColor = [UIColor mi_colorWithHexString:@"00FFFFFF"];
        self.loginBtnHighlightBgColor = [UIColor mi_colorWithHexString:@"FF78C9ED"];
        self.loginBtnTextColor = [UIColor whiteColor];
        self.loginBtnHighlightTextColor = [UIColor whiteColor];
        self.loginIconColor = [UIColor whiteColor];
        
        self.buttonBackgroundImage = nil;
        self.buttonBorderColor = [UIColor whiteColor];
        self.buttonBgColor = [UIColor mi_colorWithHexString:@"00FFFFFF"];
        self.buttonHighlightBgColor = [UIColor mi_colorWithHexString:@"FF78C9ED"];
        self.buttonTextColor = [UIColor whiteColor];
        self.buttonHighlightTextColor = [UIColor whiteColor];
        
        self.appId = @"";
        self.appSecret = @"";
        self.productName = @"机智云空气管家";
        self.productKeys = nil;
        self.timeoutSeconds = 15.0;
    }
    
    return self;
}

#pragma mark - Getters

- (NSMutableArray<GizWifiDevice *> *)boundDeviceArray
{
    if (!_boundDeviceArray)
    {
        _boundDeviceArray = [NSMutableArray array];
    }
    
    return _boundDeviceArray;
}

- (NSDictionary *)errorMsgDict
{
    if (!_errorMsgDict)
    {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"errorMsg" ofType:@"plist"];
        
        if (path)
        {
            _errorMsgDict = [[NSDictionary alloc] initWithContentsOfFile:path];
        }
        else
        {
            _errorMsgDict = [NSDictionary new];
        }
    }
    
    return _errorMsgDict;
}

#pragma mark - Archive method

+ (void)archiveUserAccount:(NSString *)account password:(NSString *)password
{
    [[NSUserDefaults standardUserDefaults] setObject:account forKey:accountCacheKey];
    [[NSUserDefaults standardUserDefaults] setObject:(password?:@"") forKey:passwordCacheKey];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)clearUserPassword
{
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:passwordCacheKey];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)resetUserPassword:(NSString *)password
{
    [[NSUserDefaults standardUserDefaults] setObject:(password?:@"") forKey:passwordCacheKey];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)removeUserAccount
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:accountCacheKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:passwordCacheKey];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)getArchiveAccount
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:accountCacheKey];
}

+ (NSString *)getArchivePassword
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:passwordCacheKey];
}

/// 本地存储 Wi-Fi ssid & 密码 对
+ (void)archiveSSID:(NSString *)ssid password:(NSString *)password
{
    NSAssert([ssid length] > 0, @"SSID 不能为空.");
    
    if ([password length] > 0)
    {
        NSDictionary *ssidCache = [[NSUserDefaults standardUserDefaults] objectForKey:ssidCacheKey];
        
        NSMutableDictionary *mSSIDCache;
        
        if (ssidCache)
        {
            mSSIDCache = [ssidCache mutableCopy];
        }
        else
        {
            mSSIDCache = [NSMutableDictionary new];
        }
        
        NSString *encryptKey = makeEncryptKey([self class], ssid);
        NSData *encryptData = AES256EncryptWithKey(encryptKey, [password dataUsingEncoding:NSUTF8StringEncoding]);
        
        [mSSIDCache setObject:encryptData forKey:ssid];
        
        [[NSUserDefaults standardUserDefaults] setObject:mSSIDCache forKey:ssidCacheKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

/// 根据 Wi-Fi ssid 获取相应的密码
+ (NSString *)passwordForSSID:(NSString *)ssid
{
    NSDictionary *ssidCache = [[NSUserDefaults standardUserDefaults] objectForKey:ssidCacheKey];
    
    NSData *encryptData = [ssidCache objectForKey:ssid];
    
    if (encryptData)
    {
        NSString *encryptKey = makeEncryptKey([self class], ssid);
        NSData *decryptData = AES256DecryptWithKey(encryptKey, encryptData);
        
        NSString *password = [[NSString alloc] initWithData:decryptData encoding:NSUTF8StringEncoding];
        
        return password;
    }
    
    return @"";
}

+ (BOOL)shouldAutoLogin
{
    NSString *password = [[NSUserDefaults standardUserDefaults] objectForKey:passwordCacheKey];
    
    return ([password length] > 0);
}

#pragma mark - Instance method

+ (NSString *)loadPropertiesContent {
    
    // 加载配置文件，背景图片、背景颜色、文本颜色等
    NSString *path = [[NSBundle mainBundle] pathForResource:@"UIProperties" ofType:@"json"];
    
    if (!path || path.length <= 0)
    {
        NSLog(@"配置文件不存在...");
        return nil;
    }
    
    NSError *error;
    
    NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    
    if (error)
    {
        NSLog(@"配置文件加载失败... %@", error);
        return nil;
    }
    
    return content;
}

- (void)loadConfiguration
{
    // 加载配置文件，背景图片、背景颜色、文本颜色等
    NSString *content = [GizCommon loadPropertiesContent];
    
    if (!content || content.length == 0)
    {
        return;
    }
    
    NSError *error;
    
    NSData *jsonData = [content dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *properties = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
    
    if (error)
    {
        NSLog(@"配置文件内容解析出错... %@", error);
        return;
    }
    
    self.appId = properties[@"app_id"];
    self.appSecret = properties[@"app_secret"];
    
    self.productSecret = properties[@"product_secret"];
    
    NSString *productKey = properties[@"product_key"];
    if ([productKey length] > 0)
    {
        self.productKeys = @[productKey];
    }
    else
    {
        self.productKeys = nil;
    }
    
    self.productName = properties[@"device_name"];
    
    // 图片
    NSDictionary *imagesDict = properties[@"image"];
    // 引导页 图片
    self.guideImageNames = imagesDict[@"guide"];
    // 登录界面
    self.loginLogoImage = [UIImage imageNamed:imagesDict[@"login_logo"]];
    self.loginBackgroundImage = [UIImage imageNamed:imagesDict[@"login_background"]];
    
    self.addDeviceImage = [UIImage imageNamed:imagesDict[@"add_device"]];
    self.touchDeviceImage = [UIImage imageNamed:imagesDict[@"touch_device"]];
    self.deviceImage = [UIImage imageNamed:imagesDict[@"device"]];
    
    // 颜色
    NSDictionary *colorsDict = properties[@"color"];
    // 登录界面
    self.loginTextColor = [UIColor mi_colorWithHexString:colorsDict[@"login_text"]];
    self.loginHintColor = [UIColor mi_colorWithHexString:colorsDict[@"login_hint"]];
    self.loginBtnBgColor = [UIColor mi_colorWithHexString:colorsDict[@"login_button_background"]];
    self.loginBtnHighlightBgColor = [UIColor mi_colorWithHexString:colorsDict[@"login_button_background_selected"]];
    self.loginBtnBorderColor = [UIColor mi_colorWithHexString:colorsDict[@"login_button_background_frame"]];
    self.loginBtnBgImage = [UIImage imageWithColor:self.loginBtnBgColor];
    self.loginBtnHighlightBgImage = [UIImage imageWithColor:self.loginBtnHighlightBgColor];
    self.loginBtnTextColor = [UIColor mi_colorWithHexString:colorsDict[@"login_button_text"]];
    self.loginBtnHighlightTextColor = [UIColor mi_colorWithHexString:colorsDict[@"login_button_text_selected"]];
    self.loginIconColor = [UIColor mi_colorWithHexString:colorsDict[@"login_icon"]];
    
    // 按钮
    self.buttonBgColor = [UIColor mi_colorWithHexString:colorsDict[@"button_background"]];
    self.buttonHighlightBgColor = [UIColor mi_colorWithHexString:colorsDict[@"button_background_selected"]];
    self.buttonBorderColor = [UIColor mi_colorWithHexString:colorsDict[@"button_background_frame"]];
    self.buttonBgImage = [UIImage imageWithColor:self.buttonBgColor];
    self.buttonHighlightBgImage = [UIImage imageWithColor:self.buttonHighlightBgColor];
    self.buttonTextColor = [UIColor mi_colorWithHexString:colorsDict[@"button_text"]];
    self.buttonHighlightTextColor = [UIColor mi_colorWithHexString:colorsDict[@"button_text_selected"]];
    
    // 其他
    self.baseTextColor = [UIColor mi_colorWithHexString:colorsDict[@"text"]];
    self.baseHintColor = [UIColor mi_colorWithHexString:colorsDict[@"hint"]];
    self.vcBackgroundColor = [UIColor mi_colorWithHexString:colorsDict[@"background"]];
    self.iconColor = [UIColor mi_colorWithHexString:colorsDict[@"icon"]];
    // 导航栏
    self.navigationBarTitleColor = [UIColor mi_colorWithHexString:colorsDict[@"navigationbar_text"]];
    self.navigationBarTintColor = [UIColor mi_colorWithHexString:colorsDict[@"navigationbar_icon"]];
    
//    if ([colorsDict[@"background"] isEqualToString:colorsDict[@"navigationbar_background"]]) {
//        self.navigationBarBgColor = nil;
//    } else {
        self.navigationBarBgColor = [UIColor mi_colorWithHexString:colorsDict[@"navigationbar_background"]];
//    }
}

- (void)configureNavigationBarAttributes
{
    UINavigationBar *bar = [UINavigationBar appearance];
    
    [bar setTitleTextAttributes:@{NSForegroundColorAttributeName: self.navigationBarTitleColor}];
    [bar setTintColor:self.navigationBarTintColor];
    
    CGFloat white = 0.0, alpha = 0.0;
    
    [self.navigationBarBgColor getWhite:&white alpha:&alpha];
    
    if (self.navigationBarBgColor && alpha != 0)
    {
        [bar setBarTintColor:self.navigationBarBgColor];
    }
    else if (self.navigationBarBgImage)
    {
        [bar setBackgroundImage:self.navigationBarBgImage forBarMetrics:UIBarMetricsDefault];
    }
    else
    {
        [bar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        [bar setShadowImage:[UIImage new]];
    }
}

- (NSString *)errorMsgForCode:(GizWifiErrorCode)errorCode
{
    NSString *key;
    
    switch (errorCode)
    {
        case GIZ_SDK_PARAM_FORM_INVALID:
            key = @"GIZ_SDK_PARAM_FORM_INVALID";
            break;
        case GIZ_SDK_CLIENT_NOT_AUTHEN:
            key = @"GIZ_SDK_CLIENT_NOT_AUTHEN";
            break;
        case GIZ_SDK_CLIENT_VERSION_INVALID:
            key = @"GIZ_SDK_CLIENT_VERSION_INVALID";
            break;
        case GIZ_SDK_UDP_PORT_BIND_FAILED:
            key = @"GIZ_SDK_UDP_PORT_BIND_FAILED";
            break;
        case GIZ_SDK_DAEMON_EXCEPTION:
            key = @"GIZ_SDK_DAEMON_EXCEPTION";
            break;
        case GIZ_SDK_PARAM_INVALID:
            key = @"GIZ_SDK_PARAM_INVALID";
            break;
        case GIZ_SDK_APPID_LENGTH_ERROR:
            key = @"GIZ_SDK_APPID_LENGTH_ERROR";
            break;
        case GIZ_SDK_LOG_PATH_INVALID:
            key = @"GIZ_SDK_LOG_PATH_INVALID";
            break;
        case GIZ_SDK_LOG_LEVEL_INVALID:
            key = @"GIZ_SDK_LOG_LEVEL_INVALID";
            break;
        case GIZ_SDK_DEVICE_CONFIG_SEND_FAILED:
            key = @"GIZ_SDK_DEVICE_CONFIG_SEND_FAILED";
            break;
        case GIZ_SDK_DEVICE_CONFIG_IS_RUNNING:
            key = @"GIZ_SDK_DEVICE_CONFIG_IS_RUNNING";
            break;
        case GIZ_SDK_DEVICE_CONFIG_TIMEOUT:
            key = @"GIZ_SDK_DEVICE_CONFIG_TIMEOUT";
            break;
        case GIZ_SDK_DEVICE_DID_INVALID:
            key = @"GIZ_SDK_DEVICE_DID_INVALID";
            break;
        case GIZ_SDK_DEVICE_MAC_INVALID:
            key = @"GIZ_SDK_DEVICE_MAC_INVALID";
            break;
        case GIZ_SDK_SUBDEVICE_DID_INVALID:
            key = @"GIZ_SDK_SUBDEVICE_DID_INVALID";
            break;
        case GIZ_SDK_DEVICE_PASSCODE_INVALID:
            key = @"GIZ_SDK_DEVICE_PASSCODE_INVALID";
            break;
        case GIZ_SDK_DEVICE_NOT_SUBSCRIBED:
            key = @"GIZ_SDK_DEVICE_NOT_SUBSCRIBED";
            break;
        case GIZ_SDK_DEVICE_NO_RESPONSE:
            key = @"GIZ_SDK_DEVICE_NO_RESPONSE";
            break;
        case GIZ_SDK_DEVICE_NOT_READY:
            key = @"GIZ_SDK_DEVICE_NOT_READY";
            break;
        case GIZ_SDK_DEVICE_NOT_BINDED:
            key = @"GIZ_SDK_DEVICE_NOT_BINDED";
            break;
        case GIZ_SDK_DEVICE_CONTROL_WITH_INVALID_COMMAND:
            key = @"GIZ_SDK_DEVICE_CONTROL_WITH_INVALID_COMMAND";
            break;
        case GIZ_SDK_DEVICE_CONTROL_FAILED:
            key = @"GIZ_SDK_DEVICE_CONTROL_FAILED";
            break;
        case GIZ_SDK_DEVICE_GET_STATUS_FAILED:
            key = @"GIZ_SDK_DEVICE_GET_STATUS_FAILED";
            break;
        case GIZ_SDK_DEVICE_CONTROL_VALUE_TYPE_ERROR:
            key = @"GIZ_SDK_DEVICE_CONTROL_VALUE_TYPE_ERROR";
            break;
        case GIZ_SDK_DEVICE_CONTROL_VALUE_OUT_OF_RANGE:
            key = @"GIZ_SDK_DEVICE_CONTROL_VALUE_OUT_OF_RANGE";
            break;
        case GIZ_SDK_DEVICE_CONTROL_NOT_WRITABLE_COMMAND:
            key = @"GIZ_SDK_DEVICE_CONTROL_NOT_WRITABLE_COMMAND";
            break;
        case GIZ_SDK_BIND_DEVICE_FAILED:
            key = @"GIZ_SDK_BIND_DEVICE_FAILED";
            break;
        case GIZ_SDK_UNBIND_DEVICE_FAILED:
            key = @"GIZ_SDK_UNBIND_DEVICE_FAILED";
            break;
        case GIZ_SDK_DNS_FAILED:
            key = @"GIZ_SDK_DNS_FAILED";
            break;
        case GIZ_SDK_M2M_CONNECTION_SUCCESS:
            key = @"GIZ_SDK_M2M_CONNECTION_SUCCESS";
            break;
        case GIZ_SDK_SET_SOCKET_NON_BLOCK_FAILED:
            key = @"GIZ_SDK_SET_SOCKET_NON_BLOCK_FAILED";
            break;
        case GIZ_SDK_CONNECTION_TIMEOUT:
            key = @"GIZ_SDK_CONNECTION_TIMEOUT";
            break;
        case GIZ_SDK_CONNECTION_REFUSED:
            key = @"GIZ_SDK_CONNECTION_REFUSED";
            break;
        case GIZ_SDK_CONNECTION_ERROR:
            key = @"GIZ_SDK_CONNECTION_ERROR";
            break;
        case GIZ_SDK_CONNECTION_CLOSED:
            key = @"GIZ_SDK_CONNECTION_CLOSED";
            break;
        case GIZ_SDK_SSL_HANDSHAKE_FAILED:
            key = @"GIZ_SDK_SSL_HANDSHAKE_FAILED";
            break;
        case GIZ_SDK_DEVICE_LOGIN_VERIFY_FAILED:
            key = @"GIZ_SDK_DEVICE_LOGIN_VERIFY_FAILED";
            break;
        case GIZ_SDK_INTERNET_NOT_REACHABLE:
            key = @"GIZ_SDK_INTERNET_NOT_REACHABLE";
            break;
        case GIZ_SDK_HTTP_ANSWER_FORMAT_ERROR:
            key = @"GIZ_SDK_HTTP_ANSWER_FORMAT_ERROR";
            break;
        case GIZ_SDK_HTTP_ANSWER_PARAM_ERROR:
            key = @"GIZ_SDK_HTTP_ANSWER_PARAM_ERROR";
            break;
        case GIZ_SDK_HTTP_SERVER_NO_ANSWER:
            key = @"GIZ_SDK_HTTP_SERVER_NO_ANSWER";
            break;
        case GIZ_SDK_HTTP_REQUEST_FAILED:
            key = @"GIZ_SDK_HTTP_REQUEST_FAILED";
            break;
        case GIZ_SDK_OTHERWISE:
            key = @"GIZ_SDK_OTHERWISE";
            break;
        case GIZ_SDK_MEMORY_MALLOC_FAILED:
            key = @"GIZ_SDK_MEMORY_MALLOC_FAILED";
            break;
        case GIZ_SDK_THREAD_CREATE_FAILED:
            key = @"GIZ_SDK_THREAD_CREATE_FAILED";
            break;
        case GIZ_SDK_GROUP_ID_INVALID:
            key = @"GIZ_SDK_GROUP_ID_INVALID";
            break;
        case GIZ_SDK_GROUP_PRODUCTKEY_INVALID:
            key = @"GIZ_SDK_GROUP_PRODUCTKEY_INVALID";
            break;
        case GIZ_SDK_GROUP_FAILED_DELETE_DEVICE:
            key = @"GIZ_SDK_GROUP_FAILED_DELETE_DEVICE";
            break;
        case GIZ_SDK_GROUP_FAILED_ADD_DEVICE:
            key = @"GIZ_SDK_GROUP_FAILED_ADD_DEVICE";
            break;
        case GIZ_SDK_GROUP_GET_DEVICE_FAILED:
            key = @"GIZ_SDK_GROUP_GET_DEVICE_FAILED";
            break;
        case GIZ_SDK_DATAPOINT_NOT_DOWNLOAD:
            key = @"GIZ_SDK_DATAPOINT_NOT_DOWNLOAD";
            break;
        case GIZ_SDK_DATAPOINT_SERVICE_UNAVAILABLE:
            key = @"GIZ_SDK_DATAPOINT_SERVICE_UNAVAILABLE";
            break;
        case GIZ_SDK_DATAPOINT_PARSE_FAILED:
            key = @"GIZ_SDK_DATAPOINT_PARSE_FAILED";
            break;
        case GIZ_SDK_NOT_INITIALIZED:
            key = @"GIZ_SDK_NOT_INITIALIZED";
            break;
        case GIZ_SDK_EXEC_DAEMON_FAILED:
            key = @"GIZ_SDK_EXEC_DAEMON_FAILED";
            break;
        case GIZ_SDK_EXEC_CATCH_EXCEPTION:
            key = @"GIZ_SDK_EXEC_CATCH_EXCEPTION";
            break;
        case GIZ_SDK_APPID_IS_EMPTY:
            key = @"GIZ_SDK_APPID_IS_EMPTY";
            break;
        case GIZ_SDK_UNSUPPORTED_API:
            key = @"GIZ_SDK_UNSUPPORTED_API";
            break;
        case GIZ_SDK_REQUEST_TIMEOUT:
            key = @"GIZ_SDK_REQUEST_TIMEOUT";
            break;
        case GIZ_SDK_DAEMON_VERSION_INVALID:
            key = @"GIZ_SDK_DAEMON_VERSION_INVALID";
            break;
        case GIZ_SDK_PHONE_NOT_CONNECT_TO_SOFTAP_SSID:
            key = @"GIZ_SDK_PHONE_NOT_CONNECT_TO_SOFTAP_SSID";
            break;
        case GIZ_SDK_DEVICE_CONFIG_SSID_NOT_MATCHED:
            key = @"GIZ_SDK_DEVICE_CONFIG_SSID_NOT_MATCHED";
            break;
        case GIZ_SDK_NOT_IN_SOFTAPMODE:
            key = @"GIZ_SDK_NOT_IN_SOFTAPMODE";
            break;
        case GIZ_SDK_PHONE_WIFI_IS_UNAVAILABLE:
            key = @"GIZ_SDK_PHONE_WIFI_IS_UNAVAILABLE";
            break;
        case GIZ_SDK_RAW_DATA_TRANSMIT:
            key = @"GIZ_SDK_RAW_DATA_TRANSMIT";
            break;
        case GIZ_SDK_PRODUCT_IS_DOWNLOADING:
            key = @"GIZ_SDK_PRODUCT_IS_DOWNLOADING";
            break;
        case GIZ_SDK_START_SUCCESS:
            key = @"GIZ_SDK_START_SUCCESS";
            break;
        case GIZ_SITE_PRODUCTKEY_INVALID:
            key = @"GIZ_SITE_PRODUCTKEY_INVALID";
            break;
        case GIZ_SITE_DATAPOINTS_NOT_DEFINED:
            key = @"GIZ_SITE_DATAPOINTS_NOT_DEFINED";
            break;
        case GIZ_SITE_DATAPOINTS_NOT_MALFORME:
            key = @"GIZ_SITE_DATAPOINTS_NOT_MALFORME";
            break;
        case GIZ_OPENAPI_MAC_ALREADY_REGISTERED:
            key = @"GIZ_OPENAPI_MAC_ALREADY_REGISTERED";
            break;
        case GIZ_OPENAPI_PRODUCT_KEY_INVALID:
            key = @"GIZ_OPENAPI_PRODUCT_KEY_INVALID";
            break;
        case GIZ_OPENAPI_APPID_INVALID:
            key = @"GIZ_OPENAPI_APPID_INVALID";
            break;
        case GIZ_OPENAPI_TOKEN_INVALID:
            key = @"GIZ_OPENAPI_TOKEN_INVALID";
            break;
        case GIZ_OPENAPI_USER_NOT_EXIST:
            key = @"GIZ_OPENAPI_USER_NOT_EXIST";
            break;
        case GIZ_OPENAPI_TOKEN_EXPIRED:
            key = @"GIZ_OPENAPI_TOKEN_EXPIRED";
            break;
        case GIZ_OPENAPI_M2M_ID_INVALID:
            key = @"GIZ_OPENAPI_M2M_ID_INVALID";
            break;
        case GIZ_OPENAPI_SERVER_ERROR:
            key = @"GIZ_OPENAPI_SERVER_ERROR";
            break;
        case GIZ_OPENAPI_CODE_EXPIRED:
            key = @"GIZ_OPENAPI_CODE_EXPIRED";
            break;
        case GIZ_OPENAPI_CODE_INVALID:
            key = @"GIZ_OPENAPI_CODE_INVALID";
            break;
        case GIZ_OPENAPI_SANDBOX_SCALE_QUOTA_EXHAUSTED:
            key = @"GIZ_OPENAPI_SANDBOX_SCALE_QUOTA_EXHAUSTED";
            break;
        case GIZ_OPENAPI_PRODUCTION_SCALE_QUOTA_EXHAUSTED:
            key = @"GIZ_OPENAPI_PRODUCTION_SCALE_QUOTA_EXHAUSTED";
            break;
        case GIZ_OPENAPI_PRODUCT_HAS_NO_REQUEST_SCALE:
            key = @"GIZ_OPENAPI_PRODUCT_HAS_NO_REQUEST_SCALE";
            break;
        case GIZ_OPENAPI_DEVICE_NOT_FOUND:
            key = @"GIZ_OPENAPI_DEVICE_NOT_FOUND";
            break;
        case GIZ_OPENAPI_FORM_INVALID:
            key = @"GIZ_OPENAPI_FORM_INVALID";
            break;
        case GIZ_OPENAPI_DID_PASSCODE_INVALID:
            key = @"GIZ_OPENAPI_DID_PASSCODE_INVALID";
            break;
        case GIZ_OPENAPI_DEVICE_NOT_BOUND:
            key = @"GIZ_OPENAPI_DEVICE_NOT_BOUND";
            break;
        case GIZ_OPENAPI_PHONE_UNAVALIABLE:
            key = @"GIZ_OPENAPI_PHONE_UNAVALIABLE";
            break;
        case GIZ_OPENAPI_USERNAME_UNAVALIABLE:
            key = @"GIZ_OPENAPI_USERNAME_UNAVALIABLE";
            break;
        case GIZ_OPENAPI_USERNAME_PASSWORD_ERROR:
            key = @"GIZ_OPENAPI_USERNAME_PASSWORD_ERROR";
            break;
        case GIZ_OPENAPI_SEND_COMMAND_FAILED:
            key = @"GIZ_OPENAPI_SEND_COMMAND_FAILED";
            break;
        case GIZ_OPENAPI_EMAIL_UNAVALIABLE:
            key = @"GIZ_OPENAPI_EMAIL_UNAVALIABLE";
            break;
        case GIZ_OPENAPI_DEVICE_DISABLED:
            key = @"GIZ_OPENAPI_DEVICE_DISABLED";
            break;
        case GIZ_OPENAPI_FAILED_NOTIFY_M2M:
            key = @"GIZ_OPENAPI_FAILED_NOTIFY_M2M";
            break;
        case GIZ_OPENAPI_ATTR_INVALID:
            key = @"GIZ_OPENAPI_ATTR_INVALID";
            break;
        case GIZ_OPENAPI_USER_INVALID:
            key = @"GIZ_OPENAPI_USER_INVALID";
            break;
        case GIZ_OPENAPI_FIRMWARE_NOT_FOUND:
            key = @"GIZ_OPENAPI_FIRMWARE_NOT_FOUND";
            break;
        case GIZ_OPENAPI_JD_PRODUCT_NOT_FOUND:
            key = @"GIZ_OPENAPI_JD_PRODUCT_NOT_FOUND";
            break;
        case GIZ_OPENAPI_DATAPOINT_DATA_NOT_FOUND:
            key = @"GIZ_OPENAPI_DATAPOINT_DATA_NOT_FOUND";
            break;
        case GIZ_OPENAPI_SCHEDULER_NOT_FOUND:
            key = @"GIZ_OPENAPI_SCHEDULER_NOT_FOUND";
            break;
        case GIZ_OPENAPI_QQ_OAUTH_KEY_INVALID:
            key = @"GIZ_OPENAPI_QQ_OAUTH_KEY_INVALID";
            break;
        case GIZ_OPENAPI_OTA_SERVICE_OK_BUT_IN_IDLE:
            key = @"GIZ_OPENAPI_OTA_SERVICE_OK_BUT_IN_IDLE";
            break;
        case GIZ_OPENAPI_BT_FIRMWARE_UNVERIFIED:
            key = @"GIZ_OPENAPI_BT_FIRMWARE_UNVERIFIED";
            break;
        case GIZ_OPENAPI_BT_FIRMWARE_NOTHING_TO_UPGRADE:
            key = @"GIZ_OPENAPI_BT_FIRMWARE_NOTHING_TO_UPGRADE";
            break;
        case GIZ_OPENAPI_SAVE_KAIROSDB_ERROR:
            key = @"GIZ_OPENAPI_SAVE_KAIROSDB_ERROR";
            break;
        case GIZ_OPENAPI_EVENT_NOT_DEFINED:
            key = @"GIZ_OPENAPI_EVENT_NOT_DEFINED";
            break;
        case GIZ_OPENAPI_SEND_SMS_FAILED:
            key = @"GIZ_OPENAPI_SEND_SMS_FAILED";
            break;
        case GIZ_OPENAPI_APPLICATION_AUTH_INVALID:
            key = @"GIZ_OPENAPI_APPLICATION_AUTH_INVALID";
            break;
        case GIZ_OPENAPI_NOT_ALLOWED_CALL_API:
            key = @"GIZ_OPENAPI_NOT_ALLOWED_CALL_API";
            break;
        case GIZ_OPENAPI_BAD_QRCODE_CONTENT:
            key = @"GIZ_OPENAPI_BAD_QRCODE_CONTENT";
            break;
        case GIZ_OPENAPI_REQUEST_THROTTLED:
            key = @"GIZ_OPENAPI_REQUEST_THROTTLED";
            break;
        case GIZ_OPENAPI_DEVICE_OFFLINE:
            key = @"GIZ_OPENAPI_DEVICE_OFFLINE";
            break;
        case GIZ_OPENAPI_TIMESTAMP_INVALID:
            key = @"GIZ_OPENAPI_TIMESTAMP_INVALID";
            break;
        case GIZ_OPENAPI_SIGNATURE_INVALID:
            key = @"GIZ_OPENAPI_SIGNATURE_INVALID";
            break;
        case GIZ_OPENAPI_DEPRECATED_API:
            key = @"GIZ_OPENAPI_DEPRECATED_API";
            break;
        case GIZ_OPENAPI_RESERVED:
            key = @"GIZ_OPENAPI_RESERVED";
            break;
        case GIZ_PUSHAPI_BODY_JSON_INVALID:
            key = @"GIZ_PUSHAPI_BODY_JSON_INVALID";
            break;
        case GIZ_PUSHAPI_DATA_NOT_EXIST:
            key = @"GIZ_PUSHAPI_DATA_NOT_EXIST";
            break;
        case GIZ_PUSHAPI_NO_CLIENT_CONFIG:
            key = @"GIZ_PUSHAPI_NO_CLIENT_CONFIG";
            break;
        case GIZ_PUSHAPI_NO_SERVER_DATA:
            key = @"GIZ_PUSHAPI_NO_SERVER_DATA";
            break;
        case GIZ_PUSHAPI_GIZWITS_APPID_EXIST:
            key = @"GIZ_PUSHAPI_GIZWITS_APPID_EXIST";
            break;
        case GIZ_PUSHAPI_PARAM_ERROR:
            key = @"GIZ_PUSHAPI_PARAM_ERROR";
            break;
        case GIZ_PUSHAPI_AUTH_KEY_INVALID:
            key = @"GIZ_PUSHAPI_AUTH_KEY_INVALID";
            break;
        case GIZ_PUSHAPI_APPID_OR_TOKEN_ERROR:
            key = @"GIZ_PUSHAPI_APPID_OR_TOKEN_ERROR";
            break;
        case GIZ_PUSHAPI_TYPE_PARAM_ERROR:
            key = @"GIZ_PUSHAPI_TYPE_PARAM_ERROR";
            break;
        case GIZ_PUSHAPI_ID_PARAM_ERROR:
            key = @"GIZ_PUSHAPI_ID_PARAM_ERROR";
            break;
        case GIZ_PUSHAPI_APPKEY_SECRETKEY_INVALID:
            key = @"GIZ_PUSHAPI_APPKEY_SECRETKEY_INVALID";
            break;
        case GIZ_PUSHAPI_CHANNELID_ERROR_INVALID:
            key = @"GIZ_PUSHAPI_CHANNELID_ERROR_INVALID";
            break;
        case GIZ_PUSHAPI_PUSH_ERROR:
            key = @"GIZ_PUSHAPI_PUSH_ERROR";
            break;
        case GIZ_OPENAPI_CANNOT_SHARE_TO_SELF:
            key = @"GIZ_OPENAPI_CANNOT_SHARE_TO_SELF";
            break;
        case GIZ_OPENAPI_ONLY_OWNER_CAN_SHARE:
            key = @"GIZ_OPENAPI_ONLY_OWNER_CAN_SHARE";
            break;
        case GIZ_OPENAPI_GUEST_ALREADY_BOUND:
            key = @"GIZ_OPENAPI_GUEST_ALREADY_BOUND";
            break;
        case GIZ_OPENAPI_SHARING_IS_EXPIRED:
            key = @"GIZ_OPENAPI_SHARING_IS_EXPIRED";
            break;
        default:
            key = @"UNKNOWN_ERROR";
            break;
    }
    
    return self.errorMsgDict[key];
}

@end

#pragma mark - C method implementations
#pragma mark Private

static NSData *AES256EncryptWithKey(NSString *key, NSData *data) {
    // 'key' should be 32 bytes for AES256, will be null-padded otherwise
    char keyPtr[kCCKeySizeAES256+1]; // room for terminator (unused)
    bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
    
    // fetch key data
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [data length];
    
    //See the doc: For block ciphers, the output size will always be less than or
    //equal to the input size plus the size of one block.
    //That's why we need to add the size of one block here
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                          keyPtr, kCCKeySizeAES256,
                                          NULL /* initialization vector (optional) */,
                                          [data bytes], dataLength, /* input */
                                          buffer, bufferSize, /* output */
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        //the returned NSData takes ownership of the buffer and will free it on deallocation
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    
    free(buffer); //free the buffer;
    return nil;
}

static NSData *AES256DecryptWithKey(NSString *key, NSData *data) {
    // 'key' should be 32 bytes for AES256, will be null-padded otherwise
    char keyPtr[kCCKeySizeAES256+1]; // room for terminator (unused)
    bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
    
    // fetch key data
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [data length];
    
    //See the doc: For block ciphers, the output size will always be less than or
    //equal to the input size plus the size of one block.
    //That's why we need to add the size of one block here
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                          keyPtr, kCCKeySizeAES256,
                                          NULL /* initialization vector (optional) */,
                                          [data bytes], dataLength, /* input */
                                          buffer, bufferSize, /* output */
                                          &numBytesDecrypted);
    
    if (cryptStatus == kCCSuccess) {
        //the returned NSData takes ownership of the buffer and will free it on deallocation
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }
    
    free(buffer); //free the buffer;
    return nil;
}

static NSString *makeEncryptKey(Class class, NSString *ssid) {
    NSString *tmpEncryptKey = NSStringFromClass(class);
    tmpEncryptKey = [tmpEncryptKey stringByAppendingString:@"_"];
    tmpEncryptKey = [tmpEncryptKey stringByAppendingString:ssid];
    tmpEncryptKey = [tmpEncryptKey stringByAppendingString:@"_"];
    
    unsigned char result[16] = { 0 };
    CC_MD5(tmpEncryptKey.UTF8String, (CC_LONG)tmpEncryptKey.length, result);
    NSString *ret = @"";
    
    for (int i=0; i<16; i++) {
        ret = [ret stringByAppendingFormat:@"%02X", result[i]];
    }
    
    return ret;
}

#pragma mark Public

NSString * _Nonnull getCurrentSSID() {
    NSArray *interfaces = (__bridge_transfer NSArray *)CNCopySupportedInterfaces();
    for (NSString *interface in interfaces) {
        NSDictionary *ssidInfo = (__bridge_transfer NSDictionary *)CNCopyCurrentNetworkInfo((__bridge CFStringRef)interface);
        NSString *ssid = ssidInfo[(__bridge_transfer NSString *)kCNNetworkInfoKeySSID];
        if ([ssid length] > 0) {
            return ssid;
        }
    }
    return @"";
}

BOOL isPhoneNumber(NSString * _Nullable phone) {
    if (!phone || phone.length <= 0) {
        return NO;
    }
    
    // 电信号段:133/153/180/181/189/177/173/149
    // 联通号段:130/131/132/155/156/185/186/145/176/175
    // 移动号段:134/135/136/137/138/139/150/151/152/157/158/159/182/183/184/187/188/147/178
    // 虚拟运营商:170[1700/1701/1702(电信)、1703/1705/1706(移动)、1704/1707/1708/1709(联通)]、171(联通)
    
    NSString *regularExpression = @"^1(3[0-9]|4[579]|5[0-35-9]|7[0135-8]|8[0-9])\\d{8}$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regularExpression];
    return [predicate evaluateWithObject:phone];
}
