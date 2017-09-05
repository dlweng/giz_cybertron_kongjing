//
//  GizUserInfoViewController.m
//  GizIndustrySolution
//
//  Created by Minus🍀 on 16/9/19.
//  Copyright © 2016年 Gizwits. All rights reserved.
//

#import <GizWifiSDK/GizWifiSDK.h>

#import "MLLocation.h"

#import "GizUserInfoViewController.h"
#import "GizEditUserInfoViewController.h"
#import "GizChangePasswordViewController.h"
#import "GizLocationSelectViewController.h"
#import "GizLoginViewController.h"

@interface GizUserInfoViewController () <UITableViewDelegate, UITableViewDataSource, MLLocationDeletate>
{
    NSArray<NSString *> *cellIdentifiers1;
    NSArray<NSString *> *cellIdentifiers2;
    
    GizUserInfo *userInfo;
}

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet GizButton *logoutButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoutButtonBottom;

@end

@implementation GizUserInfoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    userInfo = [GizCommon sharedInstance].userInfo;
    
    self.phoneLabel.text = userInfo.phone;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userInfoDidChangeNotification:) name:GizUserInfoDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDidSelectNotification:) name:GizLocationDidSelectNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)initializeUI
{
    [super initializeUI];
    
    UIColor *textColor = GizBaseTextColor;
    UIColor *iconColor = GizBaseIconColor;
    
    self.phoneLabel.textColor = textColor;
    self.tipLabel.textColor = textColor;
    
    [self setupAppearanceForButton:self.logoutButton];
    
    if (GizScreenHeight > 600)
    {
        self.logoutButtonBottom.constant = 40;
    }
    
    self.profileImageView.tintColor = iconColor;
    self.profileImageView.image = [self.profileImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    self.editButton.tintColor = iconColor;
    UIImage *editImage = [[UIImage imageNamed:@"edit_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.editButton setImage:editImage forState:UIControlStateNormal];
    
    cellIdentifiers1 = @[@"cellName", @"cellSex", @"cellMail"];
    cellIdentifiers2 = @[@"cellLocation", @"cellPassword"];
}

#pragma mark - Notifications

- (void)userInfoDidChangeNotification:(NSNotification *)notification
{
    [self.tableView reloadData];
}

- (void)locationDidSelectNotification:(NSNotification *)notification
{
    NSDictionary *dict = notification.object;
    
    MLLocation *location = [MLLocation defaultLocation];
    
    location.selectProvince = dict[@"province"];
    location.selectCity = dict[@"city"];
    
    userInfo.address = [NSString stringWithFormat:@"%@%@", location.selectProvince, location.selectCity];
    
    [[GizWifiSDK sharedInstance] changeUserInfo:GizUserToken username:nil SMSVerifyCode:nil accountType:GizUserNormal additionalInfo:userInfo];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    if (cell) {
        UILabel *addressLabel = [cell.contentView viewWithTag:101];
        addressLabel.text = userInfo.address;
    } else {
        [self.tableView reloadData];
    }
}

#pragma mark - Actions

- (IBAction)actionEdit:(id)sender
{
    GizEditUserInfoViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"GizEditUserInfoViewController"];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)actionLogout:(id)sender
{
    [self alertWithTitle:@"提示" message:@"退出登录?" cancel:@"取消" confirm:@"确定" confirmBlock:^{
        
        [[NSNotificationCenter defaultCenter] postNotificationName:GizUserDidLogoutNotification object:nil];
        
        [GizCommon clearUserPassword];
        
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

- (void)actionStartLocate:(id)sender
{
    MLLocation *location = [MLLocation defaultLocation];
    location.delegate = self;
    [location requestLocation];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    if (cell) {
        UILabel *addressLabel = [cell.contentView viewWithTag:101];
        addressLabel.text = @"定位中";
    }
}

#pragma mark - UITableView data source & delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section == 0 ? [cellIdentifiers1 count] : [cellIdentifiers2 count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return section == 0 ? 0.1 : 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier;
    UITableViewCell *cell;
    
    UIColor *textColor = GizBaseTextColor;
    
    if (indexPath.section == 0)
    {
        identifier = cellIdentifiers1[indexPath.row];
        
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        switch (indexPath.row)
        {
            case 0: // 昵称
            {
                UILabel *valueLabel = [cell.contentView viewWithTag:101];
                valueLabel.textColor = textColor;
                valueLabel.text = userInfo.name;
            }
                break;
                
            case 1: // 性别
            {
                UILabel *valueLabel = [cell.contentView viewWithTag:101];
                valueLabel.textColor = textColor;
                switch (userInfo.userGender)
                {
                    case GizUserGenderMale:
                        valueLabel.text = @"男";
                        break;
                        
                    case GizUserGenderFemale:
                        valueLabel.text = @"女";
                        break;
                        
                    default:
                        valueLabel.text = @"";
                        break;
                }
            }
                break;
                
            case 2: // 邮箱
            {
                UILabel *valueLabel = [cell.contentView viewWithTag:101];
                valueLabel.textColor = textColor;
                valueLabel.text = userInfo.remark;
            }
                break;
                
            default:
                break;
        }
    }
    else
    {
        identifier = cellIdentifiers2[indexPath.row];
        
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        if (indexPath.row == 0) {   // 定位
            UILabel *valueLabel = [cell.contentView viewWithTag:101];
            valueLabel.textColor = textColor;
            
            valueLabel.text = userInfo.address;
            
            UIButton *locateButton = (UIButton *)[cell.contentView viewWithTag:103];
            locateButton.tintColor = GizBaseIconColor;
            UIImage *locateImage = [[UIImage imageNamed:@"location_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            [locateButton setImage:locateImage forState:UIControlStateNormal];
            
            if ((locateButton.allControlEvents & UIControlEventTouchUpInside) == 0) {
                [locateButton addTarget:self action:@selector(actionStartLocate:) forControlEvents:UIControlEventTouchUpInside];
            }
        }
    }
    
    UILabel *titleLabel = [cell.contentView viewWithTag:100];
    UIView *lineView = [cell.contentView viewWithTag:102];
    
    titleLabel.textColor = textColor;
    lineView.backgroundColor = textColor;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 1)
    {
        switch (indexPath.row)
        {
            case 0:
            {
                GizLocationSelectViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"GizLocationSelectViewController"];
                viewController.type = GizLocationProvince;
                [self.navigationController pushViewController:viewController animated:YES];
            }
                break;
                
            case 1:
            {
                GizChangePasswordViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"GizChangePasswordViewController"];
                [self.navigationController pushViewController:viewController animated:YES];
            }
                break;
                
            default:
                break;
        }
    }
}

#pragma mark - MLLocationDeletate

- (void)locationDidReverseGeocodeLocation:(MLLocation *)location
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    NSString *address = [NSString stringWithFormat:@"%@%@", location.province, location.city];
    userInfo.address = address;
    [[GizWifiSDK sharedInstance] changeUserInfo:GizUserToken username:nil SMSVerifyCode:nil accountType:GizUserNormal additionalInfo:userInfo];
    
    if (cell) {
        UILabel *addressLabel = [cell.contentView viewWithTag:101];
        addressLabel.text = address;
    } else {
        [self.tableView reloadData];
    }
}

@end
