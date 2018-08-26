//
//  SCComicRankViewController.m
//  SComicReader
//
//  Created by 冰河依然在 on 2018/5/20.
//  Copyright © 2018年 shuchang. All rights reserved.
//

#import "SCComicRankViewController.h"
#import "SCComic.h"
#import "SCNetWorkManager.h"
#import "SCComicCollectionViewCell.h"
#import <MJExtension.h>
#import <UIImageView+WebCache.h>
#import "SCConst.h"
#import <MJRefresh.h>
#import "SCComicRankCellLayout.h"
#import "SCComicViewController.h"
#import "SCPrompt.h"
#import "SCComicRankTableCell.h"


@interface SCComicRankViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic)  UICollectionView *collectionView;
@property (weak, nonatomic)  UITableView *tableView;
@property (nonatomic,strong) NSArray *comicsRecommend;
@property (nonatomic,strong) NSMutableArray *comicsRank;
@property (nonatomic,assign) int pageIndex;
@end

@implementation SCComicRankViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.pageIndex = 1 ;
    [self initCollectionView];
    [self initTableView];
    
    [self requestRecommendData];
    
    [self requestRankData:self.pageIndex];

}

-(void)loadMoreData{
    
    self.pageIndex ++;
    [self requestRankData:self.pageIndex];
}


/**
 初始化tableview，不注册,自己cell里创建
 */
-(void)initTableView{
    UITableView *tableView = [[UITableView alloc] init];
    tableView.frame = CGRectMake(0, headerHeight, screenWidth, screenHeight - headerHeight - kNavigationBarHeight);
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    //设置高
    tableView.rowHeight = 60;
    //设置没数据不显示分割线
    tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    [self.view addSubview:tableView];
    self.tableView = tableView;
}


/**
 初始化collectionview
 */
-(void)initCollectionView{
    //创建布局对象
    SCComicRankCellLayout *layout = [[SCComicRankCellLayout alloc]init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    //创建collectionview
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, headerHeight) collectionViewLayout:layout];
    collectionView.backgroundColor = [UIColor whiteColor];
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.dataSource = self;
    collectionView.delegate = self;
    //注册cell
    [collectionView registerClass:[SCComicCollectionViewCell class] forCellWithReuseIdentifier:comicCellId];
    
    [self.view addSubview:collectionView];
    self.collectionView = collectionView;

    //创建一个 猜你喜欢 labei
    UILabel *label = [[UILabel alloc]init];
    label.text = @"猜你喜欢";
    label.font = [UIFont systemFontOfSize:13];
    label.textColor = [UIColor redColor];
    label.frame = CGRectMake(10, 2, 60, 20);
    [self.view addSubview:label];
    
}

-(NSMutableArray *)comicsRank{
    if(_comicsRank == nil){
        _comicsRank = [NSMutableArray array];
    }
    return _comicsRank;
}


/**
 请求推荐数据
 */
-(void)requestRecommendData{
    //加载推荐页的数据
    NSString *indexUrl = [NSString stringWithFormat:@"%@/comic-random-recommend/",domainUrl];
    
    SCNetWorkManager *manager = [SCNetWorkManager sharedManager];
    [manager requestWithMethod:GET withUrl:indexUrl withParams:nil withSuccessBlock:^(id response) {
        self.comicsRecommend = [SCComic mj_objectArrayWithKeyValuesArray:response];
        //刷新数据
        [self.collectionView reloadData];
        
    } withFailurBlock:^(NSError *error) {
        [SCPrompt showTips:self.view withContent:@"网络加载出错，请重试..."];
        
    }];
}


/**
请求排序数据
 */
