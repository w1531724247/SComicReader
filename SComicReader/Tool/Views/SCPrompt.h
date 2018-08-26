//
//  SCPrompt.h
//  SComicReader
//
//  Created by 冰河依然在 on 2018/5/21.
//  Copyright © 2018年 shuchang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SCPrompt : NSObject
+(void)showTips:(UIView *)superView withContent:(NSString *)content;
+(void)showText:(UIView *)superView withContent:(NSString *)content;
@end
