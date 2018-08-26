//
//  SCComicViewController.h
//  SComicReader
//
//  Created by 冰河依然在 on 2018/5/23.
//  Copyright © 2018年 shuchang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WMPageController.h>
@interface SCComicViewController : WMPageController
@property (nonatomic,copy) NSString *ID;
@property (nonatomic,copy) NSString *titlePicAddr;
@end
