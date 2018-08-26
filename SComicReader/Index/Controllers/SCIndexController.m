//
//  SCIndexController.m
//  SComicReader
//
//  Created by 冰河依然在 on 2018/4/29.
//  Copyright © 2018年 shuchang. All rights reserved.
//

#import "SCIndexController.h"
#import "SCComicGroup.h"
#import "SCComic.h"
#import "SCScrollView.h"
#import "SCNetWorkManager.h"
#import "SCWaterfallFlowLayout.h"
#import "SCCollectionHeaderView.h"
#import "SCComicCollectionViewCell.h"
#import <MJExtension.h>
#import <Masonry.h>
#import "SCComicInfoViewController.h"
#import "SCComicChapterViewController.h"
#import "SCComicRankViewController.h"
#import "SCConst.h"
#import <MJRefresh.h>
#import "SCPrompt.h"
#import "SCComicViewController.h"
#import "LSPaoMaView.h"

@interface SCIndexController ()<SCScrollViewDelegate,SCWaterfallFlowLayoutDataSource,UICollectionViewDataSource,UICollectionViewDelegate>
@property (nonatomic,strong) NSArray *comicGroups;
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic)  UIView *categoryView;
@property (strong, nonatomic)  SCScrollView *scrollView;

@property (nonatomic,strong) NSArray *comicSwiper;
//@property (nonatomic,strong)  NSDictionary *indexPageResponse;
@end

@implementation SCIndexController
/**
 问题1：修改漫画排序下面的图片变化
 
 后续：搜索tab下面添加搜索框
 */
- (void)viewDidLoad {
    [super viewDidLoad];

    //初始化view
    [self initView];
    
    //下拉刷新
    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(updateData)];
    //由于scrollView的frame在collectionView中高为负，需要把headerView放到scrollView上面去
    self.collectionView.mj_header.ignoredScrollViewContentInsetTop = (scrollViewHeight+categoryViewHeight);
    //请求首页数据
    [self requestIndexData];
    
    //请求通知信息
    [self requestNotification];
    
}


/**
 请求通知信息
 */
-(void)requestNotification{
    NSString *indexUrl = [NSString stringWithFormat:@"%@/comic-notification/",domainUrl];
    
    SCNetWorkManager *manager = [SCNetWorkManager sharedManager];
    [manager requestWithMethod:GET withUrl:indexUrl withParams:nil withSuccessBlock:^(id response) {
        NSString *notificationText = response[@"content"];
        
        //如果数据库中插入为空字符串则不创建通知框
        if(![notificationText isEqual:[NSNull null]]){
            //去掉空格
            if(![[notificationText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""] ){
                [self createScrollText:notificationText];
            }
        }

        
    } withFailurBlock:^(NSError *error) {
        [SCPrompt showTips:self.view withContent:@"网络加载出错，请重试..."];
        
    }];
}

/**
 得到滚动通知字幕
 */
-(void)createScrollText:(NSString *)notificationText{
    LSPaoMaView* paomav = [[LSPaoMaView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 40) title:notificationText];
    [self.view addSubview:paomav];
}


/**
 下拉刷新更新数据
 */
-(void)updateData{
    [self requestIndexData];
}

#pragma -mark 初始化操作

/**
 初始化类别的view
 */
-(void)initCategoryView:(UIView *)superView{
    //创建类别的view
    UIView *categoryView = [[UIView alloc] init];
    
//    使用contentInset后，设置约束有问题
//    [categoryView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.right.equalTo(superView);
//        make.height.mas_equalTo(categoryViewHeight);
//        make.top.equalTo(superView).offset(-100);
//    }];
    
    //设置frame
    categoryView.frame = CGRectMake(0, -categoryViewHeight, screenWidth, categoryViewHeight);
    [superView addSubview:categoryView];
    
    //创建按钮
    UIButton *rankBookBtn = [[UIButton alloc] init];
    UIButton *newBookBtn = [[UIButton alloc] init];
    UIButton *freeBookBtn = [[UIButton alloc] init];
    [rankBookBtn setBackgroundImage:[UIImage imageNamed:@"book-rank"] forState:UIControlStateNormal];
    [newBookBtn setBackgroundImage:[UIImage imageNamed:@"book-update"] forState:UIControlStateNormal];
    [freeBookBtn setBackgroundImage:[UIImage imageNamed:@"book-free"] forState:UIControlStateNormal];
    
    UILabel *rankBookLabel = [[UILabel alloc] init];
    UILabel *newkBookLabel = [[UILabel alloc] init];
    UILabel *freeBookLabel = [[UILabel alloc] init];
    rankBookLabel.text = @"排行榜";
    newkBookLabel.text = @"新书榜";
    freeBookLabel.text = @"精选榜";
    
    rankBookLabel.adjustsFontSizeToFitWidth = YES;
    newkBookLabel.adjustsFontSizeToFitWidth = YES;
    freeBookLabel.adjustsFontSizeToFitWidth = YES;
    
    [categoryView addSubview:rankBookLabel];
    [categoryView addSubview:newkBookLabel];
    [categoryView addSubview:freeBookLabel];
    
    [categoryView addSubview:rankBookBtn];
    [categoryView addSubview:newBookBtn];
    [categoryView addSubview:freeBookBtn];
    
    //btn
    [newBookBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(categoryView);
        make.top.mas_equalTo(5);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];

    [rankBookBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(categoryView).offset(40);
        make.top.equalTo(newBookBtn.mas_top);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];

    [freeBookBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(categoryView).offset(-40);
        make.top.equalTo(newBookBtn.mas_top);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    
    //label
    [newkBookLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(newBookBtn);
        make.top.equalTo(newBookBtn.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(40, 10));
    }];
    
    [rankBookLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(rankBookBtn);
        make.top.equalTo(rankBookBtn.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(40, 10));
    }];

    [freeBookLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(freeBookBtn);
        make.top.equalTo(freeBookBtn.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(40, 10));
    }];
    
    //设置点击事件
    rankBookBtn.tag = 1;
    newBookBtn.tag = 2;
    freeBookBtn.tag = 3;
    [rankBookBtn addTarget:self action:@selector(didClickRankButton:) forControlEvents:UIControlEventTouchUpInside];
    [freeBookBtn addTarget:self action:@selector(didClickRankButton:) forControlEvents:UIControlEventTouchUpInside];
    [newBookBtn addTarget:self action:@selector(didClickRankButton:) forControlEvents:UIControlEventTouchUpInside];
    
    self.categoryView = categoryView;
}


