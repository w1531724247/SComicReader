//
//  SCComicRecommendCell.m
//  SComicReader
//
//  Created by 冰河依然在 on 2018/5/25.
//  Copyright © 2018年 shuchang. All rights reserved.
//

#import "SCRecommendHeaderView.h"
@interface SCRecommendHeaderView()
@property (nonatomic,weak) UIButton *changeBtn;
@end

@implementation SCRecommendHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        CGFloat height = self.bounds.size.height;
        CGFloat width = self.bounds.size.width;
        UILabel *txtLbl = [[UILabel alloc] init];
        txtLbl.text = @"猜你喜欢";
        txtLbl.frame = CGRectMake(10, 10, 80, height);
        txtLbl.font = [UIFont systemFontOfSize:18];
        txtLbl.textAlignment = NSTextAlignmentCenter;
        
        UIButton *changeBtn = [[UIButton alloc] init];
        changeBtn.frame = CGRectMake(width - 90, 10, 80, height);
        changeBtn.titleLabel.font = [UIFont systemFontOfSize:18];
        
        [changeBtn setTitle:@"换一换" forState:UIControlStateNormal];
        [changeBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        
        [changeBtn addTarget:self action:@selector(didClickChangeRecomend:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:changeBtn];
        [self addSubview:txtLbl];
    }
    return self;
}

-(void)didClickChangeRecomend:(UIButton *)sender{
    if ([self.delegate respondsToSelector:@selector(reloadRecommendData:)]) {
        [self.delegate reloadRecommendData:self];
    }
}

@end
