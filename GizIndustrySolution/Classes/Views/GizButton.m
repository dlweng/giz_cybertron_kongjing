//
//  GizButton.m
//  GizIndustrySolution
//
//  Created by Minus🍀 on 2016/9/26.
//  Copyright © 2016年 Gizwits. All rights reserved.
//

#import "GizButton.h"
#import "UIImage+PureColor.h"

@implementation GizButton

- (void)setGizHighlightBgColor:(UIColor *)gizHighlightBgColor
{
    _gizHighlightBgColor = gizHighlightBgColor;
    
    UIImage *image = [UIImage imageWithColor:gizHighlightBgColor];
    
    if (image)
    {
        self.clipsToBounds = YES;
    }
    else
    {
        self.clipsToBounds = NO;
    }
    
    [self setBackgroundImage:image forState:UIControlStateHighlighted];
}

- (void)setGizBgColor:(UIColor *)gizBgColor
{
    _gizBgColor = gizBgColor;
    
    UIImage *image = [UIImage imageWithColor:gizBgColor];
    
    [self setBackgroundImage:image forState:UIControlStateNormal];
}

- (void)setGizBgImage:(UIImage *)gizBgImage
{
    _gizBgImage = gizBgImage;
    
    [self setBackgroundImage:gizBgImage forState:UIControlStateNormal];
}

- (void)setGizHighlightBgImage:(UIImage *)gizHighlightBgImage
{
    _gizHighlightBgImage = gizHighlightBgImage;
    
    if (gizHighlightBgImage)
    {
        self.clipsToBounds = YES;
    }
    else
    {
        self.clipsToBounds = NO;
    }
    
    [self setBackgroundImage:gizHighlightBgImage forState:UIControlStateHighlighted];
}

@end
