//
//  SCBaseHisCollectionViewController.m
//  SComicReader
//
//  Created by 冰河依然在 on 2018/5/26.
//  Copyright © 2018年 shuchang. All rights reserved.
//

#import "SCBaseHisCollectionViewController.h"
#import "SCWaterfallFlowLayout.h"
#import "SCComicCollectionViewCell.h"
#import "SCComicViewController.h"
#import "SCConst.h"
#import <MJExtension.h>
#import "SCComic.h"
#import "SCPrompt.h"



@interface SCBaseHisCollectionViewController ()<SCWaterfallFlowLayoutDataSource,UICollectionViewDataSource,UICollectionViewDelegate>

@end

@implementation SCBaseHisCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initColleciontView];
    //创建deleteView
    if(self.isEdit){
        [self createDeleteView];
    }else{
        if(self.deleteView != nil){
            [self.deleteView removeFromSuperview];
        }
    }
}

#pragma -mark 懒加载

-(NSArray *)selectedComicIds{
    if(_selectedComicIds == nil){
        _selectedComicIds = [NSMutableArray array];
    }
    return _selectedComicIds;
}

/**
 创建删除的view
 */
-(void)createDeleteView{
    UIView *deleteView = [[UIView alloc]init];
    deleteView.backgroundColor = [UIColor colorWithRed:0/255 green:1 blue:1 alpha:0.5];
    deleteView.frame = CGRectMake(0, CGRectGetMaxY(self.collectionView.frame)-deleteViewHeight, screenWidth, deleteViewHeight);
//    deleteView.frame = CGRectMake(0, CGRectGetMaxY(self.view.frame)-tabBarHeight, screenWidth,deleteViewHeight);
    /**让deleteView不挡住collectionView的frame*/
    self.collectionView.frame = CGRectMake(0, 0, screenWidth, screenHeight -deleteViewHeight-kNavigationBarHeight-menuViewHeight-tabBarHeight);
    //创建全选按钮
    UIButton *selectAllBtn = [[UIButton alloc]init];
    selectAllBtn.frame = CGRectMake(10, 7.5, 35, 35);
    [selectAllBtn setImage:[UIImage imageNamed:@"gou"] forState:UIControlStateNormal];
    [selectAllBtn setImage:[UIImage imageNamed:@"gou-actived"] forState:UIControlStateSelected];
    //全选按钮，用于界面出现前设置未选中状态
    self.selectAllBtn = selectAllBtn;
    
    //注册单击事件，点击全选按钮
    [selectAllBtn addTarget:self action:@selector(didClickSelectAllButton:) forControlEvents:UIControlEventTouchDown];
    
    //创建描述
    UILabel *label = [[UILabel alloc]init];
    label.frame = CGRectMake(50, 5, 100, 40);
    label.textColor = [UIColor blackColor];
    label.adjustsFontSizeToFitWidth = YES;
    label.text = @"全选";
    //创建删除按钮
    UIButton *deleteBtn = [[UIButton alloc]init];
    deleteBtn.frame = CGRectMake(screenWidth - 100, 0, 100, deleteViewHeight);
    deleteBtn.backgroundColor = [UIColor redColor];
    deleteBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [deleteBtn setTitle:@"确定删除" forState:UIControlStateNormal];
    [deleteBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //注册单击事件，点击删除按钮
    [deleteBtn addTarget:self action:@selector(didClickDeleteButton:withKey:) forControlEvents:UIControlEventTouchDown];
    
    //加入父容器
    [deleteView addSubview:selectAllBtn];
    [deleteView addSubview:label];
    [deleteView addSubview:deleteBtn];
    [self.view addSubview:deleteView];
    [self.view bringSubviewToFront:deleteView];
    
    self.deleteView = deleteView;
}


/**
 点击删除按钮
 */
-(void)didClickDeleteButton:(UIButton *)sender withKey:(NSString *)key{
    if(self.selectedComicIds.count > 0){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"是否删除" message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        //创建取消按钮
        UIAlertAction *anctionCancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        
        //创建确定按钮
        UIAlertAction *anctionOK = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //取得保存的持久化收藏记录
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSArray *comicDicts = [defaults objectForKey:key];
            
            //复制删除的数组
            NSMutableArray *comicsCopy = [comicDicts mutableCopy];
            for (NSString *comicId in self.selectedComicIds) {
                //遍历collectionview的漫画并删除
                for (int i = 0; i < comicsCopy.count; i ++) {
                    NSDictionary *comic = comicsCopy[i];
                    if([comic[@"id"] isEqualToString:comicId]){
                        [comicsCopy removeObject:comic];
                    }
                }
            }
            //保存到偏好文件
            [defaults setObject:comicsCopy forKey:key];
            //取消编辑，使用代理方式修改SCBookShelfViewController的rightBarButtonItem的可编辑状态,包含刷新
            if ([self.delegate respondsToSelector:@selector(modifyEditNormal:isEdit:)]) {
                [self.delegate modifyEditNormal:self isEdit:false];
            }
        }];
        
        [alert addAction:anctionCancel];
        [alert addAction:anctionOK];
        
        //显示alert
        [self presentViewController:alert animated:YES completion:nil];
    }else{
        [SCPrompt showText:self.view withContent:@"请至少选中一个删除"];
    }
 
}


