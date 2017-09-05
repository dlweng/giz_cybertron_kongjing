//
//  GizMoreViewController.m
//  GizIndustrySolution
//
//  Created by Minus🍀 on 2016/9/25.
//  Copyright © 2016年 Gizwits. All rights reserved.
//

#import <GizWifiSDK/GizWifiSDK.h>

#import "GizMoreViewController.h"
#import "GizShareDeviceViewController.h"
#import "GizAddDeviceGuideViewController.h"
#import "GizLoginViewController.h"

@interface GizMoreViewController () <UITextFieldDelegate, GizWifiSDKDelegate>
{
    NSTimer *saveNameTimer;
    NSTimer *unbindTimer;
}

@property (weak, nonatomic) IBOutlet UIImageView *deviceImageView;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UIView *lineView;
@property (weak, nonatomic) IBOutlet UIButton *clearButton;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;

@property (weak, nonatomic) IBOutlet GizButton *bottomButton1;
@property (weak, nonatomic) IBOutlet GizButton *bottomButton2;

@property (nonatomic, assign) BOOL editingName;

@end

@implementation GizMoreViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 注意不要修改了 device 的 delegate
    
    if (self.device)
    {
        self.nameTextField.text = self.device.alias;
    }
    else
    {
        self.nameTextField.text = @"";
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceDidChangeNameNotification:) name:GizDeviceNameDidChangeNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (void)initializeUI
{
    [super initializeUI];
    
    self.deviceImageView.image = [GizCommon sharedInstance].deviceImage;
    
    UIColor *textColor = GizBaseTextColor;
    UIColor *hintColor = GizBaseHintColor;
    UIColor *iconColor = GizBaseIconColor;
    
    NSDictionary *attributes = @{NSForegroundColorAttributeName: hintColor};
    
    self.nameTextField.textColor = textColor;
    self.nameTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.nameTextField.placeholder attributes:attributes];
    
    self.lineView.backgroundColor = textColor;
    self.tipLabel.textColor = textColor;
    
    [self setupAppearanceForButton:self.bottomButton1];
    [self setupAppearanceForButton:self.bottomButton2];
    
    self.editingName = NO;
    
    self.deviceImageView.tintColor = iconColor;
    self.deviceImageView.image = [self.deviceImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    self.clearButton.tintColor = iconColor;
    UIImage *clearImage = [[UIImage imageNamed:@"delete"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.clearButton setImage:clearImage forState:UIControlStateNormal];
    
    self.editButton.tintColor = iconColor;
    UIImage *editImage = [[UIImage imageNamed:@"edit_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.editButton setImage:editImage forState:UIControlStateNormal];
}

#pragma mark - Setters

- (void)setEditingName:(BOOL)editingName
{
    _editingName = editingName;
    
    self.nameTextField.userInteractionEnabled = editingName;
    self.editButton.hidden = editingName;
    self.clearButton.hidden = !editingName;
    self.lineView.hidden = !editingName;
    self.tipLabel.hidden = !editingName;
    
    NSString *title1 = editingName ? @"保存" : @"分享设备";
    NSString *title2 = editingName ? @"返回" : @"解除绑定";
    
    [self.bottomButton1 setTitle:title1 forState:UIControlStateNormal];
    [self.bottomButton2 setTitle:title2 forState:UIControlStateNormal];
}

#pragma mark - Notifications

- (void)deviceDidChangeNameNotification:(NSNotification *)notification
{
    NSDictionary *dict = notification.object;
    
    GizWifiDevice *device = dict[@"device"];
    NSError *result = dict[@"result"];
    
    if ([device isEqual:self.device])
    {
        [saveNameTimer invalidate];
        saveNameTimer = nil;
        
        if (result.code == GIZ_SDK_SUCCESS)
        {
            [self showSuccess:@"保存成功"];
            [self.view endEditing:YES];
            self.editingName = NO;
        }
        else
        {
            [self hideLoading];
            
            if (result.code == GIZ_SDK_CONNECTION_TIMEOUT)
            {
                [self alertWithTitle:@"保存失败" message:@"网络异常，请重试" cancel:@"不了" confirm:@"重试" confirmBlock:^{
                    
                    [self.bottomButton1 sendActionsForControlEvents:UIControlEventTouchUpInside];
                }];
            }
            else
            {
                [self alertWithTitle:@"保存失败" errorCode:result.code confirm:@"好的"];
            }
        }
    }
}

#pragma mark - Transactions

- (void)saveDeviceNameTimeout
{
    saveNameTimer = nil;
    
    [self alertWithTitle:@"保存失败" message:@"网络异常，请重试" cancel:@"不了" confirm:@"重试" confirmBlock:^{
        
        [self.bottomButton1 sendActionsForControlEvents:UIControlEventTouchUpInside];
    }];
}

- (void)unbindDevice
{
    [GizWifiSDK sharedInstance].delegate = self;
    
    [self showLoading:@"解绑设备中"];
    
    unbindTimer = [NSTimer scheduledTimerWithTimeInterval:GizTimeoutSeconds target:self selector:@selector(unbindDeviceTimeout) userInfo:nil repeats:NO];
    
    [[GizWifiSDK sharedInstance] unbindDevice:GizUserId token:GizUserToken did:self.device.did];
}

- (void)unbindDeviceTimeout
{
    unbindTimer = nil;
    
    [self alertWithTitle:@"解绑失败" message:@"网络异常，请重试" cancel:@"不了" confirm:@"重试" confirmBlock:^{
        
        [self unbindDevice];
    }];
}

- (void)didUnbindDevice
{
    NSUInteger deviceIndex = [[GizCommon sharedInstance].boundDeviceArray indexOfObject:self.device];
    
    [[GizCommon sharedInstance].boundDeviceArray removeObject:self.device];
    
    self.device.delegate = nil;
    
    // 没有设备，则返回到【无设备】界面
    if ([GizCommon sharedInstance].boundDeviceArray.count == 0)
    {
        // navi ➔ login ➔ configGuide ➔ main ➔ more
        UIViewController *viewController = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-3];
        [self.navigationController popToViewController:viewController animated:YES];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:GizDidUnbindDeviceNotification object:@(deviceIndex)];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Actions

- (IBAction)actionEditName:(id)sender
{
    self.editingName = YES;
    [self.nameTextField becomeFirstResponder];
}

- (IBAction)actionClearText:(id)sender
{
    self.nameTextField.text = @"";
}

- (IBAction)actionAddDevice:(id)sender
{
    [self.view endEditing:YES];
    
    GizAddDeviceGuideViewController *viewController = [UIStoryboard mi_instantiateViewControllerWithIdentifier:@"GizAddDeviceGuideViewController" storyboard:@"DeviceConfig"];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)actionBottomButton1:(id)sender
{
    if (self.editingName)
    {
        [self.view endEditing:YES];
        
        // 保存
        NSString *name = self.nameTextField.text;
        
        if ([name length] <= 0)
        {
            [self alertWithTitle:@"提示" message:@"设备名不能为空" confirm:@"确定"];
            return;
        }
        
        [self showLoading:@"保存中"];
        
        saveNameTimer = [NSTimer scheduledTimerWithTimeInterval:GizTimeoutSeconds target:self selector:@selector(saveDeviceNameTimeout) userInfo:nil repeats:NO];
        
        [self.device setCustomInfo:nil alias:name];
    }
    else
    {
        GizShareDeviceViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"GizShareDeviceViewController"];
        viewController.did = self.device.did;
        viewController.mac = self.device.macAddress;
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

- (IBAction)actionBottomButton2:(id)sender
{
    if (self.editingName)   // 返回
    {
        self.nameTextField.text = self.device.alias;
        [self.view endEditing:YES];
        self.editingName = NO;
    }
    else    // 解除绑定
    {
        [self alertWithTitle:@"提示" message:@"确定解绑设备吗?\n解绑后需要重新绑定哦" cancel:@"不了" confirm:@"确定" confirmBlock:^{
            
            [self unbindDevice];
        }];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark - GizWifiSDKDelegate

- (void)wifiSDK:(GizWifiSDK *)wifiSDK didUnbindDevice:(NSError *)result did:(NSString *)did
{
    if ([did isEqualToString:self.device.did])
    {
        [unbindTimer invalidate];
        unbindTimer = nil;
        
        if (result.code == GIZ_SDK_SUCCESS)
        {
            self.device.delegate = nil;
            
            @weakify(self);
            [self showSuccess:@"解绑成功" complete:^{
                
                @strongify(self);
                [self didUnbindDevice];
            }];
        }
        else
        {
            if (result.code == GIZ_SDK_CONNECTION_TIMEOUT)
            {
                [self alertWithTitle:@"解绑失败" message:@"网络异常，请重试" cancel:@"不了" confirm:@"重试" confirmBlock:^{
                    
                    [self unbindDevice];
                }];
            }
            else
            {
                [self alertWithTitle:@"解绑失败" errorCode:result.code confirm:@"好的"];
            }
        }
    }
}

@end
