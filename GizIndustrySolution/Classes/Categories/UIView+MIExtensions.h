//
//  UIView+MIExtensions.h
//  midea_center_air
//
//  Created by Minus on 15/7/30.
//  Copyright (c) 2015年 Minus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (MIExtensions)

@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) CGPoint origin;

@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;

@property (nonatomic, assign) CGFloat top;
@property (nonatomic, assign) CGFloat left;
@property (nonatomic, assign) CGFloat bottom;
@property (nonatomic, assign) CGFloat right;

@property (nonatomic, assign) CGFloat centerX;
@property (nonatomic, assign) CGFloat centerY;

@property (nonatomic, assign, readonly) CGPoint superOrigin;

- (CGPoint)originInView:(UIView *)view;

@end
