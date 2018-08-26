//
//  SCComicRecommendCell.h
//  SComicReader
//
//  Created by 冰河依然在 on 2018/5/25.
//  Copyright © 2018年 shuchang. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SCRecommendHeaderView ;
@protocol SCRecommendHeaderViewDelegate <NSObject>
-(void)reloadRecommendData:(SCRecommendHeaderView *)controller;
@end

@interface SCRecommendHeaderView : UICollectionReusableView
@property (nonatomic,weak) id<SCRecommendHeaderViewDelegate> delegate;
@end
