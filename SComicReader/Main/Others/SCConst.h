//
//  SCConst.h
//  SComicReader
//
//  Created by 冰河依然在 on 2018/5/20.
//  Copyright © 2018年 shuchang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**还有少数没整理完的分散在其他类里面*/

#define screenWidth [UIScreen mainScreen].bounds.size.width
#define screenHeight [UIScreen mainScreen].bounds.size.height

#define tabBarHeight self.tabBarController.tabBar.bounds.size.height

#define kNavigationBarHeight (self.navigationController.navigationBar.frame.size.height + [[UIApplication sharedApplication] statusBarFrame].size.height)

//#define menuViewHeight 44 //切换controller的bar的高度
#define menuViewHeight screenHeight*0.066

//#define deleteViewHeight 50 //书架的删除栏高度
#define deleteViewHeight screenHeight*0.075

//#define scrollViewHeight 250 //首页的scrollView高度
#define scrollViewHeight screenHeight*0.37

//#define categoryViewHeight 65 //首页的类目栏高度
#define categoryViewHeight screenHeight*0.1

//#define kWMHeaderViewHeight 200 //漫画详情页面的头部图片高度
#define kWMHeaderViewHeight screenHeight*0.3

//#define chapterHisViewHeight 40 //漫画章节页面的历史记录栏高度
#define chapterHisViewHeight screenHeight*0.06

#define tableViewWidth 86 //分类页面左边分类tableView的宽度

//#define headerHeight 140 //类目页面的头部的collectionview的高度
#define headerHeight screenHeight*0.21


#define pageCount 30  //分页条数

UIKIT_EXTERN  NSString * const rootUrl;
UIKIT_EXTERN  NSString * const comicCellId;
UIKIT_EXTERN  NSString * const comicHeaderCellId;
UIKIT_EXTERN  NSString * const comicTypeCellId;
UIKIT_EXTERN  NSString * const comicInfoHeaderCellId;
UIKIT_EXTERN  NSString * const recomendHeaderCellId;
UIKIT_EXTERN  NSString * const comicRankCellId;
UIKIT_EXTERN  NSString * const chapterCellId;
UIKIT_EXTERN  NSString * const comicPlaceholder;
UIKIT_EXTERN  NSString * const domainUrl; //域名


