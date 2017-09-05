//
//  GizPageControl.h
//  GizIndustrySolution
//
//  Created by Minus🍀 on 2016/9/22.
//  Copyright © 2016年 Gizwits. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GizPageControl : UIView

@property (nonatomic, assign) NSInteger numberOfPages;
@property (nonatomic, assign) NSInteger currentPage;

/// 先设置图片，然后再设置 numberOfPages
@property(nullable, nonatomic,strong) UIImage *pageIndicatorImage;
@property(nullable, nonatomic,strong) UIImage *currentPageIndicatorImage;

@end
