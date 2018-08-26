//
//  SCImageViewController.m
//  SComicReader
//
//  Created by 冰河依然在 on 2018/5/17.
//  Copyright © 2018年 shuchang. All rights reserved.
//

#import "SCImageViewController.h"
#import "SCNetWorkManager.h"
#import <MJExtension.h>
#import <MJRefresh.h>
#import "SCImage.h"
#import "SCImageTableViewCell.h"
#import <UIImageView+WebCache.h>
#import "SCPrompt.h"
#import "SCConst.h"


@interface SCImageViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *images;
@property (nonatomic,assign) int currentChapterId;
@end

@implementation SCImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.chapter.name;
    self.view.backgroundColor = [UIColor whiteColor];
    //当前的章节id
    self.currentChapterId = [self.chapter.chapterId intValue];
    [self initTableView];
    [self requestChapterImageData:self.currentChapterId];
    
    
    // Do any additional setup after loading the view.
}

-(void)requestChapterImageData:(int)chapterId{
    
    NSString *indexUrl = [NSString stringWithFormat:@"%@/comic-chapter-image/%@/%d/",domainUrl,self.chapter.comicId,chapterId];
    
    SCNetWorkManager *manager = [SCNetWorkManager sharedManager];
    [manager requestWithMethod:GET withUrl:indexUrl withParams:nil withSuccessBlock:^(id response) {
        NSArray *imagePart = [SCImage mj_objectArrayWithKeyValuesArray:response];
        [self.images addObjectsFromArray:imagePart];
        //刷新数据
        [self.tableView reloadData];;
        //到底了就不刷新了
        if(imagePart.count == 0 ){
            //设置后下拉不执行loadMoreData
            self.tableView.mj_footer.state = MJRefreshStateNoMoreData;
        }else{
            //结束刷新
            [self.tableView.mj_footer endRefreshing];
            //保存章节记录
            [self saveChapterHis:chapterId];
        }

    } withFailurBlock:^(NSError *error) {
        [SCPrompt showTips:self.view withContent:@"网络加载出错，请重试..."];

    }];
    
}


/**
 更新章节对象
 */
-(SCComicChapter *)getNewChapter:(NSString *)chapterId{
    SCComicChapter *newChapter = nil;
    for (SCComicChapter *chapter in self.chapters) {
        if([chapter.chapterId isEqualToString:chapterId]){
            newChapter = chapter;
            self.title = chapter.name;
            break;
        }
    }
    return newChapter;
}

/**
保存漫画的章节id，每个漫画只保存一个章节
 */
-(void)saveChapterHis:(int)chapterId{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //取得之前的收藏记录
    NSMutableArray *comicsChapter = [defaults objectForKey:@"history_chapter"];
    //为空的话创建
    if(comicsChapter == nil){
        comicsChapter = [NSMutableArray array];
    }
    /** 由于取出来的类型不可变，需要另一个可变数组*/
    NSMutableArray *comicsChapterCopy = [comicsChapter mutableCopy];
    
    //得到新章节
    SCComicChapter *newChapter = [self getNewChapter:[NSString stringWithFormat:@"%d",chapterId]];

    //模型转字典,key为模型对应字典的名称，也就是网络加载的key
    NSMutableDictionary *chapterDict = newChapter.mj_keyValues;
    //false为保存的历史漫画章节中不包含漫画id
    Boolean flag = false;
    for (int i = 0; i < comicsChapterCopy.count; i ++) {
        //修改字典
        NSDictionary *dict = comicsChapterCopy[i];
        NSMutableDictionary *chapterCopy = [NSMutableDictionary dictionaryWithDictionary:dict];
        //如果找到漫画id，则修改漫画下面的章节id
        if([chapterCopy[@"id"] isEqualToString:chapterDict[@"id"]]){
            //修改章节内容
            chapterCopy = chapterDict;
            //修改漫画章节数组
            [comicsChapterCopy setObject:chapterCopy atIndexedSubscript:i];
            flag = true;
            break;
        }
        
    }
    //不保存漫画则加入历史
    if(!flag){
        [comicsChapterCopy addObject:chapterDict];
    }

    //保存到偏好文件
    [defaults setObject:comicsChapterCopy forKey:@"history_chapter"];
}

/**
 初始化tableview
 */
-(void)initTableView{
    UITableView *tableView = [[UITableView alloc]init ];
    tableView.frame = CGRectMake(0, 0, screenWidth, screenHeight);
    tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight ;
    //设置预估行高，避免heightForRowAtIndexPath刚开始加载就每行都调用
    tableView.estimatedRowHeight = 100;
    //设置数据源为当前控制器
    tableView.dataSource = self;
    //设置代理为当前控制器
    tableView.delegate = self;
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];

    [self.view addSubview:tableView];
    self.tableView = tableView;
}


/**
 下拉执行方法
 */
-(void)loadMoreData{
    self.currentChapterId ++;
    [self requestChapterImageData:self.currentChapterId];
    
}

#pragma -mark 懒加载
-(NSMutableArray *)images{
    if(_images == nil){
        _images = [NSMutableArray array];
    }
    return _images;
}


#pragma -mark tableView代理方法

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *imageUrl =  [self.images[indexPath.row] imageAddr];
    // 先从缓存中查找图片
    UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey: imageUrl];

    // 没有找到已下载的图片就使用默认的占位图，当然高度也是默认的高度了，除了高度不固定的文字部分。
    if (!image) {
        image = [UIImage imageNamed:@"placeholder"];
    }

    //手动计算cell
    CGFloat imgHeight = image.size.height * screenWidth / image.size.width;
    return imgHeight;
}

#pragma -mark tableViwe数据源方法

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.images.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SCImage *image = self.images[indexPath.row];
    SCImageTableViewCell *cell = [SCImageTableViewCell imageWithTableView:tableView withIndexPath:indexPath];
    //把数据赋值给cell
    cell.image = image;
    return cell;
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
