//
//  FSNetworkManager.m
//  FSNetWorkManagerDemo
//
//  Created by huim on 2017/3/22.
//  Copyright © 2017年 fengshun. All rights reserved.
//

#import "FSNetworkManager.h"
#import <AFNetworkActivityIndicatorManager.h>

@implementation FSNetworkManager


static NSMutableArray *tasks;

+ (FSNetworkManager *)sharedFSNetworkManager
{
    static id sharedFSNetworkManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedFSNetworkManager = [[super allocWithZone:NULL] init];
    });
    return sharedFSNetworkManager;
}

+ (id)allocWithZone:(struct _NSZone *)zone
{
    return [FSNetworkManager sharedFSNetworkManager];
}

- (id)copyWithZone:(struct _NSZone *)zone
{
    return [FSNetworkManager sharedFSNetworkManager];
}

+ (NSMutableArray *)tasks
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tasks = [[NSMutableArray alloc] init];
    });
    return tasks;
}

+ (AFHTTPSessionManager *)sharedAFHttpManager
{
    static AFHTTPSessionManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [AFHTTPSessionManager manager];
        manager.requestSerializer.timeoutInterval = 30;
        
        [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
        
        AFJSONResponseSerializer *response = [AFJSONResponseSerializer serializer];
        response.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"text/css",@"text/xml",@"text/plain", @"application/javascript", @"image/*", nil];
        response.removesKeysWithNullValues = YES;
        manager.responseSerializer = response;
        
    });
    return manager;
}


+ (FSURLSessionTask *)FS_requestWithType:(FSNetRequestType)requestType
                             withUrlStr:(NSString *)urlStr
                       withHeaderParams:(NSDictionary *)headerParams
                        withBodyParams:(NSDictionary *)bodyParams
                           successBlock:(FSResponseSuccess)successBlock
                           failureBlock:(FSResponseFailure)failureBlock
{
    if (!urlStr || urlStr.length <= 0) {
        return nil;
    }
    
    urlStr = [NSURL URLWithString:urlStr] ? urlStr:[self strUTF8Encoding:urlStr];
    
    AFJSONRequestSerializer *request = [AFJSONRequestSerializer serializer];
    
    NSArray *allKeys = [headerParams allKeys];
    for (NSString *key in allKeys) {
        [request setValue:headerParams[key] forHTTPHeaderField:key];//添加请求头参数
    }
    [self sharedAFHttpManager].requestSerializer = request;
    
    FSURLSessionTask *sessionTask = nil;
    
    __weak __typeof(self) weakSelf = self;
    
    if (requestType == FS_Get) {
        
        sessionTask = [[self sharedAFHttpManager] GET:urlStr parameters:bodyParams progress:^(NSProgress * _Nonnull downloadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            if (successBlock)
            {
                successBlock(responseObject);
            }
            
            [[weakSelf tasks] removeObject:sessionTask];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            if (failureBlock)
            {
                failureBlock(error);
            }
            [[weakSelf tasks] removeObject:sessionTask];
            
        }];
        
    }
    else if (requestType == FS_Post){
        
        sessionTask = [[self sharedAFHttpManager] POST:urlStr parameters:bodyParams progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            if (successBlock)
            {
                successBlock(responseObject);
            }
            
            [[weakSelf tasks] removeObject:sessionTask];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            if (failureBlock)
            {
                failureBlock(error);
            }
            [[weakSelf tasks] removeObject:sessionTask];
            
        }];
        
    }
    else if (requestType == FS_Put){
        
        sessionTask = [[self sharedAFHttpManager] PUT:urlStr parameters:bodyParams success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            if (successBlock)
            {
                successBlock(responseObject);
            }
            
            [[weakSelf tasks] removeObject:sessionTask];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            if (failureBlock)
            {
                failureBlock(error);
            }
            [[weakSelf tasks] removeObject:sessionTask];
            
        }];
        
    }
    else if (requestType == FS_Delete){
        
        sessionTask = [[self sharedAFHttpManager] DELETE:urlStr parameters:bodyParams success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            if (successBlock)
            {
                successBlock(responseObject);
            }
            
            [[weakSelf tasks] removeObject:sessionTask];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            if (failureBlock)
            {
                failureBlock(error);
            }
            [[weakSelf tasks] removeObject:sessionTask];
            
        }];
        
    }
    if (sessionTask)
    {
        [[weakSelf tasks] addObject:sessionTask];
    }
    
    return sessionTask;
}

/*!
 *  开启网络监测
 */
+ (void)FS_startNetWorkMonitoringWithBlock:(FSNetworkStatusBlock)networkStatus
{
    /*! 1.获得网络监控的管理者 */
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    /*! 当使用AF发送网络请求时,只要有网络操作,那么在状态栏(电池条)wifi符号旁边显示  菊花提示 */
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    /*! 2.设置网络状态改变后的处理 */
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status)
        {
            case AFNetworkReachabilityStatusUnknown:
                NSLog(@"未知网络");
                networkStatus ? networkStatus(FSNetworkStatusUnknown) : nil;
                [FSNetworkManager sharedFSNetworkManager].netWorkStatu = FSNetworkStatusUnknown;
                break;
            case AFNetworkReachabilityStatusNotReachable:
                NSLog(@"没有网络");
                networkStatus ? networkStatus(FSNetworkStatusNotReachable) : nil;
                [FSNetworkManager sharedFSNetworkManager].netWorkStatu = FSNetworkStatusUnknown;
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                NSLog(@"手机自带网络");
                networkStatus ? networkStatus(FSNetworkStatusReachableViaWWAN) : nil;
                [FSNetworkManager sharedFSNetworkManager].netWorkStatu = FSNetworkStatusUnknown;
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                NSLog(@"wifi 网络");
                networkStatus ? networkStatus(FSNetworkStatusReachableViaWiFi) : nil;
                [FSNetworkManager sharedFSNetworkManager].netWorkStatu = FSNetworkStatusUnknown;
                break;
        }
    }];
    [manager startMonitoring];
}

#pragma mark - url 中文格式化
+ (NSString *)strUTF8Encoding:(NSString *)str
{
    if ([[UIDevice currentDevice] systemVersion].floatValue >= 9.0)
    {
        return [str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]];
    }
    else
    {
        return [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
}

@end
