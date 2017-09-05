//
//  MIQRCodeGenerator.h
//  midea_center_air
//
//  Created by Minus on 15/9/20.
//  Copyright (c) 2015年 Minus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MIQRCodeGenerator : NSObject

+ (UIImage *)createQRCodeForString:(NSString *)string withSize:(CGFloat)size;
+ (UIImage *)addIconToQRCodeImage:(UIImage *)image withIcon:(UIImage *)icon withIconSize:(CGSize)iconSize;
+ (UIImage *)imageBlackToTransparent:(UIImage *)image withRed:(CGFloat)red andGreen:(CGFloat)green andBlue:(CGFloat)blue;

@end
