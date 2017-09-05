//
//  GizLoginViewController.m
//  GizIndustrySolution
//
//  Created by Minus🍀 on 16/9/8.
//  Copyright © 2016年 Gizwits. All rights reserved.
//

#import <GizWifiSDK/GizWifiSDK.h>

#import "GizPageControl.h"
#import "GizGuideScrollView.h"

#import "GizLoginViewController.h"
#import "GizConfigGuideViewController.h"

@interface GizLoginViewController () <UITextFieldDelegate, UIScrollViewDelegate, GizWifiSDKDelegate>
{
    NSTimer *loginTimer;
    
    BOOL shouldRemoveGuideView;
}

@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UIImageView *accountIconImageView;
@property (weak, nonatomic) IBOutlet UIImageView *passwordIconImageView;
@property (weak, nonatomic) IBOutlet UITextField *accountTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *clearAccountButton;
@property (weak, nonatomic) IBOutlet UIButton *showOrHideButton;
@property (weak, nonatomic) IBOutlet GizButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *forgotButton;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;

@property (weak, nonatomic) IBOutlet UIView *horizontalLineView;
@property (weak, nonatomic) IBOutlet UIView *verticalLineView;

@property (nonatomic, strong) UIView *guideView;
@property (nonatomic, strong) GizGuideScrollView *scrollView;
@property (nonatomic, strong) GizPageControl *pageControl;

@end


@implementation GizLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.accountTextField.text = [GizCommon getArchiveAccount];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLogoutNotification:) name:GizUserDidLogoutNotification object:nil];
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"GizAppFirstLaunch"])
    {
        [[NSUserDefaults standardUserDefaults] setObject:@NO forKey:@"GizAppFirstLaunch"];
        
        self.automaticallyAdjustsScrollViewInsets = NO;
        
        self.guideView = [[UIView alloc] initWithFrame:self.view.bounds];
        self.guideView.backgroundColor = GizVCBackgroundColor;
        [self.view addSubview:self.guideView];
        
        self.scrollView = [[GizGuideScrollView alloc] initWithFrame:self.view.bounds];
        self.scrollView.delegate = self;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.pagingEnabled = YES;
        self.scrollView.bounces = NO;
        [self.guideView addSubview:self.scrollView];
        
        self.pageControl = [[GizPageControl alloc] initWithFrame:CGRectMake(0, GizScreenHeight-50, GizScreenWidth, 20)];
        self.pageControl.pageIndicatorImage = [UIImage imageNamed:@"guide_point_normal"];
        self.pageControl.currentPageIndicatorImage = [UIImage imageNamed:@"guide_point_selected"];
        [self.guideView addSubview:self.pageControl];
        
        NSArray<NSString *> *guideImageNames = [GizCommon sharedInstance].guideImageNames;
        
        for (int i = 0; i < guideImageNames.count; i++)
        {
            NSString *name = guideImageNames[i];
            UIImage *image = [UIImage imageNamed:name];
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.scrollView.bounds];
            imageView.image = image;
            imageView.left = i * self.scrollView.width;
            [self.scrollView addSubview:imageView];
            
            if (i == guideImageNames.count-1) {
                UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTapGuideImageToRemove:)];
                [imageView addGestureRecognizer:tapGesture];
                imageView.userInteractionEnabled = YES;
            }
        }
        
        self.pageControl.numberOfPages = guideImageNames.count;
        self.scrollView.contentSize = CGSizeMake(self.scrollView.width*guideImageNames.count, 0);
        
