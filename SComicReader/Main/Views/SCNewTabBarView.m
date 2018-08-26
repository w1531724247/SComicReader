//
//  SCNewTabBarView.m
//  彩票案例
//
//  Created by 冰河依然在 on 2018/2/3.
//  Copyright © 2018年 冰河依然在. All rights reserved.
//

#import "SCNewTabBarView.h"
#import "SCTabBarButton.h"
@interface SCNewTabBarView()
//@property (nonatomic,strong) NSArray *tabBarButtons;
@property (nonatomic,weak) UIButton *selectedBtn;
@end


@implementation SCNewTabBarView

-(void)addTabBarButton:(NSString *) imageName imageNameSelect:(NSString *)imageNameSelect{
    SCTabBarButton *btn = [[SCTabBarButton alloc] init];
    
    [btn setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:imageNameSelect] forState:UIControlStateSelected];
    //切换子控制器，增加tabbar按钮的单击事件
    [btn addTarget:self action:@selector(didClickTabBarButton:) forControlEvents:UIControlEventTouchDown];
    [self addSubview:btn];
}

-(void)didClickTabBarButton:(UIButton *)sender{
    //设置按下切换效果
    self.selectedBtn.selected = NO;
    sender.selected = YES;
    self.selectedBtn = sender;
    
    //1.获取当前btn的索引
    int index = (int)sender.tag;

    //2.点击按钮进行切换,由于切换需要在tabbarcontroller中，所以需要设置代理
    if ([self.delegate respondsToSelector:@selector(tabBarButtonSwitch:didClickTabBarButtonIndex:)]) {
        [self.delegate tabBarButtonSwitch:self didClickTabBarButtonIndex:index];
    }
    
}

//-(NSArray *)tabBarButtons{
//    if (_tabBarButtons == nil) {
//        NSMutableArray *array = [NSMutableArray array];
//        for (int i = 0; i < 5; i ++) {
//            UIButton *btn = [[UIButton alloc] init];
//            NSString *normal = [NSString stringWithFormat:@"tabBar%d",i+1];
//            NSString *selected = [NSString stringWithFormat:@"tabBar%dSel",i+1];
//            [btn setBackgroundImage:[UIImage imageNamed:normal] forState:UIControlStateNormal];
//            [btn setBackgroundImage:[UIImage imageNamed:selected] forState:UIControlStateSelected];
//
//            [self addSubview:btn];
//            [array addObject:btn];
//        }
//        _tabBarButtons = array.copy;
//    }
//    return _tabBarButtons;
//}


/**
 手动调用，放在layoutSubviews导致返回的时候，第一个也被选中，
 */
-(void) initTabBarButton{

    CGFloat w = self.bounds.size.width / self.subviews.count;
    CGFloat h = self.bounds.size.height;
    CGFloat y = 0;
    for (int i = 0; i < self.subviews.count; i ++) {
        CGFloat x = i * w;
        UIButton *btn = self.subviews[i];
        btn.tag = i;
        btn.frame = CGRectMake(x, y, w, h);
        if (i == 0) {
            btn.selected = YES;
            self.selectedBtn = btn;
        }
    }
}

/**
 设置按钮的frame
 */
-(void)layoutSubviews{
    [super layoutSubviews];
//    CGFloat w = self.bounds.size.width / self.subviews.count;
//    CGFloat h = self.bounds.size.height;
//    CGFloat y = 0;
//    for (int i = 0; i < self.subviews.count; i ++) {
//        CGFloat x = i * w;
//        UIButton *btn = self.subviews[i];
//        btn.tag = i;
//        btn.frame = CGRectMake(x, y, w, h);
//        if (i == 0) {
//            btn.selected = YES;
//            self.selectedBtn = btn;
//        }
//    }
}
@end


