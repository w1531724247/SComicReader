//
//  SCBaseHisCollectionViewController.h
//  SComicReader
//
//  Created by 冰河依然在 on 2018/5/26.
//  Copyright © 2018年 shuchang. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SCBaseHisCollectionViewController ;
@protocol SCHisCollectionComicDelegate <NSObject>
-(void)modifyEditNormal:(SCBaseHisCollectionViewController *)controller isEdit:(Boolean)isEdit;
@end

@interface SCBaseHisCollectionViewController : UIViewController
@property (nonatomic,assign) Boolean isEdit;
@property (nonatomic,weak) id<SCHisCollectionComicDelegate> delegate;

@property (weak, nonatomic) UICollectionView *collectionView;
@property (nonatomic,strong) NSArray *comics;
@property (nonatomic,strong) NSMutableArray *selectedComicIds;
@property (nonatomic,weak) UIView *deleteView;
@property (nonatomic,weak) UIButton *selectAllBtn;

-(void)didClickDeleteButton:(UIButton *)sender withKey:(NSString *)key;
@end

