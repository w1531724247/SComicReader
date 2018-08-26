//
//  SCComicRankTableCellTableViewCell.h
//  SComicReader
//
//  Created by 冰河依然在 on 2018/5/27.
//  Copyright © 2018年 shuchang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCComic.h"
@interface SCComicRankTableCell : UITableViewCell
@property (nonatomic,strong) SCComic *comic;

+(instancetype)comicWithTableView:(UITableView *)tableView withIndexPath:(NSIndexPath *)indexPath;
@end
