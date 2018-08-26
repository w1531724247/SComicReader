//
//  SCComicGroup.m
//  SComicReader
//
//  Created by 冰河依然在 on 2018/5/4.
//  Copyright © 2018年 shuchang. All rights reserved.
//

#import "SCComicGroup.h"
#import "SCComic.h"
@implementation SCComicGroup


/**
对应数组下的模型类型
 */
+(NSDictionary *)mj_objectClassInArray
{
    return @{
             @"comics" : @"SCComic"
             };
}

/**
 对应模型和字典的字段名称
 */
+ (NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{@"name":@"recommend_title",@"comics":@"content"};
}


-(instancetype)initWithDict:(NSDictionary *)dict{
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dict];
        
        NSMutableArray *arrayM = [NSMutableArray array];
        for (NSDictionary *dict in self.comics) {
            SCComic *comic = [SCComic comicWithDict:dict];
            [arrayM addObject:comic];
        }
        self.comics = arrayM.copy;
    }
    return self;
}

+(instancetype)comicGroupWithDict:(NSDictionary *)dict{
    return [[self alloc] initWithDict:dict];
}
@end
