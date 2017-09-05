//
//  GizChangePasswordViewController.m
//  GizIndustrySolution
//
//  Created by Minus🍀 on 2016/9/25.
//  Copyright © 2016年 Gizwits. All rights reserved.
//

#import <GizWifiSDK/GizWifiSDK.h>

#import "GizChangePasswordViewController.h"

@interface GizChangePasswordViewController () <GizWifiSDKDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *oldPwdTipLabel;
@property (weak, nonatomic) IBOutlet UITextField *oldPasswordTextField;
@property (weak, nonatomic) IBOutlet UIView *lineView1;

@property (weak, nonatomic) IBOutlet UILabel *pwdTipLabel;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIView *lineView2;

@property (weak, nonatomic) IBOutlet UILabel *confirmPwdTipLabel;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTextField;
@property (weak, nonatomic) IBOutlet UIView *lineView3;

@end

@implementation GizChangePasswordViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initializeUI
{
    UIColor *textColor = GizBaseTextColor;
    UIColor *hintColor = GizBaseHintColor;
    
    self.tableView.backgroundColor = GizVCBackgroundColor;
        NSDictionary *attributes = @{NSForegroundColorAttributeName: hintColor};
    
    self.oldPasswordTextField.textColor = textColor;
    self.oldPasswordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.oldPasswordTextField.placeholder attributes:attributes];
    self.passwordTextField.textColor = textColor;
    self.passwordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.passwordTextField.placeholder attributes:attributes];
    self.confirmPasswordTextField.textColor = textColor;
    self.confirmPasswordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.confirmPasswordTextField.placeholder attributes:attributes];
    
    self.oldPwdTipLabel.textColor = textColor;
    self.pwdTipLabel.textColor = textColor;
    self.confirmPwdTipLabel.textColor = textColor;
    
    self.lineView1.backgroundColor = textColor;
    self.lineView2.backgroundColor = textColor;
    self.lineView3.backgroundColor = textColor;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark - Actions

- (IBAction)actionSave:(id)sender
{
    [self.tableView endEditing:YES];
    
    NSString *oldPassword = self.oldPasswordTextField.text;
    NSString *password = self.passwordTextField.text;
    NSString *confirmPassword = self.confirmPasswordTextField.text;
    
    if ([oldPassword length] <= 0)
    {
        [self alertWithTitle:@"提示" message:@"请输入原密码" confirm:@"确定"];
        return;
    }
    
    if ([oldPassword length] < 6)
    {
        [self alertWithTitle:@"提示" message:@"请输入正确格式的密码" confirm:@"确定"];
        return;
    }
    
    if ([password length] <= 0)
    {
        [self alertWithTitle:@"提示" message:@"请输入新密码" confirm:@"确定"];
        return;
    }
    
    if ([password length] < 6)
    {
        [self alertWithTitle:@"提示" message:@"请输入正确格式的密码" confirm:@"确定"];
        return;
    }
    
    if (![confirmPassword isEqualToString:password])
    {
        [self alertWithTitle:@"提示" message:@"两次输入的新密码不相等" confirm:@"确定"];
        return;
    }
    
    [GizWifiSDK sharedInstance].delegate = self;
    
    [self showLoading:@"密码修改中"];
    
    [[GizWifiSDK sharedInstance] changeUserPassword:GizUserToken oldPassword:oldPassword newPassword:password];
}

#pragma mark - GizWifiSDKDelegate

- (void)wifiSDK:(GizWifiSDK *)wifiSDK didChangeUserPassword:(NSError *)result
{
    if (result.code == GIZ_SDK_SUCCESS)
    {
        [GizCommon clearUserPassword];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:GizUserDidLogoutNotification object:nil];
        
        [self showSuccess:@"密码修改成功" complete:^{
            
            [GizWifiSDK sharedInstance].delegate = nil;
            
            for (GizWifiDevice *device in [GizCommon sharedInstance].boundDeviceArray) {
                [device setSubscribe:GizProductSecret subscribed:YES];
                device.delegate = nil;
            }
            
            [GizCommon sharedInstance].boundDeviceArray = nil;
            [GizCommon sharedInstance].userInfo = nil;
            [GizCommon sharedInstance].uid = nil;
            [GizCommon sharedInstance].token = nil;
            
            [self.navigationController popToRootViewControllerAnimated:YES];
        }];
    }
    else
    {
        [self hideLoading];
        
        switch (result.code) {
            case GIZ_SDK_CONNECTION_TIMEOUT:
            {
                [self alertWithTitle:@"密码修改失败" message:@"网络异常，请重试" cancel:@"不了" confirm:@"重试" confirmBlock:^{
                    
                    [self actionSave:nil];
                }];
            }
                break;
                
            case GIZ_OPENAPI_USERNAME_PASSWORD_ERROR:
            {
                [self alertWithTitle:@"密码修改失败" message:@"旧密码错误" confirm:@"好的"];
            }
                break;
                
            default:
            {
                [self alertWithTitle:@"密码修改失败" errorCode:result.code confirm:@"好的"];
            }
                break;
        }
    }
}

@end
