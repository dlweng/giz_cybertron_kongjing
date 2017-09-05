//
//  GizBaseViewController.h
//  GizIndustrySolution
//
//  Created by Minus🍀 on 16/9/13.
//  Copyright © 2016年 Gizwits. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GizAppGlobal.h"

@class GizButton;

@interface GizBaseViewController : UIViewController

- (void)initializeUI;
- (void)setupAppearanceForButton:(GizButton *)button;

// 导航栏 返回按钮
- (void)setupBackBarButtonItem;
- (void)actionBackBarButtonClicked:(id)sender;

// HUD
- (void)showLoading:(NSString *)text;
- (void)hideLoading;
- (void)showSuccess:(NSString *)text;
- (void)showSuccess:(NSString *)text complete:(void (^)())completeBlock;

// Alert
- (void)alertWithTitle:(NSString *)title message:(NSString *)message confirm:(NSString *)confirm;
- (void)alertWithTitle:(NSString *)title message:(NSString *)message cancel:(NSString *)cancel confirm:(NSString *)confirm confirmBlock:(void (^)())confirmBlock;
- (void)alertWithTitle:(NSString *)title errorCode:(GizWifiErrorCode)errorCode confirm:(NSString *)confirm;
- (void)alertWithTitle:(NSString *)title errorCode:(GizWifiErrorCode)errorCode cancel:(NSString *)cancel confirm:(NSString *)confirm confirmBlock:(void (^)())confirmBlock;

@end
