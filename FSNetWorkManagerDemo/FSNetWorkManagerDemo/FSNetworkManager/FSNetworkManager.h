//
//  FSNetworkManager.h
//  FSNetWorkManagerDemo
//
//  Created by huim on 2017/3/22.
//  Copyright © 2017年 fengshun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>

typedef NSURLSessionTask FSURLSessionTask;

typedef NS_ENUM(NSUInteger,FSNetRequestType) {
    FS_Get = 0,
    FS_Post,
    FS_Put,
    FS_Delete
};

typedef NS_ENUM(NSUInteger, FSNetworkStatus)
{
    /*! 未知网络 */
    FSNetworkStatusUnknown           = 0,
    /*! 没有网络 */
    FSNetworkStatusNotReachable,
    /*! 手机 3G/4G 网络 */
    FSNetworkStatusReachableViaWWAN,
    /*! wifi 网络 */
    FSNetworkStatusReachableViaWiFi
};

typedef void( ^ FSResponseSuccess)(id responseData);//成功回调

typedef void( ^ FSResponseFailure)(NSError *error);//失败回调

typedef void(^FSNetworkStatusBlock)(FSNetworkStatus status);

@interface FSNetworkManager : NSObject

/*! 获取当前网络状态 */
@property (nonatomic, assign) FSNetworkStatus netWorkStatu;

+ (FSNetworkManager *)sharedFSNetworkManager;

+ (FSURLSessionTask *)FS_requestWithType:(FSNetRequestType)requestType
                              withUrlStr:(NSString *)urlStr
                        withHeaderParams:(NSDictionary *)headerParams
                          withBodyParams:(NSDictionary *)bodyParams
                            successBlock:(FSResponseSuccess)successBlock
                            failureBlock:(FSResponseFailure)failureBlock;

+ (void)FS_startNetWorkMonitoringWithBlock:(FSNetworkStatusBlock)networkStatus;

@end
