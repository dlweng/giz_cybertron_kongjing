//
//  GizDiscoverFailViewController.m
//  GizIndustrySolution
//
//  Created by Minus🍀 on 2016/9/22.
//  Copyright © 2016年 Gizwits. All rights reserved.
//

#import "GizDiscoverFailViewController.h"

@interface GizDiscoverFailViewController ()

@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet UIImageView *failImageView;
@property (weak, nonatomic) IBOutlet GizButton *retryButton;

@end

@implementation GizDiscoverFailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.hidesBackButton = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initializeUI
{
    [super initializeUI];
    
    UIColor *iconColor = GizBaseIconColor;
    
    self.title = [NSString stringWithFormat:@"加载%@", GizProductName];
    
    UIColor *textColor = GizBaseTextColor;
    
    self.tipLabel.textColor = textColor;
    
    [self setupAppearanceForButton:self.retryButton];
    
    self.failImageView.tintColor = iconColor;
    self.failImageView.image = [self.failImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

#pragma mark - Actions

- (IBAction)actionRetry:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    
    if (self.retryBlock)
    {
        self.retryBlock();
    }
}

@end
