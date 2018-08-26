//
//  SCChapterCollectionViewCell.h
//  SComicReader
//
//  Created by 冰河依然在 on 2018/5/16.
//  Copyright © 2018年 shuchang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCComicChapter.h"
@interface SCChapterCollectionViewCell : UICollectionViewCell
@property (nonatomic,strong) SCComicChapter *chapter;

+(instancetype)cellWithCollectionView:(UICollectionView *)collectionView withIndexPath:(NSIndexPath *)indexPath;
@end
