//
//  SCChapterViewController.m
//  SComicReader
//
//  Created by 冰河依然在 on 2018/5/14.
//  Copyright © 2018年 shuchang. All rights reserved.
//

#import "SCComicChapterViewController.h"
#import "SCWaterfallFlowLayout.h"
#import "SCNetWorkManager.h"
#import "SCChapterCollectionViewCell.h"
#import <MJExtension.h>
#import "SCComicChapter.h"
#import "SCImageViewController.h"
#import "SCConst.h"
#import "SCPrompt.h"


@interface SCComicChapterViewController ()<SCWaterfallFlowLayoutDataSource,UICollectionViewDataSource,UICollectionViewDelegate>
@property (weak, nonatomic) UICollectionView *collectionView;
@property (nonatomic,weak) UILabel *chapterNameHisLabel;
@property (nonatomic,strong) SCComicChapter *currentChapter;
@property (nonatomic,strong) NSArray *chapters;
@end

@implementation SCComicChapterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initView];
    
    [self requestChapterData:self.comicId];
    
}

-(void)viewWillAppear:(BOOL)animated{
    self.chapterNameHisLabel.text = [self getChapterHis];
}

-(void)requestChapterData:(NSString *)comicId{
    NSString *indexUrl = [NSString stringWithFormat:@"%@/comic-chapter-detail/%@/",domainUrl,comicId];
    SCNetWorkManager *manager = [SCNetWorkManager sharedManager];
    [manager requestWithMethod:GET withUrl:indexUrl withParams:nil withSuccessBlock:^(id response) {
        NSArray *chaptersDict = [response valueForKey:@"comic_chapter"];
        self.chapters = [SCComicChapter mj_objectArrayWithKeyValuesArray:chaptersDict];
        //创建章节阅读历史view
        [self createHisChapterView];
        
        [self.collectionView reloadData];
        
        
    } withFailurBlock:^(NSError *error) {
        [SCPrompt showTips:self.view withContent:@"网络加载出错，请重试..."];
        
    }];
}


/**
 创建阅读历史的view
 */
-(void)createHisChapterView{
    UIView *chapterHisView = [[UIView alloc]init];
    chapterHisView.backgroundColor = [UIColor colorWithRed:0/255 green:1 blue:1 alpha:0.5];
    chapterHisView.frame = CGRectMake(0, CGRectGetMaxY(self.collectionView.frame), screenWidth, chapterHisViewHeight);
    
    //创建描述
    UILabel *label = [[UILabel alloc]init];
    label.frame = CGRectMake(10, 5, screenWidth - 120, 30);
    label.textColor = [UIColor blackColor];
    label.font = [UIFont systemFontOfSize:14];
    label.text = [self getChapterHis];
    
    //创建删除按钮
    UIButton *startReadBtn = [[UIButton alloc]init];
    startReadBtn.frame = CGRectMake(screenWidth - 120, 0, 120, chapterHisViewHeight);
    startReadBtn.backgroundColor = [UIColor redColor];
    startReadBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [startReadBtn setTitle:@"▷开始阅读" forState:UIControlStateNormal];
    [startReadBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //注册单击事件，点击跳转到章节下的漫画图片页面
    [startReadBtn addTarget:self action:@selector(didClickStartReadButton:) forControlEvents:UIControlEventTouchDown];
    
    //加入父容器
    [chapterHisView addSubview:label];
    [chapterHisView addSubview:startReadBtn];
    [self.view addSubview:chapterHisView];
    [self.view bringSubviewToFront:chapterHisView];
    self.chapterNameHisLabel = label;
    
}


/**
跳转到章节下的漫画图片页面
 */
-(void)didClickStartReadButton:(UIButton *)sender{
    //如果章节有记录则跳转，没有记录，则提示下
    if(self.currentChapter != NULL){
        SCImageViewController *chapterImageController = [[SCImageViewController alloc] init];
        chapterImageController.chapter = self.currentChapter;
        chapterImageController.chapters = self.chapters;
        [self.navigationController pushViewController:chapterImageController animated:YES];
    }else{
        [SCPrompt showText:self.view withContent:@"章节信息更新中..."];
    }

}

/**
取得历史章节记录的章节名称
 */
-(NSString *)getChapterHis{
    NSString *chapterName ;
    if(self.chapters != nil && self.chapters.count > 0){
        //初始为漫画第一章节的名称
        chapterName = [self.chapters[0] name];
        NSString *chapterId = [self.chapters[0] chapterId];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSArray *comicsChapter = [defaults objectForKey:@"history_chapter"];
        //    NSLog(@"-------comicsChapterCopy:%@",comicsChapter);
        for (NSDictionary *chapter in comicsChapter) {
            //有漫画记录则读取访问的漫画章节记录
            if([chapter[@"id"] isEqualToString:self.comicId]){
                chapterName = chapter[@"chapter_name"];
                chapterId = chapter[@"chapter_id"];
                break;
            }
        }
        //保存当前章节对象，作为跳转的漫画章节
        for (int i = 0; i < self.chapters.count; i ++) {
            SCComicChapter *chapter = self.chapters[i];
            //保存当前章节对象
            if([chapter.chapterId isEqualToString:chapterId]){
                self.currentChapter = chapter;
                break;
            }
        }

    }
    return chapterName;
}


-(void)initView{
    //创建布局对象
    SCWaterfallFlowLayout *layout = [[SCWaterfallFlowLayout alloc]init];
    //创建collectionview
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight-(menuViewHeight+kWMHeaderViewHeight+kNavigationBarHeight+chapterHisViewHeight)) collectionViewLayout:layout];
    //背景自带黑色，需要设置
    collectionView.backgroundColor = [UIColor whiteColor];
    
    layout.dataSource = self;
    collectionView.dataSource = self;
    collectionView.delegate = self;
    
    //注册cell
    [collectionView registerClass:[SCChapterCollectionViewCell class] forCellWithReuseIdentifier:chapterCellId];
    
    [self.view addSubview:collectionView];
    self.collectionView = collectionView;
    
}

#pragma -mark collectionView代理方法

/**
 点击cell
 */
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    SCComicChapter *chapter = self.chapters[indexPath.row];
    SCImageViewController *chapterImageController = [[SCImageViewController alloc] init];
    chapterImageController.chapter = chapter;
    chapterImageController.chapters = self.chapters;
    [self.navigationController pushViewController:chapterImageController animated:YES];
    
}

#pragma -mark collectionView数据源方法
//返回多少组
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
    
}

//返回每组多少个
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return self.chapters.count;
}

//每个cell的内容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    SCComicChapter *chapter = self.chapters[indexPath.row];
    
    SCChapterCollectionViewCell *cell = [SCChapterCollectionViewCell cellWithCollectionView:collectionView withIndexPath:indexPath];
    
    cell.chapter = chapter;
    
    return cell;
}

#pragma -mark waterfull的数据源方法

- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(SCWaterfallFlowLayout *)layout numberOfColumnInSection:(NSInteger)section {
    return  4;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(SCWaterfallFlowLayout *)layout itemWidth:(CGFloat)width heightForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.collectionView.bounds.size.width / 10 ;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(SCWaterfallFlowLayout *)layout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10.0, 40.0, 10.0, 40.0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(SCWaterfallFlowLayout*)layout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 10.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(SCWaterfallFlowLayout*)layout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 10.0;
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
