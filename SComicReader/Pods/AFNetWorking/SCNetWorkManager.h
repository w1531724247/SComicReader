//
//  SCNetworkNew.h
//  SComicReader
//
//  Created by 冰河依然在 on 2018/5/6.
//  Copyright © 2018年 shuchang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AFNetworking.h>

typedef enum {
    GET,
    POST,
    PUT,
    DELETE,
    HEAD
} HTTPMethod;

//请求成功回调block
typedef void (^requestSuccessBlock)(id response);

//请求失败回调block
typedef void (^requestFailureBlock)(NSError *error);

@interface SCNetWorkManager : AFHTTPSessionManager


/**
 创建网络请求工具类的单例
 */
+ (instancetype)sharedManager;

/**
 创建请求方法
 */
- (void)requestWithMethod:(HTTPMethod)method
                 withUrl:(NSString *)url
               withParams:(NSDictionary*)params
         withSuccessBlock:(requestSuccessBlock)success
          withFailurBlock:(requestFailureBlock)failure;

//返回的时候取消网络请求
-(void)cencelRequest;
@end
