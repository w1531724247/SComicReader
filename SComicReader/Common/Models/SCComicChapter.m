
//
//  SCComicChapter.m
//  SComicReader
//
//  Created by 冰河依然在 on 2018/5/14.
//  Copyright © 2018年 shuchang. All rights reserved.
//

#import "SCComicChapter.h"

@implementation SCComicChapter
+ (NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{@"comicId":@"id",@"chapterId":@"chapter_id",@"name":@"chapter_name",@"isCharged":@"is_charged"};
}
@end
