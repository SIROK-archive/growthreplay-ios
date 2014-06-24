//
//  GRNetworkUtils.h
//  replay
//
//  Created by A13048 on 2014/01/31.
//  Copyright (c) 2014年 SIROK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GRDeviceUtils : NSObject

+ (GRDeviceUtils *)sharedInstance;
- (BOOL)networkIsWiFi;
- (float)getCurrentDeviceVersion;
- (unsigned int)getFreeMemory;
- (uint64_t)getCPUUsage;
- (NSString *)getPlatformString;

@end
