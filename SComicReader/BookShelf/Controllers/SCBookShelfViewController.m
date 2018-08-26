//
//  SCBookShelfViewController.m
//  SComicReader
//
//  Created by 冰河依然在 on 2018/5/17.
//  Copyright © 2018年 shuchang. All rights reserved.
//

#import "SCBookShelfViewController.h"
#import "SCCollectionComicViewController.h"
#import "SCHisComicViewController.h"
#import "SCBaseHisCollectionViewController.h"
#import "SCPrompt.h"
#import "SCConst.h"

@interface SCBookShelfViewController ()<SCHisCollectionComicDelegate>
@property (nonatomic, strong) NSArray *musicCategories;
@property (nonatomic, assign) CGPoint lastPoint;
@property (nonatomic, assign) CGFloat viewTop;
@property (nonatomic,assign) Boolean isEdit;

@end

@implementation SCBookShelfViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化为不可编辑
    self.isEdit = false;
    [self setProperty];
    UIBarButtonItem *myButton = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(didClickEdit:)];
    self.navigationItem.rightBarButtonItem = myButton;
    
}



/**
网络请求同步测试，执行结束后在执行下面的

-(id)requestDataTest{
    NSLog(@"----requestDataTest start");
    NSString *indexUrl = @"https://shuchangx.cn/comic-random-recommend/";
    
    SCNetWorkManager *manager = [SCNetWorkManager sharedManager];
    
    manager.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    __block id response2;
    

    [manager requestWithMethod:GET withUrl:indexUrl withParams:nil withSuccessBlock:^(id response) {
        response2 = response;
        dispatch_semaphore_signal(semaphore);
    } withFailurBlock:^(NSError *error) {
        [SCPrompt showTips:self.view withContent:@"网络加载出错，请重试..."];
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return response2;
}
 */

-(void)didClickEdit:(UIBarButtonItem *)sender{
    self.isEdit = !self.isEdit;
    //修改按钮的title
    if(self.isEdit){
        [sender setTitle:@"取消"];
    }else{
        [sender setTitle:@"编辑"];
    }
    [self reloadData];
}


/**
SCHisComicViewController的代理方法，修改可编辑状态为false
 */
- (void)modifyEditNormal:(SCCollectionComicViewController *)hisComicViewController isEdit:(Boolean)isEdit {
    self.isEdit = isEdit;
    [self.navigationItem.rightBarButtonItem setTitle:@"编辑"];
    [self reloadData];
}

/**
 控制器个数根据这个来
 */
- (NSArray *)musicCategories {
    if (!_musicCategories) {
        _musicCategories = @[@"收藏", @"历史"];
    }
    return _musicCategories;
}


-(void)setProperty{
    self.viewTop = kNavigationBarHeight ;

    self.titleSizeNormal = 15;
    self.titleSizeSelected = 15;
    self.menuViewStyle = WMMenuViewStyleDefault;
    self.menuView.backgroundColor = [UIColor colorWithRed:0/255 green:1 blue:1 alpha:0.5];
    self.menuItemWidth = [UIScreen mainScreen].bounds.size.width / self.musicCategories.count;

}



// MARK: ChangeViewFrame (Animatable)
- (void)setViewTop:(CGFloat)viewTop {
    _viewTop = viewTop;

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
            SCCollectionComicViewController *hisController = [[SCCollectionComicViewController alloc] init];
            hisController.delegate = self;
            hisController.isEdit = self.isEdit;
            return hisController;
        }
        case 1:
        {
            SCHisComicViewController *collectionControlelr = [[SCHisComicViewController alloc] init];
            collectionControlelr.delegate = self;
            collectionControlelr.isEdit = self.isEdit;
            return collectionControlelr;
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



@end
