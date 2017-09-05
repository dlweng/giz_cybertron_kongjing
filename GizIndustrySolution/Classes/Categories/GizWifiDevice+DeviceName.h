//
//  GizWifiDevice+DeviceName.h
//  GizIndustrySolution
//
//  Created by Minus🍀 on 2016/9/27.
//  Copyright © 2016年 Gizwits. All rights reserved.
//

#import <GizWifiSDK/GizWifiSDK.h>

@interface GizWifiDevice (DeviceName)

@property (nonatomic, strong, readonly) NSString *customName;

@property (nonatomic, strong) NSDictionary *savedStatus;

@end
