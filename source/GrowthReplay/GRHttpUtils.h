//
//  GPHttpUtils.h
//  pickaxe
//
//  Created by Kataoka Naoyuki on 2013/07/03.
//  Copyright (c) 2013年 SIROK, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kMultipartBoundary (@"----------V2ymHFg03ehbqgZCaKO6jy")

@interface GRHttpUtils : NSObject

+ (NSString *)queryStringWithDictionary:(NSDictionary *)params;
+ (NSData *)formUrlencodedBodyWithDictionary:(NSDictionary *)params;
+ (NSData *)jsonBodyWithDictionary:(NSDictionary *)params;
+ (NSData *)multipartBodyWithDictionary:(NSDictionary *)params;

@end
