//
//  GizAddDeviceGuideViewController.m
//  GizIndustrySolution
//
//  Created by Minus🍀 on 16/9/18.
//  Copyright © 2016年 Gizwits. All rights reserved.
//

#import "GizAddDeviceGuideViewController.h"
#import "GizScanCodeViewController.h"

@interface GizAddDeviceGuideViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *guideImageView;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet GizButton *confirmButton;
@property (weak, nonatomic) IBOutlet UIButton *scanButton;

@end

@implementation GizAddDeviceGuideViewController

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
    [super initializeUI];
    
    UIColor *textColor = GizBaseTextColor;
    UIColor *iconColor = GizBaseIconColor;
    
    self.guideImageView.image = [GizCommon sharedInstance].touchDeviceImage;
    
    self.title = [NSString stringWithFormat:@"添加%@", GizProductName];
    
    self.tipLabel.textColor = textColor;
    
    [self setupAppearanceForButton:self.confirmButton];
    
    NSDictionary *attributes = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle),
                                 NSForegroundColorAttributeName: textColor};
    NSAttributedString *underlineString = [[NSAttributedString alloc] initWithString:@"扫码绑定设备" attributes:attributes];
    [self.scanButton setAttributedTitle:underlineString forState:UIControlStateNormal];
    
    self.guideImageView.tintColor = iconColor;
    self.guideImageView.image = [self.guideImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

#pragma mark - Actions

- (IBAction)actionScanCode:(id)sender
{
    GizScanCodeViewController *viewController = [[GizScanCodeViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
