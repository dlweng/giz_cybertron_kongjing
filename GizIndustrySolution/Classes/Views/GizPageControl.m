//
//  GizPageControl.m
//  GizIndustrySolution
//
//  Created by Minus🍀 on 2016/9/22.
//  Copyright © 2016年 Gizwits. All rights reserved.
//

#import "GizAppGlobal.h"

#import "GizPageControl.h"

@interface GizPageControl ()

@property (nonatomic, strong) UIView *indicatorSuperView;
@property (nonatomic, strong) NSMutableArray<UIImageView *> *indicatorViews;

@end

@implementation GizPageControl

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self.userInteractionEnabled = NO;
    }
    
    return self;
}

- (void)setNumberOfPages:(NSInteger)numberOfPages
{
    _numberOfPages = numberOfPages;
    
    if (self.indicatorViews)
    {
        [self.indicatorViews removeAllObjects];
    }
    else
    {
        self.indicatorViews = [NSMutableArray new];
    }
    
    if (self.indicatorSuperView)
    {
        [self.indicatorSuperView removeFromSuperview];
        self.indicatorSuperView = nil;
    }
    
    self.indicatorSuperView = [[UIView alloc] init];
    self.indicatorSuperView.height = self.height;
    
    CGFloat width = MAX(self.pageIndicatorImage.size.width, self.currentPageIndicatorImage.size.width);
    CGFloat height = MAX(self.pageIndicatorImage.size.height, self.currentPageIndicatorImage.size.height);
    
    for (int i = 0; i < numberOfPages; i++)
    {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
        imageView.contentMode = UIViewContentModeCenter;
        imageView.image = self.pageIndicatorImage;
        imageView.highlightedImage = self.currentPageIndicatorImage;
        
        imageView.centerY = self.height / 2.0;
        imageView.left = i * (width + 5);
        [self.indicatorSuperView addSubview:imageView];
        
        [self.indicatorViews addObject:imageView];
        
        imageView.highlighted = i == _currentPage;
    }
    
    self.indicatorSuperView.width = width * numberOfPages + 5 * (numberOfPages - 1);
    self.indicatorSuperView.centerX = self.width / 2.0;
    [self addSubview:self.indicatorSuperView];
}

- (void)setCurrentPage:(NSInteger)currentPage
{
    _currentPage = currentPage;
    
    for (int i = 0; i < self.indicatorViews.count; i++)
    {
        UIImageView *imageView = self.indicatorViews[i];
        imageView.highlighted = i == currentPage;
    }
}

@end
