//
//  GizCommon.h
//  GizIndustrySolution
//
//  Created by Minus🍀 on 16/9/8.
//  Copyright © 2016年 Gizwits. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <GizWifiSDK/GizWifiDefinitions.h>

// User
#define GizUserId       [GizCommon sharedInstance].uid
#define GizUserToken    [GizCommon sharedInstance].token

// UI
#define GizVCBackgroundColor [GizCommon sharedInstance].vcBackgroundColor
#define GizVCBackgroundImage [GizCommon sharedInstance].vcBackgroundImage
#define GizBaseTextColor     [GizCommon sharedInstance].baseTextColor
#define GizBaseHintColor     [GizCommon sharedInstance].baseHintColor
#define GizBaseIconColor     [GizCommon sharedInstance].iconColor

#define GizNavigationBarBgColor    [GizCommon sharedInstance].navigationBarBgColor
#define GizNavigationBarBgImage    [GizCommon sharedInstance].navigationBarBgImage
#define GizNavigationBarTitleColor [GizCommon sharedInstance].navigationBarTitleColor
#define GizNavigationBarTintColor  [GizCommon sharedInstance].navigationBarTintColor

#define GizLoginBackgroundImage       [GizCommon sharedInstance].loginBackgroundImage
#define GizLoginLogoImage             [GizCommon sharedInstance].loginLogoImage
#define GizLoginTextColor             [GizCommon sharedInstance].loginTextColor
#define GizLoginHintColor             [GizCommon sharedInstance].loginHintColor
#define GizLoginBtnBgColor            [GizCommon sharedInstance].loginBtnBgColor
#define GizLoginBtnHighlightBgColor   [GizCommon sharedInstance].loginBtnHighlightBgColor
#define GizLoginBtnBorderColor        [GizCommon sharedInstance].loginBtnBorderColor
#define GizLoginBtnBgImage            [GizCommon sharedInstance].loginBtnBgImage
#define GizLoginBtnHighlightBgImage   [GizCommon sharedInstance].loginBtnHighlightBgImage
#define GizLoginBtnTextColor          [GizCommon sharedInstance].loginBtnTextColor
#define GizLoginBtnHighlightTextColor [GizCommon sharedInstance].loginBtnHighlightTextColor
#define GizLoginIconColor             [GizCommon sharedInstance].loginIconColor

#define GizButtonBgColor            [GizCommon sharedInstance].buttonBgColor
#define GizButtonHighlightBgColor   [GizCommon sharedInstance].buttonHighlightBgColor
#define GizButtonBgImage            [GizCommon sharedInstance].buttonBgImage
#define GizButtonHighlightBgImage   [GizCommon sharedInstance].buttonHighlightBgImage
#define GizButtonBorderColor        [GizCommon sharedInstance].buttonBorderColor
#define GizButtonBackgroundImage    [GizCommon sharedInstance].buttonBackgroundImage
#define GizButtonTextColor          [GizCommon sharedInstance].buttonTextColor
#define GizButtonHighlightTextColor [GizCommon sharedInstance].buttonHighlightTextColor

// APP
#define GizAppId          [GizCommon sharedInstance].appId
#define GizAppSecret      [GizCommon sharedInstance].appSecret
#define GizProductName    [GizCommon sharedInstance].productName
#define GizProductKeys    [GizCommon sharedInstance].productKeys
#define GizProductSecret  [GizCommon sharedInstance].productSecret
#define GizTimeoutSeconds [GizCommon sharedInstance].timeoutSeconds

NS_ASSUME_NONNULL_BEGIN

@class GizWifiDevice, GizUserInfo;

@interface GizCommon : NSObject

// 用户
@property (nullable, nonatomic, strong) NSString *uid;
@property (nullable, nonatomic, strong) NSString *token;
@property (nullable, nonatomic, strong) GizUserInfo *userInfo;

@property (nullable, nonatomic, strong) NSMutableArray<GizWifiDevice *> *boundDeviceArray;

// UI (注意: 背景图的优先级大于背景色)
@property (nullable, nonatomic, strong) UIColor *vcBackgroundColor;   // 视图控制器 背景色
@property (nullable, nonatomic, strong) UIImage *vcBackgroundImage;   // 视图控制器 背景图片
@property (nonatomic, strong) UIColor *baseTextColor;
@property (nonatomic, strong) UIColor *baseHintColor;

