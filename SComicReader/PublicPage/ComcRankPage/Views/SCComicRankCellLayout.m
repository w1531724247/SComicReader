//
//  SCCellLayout.m
//  collectionViews使用032
//
//  Created by 冰河依然在 on 2017/12/25.
//  Copyright © 2017年 冰河依然在. All rights reserved.
//

#import "SCComicRankCellLayout.h"

@implementation SCComicRankCellLayout
-(void)prepareLayout{
    [super prepareLayout];
}

//当bounds发生改变时是否重新布局
-(BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds{
    return YES;
}

-(NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect{
    NSArray *attrs = [[NSArray alloc] initWithArray:[super layoutAttributesForElementsInRect:rect] copyItems:YES];
    //屏幕中心的x值
    CGFloat centerViewX = self.collectionView.contentOffset.x + self.collectionView.bounds.size.width * 0.5;
    for (UICollectionViewLayoutAttributes *attr in attrs) {
        CGFloat centerX = attr.center.x;
        CGFloat distance = ABS(centerX - centerViewX);
        CGFloat factor = 0.004;
        CGFloat scale = 1 / ( 1 + distance * factor);
        
        attr.transform = CGAffineTransformMakeScale(scale, scale);
    }
    return attrs;
}

/**
 返回结束后的位置

 @param proposedContentOffset 自动滚动结束的偏移
 @param velocity 速率（point/s）
 @return 需要返回的便宜位置
 */
-(CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity{
    //1.滚动结束屏幕的center
    CGFloat centerViewX = proposedContentOffset.x + self.collectionView.bounds.size.width * 0.5;
    //2.滚动结束的屏幕内的UICollectionViewLayoutAttributes集合
    CGFloat visibleX = proposedContentOffset.x;
    CGFloat visibleY = proposedContentOffset.y;
    CGFloat visibleW = self.collectionView.bounds.size.width;
    CGFloat visibleH = self.collectionView.bounds.size.height;

    CGRect visibleRect = CGRectMake(visibleX, visibleY, visibleW, visibleH);
    //得到当前可视的属性集合
    NSArray *attrs = [super layoutAttributesForElementsInRect:visibleRect];
    //3.计算最小离屏幕center的最小偏移量
    CGFloat minX = ((UICollectionViewLayoutAttributes *)attrs[0]).center.x;
    for (int i = 1; i < attrs.count; i ++) {
        UICollectionViewLayoutAttributes *attr = attrs[i];
        if (ABS(minX - centerViewX) > ABS(attr.center.x - centerViewX) ) {
            minX = attr.center.x;
        }
    }
    //4.返回结果
    //实际偏移量
    CGFloat offSet = minX - centerViewX;
    return CGPointMake(proposedContentOffset.x + offSet, proposedContentOffset.y);
}


@end
