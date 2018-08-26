//
//  SCScrollVIew.m
//  SComicReader
//
//  Created by 冰河依然在 on 2018/5/5.
//  Copyright © 2018年 shuchang. All rights reserved.
//

#import "SCScrollView.h"
#import "SCConst.h"
@interface SCScrollView ()
@property (nonatomic,strong) SCScrollView *scrollView;
@end
@implementation SCScrollView
@dynamic delegate;
-(instancetype)initWithScrollView:(NSArray *)imageUrls withFrame:(CGRect)scrollViewFrame{
    SCScrollView *scrollView = [SCScrollView cycleScrollViewWithFrame:scrollViewFrame imageURLStringsGroup:imageUrls];
    
    
    //设置图片视图显示类型
    scrollView.bannerImageViewContentMode = UIViewContentModeScaleAspectFill;
    
//    scrollView.placeholderImage = [UIImage imageNamed:comicPlaceholder];
    
    //设置轮播视图的分页控件的显示
    scrollView.showPageControl = YES;
    
    //设置轮播视图控件的位置
    scrollView.pageControlAliment = SDCycleScrollViewPageContolAlimentCenter;
    
    //当前分页控件小圆标图片
    scrollView.pageDotImage = [UIImage imageNamed:@"pageCon.png"];
    
    //其他分页控件小圆标图片
    scrollView.currentPageDotImage = [UIImage imageNamed:@"pageConSel.png"];
    
    return scrollView;
}


+(instancetype)getScrollView:(NSArray *)imageUrls withFrame:(CGRect)scrollViewFrame{
    return [[self alloc] initWithScrollView:imageUrls withFrame:scrollViewFrame] ;
}


@end
