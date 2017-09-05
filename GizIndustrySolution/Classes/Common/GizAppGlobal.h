//
//  GizAppGlobal.h
//  GizIndustrySolution
//
//  Created by Minus🍀 on 16/9/8.
//  Copyright © 2016年 Gizwits. All rights reserved.
//

#ifndef GizAppGlobal_h
#define GizAppGlobal_h

#import "MIExtensions.h"
#import "UIView+MIExtensions.h"
#import "UIImage+PureColor.h"
#import "GizWifiDevice+DeviceName.h"

#import "GizButton.h"

#import "AppDelegate.h"
#import "GizCommon.h"
#import "RACEXTScope.h"

#define GizScreenWidth [UIScreen mainScreen].bounds.size.width
#define GizScreenHeight [UIScreen mainScreen].bounds.size.height

#define JBWeakSelf(type)   __weak typeof(type) weak##type = type;

static NSString * const GizUserDidLogoutNotification = @"userDidLogout";
static NSString * const GizUserInfoDidChangeNotification = @"userInfoDidChange";
static NSString * const GizDeviceNameDidChangeNotification = @"deviceNameDidChange";
static NSString * const GizLocationDidSelectNotification = @"locationDidSelect";
static NSString * const GizDidBindDeviceNotification = @"didBindDevice";
static NSString * const GizDidUnbindDeviceNotification = @"didUnbindDevice";

#endif /* GizAppGlobal_h */
