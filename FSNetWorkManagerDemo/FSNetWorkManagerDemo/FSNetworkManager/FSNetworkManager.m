//
//  FSNetworkManager.m
//  FSNetWorkManagerDemo
//
//  Created by huim on 2017/3/22.
//  Copyright © 2017年 fengshun. All rights reserved.
//

#import "FSNetworkManager.h"
#import <AFNetworking.h>
#import <AFNetworkActivityIndicatorManager.h>

@implementation FSNetworkManager


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

@end
