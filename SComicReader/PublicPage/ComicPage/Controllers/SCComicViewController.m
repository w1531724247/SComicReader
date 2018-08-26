//
//  SCComicViewController.m
//  SComicReader
//
//  Created by 冰河依然在 on 2018/5/23.
//  Copyright © 2018年 shuchang. All rights reserved.
//

#import "SCComicViewController.h"
#import "SCComicInfoViewController.h"
#import "SCComicChapterViewController.h"
#import <UIImageView+WebCache.h>
#import "SCNetWorkManager.h"
#import "SCComic.h"
#import "SCComicChapter.h"
#import <MJExtension.h>
#import "SCPrompt.h"
#import "SCConst.h"


@interface SCComicViewController ()
@property (nonatomic, strong) NSArray *musicCategories;
@property (nonatomic, assign) CGPoint lastPoint;
@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, assign) CGFloat viewTop;

@property (nonatomic,strong) NSArray *chapters;
@property (nonatomic,strong) SCComic *comic;


@end

@implementation SCComicViewController

- (void)viewDidLoad {
    //放在最前面，不然图片要覆盖切换controller
    [self initImageView:self.titlePicAddr];

    [super viewDidLoad];
    [self setProperty];
    
}


/**
 请求漫画页面的数据并保存到模型
 */
-(void)requestComicData:(NSString *)ID{
    //加载首页的数据
    NSString *indexUrl = [NSString stringWithFormat:@"%@/comic-type-chapter/%@/",domainUrl,ID];
    SCNetWorkManager *manager = [SCNetWorkManager sharedManager];
    [manager requestWithMethod:GET withUrl:indexUrl withParams:nil withSuccessBlock:^(id response) {
        NSDictionary *comicDict = [response valueForKey:@"comic_type_summary"];
        NSArray *chaptersDict = [response valueForKey:@"comic_chapter"];
        
        //保存漫画模型数据
        self.comic = [SCComic mj_objectWithKeyValues:comicDict];

        self.chapters = [SCComicChapter mj_objectArrayWithKeyValuesArray:chaptersDict];

        [self reloadData];
        
        //添加网络图片
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:self.comic.titlePicAddr] placeholderImage:[UIImage imageNamed:comicPlaceholder]];
        
    } withFailurBlock:^(NSError *error) {
        [SCPrompt showTips:self.view withContent:@"网络加载出错，请重试..."];
        
    }];
}


/**
 读取漫画封面图片
 */

-(void)initImageView:(NSString *)imageUrl{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, kNavigationBarHeight, screenWidth, kWMHeaderViewHeight)];
    /* UIViewContentModeScaleAspectFill导致加载网络图片后imageView的frame改变**/
    imageView.contentMode = UIViewContentModeScaleAspectFill;
//    imageView.contentMode = UIViewContentModeScaleToFill;
    //添加网络图片
    [imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:comicPlaceholder]];
    
    [self.view addSubview:imageView];

}

/**
 控制器个数根据这个来
 */
- (NSArray *)musicCategories {
    if (!_musicCategories) {
        _musicCategories = @[@"详情", @"选集"];
    }
    return _musicCategories;
}



-(void)setProperty{
    self.viewTop = kNavigationBarHeight + kWMHeaderViewHeight;
    self.titleSizeNormal = 15;
    self.titleSizeSelected = 15;
    self.menuViewStyle = WMMenuViewStyleLine;
    self.menuView.backgroundColor = [UIColor colorWithRed:0/255 green:1 blue:1 alpha:0.5];
    self.menuItemWidth = [UIScreen mainScreen].bounds.size.width / self.musicCategories.count;
//    设置后，用reload后样式会出问题
//    self.titleColorSelected = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0];
//    self.titleColorNormal = [UIColor colorWithRed:0.4 green:0.8 blue:0.1 alpha:1.0];
}



// MARK: ChangeViewFrame (Animatable)
- (void)setViewTop:(CGFloat)viewTop {
    _viewTop = viewTop;
    
    if (_viewTop <= kNavigationBarHeight) {
        _viewTop = kNavigationBarHeight;
    }
    
    if (_viewTop > kWMHeaderViewHeight + kNavigationBarHeight) {
        _viewTop = kWMHeaderViewHeight + kNavigationBarHeight;
    }
    
    self.imageView.frame = ({
        CGRect oriFrame = self.imageView.frame;
        oriFrame.origin.y = _viewTop - kWMHeaderViewHeight;
        oriFrame;
    });
    
    [self forceLayoutSubviews];
}


#pragma mark - Datasource & Delegate
- (NSInteger)numbersOfChildControllersInPageController:(WMPageController *)pageController {
    return self.musicCategories.count;
}

- (UIViewController *)pageController:(WMPageController *)pageController viewControllerAtIndex:(NSInteger)index {
    
    switch (index % 2) {
        case 0:
        {
            SCComicInfoViewController *comicInfoController =[[SCComicInfoViewController alloc] init];
            comicInfoController.comicId = self.ID;
            return comicInfoController;
            
        }
        case 1:
        {
            SCComicChapterViewController *chapterController = [[SCComicChapterViewController alloc] init];
            chapterController.comicId = self.ID;
            return chapterController;
        }
    }
    return [[UIViewController alloc] init];
}

- (NSString *)pageController:(WMPageController *)pageController titleAtIndex:(NSInteger)index {
    return self.musicCategories[index];
}

- (CGRect)pageController:(WMPageController *)pageController preferredFrameForMenuView:(WMMenuView *)menuView {
    return CGRectMake(0, _viewTop, self.view.frame.size.width, menuViewHeight);
}

- (CGRect)pageController:(WMPageController *)pageController preferredFrameForContentView:(WMScrollView *)contentView {
    CGFloat originY = _viewTop + menuViewHeight;
    return CGRectMake(0, originY, self.view.frame.size.width, self.view.frame.size.height - originY);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
