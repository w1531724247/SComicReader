//
//  XPCollectionViewWaterfallFlowLayout.h
//  SComicReader
//
//  Created by 冰河依然在 on 2018/5/11.
//  Copyright © 2018年 shuchang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SCWaterfallFlowLayout;
@protocol SCWaterfallFlowLayoutDataSource;


#pragma mark -

@interface SCWaterfallFlowLayout : UICollectionViewLayout

@property (nonatomic, weak) IBOutlet id<SCWaterfallFlowLayoutDataSource> dataSource;

@property (nonatomic, assign) CGFloat minimumLineSpacing; // default 0.0
@property (nonatomic, assign) CGFloat minimumInteritemSpacing; // default 0.0
@property (nonatomic, assign) IBInspectable BOOL sectionHeadersPinToVisibleBounds; // default NO
//@property (nonatomic, assign) IBInspectable BOOL sectionFootersPinToVisibleBounds;

@end


#pragma mark -

@protocol SCWaterfallFlowLayoutDataSource<NSObject>

@required
/// Return per section's column number(must be greater than 0).
- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(SCWaterfallFlowLayout*)layout numberOfColumnInSection:(NSInteger)section;
/// Return per item's height
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(SCWaterfallFlowLayout*)layout itemWidth:(CGFloat)width
 heightForItemAtIndexPath:(NSIndexPath *)indexPath;

@optional
/// Column spacing between columns
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(SCWaterfallFlowLayout*)layout minimumLineSpacingForSectionAtIndex:(NSInteger)section;
/// The spacing between rows and rows
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(SCWaterfallFlowLayout*)layout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section;
///
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(SCWaterfallFlowLayout*)layout insetForSectionAtIndex:(NSInteger)section;
/// Return per section header view height.
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(SCWaterfallFlowLayout*)layout referenceHeightForHeaderInSection:(NSInteger)section;
/// Return per section footer view height.
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(SCWaterfallFlowLayout*)layout referenceHeightForFooterInSection:(NSInteger)section;

@end
