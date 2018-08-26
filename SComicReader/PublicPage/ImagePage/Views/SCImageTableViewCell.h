//
//  SCImageTableViewCell.h
//  SComicReader
//
//  Created by 冰河依然在 on 2018/5/17.
//  Copyright © 2018年 shuchang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCImage.h"
@interface SCImageTableViewCell : UITableViewCell
@property (nonatomic,strong) SCImage *image;
+(instancetype)imageWithTableView:(UITableView *)tableView withIndexPath:(NSIndexPath *)indexPath;
@end
