//
//  SCComic.m
//  SComicReader
//
//  Created by 冰河依然在 on 2018/4/29.
//  Copyright © 2018年 shuchang. All rights reserved.
//

#import "SCComic.h"

@implementation SCComic

-(instancetype)initWithDict:(NSDictionary *)dict{
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}

+(instancetype)comicWithDict:(NSDictionary *)dict{
    return [[self alloc] initWithDict:dict];
}

/**
 对应模型和字典的字段名称
 */
+ (NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{@"ID":@"id",@"titlePicAddr":@"title_pic_addr",@"title":@"title",@"brief":@"brief",@"typeNameList":@"type_name_list"};
}

@end
