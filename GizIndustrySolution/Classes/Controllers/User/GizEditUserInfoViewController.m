//
//  GizEditUserInfoViewController.m
//  GizIndustrySolution
//
//  Created by Minus🍀 on 2016/9/25.
//  Copyright © 2016年 Gizwits. All rights reserved.
//

#import <GizWifiSDK/GizWifiSDK.h>

#import "GizEditUserInfoViewController.h"

@interface GizEditUserInfoViewController () <UITextFieldDelegate, GizWifiSDKDelegate>
{
    GizUserInfo *userInfo;
}

@property (weak, nonatomic) IBOutlet UILabel *nameTipLabel;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UIView *lineView1;

@property (weak, nonatomic) IBOutlet UILabel *sexTipLabel;
@property (weak, nonatomic) IBOutlet UIButton *maleRadioButton;
@property (weak, nonatomic) IBOutlet UIButton *femaleRadioButton;
@property (weak, nonatomic) IBOutlet UIView *lineView2;

@property (weak, nonatomic) IBOutlet UILabel *mailTipLabel;
@property (weak, nonatomic) IBOutlet UITextField *mailTextField;
@property (weak, nonatomic) IBOutlet UIView *lineView3;

@end

@implementation GizEditUserInfoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    userInfo = [GizCommon sharedInstance].userInfo;
    self.nameTextField.text = userInfo.name;
    self.maleRadioButton.selected = userInfo.userGender == GizUserGenderMale;
    self.femaleRadioButton.selected = userInfo.userGender == GizUserGenderFemale;
    self.mailTextField.text = userInfo.remark;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initializeUI
{
    UIColor *textColor = GizBaseTextColor;
    UIColor *hintColor = GizBaseHintColor;
    UIColor *iconColor = GizBaseIconColor;
    
    self.tableView.backgroundColor = GizVCBackgroundColor;
    
    [self setupBackBarButtonItem];
    
    self.nameTipLabel.textColor = textColor;
    self.sexTipLabel.textColor = textColor;
    self.mailTipLabel.textColor = textColor;
    
    NSDictionary *attributes = @{NSForegroundColorAttributeName: hintColor};
    
    self.nameTextField.textColor = textColor;
    self.nameTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.nameTextField.placeholder attributes:attributes];
    self.mailTextField.textColor = textColor;
    self.mailTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.mailTextField.placeholder attributes:attributes];
    
    [self.maleRadioButton setTitleColor:textColor forState:UIControlStateNormal];
    [self.femaleRadioButton setTitleColor:textColor forState:UIControlStateNormal];
    
    self.lineView1.backgroundColor = textColor;
    self.lineView2.backgroundColor = textColor;
    self.lineView3.backgroundColor = textColor;
    
    UIImage *normalImage = [[UIImage imageNamed:@"sex_toggle_unselected"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImage *selectedImage = [[UIImage imageNamed:@"sex_toggle_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    self.maleRadioButton.tintColor = iconColor;
    [self.maleRadioButton setImage:normalImage forState:UIControlStateNormal];
    [self.maleRadioButton setImage:selectedImage forState:UIControlStateSelected];
    
    self.femaleRadioButton.tintColor = iconColor;
    [self.femaleRadioButton setImage:normalImage forState:UIControlStateNormal];
    [self.femaleRadioButton setImage:selectedImage forState:UIControlStateSelected];
}

#pragma mark - Actions

- (void)actionBackBarButtonClicked:(id)sender
{
    [self alertWithTitle:@"提示" message:@"是否放弃修改?" cancel:@"取消" confirm:@"确定" confirmBlock:^{
        
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

- (IBAction)actionSave:(id)sender
{
    [self.tableView endEditing:YES];
    
    NSString *nickname = self.nameTextField.text;
    NSString *mail = self.mailTextField.text;
    
    GizUserGenderType gender = GizUserGenderUnknown;
    
    if (self.maleRadioButton.selected)
    {
        gender = GizUserGenderMale;
    }
    else if (self.femaleRadioButton.selected)
    {
        gender = GizUserGenderFemale;
    }
    
    userInfo.name = nickname;
    userInfo.userGender = gender;
    userInfo.remark = mail;
    
    [GizWifiSDK sharedInstance].delegate = self;
    
    [self showLoading:@"保存中"];
    
    [[GizWifiSDK sharedInstance] changeUserInfo:GizUserToken username:nil SMSVerifyCode:nil accountType:GizUserNormal additionalInfo:userInfo];
}

- (IBAction)actionSeleceMale:(id)sender
{
    self.maleRadioButton.selected = YES;
    self.femaleRadioButton.selected = NO;
}

- (IBAction)actionSeleceFemale:(id)sender
{
    self.maleRadioButton.selected = NO;
    self.femaleRadioButton.selected = YES;
}

#pragma mark - UITextField delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark - GizWifiSDKDelegate

- (void)wifiSDK:(GizWifiSDK *)wifiSDK didChangeUserInfo:(NSError *)result
{
    if (result.code == GIZ_SDK_SUCCESS)
    {
        [self showSuccess:@"修改成功" complete:^{
            
            [[NSNotificationCenter defaultCenter] postNotificationName:GizUserInfoDidChangeNotification object:nil];
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }
    else
    {
        [self hideLoading];
        
        if (result.code == GIZ_SDK_CONNECTION_TIMEOUT)
        {
            [self alertWithTitle:@"修改失败" message:@"网络异常，请重试" cancel:@"不了" confirm:@"重试" confirmBlock:^{
                
                [self actionSave:nil];
            }];
        }
        else
        {
            [self alertWithTitle:@"修改失败" errorCode:result.code confirm:@"好的"];
        }
    }
}

@end
