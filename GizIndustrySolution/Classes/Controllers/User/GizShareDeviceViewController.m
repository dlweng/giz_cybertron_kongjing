//
//  GizShareDeviceViewController.m
//  GizIndustrySolution
//
//  Created by Minus🍀 on 2016/9/25.
//  Copyright © 2016年 Gizwits. All rights reserved.
//

#import "MIQRCodeGenerator.h"

#import "GizShareDeviceViewController.h"

@interface GizShareDeviceViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *qrcodeImageView;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;

@end

@implementation GizShareDeviceViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self.did length] > 0)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSString *productKey = GizProductKeys.firstObject;
//            NSString *qrcode = [NSString stringWithFormat:@"http://www.gizwits.com?product_key=%@&did=%@&passcode=123456", productKey, self.did];
            NSString *qrcode = [NSString stringWithFormat:@"http://www.gizwits.com?product_key=%@&mac=%@", productKey, self.mac];
            UIImage *image = [MIQRCodeGenerator createQRCodeForString:qrcode withSize:GizScreenWidth*0.7*2];
            image = [MIQRCodeGenerator imageBlackToTransparent:image withRed:0 andGreen:0 andBlue:0];
            
            self.qrcodeImageView.image = image;
        });
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initializeUI
{
    [super initializeUI];
    
    self.tipLabel.textColor = GizBaseTextColor;
}

@end