/**
 点击全选按钮事件
 */
-(void)didClickSelectAllButton:(UIButton *)sender{
    sender.selected = !sender.selected;
    //修改样式cell
    for (SCComicCollectionViewCell *cell in self.collectionView.visibleCells) {
        if(sender.selected){
            cell.isSelected = true;
        }else{
            cell.isSelected = false;
        }
    }
    if(sender.selected){
        //取得所有comicId
        for (SCComic *comic in self.comics) {
            //不包含则加入
            if(![self.selectedComicIds containsObject:comic.ID]){
                [self.selectedComicIds addObject:comic.ID];
            }
        }
    }else{
        [self.selectedComicIds removeAllObjects];
    }
    
}

/**
 初始化collectionview
 */
-(void)initColleciontView{
    //创建布局对象
    SCWaterfallFlowLayout *layout = [[SCWaterfallFlowLayout alloc]init];
    //创建collectionview
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight -kNavigationBarHeight-menuViewHeight-tabBarHeight) collectionViewLayout:layout];
    //    collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight ;
    //背景自带黑色，需要设置
    collectionView.backgroundColor = [UIColor whiteColor];
    
    layout.dataSource = self;
    collectionView.dataSource = self;
    collectionView.delegate = self;
    
    //注册cell
    [collectionView registerClass:[SCComicCollectionViewCell class] forCellWithReuseIdentifier:comicCellId];
    
    
    [self.view addSubview:collectionView];
    //    [self.scrollView2 addSubview:collectionView];
    self.collectionView = collectionView;
}



#pragma -mark collectionView代理方法

/**
 点击cell
 */
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if(self.isEdit){
        //取得当前cell
        SCComicCollectionViewCell * cell = (SCComicCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
        NSString *comicId = cell.comic.ID;
        cell.isSelected = !cell.isSelected;
        //保存选中的漫画id,选中则保存，取消选中则移除
        if(cell.isSelected){
            [self.selectedComicIds addObject:comicId];
        }else{
            if([self.selectedComicIds containsObject:comicId]){
                [self.selectedComicIds removeObject:comicId];
            }
        }
        
    }else{
        SCComic *comic = self.comics[indexPath.row];
        SCComicViewController *comicController = [[SCComicViewController alloc] init];
        comicController.ID = comic.ID;
        comicController.titlePicAddr = comic.titlePicAddr;
        comicController.title = comic.title;
        [self.navigationController pushViewController:comicController animated:YES];
    }
    
    
}

#pragma -mark collectionView数据源方法
//返回多少组
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
    
}

//返回每组多少个
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return self.comics.count;
}

//每个cell的内容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SCComic *comic = self.comics[indexPath.row];
    
    SCComicCollectionViewCell *cell = [SCComicCollectionViewCell cellWithCollectionView:collectionView withIndexPath:indexPath withID:comicCellId];
    
    cell.comic = comic;
    //初始未选中状态
    cell.isSelected = false;
    cell.isEdit = self.isEdit;
    
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
    return UIEdgeInsetsMake(10, 10, 10.0, 10);
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
@end
