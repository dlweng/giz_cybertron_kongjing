//
//  GizForgotGetCodeViewController.m
//  GizIndustrySolution
//
//  Created by Minus🍀 on 16/9/19.
//  Copyright © 2016年 Gizwits. All rights reserved.
//

#import "GizForgotGetCodeViewController.h"
#import "GizForgotSetNewPwdViewController.h"

@interface GizForgotGetCodeViewController () <UITextFieldDelegate, GizWifiSDKDelegate>
{
    NSTimer *sendCodeTimer;
}

@property (weak, nonatomic) IBOutlet UIImageView *accountIconImageView;
@property (weak, nonatomic) IBOutlet UITextField *accountTextField;
@property (weak, nonatomic) IBOutlet UIView *lineView;
@property (weak, nonatomic) IBOutlet GizButton *getCodeButton;
@property (weak, nonatomic) IBOutlet UIButton *clearAccountButton;

@end

@implementation GizForgotGetCodeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    }
    
    self.accountTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.accountTextField.placeholder attributes:attributes];
    self.accountTextField.textColor = textColor;
    [self.accountTextField addTarget:self action:@selector(textFieldDidChangeText:) forControlEvents:UIControlEventEditingChanged];
    
    self.clearAccountButton.hidden = YES;
    
    self.lineView.backgroundColor = textColor;
    
    [self setupAppearanceForButton:self.getCodeButton];
    
    self.accountIconImageView.tintColor = iconColor;
    self.accountIconImageView.image = [self.accountIconImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    self.clearAccountButton.tintColor = iconColor;
    UIImage *clearImage = [[UIImage imageNamed:@"delete"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.clearAccountButton setImage:clearImage forState:UIControlStateNormal];
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

#pragma mark - Actions

- (IBAction)actionClearAccount:(id)sender
{
    self.accountTextField.text = @"";
    self.clearAccountButton.hidden = YES;
}

- (IBAction)actionGetCode:(id)sender
{
    NSString *account = self.accountTextField.text;
    
    if ([account length] <= 0)
    {
        [self alertWithTitle:@"提示" message:@"请输入手机号" confirm:@"确定"];
        return;
    }
    
    if (!isPhoneNumber(account))
    {
        [self alertWithTitle:@"提示" message:@"请输入正确的手机号" confirm:@"确定"];
        return;
    }
    
    if (![AppDelegate isNetworkReachable]) {
        [self alertWithTitle:@"提示" message:@"当前无网络连接" confirm:@"确定"];
        return;
    }
    
    [self showLoading:@"获取验证码中"];
    
    sendCodeTimer = [NSTimer scheduledTimerWithTimeInterval:GizTimeoutSeconds target:self selector:@selector(sendCodeTimeout) userInfo:nil repeats:NO];
    
    [GizWifiSDK sharedInstance].delegate = self;
    [[GizWifiSDK sharedInstance] requestSendPhoneSMSCode:GizAppSecret phone:account];
}

- (void)sendCodeTimeout
{
    sendCodeTimer = nil;
    
    [self hideLoading];
    
    [self alertWithTitle:@"验证码发送失败" message:@"网络异常，请重试" cancel:@"不了" confirm:@"重试" confirmBlock:^{
        
        [self.getCodeButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    }];
}

#pragma mark - GizWifiSDKDelegate

- (void)wifiSDK:(GizWifiSDK *)wifiSDK didRequestSendPhoneSMSCode:(NSError *)result token:(NSString *)token
{
    if (!sendCodeTimer) {
        return;
    }
    
    [sendCodeTimer invalidate];
    sendCodeTimer = nil;
    
    [self hideLoading];
    
    if (result.code == GIZ_SDK_SUCCESS)
    {
        GizForgotSetNewPwdViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"GizForgotSetNewPwdViewController"];
        viewController.phone = self.accountTextField.text;
        [self.navigationController pushViewController:viewController animated:YES];
    }
    else
    {
        [self alertWithTitle:nil message:@"验证码发送失败" confirm:@"确定"];
        NSLog(@"验证码发送错误 %@", result);
    }
}

@end