@property (nullable, nonatomic, strong) UIColor *navigationBarBgColor;        // 导航栏 背景色
@property (nullable, nonatomic, strong) UIImage *navigationBarBgImage;        // 导航栏 背景图片
@property (nonatomic, strong) UIColor *navigationBarTitleColor;     // 导航栏 标题颜色
@property (nonatomic, strong) UIColor *navigationBarTintColor;      // 导航栏 控件色调

@property (nullable, nonatomic, strong) UIImage *loginBackgroundImage;        // 登录界面 背景图片
@property (nullable, nonatomic, strong) UIImage *loginLogoImage;
@property (nullable, nonatomic, strong) UIColor *loginTextColor;
@property (nullable, nonatomic, strong) UIColor *loginHintColor;
@property (nullable, nonatomic, strong) UIColor *loginBtnBgColor;
@property (nullable, nonatomic, strong) UIColor *loginBtnHighlightBgColor;
@property (nullable, nonatomic, strong) UIColor *loginBtnBorderColor;
@property (nullable, nonatomic, strong) UIImage *loginBtnBgImage;           // 图片根据背景色 loginBtnBgColor 用代码生成
@property (nullable, nonatomic, strong) UIImage *loginBtnHighlightBgImage;  // 图片根据背景色 loginBtnHighlightBgColor 用代码生成
@property (nullable, nonatomic, strong) UIColor *loginBtnTextColor;
@property (nullable, nonatomic, strong) UIColor *loginBtnHighlightTextColor;
@property (nullable, nonatomic, strong) UIColor *loginIconColor;

@property (nullable, nonatomic, strong) UIColor *buttonBgColor;             // 按钮 背景色
@property (nullable, nonatomic, strong) UIColor *buttonHighlightBgColor;       // 按钮 背景色
@property (nullable, nonatomic, strong) UIImage *buttonBgImage;             // 按钮 背景图片
@property (nullable, nonatomic, strong) UIImage *buttonHighlightBgImage;       // 按钮 高亮背景图片
@property (nullable, nonatomic, strong) UIImage *buttonBackgroundImage;       // 按钮 背景图片
@property (nullable, nonatomic, strong) UIColor *buttonBorderColor;           // 按钮 边框色
@property (nullable, nonatomic, strong) UIColor *buttonTextColor;
@property (nullable, nonatomic, strong) UIColor *buttonHighlightTextColor;

@property (nullable, nonatomic, strong) UIColor *iconColor;

@property (nullable, nonatomic, strong) NSArray<NSString *> *guideImageNames;

@property (nullable, nonatomic, strong) UIImage *addDeviceImage;
@property (nullable, nonatomic, strong) UIImage *touchDeviceImage;
@property (nullable, nonatomic, strong) UIImage *deviceImage;

// APP
@property (nonatomic, strong) NSString *appId;
@property (nonatomic, strong) NSString *appSecret;
@property (nonatomic, strong) NSString *productName;                        // 产品名
@property (nonatomic, strong) NSString *productSecret;                      // 产品名
@property (nullable, nonatomic, strong) NSArray<NSString *> *productKeys;   // product keys
@property (nonatomic, assign) CGFloat timeoutSeconds;     // 登录、注册、重置密码等操作的超时时间

- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)sharedInstance;

// 归档方法
+ (void)archiveUserAccount:(NSString *)account password:(nullable NSString *)password;
+ (void)clearUserPassword;
+ (void)resetUserPassword:(nullable NSString *)password;
+ (void)removeUserAccount;
+ (nullable NSString *)getArchiveAccount;
+ (nullable NSString *)getArchivePassword;
+ (void)archiveSSID:(NSString *)ssid password:(nullable NSString *)password;
+ (nullable NSString *)passwordForSSID:(NSString *)ssid;
+ (BOOL)shouldAutoLogin;

// 使用与 UI 相关的属性之前，如果不先调用这个方法，那么这些属性都用 default 值
+ (NSString *)loadPropertiesContent;
- (void)loadConfiguration;

- (void)configureNavigationBarAttributes;

- (nullable NSString *)errorMsgForCode:(GizWifiErrorCode)errorCode;

@end

NS_ASSUME_NONNULL_END

extern NSString * _Nonnull getCurrentSSID();
extern BOOL isPhoneNumber(NSString * _Nullable phone);
