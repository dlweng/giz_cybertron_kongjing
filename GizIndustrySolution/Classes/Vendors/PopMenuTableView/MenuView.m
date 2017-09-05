//
//  MenuView.m
//  PopMenuTableView
//
//  Created by 孔繁武 on 16/8/1.
//  Copyright © 2016年 KongPro. All rights reserved.
//

#import "MenuView.h"
#import "MenuModel.h"
#import "MenuTableViewCell.h"
#define MENU_TAG 99999  // MenuView的tag
#define BACKVIEW_TAG 88888  // 背景遮罩view的tag
#define MENU_POP_TAG 77777  //显示部分的tag
#define KRowHeight 40   // cell行高
#define KDefaultMaxValue 6  // 菜单项最大值
#define KNavigationBar_H 64 // 导航栏64
#define KIPhoneSE_ScreenW 375
#define KMargin 15
#define BACK_COLOR [UIColor whiteColor] //弹出框背景色

@interface MenuView () <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) UITableView * tableView;
@property (nonatomic,strong) UIView * backgroundView;
@property (nonatomic,strong) UIView * backView;
@property (nonatomic,assign) CGRect rect;
@property (nonatomic,strong) NSMutableArray * dataArray;
@property (nonatomic,strong) UIViewController * target;


@end

@implementation MenuView
#pragma mark -- setDataArray
- (void)setDataArray:(NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    [dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![obj isKindOfClass:[MenuModel class]]) {
            MenuModel *model = [MenuModel MenuModelWithDict:(NSDictionary *)obj];
            [_dataArray addObject:model];
        }
    }];
}

- (void)setMaxValueForItemCount:(NSInteger)maxValueForItemCount{
    if (maxValueForItemCount <= KDefaultMaxValue) {
        _maxValueForItemCount = maxValueForItemCount;
    }else{
        _maxValueForItemCount = KDefaultMaxValue;
    }
}

#pragma mark -- layoutSubviews
- (void)layoutSubviews{
    [super layoutSubviews];
    self.backgroundView.bounds = self.bounds;
}

#pragma mark -- initMenu
- (void)setUpUIWithFrame:(CGRect)frame{

    self.backgroundView = [[UIView alloc] initWithFrame:CGRectMake(self.bounds.origin.x, self.bounds.origin.y+15, self.bounds.size.width, self.bounds.size.height-15)];
    self.backgroundView.backgroundColor = BACK_COLOR;
    self.backgroundView.layer.cornerRadius = 5;
    self.backgroundView.alpha = 0.0;
    self.backgroundView.tag = MENU_POP_TAG;
    
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(self.bounds.size.width/2-15, 5)];
    [path addLineToPoint:CGPointMake(self.bounds.size.width/2, -13)];
    [path addLineToPoint:CGPointMake(self.bounds.size.width/2+15, 5)];
    [path addLineToPoint:CGPointMake(self.bounds.size.width/2-15, 5)];
    layer.path = path.CGPath;
    layer.fillColor = BACK_COLOR.CGColor;
    [self.backgroundView.layer addSublayer:layer];
    
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 15, frame.size.width, frame.size.height)];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.bounces = NO;
    self.tableView.rowHeight = KRowHeight;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[MenuTableViewCell class] forCellReuseIdentifier:@"cell"];
    
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, self.target.view.bounds.size.width, self.target.view.bounds.size.height)];
    backView.backgroundColor = [UIColor blackColor];
    backView.userInteractionEnabled = YES;
    backView.alpha = 0.0;
    backView.tag = BACKVIEW_TAG;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [backView addGestureRecognizer:tap];
    self.backView = backView;
    
    [self.target.view addSubview:backView];
    [self addSubview:self.backgroundView];
    [self addSubview:self.tableView];
}


