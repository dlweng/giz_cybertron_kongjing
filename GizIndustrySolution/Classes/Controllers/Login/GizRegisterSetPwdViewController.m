//
//  GizRegisterSetPwdViewController.m
//  GizIndustrySolution
//
//  Created by Minus🍀 on 16/9/14.
//  Copyright © 2016年 Gizwits. All rights reserved.
//

#import "GizRegisterSetPwdViewController.h"
#import "GizConfigGuideViewController.h"

#import <GizWifiSDK/GizWifiSDK.h>

@interface GizRegisterSetPwdViewController () <GizWifiSDKDelegate>
{
    NSTimer *countdownTimer;
    NSInteger currentCountdown;
    
    NSTimer *registerTimer;
}

@property (weak, nonatomic) IBOutlet UIImageView *accountIconImageView;
@property (weak, nonatomic) IBOutlet UIImageView *codeIconImageView;
@property (weak, nonatomic) IBOutlet UIImageView *passwordIconImageView;
@property (weak, nonatomic) IBOutlet UITextField *accountTextField;
@property (weak, nonatomic) IBOutlet UITextField *codeTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *clearAccountButton;
@property (weak, nonatomic) IBOutlet UIButton *sendCodeButton;
@property (weak, nonatomic) IBOutlet UIButton *showOrHideButton;
@property (weak, nonatomic) IBOutlet GizButton *registerButton;
@property (weak, nonatomic) IBOutlet UILabel *countdownLabel;

@property (weak, nonatomic) IBOutlet UIView *horizontalLineView1;
@property (weak, nonatomic) IBOutlet UIView *horizontalLineView2;
@property (weak, nonatomic) IBOutlet UIView *horizontalLineView3;

@end