/**
跳转到漫画排序的页面
 */
-(void)didClickRankButton:(UIButton *)sender{
//    UIStoryboard *mainStory = [UIStoryboard storyboardWithName:@"SCComic" bundle:nil];
//    SCComicRankViewController *comicRankController = [mainStory instantiateViewControllerWithIdentifier:@"comicRank"];
    SCComicRankViewController *comicRankController = [[SCComicRankViewController alloc]init];
    comicRankController.title = sender.titleLabel.text;
    comicRankController.type = (int)sender.tag;
    [self.navigationController pushViewController:comicRankController animated:YES];
}

/**
 初始化scrollview
 */
-(void)initScrollView:(UIView *)superView{
    //由于放在scrollView里面了，不使用自动布局约束
    CGRect frame = CGRectMake(0, -(categoryViewHeight + scrollViewHeight), screenWidth, scrollViewHeight);
    SCScrollView *scrollView = [SCScrollView getScrollView:nil withFrame:frame];
    
    //    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.left.top.right.equalTo(superView);
    //        make.height.mas_equalTo(scrollViewHeight);
    //    }];
    //更新frame,不然目前frame还没值,后续无使用frame情况已取消使用
    //[scrollView.superview layoutIfNeeded];
    
    //由于图片还没加载的时候有灰色，所以改为白色背景一样的白色
    scrollView.backgroundColor = [UIColor whiteColor];
    //设置代理
    scrollView.delegate = self;
    [superView addSubview:scrollView];
    self.scrollView = scrollView;
}


/**
 初始化控件
 */
-(void)initView{
    //创建布局对象
    SCWaterfallFlowLayout *layout = [[SCWaterfallFlowLayout alloc]init];
    //创建collectionview
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight) collectionViewLayout:layout];
    /**用了autoresizingMask后不用减去64*/
    collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight ;
    //背景自带黑色，需要设置
    collectionView.backgroundColor = [UIColor whiteColor];
    
    //添加header和category视图
    [self initScrollView:collectionView];
    [self initCategoryView:collectionView];
    
    layout.dataSource = self;
    collectionView.dataSource = self;
    collectionView.delegate = self;
    //注册headerview
    [collectionView registerClass:[SCCollectionHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:comicHeaderCellId];
    //注册cell
    [collectionView registerClass:[SCComicCollectionViewCell class] forCellWithReuseIdentifier:comicCellId];
    
    collectionView.contentInset = UIEdgeInsetsMake(scrollViewHeight+categoryViewHeight, 0, 0, 0);
    
    [self.view addSubview:collectionView];
    self.collectionView = collectionView;

}




#pragma -mark waterfull的数据源方法

- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(SCWaterfallFlowLayout *)layout numberOfColumnInSection:(NSInteger)section {
    return  3;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(SCWaterfallFlowLayout *)layout itemWidth:(CGFloat)width heightForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.collectionView.bounds.size.width / 2 ;
}

//- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(SCWaterfallFlowLayout *)layout insetForSectionAtIndex:(NSInteger)section {
//    return UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0);
//}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(SCWaterfallFlowLayout*)layout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 10.0;
}
//
//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(SCWaterfallFlowLayout*)layout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
//    return 10.0;
//}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(SCWaterfallFlowLayout *)layout referenceHeightForHeaderInSection:(NSInteger)section {
    return 40.0;
}
//
//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(SCWaterfallFlowLayout *)layout referenceHeightForFooterInSection:(NSInteger)section {
//    return 40.0;
//}


