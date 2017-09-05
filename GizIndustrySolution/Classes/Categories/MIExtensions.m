//
//  MIExtensions.m
//  midea_center_air
//
//  Created by Minus on 15/7/30.
//  Copyright (c) 2015年 Minus. All rights reserved.
//

#import "MIExtensions.h"

#import <CommonCrypto/CommonDigest.h>
#import <objc/runtime.h>

@implementation UIStoryboard (MIExtensions)

+ (__kindof UIViewController *)mi_instantiateViewControllerWithIdentifier:(NSString *)identifier storyboard:(NSString *)name
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:name bundle:nil];
    
    return [storyboard instantiateViewControllerWithIdentifier:identifier];
}

@end


@implementation NSBundle (MIExtensions)

+ (id)mi_loadNibNamed:(NSString *)nibName atIndex:(NSInteger)index
{
    return [[[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil] objectAtIndex:index];
}

@end


@implementation UIColor (MIExtensions)

+ (UIColor *)mi_colorWithHex:(UInt32)hex
{
    return [UIColor colorWithRed:((hex >> 16) & 0x000000FF) / 255.0f
                           green:((hex >> 8) & 0x000000FF) / 255.0f
                            blue:(hex & 0x000000FF) / 255.0f
                           alpha:1.0f];
}

+ (UIColor *)mi_colorWithHexString:(NSString *)stringToConvert
{
    if (!stringToConvert)
    {
        return nil;
    }
    
    NSString *tempStr = stringToConvert;
    
    if ([stringToConvert hasPrefix:@"#"])
    {
        tempStr = [stringToConvert stringByReplacingOccurrencesOfString:@"#" withString:@""];
    }
    
    UInt32 hex = (UInt32)strtoul([tempStr cStringUsingEncoding:NSUTF8StringEncoding], 0, 16);
    
    return [UIColor colorWithRed:((hex >> 16) & 0x000000FF) / 255.0f
                           green:((hex >> 8) & 0x000000FF) / 255.0f
                            blue:(hex & 0x000000FF) / 255.0f
                           alpha:((hex >> 24) & 0x000000FF) / 255.0f];
}

@end


@implementation NSString (MIExtensions)

- (NSString *)mi_md5
{
    const char *cstr = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cstr, (CC_LONG)strlen(cstr), result);
    
    return [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1],
            result[2], result[3],
            result[4], result[5],
            result[6], result[7],
            result[8], result[9],
            result[10], result[11],
            result[12], result[13],
            result[14], result[15]];
}

- (NSString *)localizedString {
    return NSLocalizedString(self, @"");
}

@end


@implementation UIImage (MIExtension)

- (UIImage *)autoCompress
{
    NSInteger maxKB = 200;  // 图片最大200KB
    
    NSData *imageData = UIImagePNGRepresentation(self);
    
    if (imageData.length/1024 > maxKB)
    {
        CGFloat compressScale = (maxKB * 1024.0) / (CGFloat)imageData.length;
        UIImage *compressImage = [self zoomWithScale:compressScale];
        //        UIImage *compressImage = [self jpegCompressWithScale:compressScale];
        
        imageData = UIImagePNGRepresentation(compressImage);
        
        return compressImage;
    }
    
    return self;
}

- (UIImage *)jpegCompressWithScale:(CGFloat)compressScale
{
    NSData *data = UIImageJPEGRepresentation(self, compressScale);
    return [UIImage imageWithData:data];
}

- (UIImage *)zoomWithScale:(CGFloat)compressScale
{
    CGSize size = self.size;
    
    size.width *= compressScale;
    size.height *= compressScale;
    
    UIGraphicsBeginImageContextWithOptions(size, YES, [UIScreen mainScreen].scale);
    
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *scaleImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return scaleImage;
}

- (void)saveToCachesWithName:(NSString *)name
{
    NSData *data = UIImagePNGRepresentation(self);
    
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    path = [path stringByAppendingPathComponent:@"images"];
    
    BOOL isDirectory;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory])
    {
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        
        if (error)
        {
            NSLog(@"创建目录失败 %@", path);
            NSLog(@"%@", error);
        }
    }
    
    NSLog(@"%@", path);
    path = [path stringByAppendingPathComponent:name];
    
    [data writeToFile:path atomically:YES];
}

+ (UIImage *)loadImageFromCachesWithName:(NSString *)name
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    path = [path stringByAppendingPathComponent:@"images"];
    path = [path stringByAppendingPathComponent:name];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        NSData *data = [[NSData alloc] initWithContentsOfFile:path];
        
        if (data)
        {
            return [UIImage imageWithData:data];
        }
    }
    
    return nil;
}

@end


@implementation NSDictionary (MIExtension)

- (NSString *)mi_prettyJSONString
{
    NSDictionary *jsonDict = [self replaceNSDataValue];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:NSJSONWritingPrettyPrinted error:NULL];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

- (NSString *)mi_JSONString
{
    NSDictionary *jsonDict = [self replaceNSDataValue];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:NULL];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

- (void)printAllClass:(NSInteger)level
{
    NSString *appendStr = @"";
    
    for (int i = 0; i < level; i++)
    {
        appendStr = [appendStr stringByAppendingString:@"→ "];
    }
    
    for (NSString *key in self.allKeys)
    {
        id value = self[key];
        
        NSLog(@"%@ 【%@】", key, NSStringFromClass([value class]));
        
        if ([value isKindOfClass:[NSDictionary class]])
        {
            [(NSDictionary *)value printAllClass:level+1];
        }
    }
}

- (NSDictionary *)replaceNSDataValue
{
    NSMutableDictionary *mdict = [self mutableCopy];
    
    for (NSString *key in mdict.allKeys)
    {
        id value = self[key];
        
        if ([value isKindOfClass:[NSData class]])
        {
            [mdict setObject:[value description] forKey:key];
        }
        else if ([value isKindOfClass:[NSDictionary class]])
        {
            value = [(NSDictionary *)value replaceNSDataValue];
            [mdict setObject:value forKey:key];
        }
    }
    
    return mdict;
}

@end


@implementation NSArray (MIExtension)

- (NSString *)mi_prettyJSONString
{
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:NULL];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

- (NSString *)mi_JSONString
{
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:0 error:NULL];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

@end

