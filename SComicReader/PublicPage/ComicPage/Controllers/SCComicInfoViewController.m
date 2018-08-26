//
//  SCComicInfoViewController.m
//  SComicReader
//
//  Created by 冰河依然在 on 2018/5/14.
//  Copyright © 2018年 shuchang. All rights reserved.
//

#import "SCComicInfoViewController.h"
#import "SCWaterfallFlowLayout.h"
#import "SCComicCollectionViewCell.h"
#import "SCNetWorkManager.h"
#import <Masonry.h>
#import <MJExtension.h>
#import "SCConst.h"
#import "SCPrompt.h"
#import "SCComicViewController.h"
#import "SCRecommendHeaderView.h"


#define margin 10
#define btnHeight 40
#define btnWidth 120

@interface SCComicInfoViewController ()<SCWaterfallFlowLayoutDataSource,UICollectionViewDataSource,UICollectionViewDelegate,SCRecommendHeaderViewDelegate>
@property (strong, nonatomic) UICollectionView *collectionView;
@property (nonatomic,strong) NSArray *comicsRecommend;
@property (nonatomic,strong) UILabel *txtLabel;
@property (nonatomic,strong) UIButton *btn;
@property (nonatomic,strong) SCComic *comic;
@end

@implementation SCComicInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //请求漫画详细信息
    [self requestComicInfoData:self.comicId];
    
}

-(void)requestComicInfoData:(NSString *)comicId{
    NSString *indexUrl = [NSString stringWithFormat:@"%@/comic-info-detail/%@/",domainUrl,comicId];
    SCNetWorkManager *manager = [SCNetWorkManager sharedManager];
    [manager requestWithMethod:GET withUrl:indexUrl withParams:nil withSuccessBlock:^(id response) {
        NSDictionary *comicDict = [response valueForKey:@"comic_type_summary"];
        //保存漫画模型数据
        self.comic = [SCComic mj_objectWithKeyValues:comicDict];
        //保存访问历史
        [self saveComicHis];
        
        //生成简介view的高度
        CGFloat breifBottomHeight = [self initBriefView:self.comic.brief];
        //初始化按钮
        CGFloat btnBottomheight = [self initButton:breifBottomHeight];
        //初始化collectionView
        [self initColleciontView:btnBottomheight];
        
        //推荐请求信息
        [self requestRecommendData];
        
    } withFailurBlock:^(NSError *error) {
        [SCPrompt showTips:self.view withContent:@"网络加载出错，请重试..."];
        
    }];
}

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
保存漫画访问的历史记录
 */
-(void)saveComicHis{
    /**数据加载后才能加入保存历史*/
    if(self.comic != nil){
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        //取得之前的收藏记录
        NSMutableArray *comics = [defaults objectForKey:@"history_comics"];
        //为空的话创建
        if(comics == nil){
            comics = [NSMutableArray array];
        }
        /** 由于取出来的类型不可变，需要另一个可变数组*/
        NSMutableArray *comicsCopy = [comics mutableCopy];
        //模型转字典,key为模型对应字典的名称，也就是网络加载的key
        NSDictionary *comicDict = self.comic.mj_keyValues;
        
        //不在列表的加入历史列表
        if(![self isComicInArray:comicsCopy withId:comicDict[@"id"]]){
            [comicsCopy addObject:comicDict];
        }
        
        //保存到偏好文件
        [defaults setObject:comicsCopy forKey:@"history_comics"];
    }

}


#pragma -mark 懒加载
-(UILabel *)txtLabel{
    if(_txtLabel == nil){
        _txtLabel = [[UILabel alloc] init];
    }
    return _txtLabel;
}

-(UIButton *)btn{
    if(_btn == nil){
        _btn = [[UIButton alloc] init];
    }
    return _btn;
}



#pragma -mark 初始化操作

-(void)initColleciontView:(CGFloat) height{
    //创建布局对象
    SCWaterfallFlowLayout *layout = [[SCWaterfallFlowLayout alloc]init];
    //创建collectionview
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - 308) collectionViewLayout:layout];
    //背景自带黑色，需要设置
    collectionView.backgroundColor = [UIColor whiteColor];
    
    layout.dataSource = self;
    collectionView.dataSource = self;
    collectionView.delegate = self;

    //注册headerview
    [collectionView registerClass:[SCRecommendHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:recomendHeaderCellId];
    
    //注册cell
    [collectionView registerClass:[SCComicCollectionViewCell class] forCellWithReuseIdentifier:comicCellId];
    
    collectionView.contentInset = UIEdgeInsetsMake(height+2*margin, 0, 0, 0);
    [collectionView addSubview:self.txtLabel];
    [collectionView addSubview:self.btn];
    [self.view addSubview:collectionView];
    self.collectionView = collectionView;
}

