//
//  GrowthReplay.h
//  replay
//
//  Created by A13048 on 2014/01/23.
//  Copyright (c) 2014年 SIROK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GrowthReplay : NSObject

+ (void)initializeWithApplicationId:(NSInteger)applicationId secret:(NSString *)secret debug:(BOOL)debug;

+ (void)setTag:(NSString *)name value:(NSString *)value;

+ (void)setDeviceTags;

+ (void)start;

+ (void)stop;

+ (void) setSpot:(NSString *)spot;

@end
