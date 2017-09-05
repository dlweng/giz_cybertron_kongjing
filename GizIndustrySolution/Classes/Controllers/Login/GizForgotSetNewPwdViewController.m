//
//  GizForgotSetNewPwdViewController.m
//  GizIndustrySolution
//
//  Created by Minus🍀 on 16/9/19.
//  Copyright © 2016年 Gizwits. All rights reserved.
//

#import <GizWifiSDK/GizWifiSDK.h>

#import "GizForgotSetNewPwdViewController.h"

@interface GizForgotSetNewPwdViewController () <UITextFieldDelegate, GizWifiSDKDelegate>
{
    NSTimer *countdownTimer;
    NSInteger currentCountdown;
    
    NSTimer *forgotTimer;
}

@property (weak, nonatomic) IBOutlet UIImageView *codeIconImageView;
@property (weak, nonatomic) IBOutlet UIImageView *passwordIconImageView;
@property (weak, nonatomic) IBOutlet UITextField *codeTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *sendCodeButton;
@property (weak, nonatomic) IBOutlet UILabel *countdownLabel;
@property (weak, nonatomic) IBOutlet UIButton *showOrHideButton;
@property (weak, nonatomic) IBOutlet GizButton *confirmButton;

@property (weak, nonatomic) IBOutlet UIView *horizontalLineView1;
@property (weak, nonatomic) IBOutlet UIView *horizontalLineView2;

@end

@implementation GizForgotSetNewPwdViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [GizWifiSDK sharedInstance].delegate = self;
    
    [self alertWithTitle:nil message:@"验证码已发送\n请查看短信" confirm:@"确定"];
    [self startCountdown];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (countdownTimer)
    {
        [countdownTimer invalidate];
        countdownTimer = nil;
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (void)initializeUI
{
    [super initializeUI];
    
    UIColor *textColor = GizBaseTextColor;
    UIColor *hintColor = GizBaseHintColor;
    UIColor *iconColor = GizBaseIconColor;
    
    NSDictionary *attributes = @{NSForegroundColorAttributeName: hintColor};
    
    if (GizScreenWidth <= 320) {
        UIFont *font = [UIFont systemFontOfSize:16];
        self.codeTextField.font = font;
        self.passwordTextField.font = font;
    }
    
    self.codeTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.codeTextField.placeholder attributes:attributes];
    self.passwordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.passwordTextField.placeholder attributes:attributes];
    
    self.codeTextField.textColor = textColor;
    self.passwordTextField.textColor = textColor;
    
    [self setupAppearanceForButton:self.confirmButton];
    
    [self.sendCodeButton setTitleColor:textColor forState:UIControlStateNormal];
    self.sendCodeButton.layer.borderWidth = 1;
    self.sendCodeButton.layer.borderColor = textColor.CGColor;
    
    self.countdownLabel.textColor = textColor;
    self.countdownLabel.layer.borderWidth = 1;
    self.countdownLabel.layer.borderColor = textColor.CGColor;
    
    self.horizontalLineView1.backgroundColor = textColor;
    self.horizontalLineView2.backgroundColor = textColor;
    
    self.codeIconImageView.tintColor = iconColor;
    self.codeIconImageView.image = [self.codeIconImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    self.passwordIconImageView.tintColor = iconColor;
    self.passwordIconImageView.image = [self.passwordIconImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    self.showOrHideButton.tintColor = iconColor;
    UIImage *closeImage = [[UIImage imageNamed:@"eye_close"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImage *openImage = [[UIImage imageNamed:@"eye_open"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.showOrHideButton setImage:closeImage forState:UIControlStateNormal];
    [self.showOrHideButton setImage:openImage forState:UIControlStateSelected];
}

#pragma mark - Transaction

- (void)startCountdown
{
    self.sendCodeButton.hidden = YES;
    self.countdownLabel.hidden = NO;
    self.countdownLabel.text = @"60s后重试";
    currentCountdown = 60;
    
    countdownTimer = [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(countingDown) userInfo:nil repeats:YES];
}

- (void)countingDown
{
    if (currentCountdown > 1)
    {
        self.countdownLabel.text = [NSString stringWithFormat:@"%@s后重试", @(currentCountdown--)];
    }
    else
    {
        [countdownTimer invalidate];
        countdownTimer = nil;
        
        self.sendCodeButton.hidden = NO;
        self.countdownLabel.hidden = YES;
    }
}

- (void)forgotTimeout
{
    forgotTimer = nil;
    
    [self hideLoading];
    
    [self alertWithTitle:@"重置失败" message:@"网络异常，请重试" cancel:@"不了" confirm:@"重试" confirmBlock:^{
        
        [self.confirmButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    }];
}

#pragma mark - Actions

- (IBAction)aciontSendCode:(id)sender
{
    if (![AppDelegate isNetworkReachable]) {
        [self alertWithTitle:@"提示" message:@"当前无网络连接" confirm:@"确定"];
        return;
    }
    
    [[GizWifiSDK sharedInstance] requestSendPhoneSMSCode:GizAppSecret phone:self.phone];
}

- (IBAction)actionShowOrHidePassword:(id)sender
{
    self.showOrHideButton.selected = !self.showOrHideButton.selected;
    self.passwordTextField.secureTextEntry = !self.passwordTextField.secureTextEntry;
    
    // 解决 切换明文/密文 textField 末尾显示空白的 bug
    NSString *password = self.passwordTextField.text;
    self.passwordTextField.text = @"";
    self.passwordTextField.text = password;
}

- (IBAction)actionConfirm:(id)sender
{
    NSString *code = self.codeTextField.text;
    NSString *password = self.passwordTextField.text;
    
    if ([password length] < 6)
    {
        [self alertWithTitle:@"提示" message:@"请输入正确格式的密码" confirm:@"确定"];
        return;
    }
    
    if ([code length] <= 0)
    {
        [self alertWithTitle:@"提示" message:@"请输入验证码" confirm:@"确定"];
        return;
    }
    
    if (![AppDelegate isNetworkReachable]) {
        [self alertWithTitle:@"提示" message:@"当前无网络连接" confirm:@"确定"];
        return;
    }
    
    [self showLoading:@"重置密码中"];
    
    forgotTimer = [NSTimer scheduledTimerWithTimeInterval:GizTimeoutSeconds target:self selector:@selector(forgotTimeout) userInfo:nil repeats:NO];
    
    [[GizWifiSDK sharedInstance] resetPassword:self.phone verifyCode:code newPassword:password accountType:GizUserPhone];
}

#pragma mark - UITextField delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - GizWifiSDKDelegate

- (void)wifiSDK:(GizWifiSDK *)wifiSDK didRequestSendPhoneSMSCode:(NSError *)result token:(NSString *)token
{
    if (result.code == GIZ_SDK_SUCCESS)
    {
        [self startCountdown];
        [self alertWithTitle:nil message:@"验证码已发送\n请查看短信" confirm:@"确定"];
    }
    else
    {
        [self alertWithTitle:nil message:@"验证码发送失败" confirm:@"确定"];
        NSLog(@"验证码发送错误 %@", result);
        
        [countdownTimer invalidate];
        countdownTimer = nil;
        
        self.sendCodeButton.hidden = NO;
        self.countdownLabel.hidden = YES;
    }
}

- (void)wifiSDK:(GizWifiSDK *)wifiSDK didChangeUserPassword:(NSError *)result
{
    // 15s 超时后，抛弃 SDK 的回调
    if (forgotTimer && forgotTimer.isValid)
    {
        [forgotTimer invalidate];
        forgotTimer = nil;
        
        if (result.code == GIZ_SDK_SUCCESS)
        {
            if (countdownTimer)
            {
                [countdownTimer invalidate];
                countdownTimer = nil;
            }
            
            @weakify(self);
            [self showSuccess:@"重置成功" complete:^{
                
                @strongify(self);
                [self.navigationController popToRootViewControllerAnimated:YES];
            }];
        }
        else
        {
            [self hideLoading];
            
            if (result.code == GIZ_SDK_CONNECTION_TIMEOUT)
            {
                [self alertWithTitle:@"重置失败" message:@"网络异常，请重试" cancel:@"不了" confirm:@"重试" confirmBlock:^{
                    
                    [self.confirmButton sendActionsForControlEvents:UIControlEventTouchUpInside];
                }];
            }
            else
            {
                [self alertWithTitle:@"重置失败" errorCode:result.code confirm:@"好的"];
            }
        }
    }
}

@end
