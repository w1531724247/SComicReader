//
//  SCNetWork.h
//  SComicReader
//
//  Created by 冰河依然在 on 2018/5/5.
//  Copyright © 2018年 shuchang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>

@interface SCNetWork : NSObject
+(NSDictionary *)getRequest:(NSString *)url parameters:(NSDictionary *)parameters;
+(void)cencelRequest;
@end
