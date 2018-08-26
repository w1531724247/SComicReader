//
//  SCScrollVIew.h
//  SComicReader
//
//  Created by 冰河依然在 on 2018/5/5.
//  Copyright © 2018年 shuchang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SDCycleScrollView.h>
@protocol SCScrollViewDelegate <NSObject,SDCycleScrollViewDelegate>
@end

@interface SCScrollView : SDCycleScrollView
@property (nonatomic, weak) id<SCScrollViewDelegate> delegate;
-(instancetype)initWithScrollView:(NSArray *)imageUrls withFrame:(CGRect)scrollViewFrame;
+(instancetype)getScrollView:(NSArray *)imageUrls withFrame:(CGRect)scrollViewFrame;
@end
