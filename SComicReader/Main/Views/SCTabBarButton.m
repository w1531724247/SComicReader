//
//  SCTabBarButton.m
//  彩票案例2
//
//  Created by 冰河依然在 on 2018/2/6.
//  Copyright © 2018年 冰河依然在. All rights reserved.
//

#import "SCTabBarButton.h"

@implementation SCTabBarButton
//由于默认的button按下会有hightlighted效果，而selected效果和hightlighted效果同时出现会有点问题，重写去掉hightlighted效果
-(void)setHighlighted:(BOOL)highlighted{
    
}


- (CGRect)imageRectForContentRect:(CGRect)bounds{
    return CGRectMake(0.0, 0.0, self.bounds.size.width * 0.7, self.bounds.size.height * 0.7);
}



@end
