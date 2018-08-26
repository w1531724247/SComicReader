//
//  SCSearchViewController.m
//  SComicReader
//
//  Created by 冰河依然在 on 2018/5/19.
//  Copyright © 2018年 shuchang. All rights reserved.
//

#import "SCSearchViewController.h"
#import "XLSphereView.h"
#import "SCNetWorkManager.h"
#import "SCComic.h"
#import <MJExtension.h>
#import "SCComicViewController.h"
#import "JBKenBurnsView.h"
#import "PYSearch.h"
#import "SCComicRankViewController.h"
#import "SCPrompt.h"
#import "SCConst.h"
#import "SCComicTip.h"

@interface SCSearchViewController ()<KenBurnsViewDelegate,PYSearchViewControllerDelegate,UITextViewDelegate>
@property (nonatomic,strong) XLSphereView *sphereView;
@property (nonatomic,strong) NSArray *comicsHot;
@property (nonatomic,strong) NSMutableArray *searchTips;
@property (nonatomic,strong) NSArray *comicTips;
@property (nonatomic,weak) UIView *coverView;
@property (nonatomic,weak) UILabel *placeholderLabelView;
@property (nonatomic,weak) UIView *inputView;
@property (nonatomic,weak) UITextView *textView;
@property (nonatomic,assign) Boolean isSuggest;
@end

@implementation SCSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //防止多次点击生成view
    self.isSuggest = true;
    //创建右上角的建议反馈按钮
    UIBarButtonItem *myButton = [[UIBarButtonItem alloc] initWithTitle:@"建议反馈" style:UIBarButtonItemStylePlain target:self action:@selector(didClickSuggestButton:)];
    self.navigationItem.rightBarButtonItem = myButton;
    [self requestSearchTips];
    [self initBackgrond];

    [self initSearchBar];
    
    [self requestHotComicData];
    
    //第一次才加载
    [self getArchiveData];
    
}

-(void)viewDidDisappear:(BOOL)animated{
    [self.sphereView timerStop];
}

-(void)viewWillAppear:(BOOL)animated{
    [self.sphereView timerStart];
}

/**
 请求搜索的热门提示词
 */
-(void)requestSearchTips{
    NSString *indexUrl = [NSString stringWithFormat:@"%@/comic-search-tips/",domainUrl];
    
    SCNetWorkManager *manager = [SCNetWorkManager sharedManager];
    [manager requestWithMethod:GET withUrl:indexUrl withParams:nil withSuccessBlock:^(id response) {
        self.comicTips = [SCComicTip mj_objectArrayWithKeyValuesArray:response];
        
    } withFailurBlock:^(NSError *error) {
        [SCPrompt showTips:self.view withContent:@"网络加载出错，请重试..."];
        
    }];
}
/**
 点击建议反馈按钮事件,我艹，好多代码
 */