#pragma mark -- UITableViewDataSource,UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MenuModel *model = self.dataArray[indexPath.row];
    MenuTableViewCell *cell = (MenuTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.menuModel = model;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    MenuModel *model = self.dataArray[indexPath.row];
    NSInteger tag = indexPath.row + 1;
    if (self.itemsClickBlock) {
        self.itemsClickBlock(model.itemName,tag);
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return KRowHeight;
}


#pragma mark -- UITapGestureRecognizer
- (void)tap:(UITapGestureRecognizer *)sender{
    [MenuView showMenuWithAnimation:NO];
    if (self.backViewTapBlock) {
        self.backViewTapBlock();
    }
}


#pragma mark -- Adjust Menu Frame
- (void)adjustFrameForMenu{
    
    MenuView *menuView = [[UIApplication sharedApplication].keyWindow viewWithTag:MENU_TAG];
    menuView.maxValueForItemCount = menuView.dataArray.count;

    CGRect rect = CGRectMake(menuView.tableView.frame.origin.x, menuView.tableView.frame.origin.y, menuView.tableView.frame.size.width, KRowHeight * menuView.maxValueForItemCount);
    CGRect frame = CGRectMake(menuView.frame.origin.x, menuView.frame.origin.y, menuView.frame.size.width,  (menuView.maxValueForItemCount * KRowHeight + KMargin) * 0.01);
    
    menuView.tableView.frame = rect;   // 根据菜单项，调整菜单内tableView的大小
    menuView.frame = frame;     // 根据菜单项，调整菜单的整体frame
}

#pragma mark -- Create Menu
+ (MenuView *)createMenuWithFrame:(CGRect)frame target:(UIViewController *)target dataArray:(NSArray *)dataArray itemsClickBlock:(void (^)(NSString *, NSInteger))itemsClickBlock backViewTap:(void (^)())backViewTapBlock{
    
    // 计算frame
    CGFloat factor = [UIScreen mainScreen].bounds.size.width < KIPhoneSE_ScreenW ? 0.6 : 0.5; // 适配比例
    CGFloat width = frame.size.width ? frame.size.width : [UIScreen mainScreen].bounds.size.width * factor;
    CGFloat height = dataArray.count > KDefaultMaxValue ? KDefaultMaxValue * KRowHeight : dataArray.count * KRowHeight;
    CGFloat x = frame.origin.x;
    CGFloat y = frame.origin.y;
    CGRect rect = CGRectMake(x, y, width, height);    // 菜单中tableView的frame
    frame = CGRectMake(x, y, width, height + KMargin); // 菜单的整体frame
    
    MenuView *menuView = [[MenuView alloc] init];
    menuView.tag = MENU_TAG;
    menuView.frame = frame;
    menuView.layer.anchorPoint = CGPointMake(0.5, 0);
    menuView.layer.position = CGPointMake(frame.origin.x, frame.origin.y);
    menuView.transform = CGAffineTransformMakeScale(0.01, 0.01);
    menuView.target = target;
    menuView.dataArray = [NSMutableArray arrayWithArray:dataArray];
    menuView.itemsClickBlock = itemsClickBlock;
    menuView.backViewTapBlock = backViewTapBlock;
    menuView.maxValueForItemCount = dataArray.count;
    [menuView setUpUIWithFrame:rect];
    [target.view addSubview:menuView];
    
    return menuView;
}


#pragma mark -- Show With Animation
+ (void)showMenuWithAnimation:(BOOL)isShow{
    
    MenuView *menuView = [[UIApplication sharedApplication].keyWindow viewWithTag:MENU_TAG];
    UIView *backView = [[UIApplication sharedApplication].keyWindow viewWithTag:BACKVIEW_TAG];
    UIView *menuBackView = [[UIApplication sharedApplication].keyWindow viewWithTag:MENU_POP_TAG];
    menuView.tableView.contentOffset = CGPointZero;
    [UIView animateWithDuration:0.2 animations:^{
        if (isShow) {
            menuView.isShowMenu = YES;
            menuView.alpha = 1;
            backView.alpha = 0.1;
            menuBackView.alpha = 1;
            menuView.transform = CGAffineTransformMakeScale(1.0, 1.0);
        }else{
            menuView.isShowMenu = NO;
            menuView.alpha = 0;
            backView.alpha = 0;
            menuBackView.alpha = 0;
            menuView.transform = CGAffineTransformMakeScale(0.01, 0.01);
        }
    }];
}


#pragma mark -- Append Menu Items
+ (void)appendMenuItemsWith:(NSArray *)appendItemsArray{
    
    MenuView *menuView = [[UIApplication sharedApplication].keyWindow viewWithTag:MENU_TAG];
    NSMutableArray *tempMutableArr = [NSMutableArray arrayWithArray:menuView.dataArray];
    [tempMutableArr addObjectsFromArray:appendItemsArray];
    menuView.dataArray = tempMutableArr;
    
    [menuView.tableView reloadData];
    [menuView adjustFrameForMenu];
}


#pragma mark -- Update Menu Items
+ (void)updateMenuItemsWith:(NSArray *)newItemsArray{
    
    MenuView *menuView = [[UIApplication sharedApplication].keyWindow viewWithTag:MENU_TAG];
    [menuView.dataArray removeAllObjects];
    menuView.dataArray = [NSMutableArray arrayWithArray:newItemsArray];
    
    [menuView.tableView reloadData];
    [menuView adjustFrameForMenu];
}


#pragma mark -- Hidden & Clear
+ (void)hiddenMenu{
    [MenuView showMenuWithAnimation:NO];
}

+ (void)clearMenuWithAnimation:(BOOL)animation{
    [MenuView showMenuWithAnimation:NO];
    if (animation) {
        [self ll_scheduledTimerWithTimeInterval:0.2 andTimeIntervalBlock:^{
            MenuView *menuView = [[UIApplication sharedApplication].keyWindow viewWithTag:MENU_TAG];
            UIView *backView = [[UIApplication sharedApplication].keyWindow viewWithTag:BACKVIEW_TAG];
            [menuView removeFromSuperview];
            [backView removeFromSuperview];
        } repeats:NO];
    }else{
        MenuView *menuView = [[UIApplication sharedApplication].keyWindow viewWithTag:MENU_TAG];
        UIView *backView = [[UIApplication sharedApplication].keyWindow viewWithTag:BACKVIEW_TAG];
        [menuView removeFromSuperview];
        [backView removeFromSuperview];
    }
    
}

+ (NSTimer *)ll_scheduledTimerWithTimeInterval:(NSTimeInterval)interval andTimeIntervalBlock:(void(^)(void))block repeats:(BOOL)yesOrNo{
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(timerBlockSelector:) userInfo:[block copy] repeats:yesOrNo];
    return timer;
    
}

+ (void)timerBlockSelector:(NSTimer *)timer{
    
    void(^block)(void) = timer.userInfo;
    
    if (block) {
        
        block();
    }
}



@end










