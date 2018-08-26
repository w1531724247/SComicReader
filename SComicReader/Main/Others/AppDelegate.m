//
//  AppDelegate.m
//  SComicReader
//
//  Created by 冰河依然在 on 2018/4/7.
//  Copyright © 2018年 shuchang. All rights reserved.
//

#import "AppDelegate.h"
#import "SCMainTabBarController.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    //1.创建uiwindow
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];

    //2.创建uitablebarcontroller
    SCMainTabBarController *mainCon = [[SCMainTabBarController alloc]init];

    //3.设置uiwindow的根控制器
    self.window.rootViewController = mainCon;
    
    //3.1设置全局默认外观
    [self setNavigationBarStyle];

    //3.2显示状态栏，启动的时候隐藏状态栏，显示图片
    [[UIApplication sharedApplication] setStatusBarHidden:NO];

    //4.设置window为主窗口并显示
    [self.window makeKeyAndVisible];
    return YES;
}


-(void)setNavigationBarStyle{
    //1.获取外观代理
    UINavigationBar *bar = [UINavigationBar appearance];
    //2.统一设置外观效果
    bar.backgroundColor = [UIColor whiteColor];
}



- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