@implementation GizRegisterSetPwdViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [GizWifiSDK sharedInstance].delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
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
        self.accountTextField.font = font;
        self.codeTextField.font = font;
        self.passwordTextField.font = font;
    }
    
    self.accountTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.accountTextField.placeholder attributes:attributes];
    self.codeTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.codeTextField.placeholder attributes:attributes];
    self.passwordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.passwordTextField.placeholder attributes:attributes];
    
    self.accountTextField.textColor = textColor;
    self.codeTextField.textColor = textColor;
    self.passwordTextField.textColor = textColor;
    
    [self.accountTextField addTarget:self action:@selector(textFieldDidChangeText:) forControlEvents:UIControlEventEditingChanged];
    
    self.clearAccountButton.hidden = YES;
    
    [self setupAppearanceForButton:self.registerButton];
    
    [self.sendCodeButton setTitleColor:textColor forState:UIControlStateNormal];
    self.sendCodeButton.layer.borderWidth = 1;
    self.sendCodeButton.layer.borderColor = textColor.CGColor;
    
    self.countdownLabel.textColor = textColor;
    self.countdownLabel.layer.borderWidth = 1;
    self.countdownLabel.layer.borderColor = textColor.CGColor;
    self.countdownLabel.hidden = YES;
    
    self.horizontalLineView1.backgroundColor = textColor;
    self.horizontalLineView2.backgroundColor = textColor;
    self.horizontalLineView3.backgroundColor = textColor;
    
    self.accountIconImageView.tintColor = iconColor;
    self.accountIconImageView.image = [self.accountIconImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    self.codeIconImageView.tintColor = iconColor;
    self.codeIconImageView.image = [self.codeIconImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    self.passwordIconImageView.tintColor = iconColor;
    self.passwordIconImageView.image = [self.passwordIconImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    self.clearAccountButton.tintColor = iconColor;
    UIImage *clearImage = [[UIImage imageNamed:@"delete"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.clearAccountButton setImage:clearImage forState:UIControlStateNormal];
    
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

- (void)registerTimeout
{
    registerTimer = nil;
    
    [GizCommon removeUserAccount];
    // 提示注册失败
    
    [self hideLoading];
    
    [self alertWithTitle:@"注册失败" message:@"网络异常，请重试" cancel:@"不了" confirm:@"重试" confirmBlock:^{
        
        [self.registerButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    }];
}

#pragma mark - Actions

- (IBAction)actionClearAccount:(id)sender
{
    self.accountTextField.text = @"";
    self.clearAccountButton.hidden = YES;
}

- (IBAction)aciontSendCode:(id)sender
{
    NSString *phone = self.accountTextField.text;
    
    if ([phone length] <= 0)
    {
        [self alertWithTitle:@"提示" message:@"请输入手机号" confirm:@"确定"];
        return;
    }
    
    if (!isPhoneNumber(phone))
    {
        [self alertWithTitle:@"提示" message:@"请输入正确的手机号" confirm:@"确定"];
        return;
    }
    
    if (![AppDelegate isNetworkReachable]) {
        [self alertWithTitle:@"提示" message:@"当前无网络连接" confirm:@"确定"];
        return;
    }
    
    [[GizWifiSDK sharedInstance] requestSendPhoneSMSCode:GizAppSecret phone:phone];
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

- (IBAction)actionRegister:(id)sender
{
    [self.view endEditing:YES];
    
    NSString *account = self.accountTextField.text;
    NSString *password = self.passwordTextField.text;
    NSString *code = self.codeTextField.text;
    
    if ([account length] <= 0)
    {
        [self alertWithTitle:@"提示" message:@"请输入手机号" confirm:@"确定"];
        return;
    }
    
    if ([password length] < 6)
    {
        [self alertWithTitle:@"提示" message:@"请输入正确格式的密码" confirm:@"确定"];
        return;
    }
    
    if (!isPhoneNumber(account))
    {
        [self alertWithTitle:@"提示" message:@"请输入正确的手机号" confirm:@"确定"];
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
    
    [GizCommon archiveUserAccount:account password:password];
    
    [self showLoading:@"注册中"];
    
    registerTimer = [NSTimer scheduledTimerWithTimeInterval:GizTimeoutSeconds target:self selector:@selector(registerTimeout) userInfo:nil repeats:NO];
    
    [[GizWifiSDK sharedInstance] registerUser:account password:password verifyCode:code accountType:GizUserPhone];
}

#pragma mark - UITextField delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([textField isEqual:self.accountTextField])
    {
        self.clearAccountButton.hidden = !(self.accountTextField.editing && [self.accountTextField.text length] > 0);
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([textField isEqual:self.accountTextField])
    {
        self.clearAccountButton.hidden = YES;
    }
}

- (void)textFieldDidChangeText:(id)sender
{
    self.clearAccountButton.hidden = !(self.accountTextField.editing && [self.accountTextField.text length] > 0);
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

- (void)wifiSDK:(GizWifiSDK *)wifiSDK didRegisterUser:(NSError *)result uid:(NSString *)uid token:(NSString *)token
{
    // 15s 超时后，抛弃 SDK 的回调
    if (registerTimer && registerTimer.isValid)
    {
        [registerTimer invalidate];
        registerTimer = nil;
        
        if (result.code == GIZ_SDK_SUCCESS)
        {
            if (countdownTimer)
            {
                [countdownTimer invalidate];
                countdownTimer = nil;
            }
            
            [GizCommon sharedInstance].uid = uid;
            [GizCommon sharedInstance].token = token;
            
            [[GizWifiSDK sharedInstance] getUserInfo:GizUserToken];
        }
        else
        {
            [GizCommon removeUserAccount];
            
            [self hideLoading];
            
            if (result.code == GIZ_SDK_CONNECTION_TIMEOUT)
            {
                [self alertWithTitle:@"注册失败" message:@"网络异常，请重试" cancel:@"不了" confirm:@"重试" confirmBlock:^{
                    
                    [self.registerButton sendActionsForControlEvents:UIControlEventTouchUpInside];
                }];
            }
            else
            {
                [self alertWithTitle:@"注册失败" errorCode:result.code confirm:@"好的"];
            }
        }
    }
}

- (void)wifiSDK:(GizWifiSDK *)wifiSDK didGetUserInfo:(NSError *)result userInfo:(GizUserInfo *)userInfo
{
    if (result.code == GIZ_SDK_SUCCESS)
    {
        [GizCommon sharedInstance].userInfo = userInfo;
    }
    else
    {
        [GizCommon sharedInstance].uid = nil;
        [GizCommon sharedInstance].token = nil;
    }
    
    @weakify(self);
    [self showSuccess:@"注册成功" complete:^{
        
        @strongify(self);
        GizConfigGuideViewController *viewController = [UIStoryboard mi_instantiateViewControllerWithIdentifier:@"GizConfigGuideViewController" storyboard:@"DeviceConfig"];
        [self.navigationController pushViewController:viewController animated:YES];
    }];
}

@end
