//
//  GizConfigResultViewController.m
//  GizIndustrySolution
//
//  Created by Minus🍀 on 16/9/18.
//  Copyright © 2016年 Gizwits. All rights reserved.
//

#import "GizConfigResultViewController.h"
#import "GizSelectWifiViewController.h"
#import "GizMainViewController.h"

@interface GizConfigResultViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *resultImageView;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet GizButton *startUseButton;

@end

@implementation GizConfigResultViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.success)
    {
        self.tipLabel.text = [NSString stringWithFormat:@"配置成功\n开始使用%@吧!", GizProductName];
        self.resultImageView.image = [[UIImage imageNamed:@"success.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [self.startUseButton setTitle:@"使用" forState:UIControlStateNormal];
    }
    else
    {
        self.tipLabel.text = @"配置失败\nWi-Fi密码输错了吗?";
        self.resultImageView.image = [[UIImage imageNamed:@"fail.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [self.startUseButton setTitle:@"重试" forState:UIControlStateNormal];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initializeUI
{
    [super initializeUI];
    
    UIColor *textColor = GizBaseTextColor;
    UIColor *iconColor = GizBaseIconColor;
    
    self.tipLabel.textColor = textColor;
    
    [self setupAppearanceForButton:self.startUseButton];
    
    self.resultImageView.tintColor = iconColor;
    self.resultImageView.image = [self.resultImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

#pragma mark - Actions

- (IBAction)actionStartUse:(id)sender
{
    if (self.success)
    {
        // 跳转到主控
        // navi ➔ login ➔ configGuide ➔ addDevice ➔ selectWifi ➔ configuring ➔ configResult
        // navi ➔ login ➔ configGuide ➔ main ➔ addDevice ➔ selectWifi ➔ configuring ➔ configResult
        for (UIViewController *viewController in self.navigationController.viewControllers)
        {
            if ([viewController isKindOfClass:[GizMainViewController class]])
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:GizDidBindDeviceNotification object:nil];
                [self.navigationController popToViewController:viewController animated:YES];
                return;
            }
        }
        
        GizMainViewController *viewController = [UIStoryboard mi_instantiateViewControllerWithIdentifier:@"GizMainViewController" storyboard:@"Main"];
        
        NSMutableArray<__kindof UIViewController *> *viewControllers = [self.navigationController.viewControllers mutableCopy];
        [viewControllers removeObjectsInRange:NSMakeRange(2, viewControllers.count-2)];
        [viewControllers addObject:viewController];
        [self.navigationController setViewControllers:viewControllers animated:YES];
    }
    else
    {
        // 重试配置设备
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
