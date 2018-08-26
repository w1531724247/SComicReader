//
//  SCNavBaseController.m
//  SComicReader
//
//  Created by 冰河依然在 on 2018/4/29.
//  Copyright © 2018年 shuchang. All rights reserved.
//

#import "SCNavBaseController.h"

@interface SCNavBaseController ()

@end

@implementation SCNavBaseController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    //修改进入子控制器后隐藏tabbar栏
    viewController.hidesBottomBarWhenPushed = YES;
    [super pushViewController:viewController animated:animated];
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
