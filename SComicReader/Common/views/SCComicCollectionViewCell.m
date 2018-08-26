//
//  SCComicCollectionViewCell.m
//  SComicReader
//
//  Created by 冰河依然在 on 2018/5/12.
//  Copyright © 2018年 shuchang. All rights reserved.
//

#import "SCComicCollectionViewCell.h"
#import <UIImageView+WebCache.h>
#import "SCConst.h"

@interface SCComicCollectionViewCell()
@property (nonatomic,weak) UIImageView *imgViewIcon;
@property (nonatomic,weak) UILabel *lblView;
@property (nonatomic,weak) UIView *coverView;
@property (nonatomic,weak) UIImageView *imageView;
@end


@implementation SCComicCollectionViewCell

-(void)setIsSelected:(Boolean)isSelected{
    _isSelected = isSelected;
    if(isSelected){
        self.imageView.image = [UIImage imageNamed:@"gou-actived"];
    }else{
        self.imageView.image = [UIImage imageNamed:@"gou"];
    }
}

/**
设置可cell为编辑状态
 */
-(void)setIsEdit:(Boolean)isEdit{
    _isEdit = isEdit;
    //防止重用coverView覆盖
    if(self.coverView != nil){
        [self.coverView removeFromSuperview];
    }
    if(self.imageView != nil){
        [self.imageView removeFromSuperview];
    }
    //点击编辑才显示遮盖
    if(isEdit){
        CGFloat width = self.contentView.bounds.size.width;
        CGFloat height = self.contentView.bounds.size.height;
        UIView *coverView = [[UIView alloc]init];
        coverView.backgroundColor = [UIColor blackColor];
        coverView.alpha = 0.5;
        coverView.frame = CGRectMake(0, 0, width, height);
        
        UIImageView *imageView = [[UIImageView alloc]init];
        imageView.frame = CGRectMake(width - 30,height -30,25,25);
        imageView.image = [UIImage imageNamed:@"gou"];
        imageView.contentMode = UIViewContentModeScaleToFill;
        [self.contentView addSubview:imageView];
        [self.contentView addSubview:coverView];
        self.coverView = coverView;
        self.imageView = imageView;
    }

}

/**
 设置frame

 */
-(void)setComic:(SCComic *)comic{
    _comic = comic;
    //设置frame
    CGFloat width = self.contentView.bounds.size.width;
    CGFloat height = self.contentView.bounds.size.height;
    self.imgViewIcon.frame = CGRectMake(0, 0, width, height * 0.9);
    self.lblView.frame = CGRectMake(0, height * 0.9, width, height *0.1);
    
    [self.imgViewIcon sd_setImageWithURL:[NSURL URLWithString:comic.titlePicAddr] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        //加载新图片，淡入淡出
        if (image && cacheType == SDImageCacheTypeNone) {
            self.imgViewIcon.alpha= 0.0;
            [UIView animateWithDuration:0.5 animations:^{
                self.imgViewIcon.alpha= 1.0;
            }];
        }
    }];
    
    self.lblView.text = comic.title ;

}


/**
 用原型cell的话此方法不执行

 */
-(instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        //创建图片view
        UIImageView *imgView = [[UIImageView alloc] init ];

        UILabel *lblView = [[UILabel alloc]init];
        //设置子体大小
        lblView.font = [UIFont systemFontOfSize:12];
        lblView.lineBreakMode =  NSLineBreakByWordWrapping;
        //设置info属性内容显示1行
        lblView.numberOfLines = 1;
        //文字居中
        lblView.textAlignment = NSTextAlignmentCenter;
        
        //week的属性需要在addSubview之后引用，不然引用不上
        [self.contentView addSubview:lblView];
        [self.contentView addSubview:imgView];
        self.imgViewIcon = imgView;
        self.lblView = lblView;
        
    }
    return self;
}


+(instancetype)cellWithCollectionView:(UICollectionView *)collectionView withIndexPath:(NSIndexPath *)indexPath withID:(NSString *)ID{
//    static NSString * const ID = @"comic_cell_id";
    SCComicCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ID forIndexPath:indexPath];
    return cell;
}
@end