-(void)didClickSuggestButton:(UIBarButtonItem *)sender{
    //点击建议
    if(self.isSuggest){
        //1.创建coverView，把界面遮盖住
        UIView *coverView = [[UIView alloc] initWithFrame:self.view.bounds];
        coverView.backgroundColor = [UIColor blackColor];
        coverView.alpha = 0.5;
        //加入当前tableview的话，tab栏和导航栏覆盖不了图片view
        [self.view addSubview:coverView];
        //会用到
        self.coverView = coverView;
        
        //输入框
        UIView *inputView = [[UIView alloc]initWithFrame:CGRectMake(48,100, screenWidth-96, 200)];
        inputView.backgroundColor = [UIColor whiteColor];
        inputView.layer.cornerRadius = 4;
        inputView.clipsToBounds = NO;
        [self.view addSubview:inputView];
        
        //建议标签
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(20, 10, screenWidth-96-40, 20)];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"请输入建议内容";
        label.font = [UIFont systemFontOfSize:16];
        //applyLabel2.backgroundColor = [UIColor greenColor];
        [inputView addSubview:label];
        
        //文本输入框
        UITextView *textView = [[UITextView alloc]initWithFrame:CGRectMake(20, 40, screenWidth-96-40,100)];
        textView.delegate = self;
        textView.alpha = 1;
        textView.layer.cornerRadius = 4;
        textView.layer.borderWidth = 1;
        textView.layer.borderColor = [UIColor colorWithRed:(232)/255.0 green:(232)/255.0 blue:(232)/255.0 alpha:1].CGColor;
        textView.backgroundColor = [UIColor clearColor];
        textView.textColor = [UIColor colorWithRed:(51)/255.0 green:(51)/255.0 blue:(51)/255.0 alpha:1];
        textView.font = [UIFont systemFontOfSize:14.f];
        textView.returnKeyType = UIReturnKeyDone;
        //会用到
        self.textView = textView;
        
        //输入框里提示符
        UILabel *placeholderLabelView = [[UILabel alloc]initWithFrame:CGRectMake(8, 8, screenWidth-96-40-16, 20)];
        placeholderLabelView.text = @"内容限制在1000字之内";
        placeholderLabelView.font = [UIFont systemFontOfSize:14.f];
        placeholderLabelView.textColor = [UIColor colorWithRed:(205)/255.0 green:(205)/255.0 blue:(205)/255.0 alpha:1];
        placeholderLabelView.numberOfLines = 0;
        placeholderLabelView.textAlignment = NSTextAlignmentLeft;
        [textView addSubview:placeholderLabelView];
        //会用到
        self.placeholderLabelView = placeholderLabelView;
        
        [inputView addSubview:textView];
        
        //取消按钮
        UIButton *cancelButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 200-44, (screenWidth-96)/2.0, 44)];
        cancelButton.layer.borderWidth = 1;
        cancelButton.layer.borderColor = [UIColor colorWithRed:(232)/255.0 green:(232)/255.0 blue:(232)/255.0 alpha:1].CGColor;
        [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        cancelButton.titleLabel.font = [UIFont systemFontOfSize:16.f];
        [cancelButton addTarget:self action:@selector(didClickSuggestCancelButton:) forControlEvents:UIControlEventTouchUpInside];
        [cancelButton setTitleColor:[UIColor colorWithRed:(51)/255.0 green:(51)/255.0 blue:(51)/255.0 alpha:1] forState:UIControlStateNormal];
        [inputView addSubview:cancelButton];
        
        //确定按钮
        UIButton *sureButton = [[UIButton alloc]initWithFrame:CGRectMake((screenWidth-96)/2.0, 200-44, (screenWidth-96)/2.0, 44)];
        
        sureButton.layer.borderWidth = 1;
        sureButton.layer.borderColor = [UIColor colorWithRed:(232)/255.0 green:(232)/255.0 blue:(232)/255.0 alpha:1].CGColor;
        [sureButton setTitle:@"确认" forState:UIControlStateNormal];
        sureButton.titleLabel.font = [UIFont systemFontOfSize:16.f];
        [sureButton addTarget:self action:@selector(didClickSuggestSureButton:) forControlEvents:UIControlEventTouchUpInside];
        [sureButton setTitleColor:[UIColor colorWithRed:(0)/255.0 green:(150)/255.0 blue:(255)/255.0 alpha:1] forState:UIControlStateNormal];
        [inputView addSubview:sureButton];
        [self.view bringSubviewToFront:inputView];
        //会用到
        self.inputView = inputView;
        
        //只有点击取消或者确定后才能继续点“建议”
        self.isSuggest = false;
    }
}


/**
 点击取消按钮
 */
-(void)didClickSuggestCancelButton:(UIButton *)sender{
    [UIView animateWithDuration:0.4 animations:^{
        self.inputView.alpha = 0.0;
        self.coverView.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.isSuggest = true;
        [self.textView removeFromSuperview];
        [self.placeholderLabelView removeFromSuperview];
        [self.inputView removeFromSuperview];
        [self.coverView removeFromSuperview];
    }];
    
}

