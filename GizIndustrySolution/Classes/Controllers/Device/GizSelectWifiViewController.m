//
//  GizSelectWifiViewController.m
//  GizIndustrySolution
//
//  Created by Minus🍀 on 16/9/18.
//  Copyright © 2016年 Gizwits. All rights reserved.
//

#import "GizSelectWifiViewController.h"
#import "GizConfiguringDeviceViewController.h"

@interface GizSelectWifiViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *wifiImageView;
@property (weak, nonatomic) IBOutlet UILabel *ssidLabel;
@property (weak, nonatomic) IBOutlet UIImageView *passwordIconImageView;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *showOrHideButton;
@property (weak, nonatomic) IBOutlet UIView *lineView;
@property (weak, nonatomic) IBOutlet GizButton *startConfigButton;
@property (weak, nonatomic) IBOutlet UIButton *switchWifiButton;

@property (nonatomic, strong) NSString *ssid;

@end

@implementation GizSelectWifiViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.ssid = getCurrentSSID();
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAppear:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillDisppear:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    self.ssid = getCurrentSSID();
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (void)initializeUI
{
    [super initializeUI];
    
    UIColor *textColor = GizBaseTextColor;
    UIColor *iconColor = GizBaseIconColor;
    
    self.ssidLabel.textColor = textColor;
    
    NSDictionary *attributes = @{NSForegroundColorAttributeName: [textColor colorWithAlphaComponent:0.6]};
    
    self.passwordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.passwordTextField.placeholder attributes:attributes];
    self.passwordTextField.textColor = textColor;
    
    self.lineView.backgroundColor = textColor;
    
    [self setupAppearanceForButton:self.startConfigButton];
    
    attributes = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle),
                                 NSForegroundColorAttributeName: textColor};
    NSAttributedString *underlineString = [[NSAttributedString alloc] initWithString:@"切换Wi-Fi" attributes:attributes];
    [self.switchWifiButton setAttributedTitle:underlineString forState:UIControlStateNormal];
    
    self.wifiImageView.tintColor = iconColor;
    self.wifiImageView.image = [self.wifiImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    self.passwordIconImageView.tintColor = iconColor;
    self.passwordIconImageView.image = [self.passwordIconImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    self.showOrHideButton.tintColor = iconColor;
    UIImage *closeImage = [[UIImage imageNamed:@"eye_close"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImage *openImage = [[UIImage imageNamed:@"eye_open"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.showOrHideButton setImage:closeImage forState:UIControlStateNormal];
    [self.showOrHideButton setImage:openImage forState:UIControlStateSelected];
}

- (void)keyboardWillAppear:(NSNotification *)notification
{
    CGRect frame;
    
    NSValue *value = notification.userInfo[UIKeyboardFrameEndUserInfoKey];
    [value getValue:&frame];
    
    CGFloat bottom = self.passwordTextField.bottom + 10;
    
    if (bottom > frame.origin.y)
    {
        CGFloat offsetY = bottom - frame.origin.y;
        
        [UIView animateWithDuration:0.25 animations:^{
            
            self.view.top -= offsetY;
        }];
    }
}

- (void)keyboardWillDisppear:(NSNotification *)notification
{
    if (self.view.top != 0)
    {
        [UIView animateWithDuration:0.25 animations:^{
            
            self.view.top = 0;
        }];
    }
}

- (void)applicationWillEnterForeground:(NSNotification *)notification
{
    self.ssid = getCurrentSSID();
}

#pragma mark - Setters

- (void)setSsid:(NSString *)ssid
{
    _ssid = ssid;
    
    self.ssidLabel.text = ssid;
    
    if ([ssid length] > 0)
    {
        NSString *password = [GizCommon passwordForSSID:ssid];
        self.passwordTextField.text = password;
    }
}

#pragma mark - UITextField delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Actions

- (IBAction)actionShowOrHidePassword:(id)sender
{
    self.showOrHideButton.selected = !self.showOrHideButton.selected;
    self.passwordTextField.secureTextEntry = !self.passwordTextField.secureTextEntry;
    
    // 解决 切换明文/密文 textField 末尾显示空白的 bug
    NSString *password = self.passwordTextField.text;
    self.passwordTextField.text = @"";
    self.passwordTextField.text = password;
}

- (IBAction)actionStartConfigure:(id)sender
{
    NSString *ssid = self.ssidLabel.text;
    NSString *password = self.passwordTextField.text;
    
    if ([ssid length] <= 0)
    {
        return;
    }
    
    [GizCommon archiveSSID:ssid password:password];
    
    GizConfiguringDeviceViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"GizConfiguringDeviceViewController"];
    viewController.ssid = ssid;
    viewController.password = password;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)actionSwitchWifi:(id)sender
{
    NSURL *url = [NSURL URLWithString:@"prefs:root=WIFI"];
    
    if ([[UIApplication sharedApplication] canOpenURL:url])
    {
        [[UIApplication sharedApplication] openURL:url];
    }
    else
    {
        [self alertWithTitle:@"提示" message:@"请打开\"设置\" → \"Wi-Fi\"，手动连接一个Wi-Fi" confirm:@"确定"];
    }
}

@end
