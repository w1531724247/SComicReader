//
//  SCComicChapter.h
//  SComicReader
//
//  Created by 冰河依然在 on 2018/5/14.
//  Copyright © 2018年 shuchang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SCComicChapter : NSObject
@property (nonatomic,copy) NSString *chapterId;
@property (nonatomic,copy) NSString *comicId;
@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *isCharged;
@end
