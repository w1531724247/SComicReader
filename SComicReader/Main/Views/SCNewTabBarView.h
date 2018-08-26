//
//  SCNewTabBarView.h
//  彩票案例
//
//  Created by 冰河依然在 on 2018/2/3.
//  Copyright © 2018年 冰河依然在. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SCNewTabBarView ;
@protocol SCNewTabBarViewDelegate <NSObject>
-(void)tabBarButtonSwitch:(SCNewTabBarView *)newTabBarView didClickTabBarButtonIndex:(int)index;
@end

@interface SCNewTabBarView : UIView
-(void)addTabBarButton:(NSString *) imageName imageNameSelect:(NSString *)imageNameSelect;
@property (nonatomic,weak) id<SCNewTabBarViewDelegate> delegate;

-(void) initTabBarButton;
@end
