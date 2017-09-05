//
//  MLLocation.m
//  ModernlandOne
//
//  Created by Minus on 16/3/31.
//  Copyright © 2016年 XPG. All rights reserved.
//

#import "MLLocation.h"


@interface MLLocation () <CLLocationManagerDelegate>
{
    CLLocationManager *locationManager;
}

@end

@implementation MLLocation

+ (instancetype)defaultLocation
{
    static MLLocation *_sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _sharedInstance = [[MLLocation alloc] init];
    });
    
    return _sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    }
    
    return self;
}

+ (CLAuthorizationStatus)status
{
    return [CLLocationManager authorizationStatus];
}

- (BOOL)requestLocation
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    if (status == kCLAuthorizationStatusDenied)
    {
        return NO;
    }
    
    if ([CLLocationManager locationServicesEnabled])
    {
        if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
        {
            [locationManager requestWhenInUseAuthorization];
        }
        
        locationManager.distanceFilter = kCLDistanceFilterNone;
        [locationManager startUpdatingLocation];
        
        return YES;
    }
    
    return NO;
}

- (void)handleAddressDictionary:(NSDictionary *)addressDictionary
{
    /**
     {
         FormattedAddressLines = [
            中国广东省广州市天河区沙东街道沙太路陶庄5号
         ],
         Street = 沙太路陶庄5号,
         Thoroughfare = 沙太路陶庄5号,
         Name = 沙东轻工业大厦,
         City = 广州市,
         Country = 中国,
         State = 广东省,
         SubLocality = 天河区,
         CountryCode = CN
     }
     */
    self.city = addressDictionary[@"City"];
    self.province = addressDictionary[@"State"];
    
    if (_delegate && [_delegate respondsToSelector:@selector(locationDidReverseGeocodeLocation:)])
    {
        [_delegate locationDidReverseGeocodeLocation:self];
    }
}

#pragma mark - CLLocationManager delegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    [self requestLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    [manager stopUpdatingLocation];
    
    CLLocation *location = [locations lastObject];
    
    self.coordinate = location.coordinate;
    
    if (_delegate && [_delegate respondsToSelector:@selector(locationDidUpdateCoordinate:)]) {
        [_delegate locationDidUpdateCoordinate:self];
    }
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    __weak typeof(self) weakSelf = self;
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        
        if (!error)
        {
            CLPlacemark *placemark = [placemarks firstObject];
            
            NSDictionary *addressDict = [placemark addressDictionary];
            NSLog(@"定位信息 %@", addressDict);
            [weakSelf handleAddressDictionary:addressDict];
        }
        else
        {
            NSLog(@"解析定位信息失败 [%@] %@", @(error.code), [error localizedDescription]);
        }
    }];
}

@end
