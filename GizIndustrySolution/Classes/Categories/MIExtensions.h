//
//  MIExtensions.h
//  midea_center_air
//
//  Created by Minus on 15/7/30.
//  Copyright (c) 2015年 Minus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface UIStoryboard (MIExtensions)

+ (__kindof UIViewController *)mi_instantiateViewControllerWithIdentifier:(NSString *)identifier storyboard:(NSString *)name;

@end


@interface NSBundle (MIExtensions)

+ (id)mi_loadNibNamed:(NSString *)nibName atIndex:(NSInteger)index;

@end


@interface UIColor (MIExtensions)

/// 0x000000  十六进制颜色值，按顺序为 red green blue
+ (UIColor *)mi_colorWithHex:(UInt32)hex;
/// 只适配1种格式 #00000000 十六进制颜色值，按顺序为 alpha red green blue
+ (UIColor *)mi_colorWithHexString:(NSString *)stringToConvert;

@end


@interface NSString (MIExtensions)

- (NSString *)mi_md5;
- (NSString *)localizedString;

@end


@interface UIImage (MIExtension)

- (UIImage *)autoCompress;

- (void)saveToCachesWithName:(NSString *)name;
+ (UIImage *)loadImageFromCachesWithName:(NSString *)name;

@end


@interface NSDictionary (MIExtension)

- (NSString *)mi_prettyJSONString;
- (NSString *)mi_JSONString;

@end


@interface NSArray (MIExtension)

- (NSString *)mi_prettyJSONString;
- (NSString *)mi_JSONString;

@end