/**
 点击确认按钮
 */
-(void)didClickSuggestSureButton:(UIButton *)sender{
    NSString *suggest = self.textView.text;
    if(suggest.length == 0 || [suggest isEqualToString:@""]){
        [SCPrompt showText:self.view withContent:@"请输入内容后提交"];
    }else if(suggest.length > 1000){
        [SCPrompt showText:self.view withContent:@"写这么多，我哪里看得完啊..."];
    }else{
        [self requestPostSuggest:suggest];
        [UIView animateWithDuration:0.4 animations:^{
            self.inputView.alpha = 0.0;
            self.coverView.alpha = 0.0;
        } completion:^(BOOL finished) {
            self.isSuggest = true;
            [self.textView removeFromSuperview];
            [self.placeholderLabelView removeFromSuperview];
            [self.inputView removeFromSuperview];
            [self.coverView removeFromSuperview];
        }];
    }
}


/**
点击背景缩回键盘
 */
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

/**
 提交建议内容
 */
-(void)requestPostSuggest:(NSString *)suggest{
    NSDate *date = [NSDate date];
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init ];
    [dateFormatter setDateFormat:@"YYYY-MM-dd hh:mm:ss"];
    NSString * dateStr = [dateFormatter stringFromDate:date];
    //提交的结果
    NSDictionary *dict = @{@"type":@2,@"content":suggest,@"datetime":dateStr};
    NSString *indexUrl = [NSString stringWithFormat:@"%@/comic-notification/",domainUrl];
    SCNetWorkManager *manager = [SCNetWorkManager sharedManager];
    
    [manager requestWithMethod:POST withUrl:indexUrl withParams:dict withSuccessBlock:^(id response) {
        if([response[@"status_code"] isEqualToString:@"200"]){
            [SCPrompt showText:self.view withContent:@"提交成功"];
        }
        
    } withFailurBlock:^(NSError *error) {
        [SCPrompt showTips:self.view withContent:@"网络加载出错，请重试..."];
        
    }];
}


#pragma -mark textView的代理方法

/**
 输入的时候隐藏placeholder
 */
-(void)textViewDidChange:(UITextView *)textView{
    
    if (textView.text.length == 0) {
        
        [self.placeholderLabelView setHidden:NO];
    }else{
        
        [self.placeholderLabelView setHidden:YES];
    }
        
}

/**
 初始化搜索框
 */
