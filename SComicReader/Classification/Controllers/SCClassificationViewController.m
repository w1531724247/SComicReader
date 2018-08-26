//
//  SCCategoryViewController.m
//  SComicReader
//
//  Created by 冰河依然在 on 2018/5/19.
//  Copyright © 2018年 shuchang. All rights reserved.
//

#import "SCClassificationViewController.h"
#import "SCComicCode.h"
#import "SCNetWorkManager.h"
#import <MJExtension.h>
#import <MJRefresh.h>
#import "SCConst.h"
#import "SCWaterfallFlowLayout.h"
#import "SCComicCollectionViewCell.h"
#import "SCComic.h"
#import "SCPrompt.h"
#import "SCComicViewController.h"


@interface SCClassificationViewController()<SCWaterfallFlowLayoutDataSource,UICollectionViewDataSource,UICollectionViewDelegate,UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic)  UITableView *tableView;
@property (weak, nonatomic)  UICollectionView *collectionView;
@property (nonatomic,strong) NSArray *comicCodes;
@property (nonatomic,strong) NSMutableArray *comicsInType;
@property (nonatomic,assign) int pageIndex;

@property (nonatomic,copy) NSString *currnetCodeId;
@end
@implementation SCClassificationViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initTableView];
    [self initCollectionView];

    //请求数据
    [self requestComicCodeData];
    
}


/**
 初始化tableview
 */
-(void)initTableView{
    UITableView *tableView = [[UITableView alloc] init];
    tableView.frame = CGRectMake(0, 0, tableViewWidth, screenHeight );
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight ;
    tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    //注册tablecell
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:comicTypeCellId];
    [self.view addSubview:tableView];
    self.tableView = tableView;
}


/**
 初始化collectionview
 */
-(void)initCollectionView{
    //创建布局对象
    SCWaterfallFlowLayout *layout = [[SCWaterfallFlowLayout alloc]init];
    //创建collectionview
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(tableViewWidth, 0, screenWidth-tableViewWidth, screenHeight ) collectionViewLayout:layout];
    collectionView.backgroundColor = [UIColor whiteColor];
    layout.dataSource = self;
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight ;
    //注册cell
    [collectionView registerClass:[SCComicCollectionViewCell class] forCellWithReuseIdentifier:comicCellId];
    //添加下拉刷新
    collectionView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    [self.view addSubview:collectionView];
    self.collectionView = collectionView;

}

-(void)loadMoreData{
    self.pageIndex ++;
    [self requestComicTypeData:self.currnetCodeId withPageIndex: self.pageIndex isScrollToTop:false];
}


/**
 加载类型下面的漫画
 */
-(void)requestComicTypeData:(NSString *)codeId withPageIndex:(int)pageIndex isScrollToTop:(Boolean)isScroll{

    //加载推荐页的数据
    NSString *indexUrl = [NSString stringWithFormat:@"%@/comic-category/%@/%d/%d/",domainUrl,codeId,pageIndex,pageCount];
    SCNetWorkManager *manager = [SCNetWorkManager sharedManager];
    [manager requestWithMethod:GET withUrl:indexUrl withParams:nil withSuccessBlock:^(id response) {
        NSArray *comics = [SCComic mj_objectArrayWithKeyValuesArray:response];
        //保存加载的数据
        [self.comicsInType addObjectsFromArray:comics];
        //判断是否到底了
        if(comics.count == 0){
            //设置后下拉不执行loadMoreData
            self.collectionView.mj_footer.state = MJRefreshStateNoMoreData;
        }else{
            //结束刷新
            [self.collectionView.mj_footer endRefreshing];
        }
        //刷新数据
        [self.collectionView reloadData];
        
        //是否滚动到顶部
        if(isScroll){
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
        }

    } withFailurBlock:^(NSError *error) {
        [SCPrompt showTips:self.view withContent:@"网络加载出错，请重试..."];
        
    }];
}

/**
 加载漫画类型
 */
