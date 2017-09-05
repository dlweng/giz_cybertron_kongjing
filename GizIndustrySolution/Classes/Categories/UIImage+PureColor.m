//
//  UIImage+PureColor.m
//  Enaiter_2_ios
//
//  Created by Minus on 15/4/21.
//  Copyright (c) 2015年 Minus. All rights reserved.
//

#import "UIImage+PureColor.h"

@implementation UIImage (PureColor)

+ (UIImage *)imageWithColor:(UIColor *)color
{
    if (!color)
    {
        return nil;
    }
    
    UIImage *image ;
    CGRect rect = CGRectMake(0, 0, 1, 1);
    
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    [color setFill];
    UIRectFill(rect);
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return [image stretchableImageWithLeftCapWidth:1 topCapHeight:1];
}

@end
