//
//  SCComic.h
//  SComicReader
//
//  Created by 冰河依然在 on 2018/4/29.
//  Copyright © 2018年 shuchang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SCComic : NSObject
@property (nonatomic,copy) NSString *ID;
@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *titlePicAddr;
@property (nonatomic,copy) NSString *brief;
@property (nonatomic,copy) NSString *typeNameList;

/**
使用了mj以后弃用
 */
-(instancetype)initWithDict:(NSDictionary *)dict;
+(instancetype)comicWithDict:(NSDictionary *)dict;
@end
