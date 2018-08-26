//
//  SCComicTip.m
//  SComicReader
//
//  Created by 冰河依然在 on 2018/8/26.
//  Copyright © 2018年 shuchang. All rights reserved.
//

#import "SCComicTip.h"

@implementation SCComicTip
/**
 对应模型和字典的字段名称
 */
+ (NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{@"ID":@"id",@"word":@"word",@"freq":@"freq"};
}
@end

