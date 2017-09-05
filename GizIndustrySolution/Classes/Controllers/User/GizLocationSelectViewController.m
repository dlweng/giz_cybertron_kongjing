//
//  GizLocationSelectViewController.m
//  GizIndustrySolution
//
//  Created by Minus🍀 on 2016/9/26.
//  Copyright © 2016年 Gizwits. All rights reserved.
//

#import "GizLocationSelectViewController.h"

@interface GizLocationSelectViewController ()


@end

@implementation GizLocationSelectViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.type == GizLocationProvince) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"city" ofType:@"plist"];
        self.cityList = [NSArray arrayWithContentsOfFile:path];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.cityList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if (self.type == GizLocationProvince)
    {
        cell = [self cellForProvince:indexPath];
    }
    else
    {
        cell = [self cellForCity:indexPath];
    }
    
    UILabel *label = [cell.contentView viewWithTag:100];
    label.textColor = GizBaseTextColor;
    
    UIView *lineView = [cell.contentView viewWithTag:101];
    lineView.backgroundColor = GizBaseTextColor;
    
    return cell;
}

- (UITableViewCell *)cellForProvince:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    UILabel *label = [cell.contentView viewWithTag:100];
    
    NSDictionary *provinceDict = [self.cityList objectAtIndex:indexPath.row];
    
    label.text = provinceDict[@"State"];
    
    return cell;
}

- (UITableViewCell *)cellForCity:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    UILabel *label = [cell.contentView viewWithTag:100];
    
    NSDictionary *cityDict = [self.cityList objectAtIndex:indexPath.row];
    
    label.text = cityDict[@"city"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.type == GizLocationProvince)
    {
        NSDictionary *provinceDict = [self.cityList objectAtIndex:indexPath.row];
        NSString *province = provinceDict[@"State"];
        
        GizLocationSelectViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"GizLocationSelectViewController"];
        viewController.type = GizLocationCity;
        viewController.province = province;
        viewController.cityList = self.cityList[indexPath.row][@"Cities"];
        [self.navigationController pushViewController:viewController animated:YES];
    }
    else
    {
        NSDictionary *cityDict = [self.cityList objectAtIndex:indexPath.row];
        
        NSString *province = self.province;
        NSString *city = cityDict[@"city"];
        
        NSDictionary *dict = @{@"province": province,
                               @"city": city};
        [[NSNotificationCenter defaultCenter] postNotificationName:GizLocationDidSelectNotification object:dict];
        NSUInteger count = self.navigationController.viewControllers.count;
        UIViewController *viewController = [self.navigationController.viewControllers objectAtIndex:count-3];
        [self.navigationController popToViewController:viewController animated:YES];
    }
}

@end