#pragma -mark collectionView代理方法

/**
 可重用headerView
 */
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    SCCollectionHeaderView *headerView = (SCCollectionHeaderView *)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:comicHeaderCellId forIndexPath:indexPath];
    SCComicGroup *comicGroup = self.comicGroups[indexPath.section];
    headerView.comicGroup = comicGroup;
    return headerView;
}

/**
点击cell
 */
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    SCComicGroup *comicGroup = self.comicGroups[indexPath.section];
    SCComic *comic = comicGroup.comics[indexPath.row];

    SCComicViewController *comicController = [[SCComicViewController alloc] init];
    comicController.ID = comic.ID;
    comicController.titlePicAddr = comic.titlePicAddr;
    comicController.title = comic.title;
    
    [self.navigationController pushViewController:comicController animated:YES];
}



#pragma -mark collectionView数据源方法
//返回多少组
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return self.comicGroups.count;

}

//返回每组多少个
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    SCComicGroup *comicGroup = self.comicGroups[section];
    return comicGroup.comics.count ;
}

//每个cell的内容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    SCComicGroup *comicGroup = self.comicGroups[indexPath.section];
    SCComic *comic = comicGroup.comics[indexPath.row];
    
    SCComicCollectionViewCell *cell = [SCComicCollectionViewCell cellWithCollectionView:collectionView withIndexPath:indexPath withID:comicCellId];

    cell.comic = comic;
    
    return cell;
}

#pragma mark - scrollView代理方法
/** 点击图片回调 */
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index{
    SCComic *comic =  self.comicSwiper[index];
    SCComicViewController *comicController = [[SCComicViewController alloc] init];
    comicController.ID = comic.ID;
    comicController.title = comic.title;
    comicController.titlePicAddr = comic.titlePicAddr;
    
    [self.navigationController pushViewController:comicController animated:YES];

}

/** 图片滚动回调 */
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didScrollToIndex:(NSInteger)index{
    //NSLog(@"%ld",index);
}


/* 仅做测试
-(NSArray *)comicGroups{
    if(_comicGroups == nil){
        NSString *path = [[NSBundle mainBundle] pathForResource:@"ComicIndex.plist" ofType:nil];
        NSDictionary *comicIndeDict = [NSDictionary dictionaryWithContentsOfFile:path];
        NSMutableArray *arrayM = [NSMutableArray array];
        for (NSDictionary *dict in [comicIndeDict objectForKey:@"comic_category"]) {
            SCComicGroup *comicGroup = [SCComicGroup comicGroupWithDict:dict];
            [arrayM addObject:comicGroup];
        }
        _comicGroups = arrayM.copy;
    }
    return _comicGroups;
} */


/**
 保存模型数据

 @param swiper swiper数据
 @param group 每个类目的漫画数据
 */
-(void)saveModeData:(NSArray *)swiper comicGroups:(NSArray *)group{
    //保存轮播模型数据
    _comicSwiper = [SCComic mj_objectArrayWithKeyValuesArray:swiper];
    //保存每个类目的漫画数据
    NSArray *comicGroups = [SCComicGroup mj_objectArrayWithKeyValuesArray:group];

    
    _comicGroups = comicGroups;
}


#pragma -mark 网络请求

/**
 请求首页的数据并保存到模型
 */
-(void)requestIndexData{
    //加载首页的数据
    NSString *indexUrl = [NSString stringWithFormat:@"%@/comic-index/",domainUrl];
    SCNetWorkManager *manager = [SCNetWorkManager sharedManager];
    [manager requestWithMethod:GET withUrl:indexUrl withParams:nil withSuccessBlock:^(id response) {
        NSArray *comicCategory = [response valueForKey:@"comic_category"];
        NSArray *swiperArray = [response valueForKey:@"swiper"];
        
        [self saveModeData:swiperArray comicGroups:comicCategory];
        
        //刷新数据
        [self.collectionView reloadData];
        
        //轮播图片
        NSMutableArray *imageUrls = [NSMutableArray array];
        for (NSMutableDictionary *comic in swiperArray) {
            NSString *title_pic_addr = [comic valueForKey:@"title_pic_addr"];
            //保存轮播图片
            [imageUrls addObject:title_pic_addr];
        }
        
        //更新swiper数据
        self.scrollView.imageURLStringsGroup = imageUrls;
        
        [self.collectionView.mj_header endRefreshing];


        
    } withFailurBlock:^(NSError *error) {
        [SCPrompt showTips:self.view withContent:@"网络加载出错，请重试..."];
//        UIAlertController *con = [UIAlertController alertControllerWithTitle:@"操作提示" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
//        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
//        [con addAction:action];
//        [self presentViewController:con animated:YES completion:nil];
        
    }];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
