//
//  SCComicGroup.h
//  SComicReader
//
//  Created by 冰河依然在 on 2018/5/4.
//  Copyright © 2018年 shuchang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SCComicGroup : NSObject
@property (nonatomic,copy) NSString *name;
@property (nonatomic,strong) NSArray *comics;

/**
 使用了mj以后弃用
 */
-(instancetype)initWithDict:(NSDictionary *)dict;
+(instancetype)comicGroupWithDict:(NSDictionary *)dict;
@end
