//
//  AppDelegate.h
//  GizIndustrySolution
//
//  Created by Minus🍀 on 16/9/1.
//  Copyright © 2016年 Gizwits. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) Reachability *networkReachability;

+ (BOOL)isNetworkReachable;

@end

