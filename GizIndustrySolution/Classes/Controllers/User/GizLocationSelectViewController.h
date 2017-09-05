//
//  GizLocationSelectViewController.h
//  GizIndustrySolution
//
//  Created by Minus🍀 on 2016/9/26.
//  Copyright © 2016年 Gizwits. All rights reserved.
//

#import "GizBaseTableViewController.h"


typedef NS_ENUM(NSInteger, GizLocationType) {
    GizLocationProvince,
    GizLocationCity,
};


@interface GizLocationSelectViewController : GizBaseTableViewController

@property (nonatomic, assign) GizLocationType type;
@property (nonatomic, assign) NSString *province;
@property (nonatomic, assign) NSString *city;

@property (nonatomic, strong) NSArray *cityList;

@end
