//
//  SCPrompt.m
//  SComicReader
//
//  Created by 冰河依然在 on 2018/5/21.
//  Copyright © 2018年 shuchang. All rights reserved.
//

#import "SCPrompt.h"
#import <MBProgressHUD.h>
@interface SCPrompt()
@property (nonatomic,weak) MBProgressHUD *hud;
@end
@implementation SCPrompt
+(void)showTips:(UIView *)superView withContent:(NSString *)content{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:superView animated:YES];
    //显示文字，默认菊花
    //    hud.mode = MBProgressHUDModeText;
    hud.label.text = NSLocalizedString(content, @"HUD loading title");
    //n秒后隐藏
    [hud hideAnimated:YES afterDelay:0.8];
    hud.removeFromSuperViewOnHide = YES;
}

+(void)showText:(UIView *)superView withContent:(NSString *)content{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:superView animated:YES];
    //显示文字，默认菊花
    hud.mode = MBProgressHUDModeText;
    hud.label.text = NSLocalizedString(content, @"HUD loading title");
    //n秒后隐藏
    [hud hideAnimated:YES afterDelay:1.2];
    hud.removeFromSuperViewOnHide = YES;
}


//-(void)showLoading:(UIView *)superView withContent:(NSString *)content{
//    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:superView animated:YES];
//    hud.label.text = NSLocalizedString(content, @"HUD loading title");
//    self.hud = hud;
//}




@end