-(void)requestComicCodeData{

    NSString *indexUrl = [NSString stringWithFormat:@"%@/comic-type-code/",domainUrl];    
    SCNetWorkManager *manager = [SCNetWorkManager sharedManager];
    [manager requestWithMethod:GET withUrl:indexUrl withParams:nil withSuccessBlock:^(id response) {
        self.comicCodes = [SCComicCode mj_objectArrayWithKeyValuesArray:response];
        NSString *codeId = [self.comicCodes[0] ID];
        //保存当前的漫画codeId，用于下拉刷新
        self.currnetCodeId = codeId;
        NSLog(@"self.comicCodes.count:%lu",self.comicCodes.count);
        
        /**等于1则为上线手动处理*/
        if(self.comicCodes.count == 1){
            //去掉tableview
            [self.tableView removeFromSuperview];
            //修改frame
            self.collectionView.frame = CGRectMake(0, 0, screenWidth, screenHeight - 110 );
        }else{
            //刷新数据
            [self.tableView reloadData];
            //第一行选中
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        }
        
        //初始加载第一个类型下的漫画
        [self requestComicTypeData:codeId withPageIndex:1 isScrollToTop:false];
        
        
    } withFailurBlock:^(NSError *error) {
        [SCPrompt showTips:self.view withContent:@"网络加载出错，请重试..."];
        
    }];
}

#pragma -mark 懒加载

-(NSMutableArray *)comicsInType{
    if(_comicsInType == nil){
        _comicsInType = [NSMutableArray array];
    }
    return _comicsInType;
}


#pragma -mark tableView数据源方法
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.comicCodes.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SCComicCode *comicType = self.comicCodes[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:comicTypeCellId forIndexPath:indexPath];
    //设置标题
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    
    cell.textLabel.lineBreakMode =  NSLineBreakByWordWrapping;
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    //设置漫画类型的名称
    cell.textLabel.text = comicType.name;
    
    return cell;
}

#pragma -mark tableView代理方法
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    SCComicCode *comicType = self.comicCodes[indexPath.row];
    //清空上一个codeId下的数组的元素
    [self.comicsInType removeAllObjects];
    
    //保存当前的漫画codeId，用于下拉刷新
    self.currnetCodeId = comicType.ID;
    
    //初始化为第一页
    self.pageIndex = 1;
    
    //请求漫画类型下第一页的数据,滚动到顶部
    [self requestComicTypeData:self.currnetCodeId withPageIndex:self.pageIndex isScrollToTop:YES];

}


#pragma -mark collectionView代理方法

/**
 点击cell
 */
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    SCComic *comic = self.comicsInType[indexPath.row];
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
    
    return self.comicsInType.count;
}

//每个cell的内容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    //
    
    /**极少情况有[__NSArrayM objectAtIndexedSubscript:]: index 21 beyond bounds for empty array 错误，由于collectionview
     上拉的时候加载数据，刚加载完的瞬间，又点击左边tableview的类别，正好执行到[self.comicsInType removeAllObjects]，然后
     collectionview reload 会导致self.comicsInType 无数据。*/
    
    //加上判断
    if(self.comicsInType.count == 0){
        
        return [SCComicCollectionViewCell cellWithCollectionView:collectionView withIndexPath:indexPath withID:comicCellId];
    }
    
    SCComic *comic = self.comicsInType[indexPath.row];
    SCComicCollectionViewCell *cell = [SCComicCollectionViewCell cellWithCollectionView:collectionView withIndexPath:indexPath withID:comicCellId];
    
    cell.comic = comic;
    
    return cell;
}

#pragma -mark waterfull的数据源方法

- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(SCWaterfallFlowLayout *)layout numberOfColumnInSection:(NSInteger)section {
    return  3;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(SCWaterfallFlowLayout *)layout itemWidth:(CGFloat)width heightForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.collectionView.bounds.size.width / 2.3 ;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(SCWaterfallFlowLayout *)layout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(SCWaterfallFlowLayout*)layout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 20.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(SCWaterfallFlowLayout*)layout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 10.0;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end


