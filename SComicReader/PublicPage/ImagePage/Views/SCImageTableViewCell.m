//
//  SCImageTableViewCell.m
//  SComicReader
//
//  Created by 冰河依然在 on 2018/5/17.
//  Copyright © 2018年 shuchang. All rights reserved.
//

#import "SCImageTableViewCell.h"
#import <Masonry.h>
#import <UIImageView+WebCache.h>

@interface SCImageTableViewCell()
@property (nonatomic,weak) UIImageView *imgView;
@end

@implementation SCImageTableViewCell

-(void)setImage:(SCImage *)image{
    _image = image;
    NSString *imageUrl = image.imageAddr;
    
    [self.imgView sd_setImageWithURL:[NSURL URLWithString:imageUrl] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        //加载新图片，淡入淡出
        if (image && cacheType == SDImageCacheTypeNone) {
            self.imgView.alpha= 0.0;
            [UIView animateWithDuration:0.5 animations:^{
                self.imgView.alpha= 1.0;
            }];
        }
    }];
    
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        UIImageView *imgView = [[UIImageView alloc] init ];
        [self.contentView addSubview:imgView];
        
        [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.bottom.equalTo(self.contentView);
        }];
        self.imgView = imgView;
        
    }
    return self;
}

+(instancetype)imageWithTableView:(UITableView *)tableView withIndexPath:(NSIndexPath *)indexPath{
    static NSString * const ID = @"image_cell_id";
    SCImageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    //手动创建了
    if(cell == nil){
        //自定义cell
        cell = [[self alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    return cell;
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
