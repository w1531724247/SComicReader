//
//  SCImageViewController.h
//  SComicReader
//
//  Created by 冰河依然在 on 2018/5/17.
//  Copyright © 2018年 shuchang. All rights reserved.
//

#import "SCBaseViewController.h"
#import "SCComicChapter.h"
@interface SCImageViewController : SCBaseViewController
@property (nonatomic,strong) SCComicChapter *chapter;
//为了翻页保存章节记录使用
@property (nonatomic,strong) NSArray *chapters;
@end
