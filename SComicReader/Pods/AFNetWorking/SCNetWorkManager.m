//
//  SCNetworkNew.m
//  SComicReader
//
//  Created by 冰河依然在 on 2018/5/6.
//  Copyright © 2018年 shuchang. All rights reserved.
//

#import "SCNetWorkManager.h"
#import "AFNetworkActivityIndicatorManager.h"

@interface SCNetWorkManager ()

@end

@implementation SCNetWorkManager

+ (instancetype)sharedManager {
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

-(void)cencelRequest{
    [self.operationQueue cancelAllOperations];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        // 超时时间
        self.requestSerializer.timeoutInterval=30;
        //返回格式 JSON
        self.responseSerializer = [AFJSONResponseSerializer serializer];
        // 设置接收的Content-Type
        self.responseSerializer.acceptableContentTypes = [[NSSet alloc] initWithObjects:@"application/xml", @"text/xml",@"text/html", @"application/json",@"text/plain",nil];
        
        /**设置请求头*/
        [self.requestSerializer setValue:@"gzip" forHTTPHeaderField:@"Content-Encoding"];
        
        //左上角出现加载圆圈
        [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
        
    }
    return self;
}


- (void)requestWithMethod:(HTTPMethod)method
                 withUrl:(NSString *)url
               withParams:(NSDictionary*)params
         withSuccessBlock:(requestSuccessBlock)success
          withFailurBlock:(requestFailureBlock)failure
{
    switch (method) {
        case GET:{
            
            [self GET:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                //请求成功返回数据 根据responseSerializer 返回不同的数据格式
                success(responseObject);
            } failure:^(NSURLSessionTask *operation, NSError *error) {
                failure(error);
            }];
            break;
        }
        case POST:{
            [self POST:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                success(responseObject);
            } failure:^(NSURLSessionTask *operation, NSError *error) {

                failure(error);
            }];
            break;
        }
        default:
            break;
    }
}

@end