-(void)requestRankData:(int)pageIndex{
    //加载推荐页的数据

    NSString *indexUrl ;
    if(self.type == 1){
        indexUrl = [NSString stringWithFormat:@"%@/comic-all/%d/%d",domainUrl,pageIndex,pageCount];
    }else if (self.type == 2){
        indexUrl = [NSString stringWithFormat:@"%@/comic-charge/%d/%d",domainUrl,pageIndex,pageCount];
    }else if(self.type == 3){
        indexUrl = [NSString stringWithFormat:@"%@/comic-free/%d/%d",domainUrl,pageIndex,pageCount];
    }else{
        //为搜索框的搜索
        indexUrl = [NSString stringWithFormat:@"%@/comic-search/%@",domainUrl,self.searchTag];
        //输入中文情况
        indexUrl = [indexUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        //设置不可上拉刷新
        self.tableView.mj_footer.state = MJRefreshStateNoMoreData;
    }
    
    SCNetWorkManager *manager = [SCNetWorkManager sharedManager];
    [manager requestWithMethod:GET withUrl:indexUrl withParams:nil withSuccessBlock:^(id response) {
        NSArray *comics = [SCComic mj_objectArrayWithKeyValuesArray:response];
        [self.comicsRank addObjectsFromArray:comics];
        //刷新数据
        [self.tableView reloadData];

        if(comics.count == 0){
            //设置后下拉不执行loadMoreData
            self.tableView.mj_footer.state = MJRefreshStateNoMoreData;
        }else if(self.type){
            //结束刷新
            [self.tableView.mj_footer endRefreshing];
        }
        
    } withFailurBlock:^(NSError *error) {
        [SCPrompt showTips:self.view withContent:@"网络加载出错，请重试..."];
        
    }];
}


#pragma -mark tableView数据源方法
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.comicsRank.count;
}
//-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    SCComic *comic = self.comicsRank[indexPath.row];
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:comicRankCellId];
//    if(cell == nil){
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:comicRankCellId];
//    }
////    cell.imageView.contentMode = UIViewContentModeScaleToFill;
//    //设置图片
//    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:comic.titlePicAddr] placeholderImage:[UIImage imageNamed:@"placeholder"]];
//    //设置标题
//    cell.textLabel.text = comic.title;
//    //设置详细信息,需要style
//    cell.detailTextLabel.text = comic.typeNameList;
//    cell.detailTextLabel.textColor = [UIColor redColor];
//
//    return cell;
//}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SCComic *comic = self.comicsRank[indexPath.row];
    /**使用默认的tableview，加载图片后会出现图片被拉伸成原来的尺寸*/
    SCComicRankTableCell *cell = [SCComicRankTableCell comicWithTableView:tableView withIndexPath:indexPath];
    cell.comic = comic;
    return cell;
}

#pragma -mark tableView代理方法
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SCComic *comic = self.comicsRank[indexPath.row];
    SCComicViewController *comicController = [[SCComicViewController alloc] init];
    comicController.ID = comic.ID;
    comicController.titlePicAddr = comic.titlePicAddr;
    comicController.title = comic.title;
    
    [self.navigationController pushViewController:comicController animated:YES];
}

#pragma -mark collectionView数据源方法

//返回多少组
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

//返回每组多少个
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.comicsRecommend.count;
}

//每个cell的内容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    SCComic *comic = self.comicsRecommend[indexPath.row];
    
    SCComicCollectionViewCell *cell = [SCComicCollectionViewCell cellWithCollectionView:collectionView withIndexPath:indexPath withID:comicCellId];
    cell.comic = comic;
    
    return cell;
}

#pragma -mark collectionView代理方法
/**
 点击cell
 */
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    SCComic *comic = self.comicsRecommend[indexPath.row];
    SCComicViewController *comicController = [[SCComicViewController alloc] init];
    comicController.ID = comic.ID;
    comicController.titlePicAddr = comic.titlePicAddr;
    comicController.title = comic.title;
    
    [self.navigationController pushViewController:comicController animated:YES];
}

/**
cell的size
 */
- (CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = self.collectionView.bounds.size.height;
    return CGSizeMake(height*0.75, height);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