-(void)initSearchBar{
//    UIButton *btn = [[UIButton alloc]init];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 2, screenWidth, 50);
    btn.adjustsImageWhenHighlighted = NO;
    [btn setBackgroundImage:[UIImage imageNamed:@"searchBar"] forState:UIControlStateNormal];

    [btn addTarget:self action:@selector(didClikcButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    
}

-(void)didClikcButton:(UIButton *)sender{
    // 1. Create an Array of popular search
    NSMutableArray *hotSeaches = nil;
    int count = 0;
    if(self.comicTips != nil && self.comicTips.count > 0){
        hotSeaches = [[NSMutableArray alloc]init];
        for(SCComicTip *comicTip in self.comicTips)
        {
            [hotSeaches addObject:comicTip.word];
            count ++;
            if (count > 12) break;
        }
    }
    // 2. Create a search view controller
    PYSearchViewController *searchViewController = [PYSearchViewController searchViewControllerWithHotSearches:hotSeaches searchBarPlaceholder:NSLocalizedString(@"请输入搜索内容", @"搜索") didSearchBlock:^(PYSearchViewController *searchViewController, UISearchBar *searchBar, NSString *searchText) {
        // Called when search begain.
        SCComicRankViewController *controller = [[SCComicRankViewController alloc] init];
        controller.searchTag = searchText;
        
        controller.title = [NSString stringWithFormat:@"'%@'搜索结果",searchText];
        [searchViewController.navigationController pushViewController:controller animated:YES];
    }];
    // 3. Set style for popular search and search history
    
    searchViewController.hotSearchStyle = 0;
    searchViewController.searchHistoryStyle = PYHotSearchStyleDefault;
    
    // 4. Set delegate
    searchViewController.delegate = self;
    
    // 5. Present(Modal) or push search view controller
    searchViewController.searchViewControllerShowMode = PYSearchViewControllerShowModePush;
    // Push search view controller
    [self.navigationController pushViewController:searchViewController animated:YES];
}

/**
 初始化动画背景
 */
-(void)initBackgrond{
    KenBurnsView *kenView =[[KenBurnsView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    kenView.layer.borderWidth = 1;
    kenView.layer.borderColor = [UIColor blackColor].CGColor;
    kenView.delegate = self;
    NSArray *myImages = [NSArray arrayWithObjects:[UIImage imageNamed:@"tiankong1"],nil];
    [kenView animateWithImages:myImages
            transitionDuration:15
                          loop:YES
                   isLandscape:YES];
    [self.view addSubview:kenView];
}

//------------------------------------搜索框
/**
 1.在PYSearchSuggestionViewController添加了self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag 滑动可收起键盘
 2.在PYSearchSuggestionViewController中修改了tableview的frame的高减去20
 */
#pragma mark - PYSearchViewControllerDelegate
- (void)searchViewController:(PYSearchViewController *)searchViewController searchTextDidChange:(UISearchBar *)seachBar searchText:(NSString *)searchText
{
    if (searchText.length) {
        // Simulate a send request to get a search suggestions
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            NSMutableArray *searchSuggestionsM = [NSMutableArray array];
            int count = 0;
            //搜索的字符被包含在searchTips就加入搜索建议
            for (NSString *title in self.searchTips) {
                if ([title rangeOfString:searchText].location != NSNotFound) {
                    //最多取100个
                    if(count > 99){
                        break;
                    }
                    [searchSuggestionsM addObject:title];
                    count ++;
                }
            }
            
            // Refresh and display the search suggustions
            searchViewController.searchSuggestions = searchSuggestionsM;
        });
    }
}

/**
保存所有漫画名称供搜索提示用
 */
-(void)requestAllComicData{
    NSString * indexUrl = [NSString stringWithFormat:@"%@/comic-all/%d/10000",domainUrl,1];
    SCNetWorkManager *manager = [SCNetWorkManager sharedManager];
    [manager requestWithMethod:GET withUrl:indexUrl withParams:nil withSuccessBlock:^(id response) {
        [self.searchTips removeAllObjects];
        for (NSDictionary *comicDict in response) {
            [self.searchTips addObject:comicDict[@"title"]];
        }
        //如果取到数据则保存
        if(self.searchTips.count > 1){
            [self writeData:self.searchTips];
        }
        
    } withFailurBlock:^(NSError *error) {
        [SCPrompt showTips:self.view withContent:@"网络加载出错，请重试..."];
        
    }];
}

/**
 如果没有历史记录则取得后保存
 */
-(void)getArchiveData{
    self.searchTips = [self readData];
    /**默认取全部漫画，本来等于0，改为小于50为了上线*/
    if(self.searchTips.count < 50){
        [self requestAllComicData];
    }
}




/**
 ---沙盒机制
1.NSDocumentDirectory：用于保存应用运行时生成的需要持久化、非常大的或者需要频繁更新的数据，iTunes会自动备份该目录
2.NSLibraryDirectory：用于存储程序的默认设置和其他状态信息，iTunes会自动备份该目录，主要有两个文件夹：Libaray/Caches和Libaray/Preferences
  2.1.NSCachesDirectory：存放缓存文件，iTunes不会备份此目录，此目录下文件不会在应用退出删除，一般存放体积比较大，不是很重要的资源
  2.2.NSPreferencesDirectory：保存应用的所有偏好设置，iTunes会自动备份该目录
3.NSTemporaryDirectory：保存应用运行时所需的临时数据
 
 ---存储方式
1.NSUserDefaults：用来存储设备和应用的配置、属性、用户的信息
2.文件沙盒存储：用来存储设备和应用的配置、属性、用户的信息
3.NSKeyedArchive：存储数据模型
 */
-(NSMutableArray *)readData{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *fileName = [path stringByAppendingPathComponent:@"searchTips.data"];
    return [NSKeyedUnarchiver unarchiveObjectWithFile:fileName];
}

//归档数据
-(void)writeData:(NSArray *)searchTips{
    
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *fileName = [path stringByAppendingPathComponent:@"searchTips.data"];
    [NSKeyedArchiver archiveRootObject:searchTips toFile:fileName];
}

#pragma -mark 懒加载
-(NSMutableArray *)searchTips{
    if(_searchTips == nil){
        _searchTips = [[NSMutableArray alloc]init];
    }
    return _searchTips;
}


//------------------------------------球
/**
 请求数据
 */
-(void)requestHotComicData{
    NSString *indexUrl = [NSString stringWithFormat:@"%@/comic-random-recommend-ios-search/",domainUrl];
    
    SCNetWorkManager *manager = [SCNetWorkManager sharedManager];
    [manager requestWithMethod:GET withUrl:indexUrl withParams:nil withSuccessBlock:^(id response) {
        self.comicsHot = [SCComic mj_objectArrayWithKeyValuesArray:response];
        [self initSphereView:self.comicsHot];
        [self.sphereView timerStart];
    } withFailurBlock:^(NSError *error) {
         [SCPrompt showTips:self.view withContent:@"网络加载出错，请重试..."];
        
    }];
}

/**
计算文字的frame
 */
-(CGSize)calTextFrame:(NSString *)text{
    NSDictionary *dict = @{NSFontAttributeName : [UIFont systemFontOfSize:16]};
    NSString *contentStr = text;
    CGSize size=[contentStr boundingRectWithSize:CGSizeMake(120, 60) options:NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil].size;
    return size;
}


/**
初始化球体
 */
-(void)initSphereView:(NSArray *)comicsHot{
    self.view.backgroundColor = [UIColor whiteColor];
    CGFloat sphereViewW = self.view.frame.size.width - 30 * 2;
    CGFloat sphereViewH = sphereViewW;
    self.sphereView = [[XLSphereView alloc] initWithFrame:CGRectMake(30, 150, sphereViewW, sphereViewH)];
    
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:0];
    for (NSInteger i = 0; i < comicsHot.count; i ++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        NSString *comicTitle = [comicsHot[i] title];
        //保存每个漫画的tag
        btn.tag = i;
        //计算漫画名称的frame
        CGSize size = [self calTextFrame:comicTitle];
        [btn setTitle:[NSString stringWithFormat:@"%@", comicTitle] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:16];
        btn.frame = CGRectMake(0, 0, size.width, size.height);
        //多余截断不要省略号
        btn.titleLabel.lineBreakMode =  NSLineBreakByWordWrapping;
        [btn addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [array addObject:btn];
        [self.sphereView addSubview:btn];
    }
    [self.sphereView setItems:array];
    [self.view addSubview:self.sphereView];
}


/**
执行跳转到漫画页面
 */
- (void)buttonPressed:(UIButton *)btn
{
    [self.sphereView timerStop];
    
    [UIView animateWithDuration:0.3 animations:^{
        btn.transform = CGAffineTransformMakeScale(2., 2.);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
            btn.transform = CGAffineTransformMakeScale(1., 1.);
        } completion:^(BOOL finished) {
            
            SCComic *comic = self.comicsHot[btn.tag];
            SCComicViewController *comicController = [[SCComicViewController alloc] init];
            comicController.ID = comic.ID;
            comicController.titlePicAddr = comic.titlePicAddr;
            comicController.title = comic.title;
            
            [self.navigationController pushViewController:comicController animated:YES];
        }];
    }];

}


@end

