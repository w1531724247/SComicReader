//
//  CollectionReusableView.h
//  SComicReader
//
//  Created by 冰河依然在 on 2018/5/11.
//  Copyright © 2018年 shuchang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCComicGroup.h"
@interface SCCollectionHeaderView : UICollectionReusableView

@property (nonatomic,strong) SCComicGroup *comicGroup;
@end
