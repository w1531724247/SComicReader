//
//  SCComicCollectionViewCell.h
//  SComicReader
//
//  Created by 冰河依然在 on 2018/5/12.
//  Copyright © 2018年 shuchang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCComic.h"
@interface SCComicCollectionViewCell : UICollectionViewCell
@property (nonatomic,strong) SCComic *comic;
@property (nonatomic,assign) Boolean isEdit;
@property (nonatomic,assign) Boolean isSelected;
+(instancetype)cellWithCollectionView:(UICollectionView *)collectionView withIndexPath:(NSIndexPath *)indexPath withID:(NSString *)ID;
@end
