//
//  SCComicRankTableCellTableViewCell.m
//  SComicReader
//
//  Created by 冰河依然在 on 2018/5/27.
//  Copyright © 2018年 shuchang. All rights reserved.
//

#import "SCComicRankTableCell.h"
#import "SCConst.h"
#import <UIImageView+WebCache.h>

@interface SCComicRankTableCell()
@property (nonatomic,weak) UIImageView *imgViewIcon;
@property (nonatomic,weak) UILabel *labelTitle;
@property (nonatomic,weak) UILabel *labelSubTitle;
@end

@implementation SCComicRankTableCell

-(void)setComic:(SCComic *)comic{
    _comic = comic;
    self.imgViewIcon.frame = CGRectMake(10, 0, 50, 60);
    
    [self.imgViewIcon sd_setImageWithURL:[NSURL URLWithString:comic.titlePicAddr] placeholderImage:[UIImage imageNamed:comicPlaceholder]];
    
    self.labelTitle.frame = CGRectMake(65, 5, 250, 30);
    self.labelTitle.text = comic.title;
    
    self.labelSubTitle.frame = CGRectMake(65, 35, 200, 20);
    self.labelSubTitle.text = comic.typeNameList;
    
}

//重写初始化方法，生成自定义cell内的veiw控件
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        //创建图片view
        UIImageView *imgView = [[UIImageView alloc] init ];
        imgView.contentMode = UIViewContentModeScaleToFill;
        
        //创建title标签
        UILabel *labelTitle = [[UILabel alloc]init];
        //设置子体大小
        labelTitle.font = [UIFont systemFontOfSize:16];
        //设置info属性内容显示1行
        labelTitle.numberOfLines = 1;
        //文字居中
        labelTitle.textAlignment = NSTextAlignmentLeft;
        
        UILabel *labelSubTitle = [[UILabel alloc]init];
        //设置子体大小
        labelSubTitle.font = [UIFont systemFontOfSize:12];
        //设置info属性内容显示1行
        labelSubTitle.numberOfLines = 1;
        //文字居中
        labelSubTitle.textAlignment = NSTextAlignmentLeft;
        labelSubTitle.textColor = [UIColor redColor];
        
        //week的属性需要在addSubview之后引用，不然引用不上
        [self.contentView addSubview:labelTitle];
        [self.contentView addSubview:labelSubTitle];
        [self.contentView addSubview:imgView];
        self.labelSubTitle = labelSubTitle;
        self.labelTitle = labelTitle;
        self.imgViewIcon = imgView;
    }
    return self;
}

+(instancetype)comicWithTableView:(UITableView *)tableView withIndexPath:(NSIndexPath *)indexPath{
    SCComicRankTableCell *cell = [tableView dequeueReusableCellWithIdentifier:comicRankCellId];
    if(cell == nil){
        cell = [[self alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:comicRankCellId];
    }
    return cell;
}

@end
