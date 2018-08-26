//
//  SCChapterCollectionViewCell.m
//  SComicReader
//
//  Created by 冰河依然在 on 2018/5/16.
//  Copyright © 2018年 shuchang. All rights reserved.
//

#import "SCChapterCollectionViewCell.h"
#import "SCConst.h"

@interface SCChapterCollectionViewCell()
@property (nonatomic,weak) UIButton *btn;
@property (nonatomic,weak) UILabel *lbl;
@end

@implementation SCChapterCollectionViewCell

-(void)setChapter:(SCComicChapter *)chapter{
    _chapter = chapter;
    self.lbl.text = chapter.name;
//    [self.btn setTitle:chapter.name forState: UIControlStateNormal];
}

-(instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
//        UIButton *btn = [[UIButton alloc]init];
//
//        btn.frame = CGRectMake(0, 0, self.contentView.bounds.size.width, self.contentView.bounds.size.height);
//        btn.userInteractionEnabled = NO;
//        //设置子体大小
//        btn.titleLabel.font = [UIFont systemFontOfSize:11];
//        //设置info属性内容显示1行
//        btn.titleLabel.numberOfLines = 1;
//        //多余截断不要省略号
//        btn.titleLabel.lineBreakMode =  NSLineBreakByTruncatingTail;
//        //文字居中
//        btn.titleLabel.textAlignment = NSTextAlignmentCenter;
//        [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
//
//        [btn.layer setCornerRadius:8];
//        [btn.layer setBorderWidth:1.0]; //边框宽度
//        [btn.layer setBorderColor:[UIColor grayColor].CGColor];
//
//
//        [self.contentView addSubview:btn];
//        //week的属性需要在addSubview之后引用，不然引用不上
//        self.btn = btn;

        UILabel *lbl = [[UILabel alloc]init];
        lbl.frame = CGRectMake(2, 0, self.contentView.bounds.size.width-4, self.contentView.bounds.size.height);
        
        lbl.font = [UIFont systemFontOfSize:11];
        //设置info属性内容显示2行
        lbl.numberOfLines = 2;
        //多余截断不要省略号
        lbl.lineBreakMode =  NSLineBreakByWordWrapping;
        //文字居中
        lbl.textAlignment = NSTextAlignmentCenter;
        lbl.textColor = [UIColor grayColor];
        
        [self.contentView.layer setCornerRadius:8];
        [self.contentView.layer setBorderWidth:1.0]; //边框宽度
        [self.contentView.layer setBorderColor:[UIColor grayColor].CGColor];
        [self.contentView addSubview:lbl];
        self.lbl = lbl;
    }
    return self;
}

+(instancetype)cellWithCollectionView:(UICollectionView *)collectionView withIndexPath:(NSIndexPath *)indexPath{
    SCChapterCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:chapterCellId forIndexPath:indexPath];
    return cell;
}
@end
