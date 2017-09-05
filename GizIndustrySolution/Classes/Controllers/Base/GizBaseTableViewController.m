//
//  GizBaseTableViewController.m
//  GizIndustrySolution
//
//  Created by Minus🍀 on 2016/9/25.
//  Copyright © 2016年 Gizwits. All rights reserved.
//
#import <MBProgressHUD.h>

#import "GizAppGlobal.h"

#import "GizBaseTableViewController.h"

@interface GizBaseTableViewController ()

@property (nonatomic, strong) MBProgressHUD *loadingHUD;

@end

@implementation GizBaseTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.navigationController) {
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    }
    
    [self initializeUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (void)initializeUI
{
    if (GizVCBackgroundImage)
    {
        UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        bgImageView.image = GizVCBackgroundImage;
        [self.view insertSubview:bgImageView atIndex:0];
        self.tableView.backgroundColor = [UIColor clearColor];
    }
    else
    {
        self.tableView.backgroundColor = [UIColor clearColor];
        self.view.backgroundColor = GizVCBackgroundColor;
    }
}

- (void)setupAppearanceForButton:(GizButton *)button
{
    [button setTitleColor:GizButtonTextColor forState:UIControlStateNormal];
    
    if (GizButtonHighlightTextColor)
    {
        [button setTitleColor:GizButtonHighlightTextColor forState:UIControlStateHighlighted];
    }
    
    if (GizButtonBackgroundImage)
    {
        [button setBackgroundImage:GizButtonBackgroundImage forState:UIControlStateNormal];
    }
    else
    {
        button.gizBgImage = GizButtonBgImage;
        button.gizHighlightBgImage = GizButtonHighlightBgImage;
        
        if (GizButtonBorderColor)
        {
            button.layer.borderColor = GizButtonBorderColor.CGColor;
            button.layer.borderWidth = 1;
            button.layer.cornerRadius = 10;
        }
    }
}

- (void)setupBackBarButtonItem
{
    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navigation_btn_back_normal.png"] style:UIBarButtonItemStylePlain target:self action:@selector(actionBackBarButtonClicked:)];
    self.navigationItem.leftBarButtonItem = backBarButton;
}

- (void)actionBackBarButtonClicked:(id)sender
{
    
}

#pragma mark - HUD

- (void)showLoading:(NSString *)text
{
    if (!self.loadingHUD)
    {
        self.loadingHUD = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].delegate.window animated:YES];
        self.loadingHUD.backgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        self.loadingHUD.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
        self.loadingHUD.bezelView.color = [[UIColor blackColor] colorWithAlphaComponent:0.7];
        self.loadingHUD.contentColor = [UIColor whiteColor];
    }
    
    self.loadingHUD.mode = MBProgressHUDModeIndeterminate;
    self.loadingHUD.label.text = text;
}

- (void)hideLoading
{
    if (self.loadingHUD)
    {
        [self.loadingHUD hideAnimated:YES];
        self.loadingHUD = nil;
    }
}

- (void)showSuccess:(NSString *)text
{
    [self showSuccess:text complete:nil];
}

- (void)showSuccess:(NSString *)text complete:(void (^)())completeBlock
{
    MBProgressHUD *successHUD;
    
    if (self.loadingHUD)
    {
        successHUD = self.loadingHUD;
        self.loadingHUD = nil;
    }
    else
    {
        successHUD = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].delegate.window animated:YES];
        successHUD.backgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        successHUD.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
        successHUD.bezelView.color = [[UIColor blackColor] colorWithAlphaComponent:0.7];
        successHUD.contentColor = [UIColor whiteColor];
    }
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_success"]];
    imageView.frame = CGRectMake(0, 0, 44, 31);
    
    successHUD.mode = MBProgressHUDModeCustomView;
    successHUD.customView = imageView;
    successHUD.label.text = text;
    successHUD.completionBlock = completeBlock;
    
    [successHUD hideAnimated:YES afterDelay:1.f];
}

- (void)showFail:(NSString *)text
{
    [self showFail:text complete:nil];
}

- (void)showFail:(NSString *)text complete:(void (^)())completeBlock
{
    MBProgressHUD *successHUD;
    
    if (self.loadingHUD)
    {
        successHUD = self.loadingHUD;
        self.loadingHUD = nil;
    }
    else
    {
        successHUD = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].delegate.window animated:YES];
        successHUD.backgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        successHUD.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
        successHUD.bezelView.color = [[UIColor blackColor] colorWithAlphaComponent:0.7];
        successHUD.contentColor = [UIColor whiteColor];
    }
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_success"]];
    imageView.frame = CGRectMake(0, 0, 44, 31);
    
    successHUD.mode = MBProgressHUDModeCustomView;
    successHUD.customView = imageView;
    successHUD.label.text = text;
    successHUD.completionBlock = completeBlock;
    
    [successHUD hideAnimated:YES afterDelay:1.5f];
}

#pragma mark - Alert

- (void)alertWithTitle:(NSString *)title message:(NSString *)message confirm:(NSString *)confirm
{
    [self alertWithTitle:title message:message cancel:confirm confirm:nil confirmBlock:nil];
}

- (void)alertWithTitle:(NSString *)title errorCode:(GizWifiErrorCode)errorCode confirm:(NSString *)confirm
{
    [self alertWithTitle:title errorCode:errorCode cancel:confirm confirm:nil confirmBlock:nil];
}

- (void)alertWithTitle:(NSString *)title errorCode:(GizWifiErrorCode)errorCode cancel:(NSString *)cancel confirm:(NSString *)confirm confirmBlock:(void (^)())confirmBlock
{
    NSString *errorMsg = [[GizCommon sharedInstance] errorMsgForCode:errorCode];
    
    [self alertWithTitle:title message:errorMsg cancel:cancel confirm:confirm confirmBlock:confirmBlock];
}

- (void)alertWithTitle:(NSString *)title message:(NSString *)message cancel:(NSString *)cancel confirm:(NSString *)confirm confirmBlock:(void (^)())confirmBlock
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    if (cancel)
    {
        UIAlertAction *action = [UIAlertAction actionWithTitle:cancel style:UIAlertActionStyleCancel handler:nil];
        
        [alertController addAction:action];
    }
    
    if (confirm)
    {
        UIAlertAction *action = [UIAlertAction actionWithTitle:confirm style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            if (confirmBlock)
            {
                confirmBlock();
            }
        }];
        
        [alertController addAction:action];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self presentViewController:alertController animated:YES completion:nil];
    });
    
    if (!cancel && !confirm)
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [self dismissViewControllerAnimated:YES completion:nil];
        });
    }
}

@end
