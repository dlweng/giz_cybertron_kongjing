//
//  GizWifiDevice+DeviceName.m
//  GizIndustrySolution
//
//  Created by Minus🍀 on 2016/9/27.
//  Copyright © 2016年 Gizwits. All rights reserved.
//

#import <objc/runtime.h>

#import "GizWifiDevice+DeviceName.h"

static const void *GizWifiDeviceCustomSavedStatus = &GizWifiDeviceCustomSavedStatus;

@implementation GizWifiDevice (DeviceName)

- (NSString *)customName
{
    return [self.alias length] > 0 ? self.alias : self.productName;
}

- (NSDictionary *)savedStatus
{
    return objc_getAssociatedObject(self, GizWifiDeviceCustomSavedStatus);
}

- (void)setSavedStatus:(NSDictionary *)savedStatus
{
    objc_setAssociatedObject(self, GizWifiDeviceCustomSavedStatus, savedStatus, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
