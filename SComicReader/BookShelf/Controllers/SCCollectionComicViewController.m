//
//  SCHisComicViewController.m
//  SComicReader
//
//  Created by 冰河依然在 on 2018/5/24.
//  Copyright © 2018年 shuchang. All rights reserved.
//

#import "SCCollectionComicViewController.h"
#import "SCComic.h"
#import <MJExtension.h>

@interface SCCollectionComicViewController ()

@end

@implementation SCCollectionComicViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}

-(void)viewWillAppear:(BOOL)animated{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *comicDicts = [defaults objectForKey:@"collection_comics"];
    self.comics = [SCComic mj_objectArrayWithKeyValuesArray:comicDicts];

    
    self.selectAllBtn.selected = false;
    //移除所有选中的漫画记录的id
    [self.selectedComicIds removeAllObjects];
    //刷新数据
    [self.collectionView reloadData];

}

-(void)didClickDeleteButton:(UIButton *)sender withKey:(NSString *)key{
    [super didClickDeleteButton:sender withKey:@"collection_comics"];
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