//        UIScreenEdgePanGestureRecognizer *panGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(edgeGesture:)];
//        panGesture.edges = UIRectEdgeRight;
//        [self.scrollView addGestureRecognizer:panGesture];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// override
- (void)initializeUI
{
    if (GizLoginBackgroundImage)
    {
        UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        bgImageView.image = GizLoginBackgroundImage;
        [self.view insertSubview:bgImageView atIndex:0];
    }
    else
    {
        self.view.backgroundColor = GizVCBackgroundColor;
    }
    
    UIColor *textColor = GizLoginTextColor;
    UIColor *hintColor = GizLoginHintColor;
    UIColor *buttonTextColor = GizLoginBtnTextColor;
    UIColor *loginIconColor = GizLoginIconColor;
    
    NSDictionary *attributes = @{NSForegroundColorAttributeName: hintColor};
    
    if (GizScreenWidth <= 320) {
        UIFont *font = [UIFont systemFontOfSize:16];
        self.accountTextField.font = font;
        self.passwordTextField.font = font;
    }
    
    self.accountTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.accountTextField.placeholder attributes:attributes];
    self.accountTextField.textColor = textColor;
    [self.accountTextField addTarget:self action:@selector(textFieldDidChangeText:) forControlEvents:UIControlEventEditingChanged];
    
    self.clearAccountButton.hidden = YES;
    
    self.passwordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.passwordTextField.placeholder attributes:attributes];
    self.passwordTextField.textColor = textColor;
    
    [self.loginButton setTitleColor:buttonTextColor forState:UIControlStateNormal];
    if (GizLoginBtnHighlightTextColor)
    {
        [self.loginButton setTitleColor:GizLoginBtnHighlightTextColor forState:UIControlStateHighlighted];
    }
    
    if (GizButtonBackgroundImage)
    {
        [self.loginButton setBackgroundImage:GizButtonBackgroundImage forState:UIControlStateNormal];
    }
    else
    {
        self.loginButton.gizBgImage = GizLoginBtnBgImage;
        self.loginButton.gizHighlightBgImage = GizLoginBtnHighlightBgImage;
        
        if (GizLoginBtnBorderColor)
        {
            self.loginButton.layer.borderColor = GizLoginBtnBorderColor.CGColor;
            self.loginButton.layer.borderWidth = 1;
            self.loginButton.layer.cornerRadius = 10;
        }
    }
    
    [self.forgotButton setTitleColor:buttonTextColor forState:UIControlStateNormal];
    [self.registerButton setTitleColor:buttonTextColor forState:UIControlStateNormal];
    
    self.horizontalLineView.backgroundColor = textColor;
    self.verticalLineView.backgroundColor = textColor;
    
    self.accountIconImageView.tintColor = loginIconColor;
    self.accountIconImageView.image = [self.accountIconImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    self.passwordIconImageView.tintColor = loginIconColor;
    self.passwordIconImageView.image = [self.passwordIconImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    self.clearAccountButton.tintColor = loginIconColor;
    UIImage *clearImage = [[UIImage imageNamed:@"delete"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.clearAccountButton setImage:clearImage forState:UIControlStateNormal];
    
    self.showOrHideButton.tintColor = loginIconColor;
    UIImage *closeImage = [[UIImage imageNamed:@"eye_close"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImage *openImage = [[UIImage imageNamed:@"eye_open"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.showOrHideButton setImage:closeImage forState:UIControlStateNormal];
    [self.showOrHideButton setImage:openImage forState:UIControlStateSelected];
}

#pragma mark - Transaction

- (void)loginTimeout
{
    loginTimer = nil;
    
    [GizCommon removeUserAccount];
    // 提示登录失败
    
    [self hideLoading];
    
    [self alertWithTitle:@"登录失败" message:@"网络异常，请重试" cancel:@"不了" confirm:@"重试" confirmBlock:^{
        
        [self.loginButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    }];
}

#pragma mark - Notification

- (void)userDidLogoutNotification:(NSNotification *)notification
{
    self.passwordTextField.text = @"";
}

#pragma mark - Actions

- (IBAction)actionClearAccount:(id)sender
{
    self.accountTextField.text = @"";
    self.clearAccountButton.hidden = YES;
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

- (IBAction)actionLogin:(id)sender
{
    [self.view endEditing:YES];
    
    NSString *account = self.accountTextField.text;
    NSString *password = self.passwordTextField.text;
    
    if ([account length] <= 0)
    {
        [self alertWithTitle:@"提示" message:@"请输入手机号" confirm:@"确定"];
        return;
    }
    
    if ([password length] <= 0)
    {
        [self alertWithTitle:@"提示" message:@"请输入密码" confirm:@"确定"];
        return;
    }
    
    if (!isPhoneNumber(account))
    {
        [self alertWithTitle:@"提示" message:@"请输入正确的手机号" confirm:@"确定"];
        return;
    }
    
    if ([password length] < 6)
    {
        [self alertWithTitle:@"提示" message:@"密码不能少于6位" confirm:@"确定"];
        return;
    }
    
    if (![AppDelegate isNetworkReachable]) {
        [self alertWithTitle:@"提示" message:@"当前无网络连接" confirm:@"确定"];
        return;
    }
    
    [GizCommon archiveUserAccount:account password:password];
    
    [GizWifiSDK sharedInstance].delegate = self;
    
    [self showLoading:@"登录中"];
    
    loginTimer = [NSTimer scheduledTimerWithTimeInterval:GizTimeoutSeconds target:self selector:@selector(loginTimeout) userInfo:nil repeats:NO];
    
    [[GizWifiSDK sharedInstance] userLogin:account password:password];
}

- (void)actionTapGuideImageToRemove:(UIGestureRecognizer *)gestureRecognizer
{
    [UIView animateWithDuration:0.75 animations:^{
        
        self.guideView.x = -self.guideView.width;
        
    } completion:^(BOOL finished) {
        [self.guideView removeFromSuperview];
        self.guideView.userInteractionEnabled = YES;
        self.scrollView = nil;
        self.pageControl = nil;
        self.guideView = nil;
    }];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([scrollView isEqual:self.scrollView])
    {
        self.pageControl.currentPage = scrollView.contentOffset.x / scrollView.width;
    }
}

/*
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (self.pageControl.currentPage == self.pageControl.numberOfPages-1) {
        shouldRemoveGuideView = YES;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (shouldRemoveGuideView) {
        CGFloat xOffset = scrollView.contentOffset.x - scrollView.width * (self.pageControl.numberOfPages-1);
        if (xOffset < 0) {
            shouldRemoveGuideView = NO;
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (self.pageControl.currentPage == 2 && shouldRemoveGuideView) {
        shouldRemoveGuideView = NO;
        CGFloat xOffset = self.guideView.x;
        self.guideView.userInteractionEnabled = NO;
        
        CGFloat remainX = xOffset + self.guideView.width;
        
        [UIView animateWithDuration:0.75 animations:^{
            
            self.guideView.x -= remainX;
            
        } completion:^(BOOL finished) {
            [self.guideView removeFromSuperview];
            self.guideView.userInteractionEnabled = YES;
            self.scrollView = nil;
            self.pageControl = nil;
            self.guideView = nil;
        }];
    }
}

- (void)edgeGesture:(UIScreenEdgePanGestureRecognizer *)panGesture
{
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            //CGPoint point = [panGesture locationInView:self.view];
            //NSLog(@"began %@", NSStringFromCGPoint(point));
        }
            break;
        
        case UIGestureRecognizerStateChanged:
        {
            CGPoint point = [panGesture locationInView:self.view];
            self.guideView.x = point.x - self.view.width;
        }
            break;
            
        case UIGestureRecognizerStateEnded:
        default:
        {
            CGFloat duration = 0.75 * (self.guideView.x + self.guideView.width) / self.guideView.width;
            
            [UIView animateWithDuration:duration animations:^{
                
                self.guideView.x = -self.guideView.width;
                
            } completion:^(BOOL finished) {
                [self.guideView removeFromSuperview];
                self.guideView.userInteractionEnabled = YES;
                self.scrollView = nil;
                self.pageControl = nil;
                self.guideView = nil;
            }];
        }
            break;
    }
}
 */

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

- (void)wifiSDK:(GizWifiSDK *)wifiSDK didUserLogin:(NSError *)result uid:(NSString *)uid token:(NSString *)token
{
    // 15s 超时后，抛弃 SDK 的回调
    if (loginTimer && loginTimer.isValid)
    {
        if (result.code == GIZ_SDK_SUCCESS)
        {
            [GizCommon sharedInstance].uid = uid;
            [GizCommon sharedInstance].token = token;
            
            [[GizWifiSDK sharedInstance] getUserInfo:GizUserToken];
        }
        else
        {
            [loginTimer invalidate];
            loginTimer = nil;
            
            [GizCommon removeUserAccount];
            // 提示登录失败
            
            [self hideLoading];
            
            if (result.code == GIZ_SDK_CONNECTION_TIMEOUT)
            {
                [self alertWithTitle:@"登录失败" message:@"网络异常，请重试" cancel:@"不了" confirm:@"重试" confirmBlock:^{
                    
                    [self.loginButton sendActionsForControlEvents:UIControlEventTouchUpInside];
                }];
            }
            else
            {
                [self alertWithTitle:@"登录失败" errorCode:result.code confirm:@"好的"];
            }
        }
    }
}

- (void)wifiSDK:(GizWifiSDK *)wifiSDK didGetUserInfo:(NSError *)result userInfo:(GizUserInfo *)userInfo
{
    if (loginTimer && loginTimer.isValid)
    {
        [loginTimer invalidate];
        loginTimer = nil;
        
        if (result.code == GIZ_SDK_SUCCESS)
        {
            [GizCommon sharedInstance].userInfo = userInfo;
            
            @weakify(self);
            [self showSuccess:@"登录成功" complete:^{
                
                @strongify(self);
                GizConfigGuideViewController *viewController = [UIStoryboard mi_instantiateViewControllerWithIdentifier:@"GizConfigGuideViewController" storyboard:@"DeviceConfig"];
                [self.navigationController pushViewController:viewController animated:YES];
            }];
        }
        else
        {
            [GizCommon removeUserAccount];
            // 提示登录失败
            
            [self hideLoading];
            
            if (result.code == GIZ_SDK_CONNECTION_TIMEOUT)
            {
                [self alertWithTitle:@"登录失败" message:@"网络异常，请重试" cancel:@"不了" confirm:@"重试" confirmBlock:^{
                    
                    [self.loginButton sendActionsForControlEvents:UIControlEventTouchUpInside];
                }];
            }
            else
            {
                [self alertWithTitle:@"登录失败" errorCode:result.code confirm:@"好的"];
            }
        }
    }
}

@end