/**
 初始化简介
 */
-(CGFloat)initBriefView:(NSString *)brief{
    //breifview的底部高度
    CGFloat breifBottom = 0;
    CGFloat height = [self getStrHeight:brief];
    self.txtLabel.numberOfLines = 0;
    self.txtLabel.font = [UIFont systemFontOfSize:16];
    self.txtLabel.text = brief;
    self.txtLabel.frame = CGRectMake(margin, -height-btnHeight-margin, screenWidth - margin*2, height);
    breifBottom = height;
    return breifBottom;
}


/**
 生成字符串的高度
 */
-(CGFloat)getStrHeight:(NSString *)content{
    NSDictionary *dict = @{NSFontAttributeName : [UIFont systemFontOfSize:14]};
    CGSize size=[content boundingRectWithSize:CGSizeMake(screenWidth-margin*2, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil].size;
    return size.height;
}

-(CGFloat)initButton:(CGFloat) height{
    //btn的底部的高度
    CGFloat btnBottom = 0;
    self.btn.backgroundColor = [UIColor orangeColor];
    self.btn.titleLabel.textColor = [UIColor whiteColor];
    [self.btn setTitle: @"加入书架" forState: UIControlStateNormal];
    [self.btn setTitle: @"+已加入" forState: UIControlStateSelected];
    self.btn.selected = [self hasAddBookshelf];
    //注册点击事件
    [self.btn addTarget:self action:@selector(didClickAddBookShelfButton:) forControlEvents:UIControlEventTouchUpInside];
    self.btn.frame = CGRectMake(margin, -btnHeight, btnWidth, btnHeight);
    btnBottom = height + btnHeight;
    return btnBottom;
}


/**
判断是否当前漫画已加入书架
 */
-(Boolean)hasAddBookshelf{
    Boolean flag = false;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //取得之前的收藏记录
    NSMutableArray *comics = [defaults objectForKey:@"collection_comics"];
    for (NSDictionary *comic in comics) {
        if([comic[@"id"] isEqualToString:self.comic.ID]){
            flag = true;
            break;
        }
    }
    return flag;
}

/**
 点击按钮加入收藏
 */
-(void)didClickAddBookShelfButton:(UIButton *)sender  {
    //数据加载后才能加入书架
    if(self.comic != nil){
        sender.selected = !sender.selected;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        //取得之前的收藏记录
        NSMutableArray *comics = [defaults objectForKey:@"collection_comics"];
        //为空的话创建
        if(comics == nil){
            comics = [NSMutableArray array];
        }
        /** 由于取出来的类型不可变，需要另一个可变数组*/
        NSMutableArray *comicsCopy = [comics mutableCopy];
        //模型转字典,key为模型对应字典的名称，也就是网络加载的key
        NSDictionary *comicDict = self.comic.mj_keyValues;
        
        //选中状态则加入列表
        if(sender.selected){
            //不在列表的加入历史列表
            if(![self isComicInArray:comicsCopy withId:comicDict[@"id"]]){
                [comicsCopy addObject:comicDict];
            }
        }else{
            //移除列表
            if([self isComicInArray:comicsCopy withId:comicDict[@"id"]]){
                [comicsCopy removeObject:comicDict];
            }
        }
        
        //保存到偏好文件
        [defaults setObject:comicsCopy forKey:@"collection_comics"];
    }
    
}


/**
判断comic_id是否在数组里面
 */
-(Boolean)isComicInArray:(NSArray *)array withId:(NSString *)comicId{
    Boolean flag = false;
    for (NSDictionary *comic in array) {
        if([comic[@"id"] isEqualToString:comicId]){
            flag = true;
            break;
        }
    }
    return flag;
}

#pragma -mark headerView代理方法
-(void)reloadRecommendData:(SCRecommendHeaderView *)controller{
    [self requestRecommendData];
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

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    SCRecommendHeaderView *headerView = (SCRecommendHeaderView *)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:recomendHeaderCellId forIndexPath:indexPath];
    headerView.delegate = self;
    return headerView;
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

#pragma -mark waterfull的数据源方法

- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(SCWaterfallFlowLayout *)layout numberOfColumnInSection:(NSInteger)section {
    return  4;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(SCWaterfallFlowLayout *)layout itemWidth:(CGFloat)width heightForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.view.bounds.size.width / 3 ;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(SCWaterfallFlowLayout *)layout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(SCWaterfallFlowLayout*)layout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 10.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(SCWaterfallFlowLayout*)layout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 10.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(SCWaterfallFlowLayout *)layout referenceHeightForHeaderInSection:(NSInteger)section {
    return 40.0;
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
