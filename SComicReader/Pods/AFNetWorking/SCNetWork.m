//
//  SCNetWork.m
//  SComicReader
//
//  Created by 冰河依然在 on 2018/5/5.
//  Copyright © 2018年 shuchang. All rights reserved.
//

#import "SCNetWork.h"

@implementation SCNetWork

+(AFHTTPSessionManager *)sharedManager
{
    static AFHTTPSessionManager *manager = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        manager = [AFHTTPSessionManager manager];
        //最大请求并发任务数
        manager.operationQueue.maxConcurrentOperationCount = 2;
        // 超时时间
        manager.requestSerializer.timeoutInterval=30.f;
        //返回格式 JSON
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        // 设置接收的Content-Type
        manager.responseSerializer.acceptableContentTypes = [[NSSet alloc] initWithObjects:@"application/xml", @"text/xml",@"text/html", @"application/json",@"text/plain",nil];
        
        [manager.requestSerializer setValue:@"gzip" forHTTPHeaderField:@"Content-Encoding"];
        
        
    });
    return manager;
}

+(NSDictionary *)getRequest:(NSString *)url parameters:(NSDictionary *)parameters
{
    __block NSDictionary *dict = nil;
    //AFN管理者调用get请求方法,post的话用POST替代GET
    [[self sharedManager] GET:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //请求成功返回数据 根据responseSerializer 返回不同的数据格式
        
        dict = responseObject;
        NSLog(@"responseObject0-->%@",dict);
        

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        //请求失败
        NSLog(@"error-->%@",error);
    }];
    NSLog(@"responseObject1-->%@",dict);
    return dict;
}

//返回的时候取消网络请求
+(void)cencelRequest{
    [[self sharedManager].operationQueue cancelAllOperations];
}
@end
