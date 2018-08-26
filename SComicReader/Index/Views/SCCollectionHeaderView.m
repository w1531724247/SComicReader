//
//  CollectionReusableView.m
//  SComicReader
//
//  Created by 冰河依然在 on 2018/5/11.
//  Copyright © 2018年 shuchang. All rights reserved.
//

#import "SCCollectionHeaderView.h"
@interface SCCollectionHeaderView()
@property(nonatomic, weak) UILabel *textLabel;
@end

@implementation SCCollectionHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UILabel *txtLbl = [[UILabel alloc] init];
        txtLbl.frame = self.bounds;
        [self addSubview:txtLbl];
        self.textLabel = txtLbl;
    }
    return self;
}

-(void)setComicGroup:(SCComicGroup *)comicGroup{
    self.textLabel.text = [NSString stringWithFormat:@"%@",comicGroup.name];
    //文字居中
    self.textLabel.textAlignment = NSTextAlignmentCenter;
}

@end

