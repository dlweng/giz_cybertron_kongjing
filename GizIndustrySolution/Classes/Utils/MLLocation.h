//
//  MLLocation.h
//  ModernlandOne
//
//  Created by Minus on 16/3/31.
//  Copyright © 2016年 XPG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>


@protocol MLLocationDeletate;


@interface MLLocation : NSObject

@property (nonatomic, weak) id<MLLocationDeletate> delegate;

@property (nonatomic, strong) NSString *province;       // 定位 - 省份
@property (nonatomic, strong) NSString *city;           // 定位 - 城市
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@property (nonatomic, strong) NSString *selectProvince;       // 手动选择 - 省份
@property (nonatomic, strong) NSString *selectCity;           // 手动选择 - 城市

+ (instancetype)defaultLocation;

+ (CLAuthorizationStatus)status;

- (BOOL)requestLocation;

@end


@protocol MLLocationDeletate <NSObject>

@optional

- (void)locationDidUpdateCoordinate:(MLLocation *)location;
- (void)locationDidReverseGeocodeLocation:(MLLocation *)location;

@end
