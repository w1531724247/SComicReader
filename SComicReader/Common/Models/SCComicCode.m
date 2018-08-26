//
//  SCComicType.m
//  SComicReader
//
//  Created by 冰河依然在 on 2018/5/20.
//  Copyright © 2018年 shuchang. All rights reserved.
//

#import "SCComicCode.h"

@implementation SCComicCode

+ (NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{@"ID":@"id",@"name":@"type_name"};
}
@end
