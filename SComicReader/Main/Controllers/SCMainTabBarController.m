//
//  SCMainTabBarController.m
//  彩票案例
//
//  Created by 冰河依然在 on 2018/2/1.
//  Copyright © 2018年 冰河依然在. All rights reserved.
//

#import "SCMainTabBarController.h"
#import "SCNewTabBarView.h"

@interface SCMainTabBarController ()<SCNewTabBarViewDelegate>

@end

@implementation SCMainTabBarController

-(void)tabBarButtonSwitch:(SCNewTabBarView *)newTabBarView didClickTabBarButtonIndex:(int)index{
    //通过 self.selectedIndex 传入的值切换控制器
    self.selectedIndex = index;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // 创建4个控制器
    UINavigationController *indexNavCon = [self navigationControllerWithStoryboardName:@"SCIndex"];
//    这种方式设置显示出来有问题,突然没问题了
    indexNavCon.tabBarItem.image = [UIImage imageNamed:@"tab1_nor"];
    indexNavCon.tabBarItem.title = @"首页";
    UINavigationController *bookShelfNavCon = [self navigationControllerWithStoryboardName:@"SCBookShelf"];
    bookShelfNavCon.tabBarItem.image = [UIImage imageNamed:@"tab2_nor"];
    bookShelfNavCon.tabBarItem.title = @"书架";
    UINavigationController *categoryNavCon = [self navigationControllerWithStoryboardName:@"SCClassification"];
    categoryNavCon.tabBarItem.image = [UIImage imageNamed:@"tab3_nor"];
    categoryNavCon.tabBarItem.title = @"分类";
    UINavigationController *searchNavCon = [self navigationControllerWithStoryboardName:@"SCSearch"];
    searchNavCon.tabBarItem.image = [UIImage imageNamed:@"tab4_nor"];
    searchNavCon.tabBarItem.title = @"搜索";
    
    // 5个控制器添加到tabbarcontroller中
    self.viewControllers = @[indexNavCon,bookShelfNavCon,categoryNavCon,searchNavCon];
    

    //创建tabbar的views
//    SCNewTabBarView *barView = [[SCNewTabBarView alloc] init];
//    //设置代理
//    barView.delegate = self;
//    for (int i = 0; i < self.viewControllers.count; i ++) {
//        NSString *normal = [NSString stringWithFormat:@"tab%d_nor",i+1];
//        NSString *selected = [NSString stringWithFormat:@"tab%d_sel",i+1];
//        [barView addTabBarButton:normal imageNameSelect:selected];
//    }
//
//    barView.frame = self.tabBar.bounds;
//    [self.tabBar addSubview:barView];
//    [barView initTabBarButton];
    
}

-(UINavigationController *)navigationControllerWithStoryboardName:(NSString *) name{
    // 加载storyboard文件
    UIStoryboard *board = [UIStoryboard storyboardWithName:name bundle:nil];
    // 创建初始化控制器
    UINavigationController *controller =[board instantiateInitialViewController];
    return controller;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
