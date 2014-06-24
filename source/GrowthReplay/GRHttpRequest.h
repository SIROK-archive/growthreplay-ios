//
//  GPHttpRequest.h
//  pickaxe
//
//  Created by Kataoka Naoyuki on 2013/07/03.
//  Copyright (c) 2013年 SIROK, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GRRequestMethod.h"
#import "GRContentType.h"

@interface GRHttpRequest : NSObject {

    GRRequestMethod requestMethod;
    GRContentType contentType;
    NSString *version;
    NSString *path;
    NSDictionary *query;
    NSDictionary *body;

}

@property (nonatomic) GRRequestMethod requestMethod;
@property (nonatomic) GRContentType contentType;
@property (nonatomic) NSString *version;
@property (nonatomic) NSString *path;
@property (nonatomic) NSDictionary *query;
@property (nonatomic) NSDictionary *body;

+ (id)instanceWithRequestMethod:(GRRequestMethod)requestMethod version:(NSString*)version path:(NSString *)path;
+ (id)instanceWithRequestMethod:(GRRequestMethod)requestMethod version:(NSString*)version path:(NSString *)path query:(NSDictionary *)query;
+ (id)instanceWithRequestMethod:(GRRequestMethod)requestMethod version:(NSString*)version path:(NSString *)path query:(NSDictionary *)query body:(NSDictionary *)body;
+ (id)instanceWithRequestMethod:(GRRequestMethod)requestMethod version:(NSString*)version path:(NSString *)path query:(NSDictionary *)query body:(NSDictionary *)body contentType:(GRContentType)contentType;

- (NSURLRequest *)urlRequestWithBaseUrl:(NSURL *)baseUrl;

@end
