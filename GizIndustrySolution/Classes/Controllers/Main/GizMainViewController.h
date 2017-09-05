//
//  GizMainViewController.h
//  GizIndustrySolution
//
//  Created by Minus🍀 on 16/9/9.
//  Copyright © 2016年 Gizwits. All rights reserved.
//

#import "GizBaseViewController.h"


@interface GizMainViewController : GizBaseViewController

- (void)selectedDevice:(GizWifiDevice*)device;

@end


@interface GizJSMethodHandler : NSObject

@property (nonatomic, weak) GizMainViewController *mainViewController;

- (instancetype)initWithMainController:(GizMainViewController *)mainController;


@end
