//
//  GPHttpRequest.m
//  pickaxe
//
//  Created by Kataoka Naoyuki on 2013/07/03.
//  Copyright (c) 2013年 SIROK, Inc. All rights reserved.
//

#import "GRHttpRequest.h"
#import "GRUtils.h"

@implementation GRHttpRequest

@synthesize requestMethod;
@synthesize contentType;
@synthesize version;
@synthesize path;
@synthesize query;
@synthesize body;

+ (id) instanceWithRequestMethod:(GRRequestMethod)requestMethod version:(NSString*)version path:(NSString *)path {

    GRHttpRequest *httpRequest = [[self alloc] init];

    httpRequest.requestMethod = requestMethod;
    httpRequest.version = version;
    httpRequest.path = path;

    return httpRequest;

}

+ (id) instanceWithRequestMethod:(GRRequestMethod)requestMethod version:(NSString*)version path:(NSString *)path query:(NSDictionary *)query {

    GRHttpRequest *httpRequest = [self instanceWithRequestMethod:requestMethod version:version path:path];

    httpRequest.query = query;

    return httpRequest;

}

+ (id) instanceWithRequestMethod:(GRRequestMethod)requestMethod version:(NSString*)version path:(NSString *)path query:(NSDictionary *)query body:(NSDictionary *)body {
    
    GRHttpRequest *httpRequest = [self instanceWithRequestMethod:requestMethod version:version path:path query:query];
    
    httpRequest.body = body;
    
    return httpRequest;
    
}

+ (id) instanceWithRequestMethod:(GRRequestMethod)requestMethod version:(NSString*)version path:(NSString *)path query:(NSDictionary *)query body:(NSDictionary *)body contentType:(GRContentType)contentType {
    
    GRHttpRequest *httpRequest = [self instanceWithRequestMethod:requestMethod version:version path:path query:query body:body];
    
    httpRequest.contentType = contentType;
    
    return httpRequest;
    
}

- (void) dealloc {

    self.path = nil;
    self.query = nil;
    self.body = nil;

}

- (NSURLRequest *) urlRequestWithBaseUrl:(NSURL *)baseUrl {
    
    if(contentType == GRContentTypeUnknown)
        contentType = GRContentTypeJson;

    NSString *requestPath = [NSString stringWithFormat:@"%@/%@", version, path ? path : @""];
    NSMutableDictionary *requestQuery = [NSMutableDictionary dictionaryWithDictionary:query];
    NSData *requestBody = nil;
    NSString *contentTypeString = nil;

    if (requestMethod == GRRequestMethodGet) {
        [requestQuery addEntriesFromDictionary:body];
    } else {
        switch (contentType) {
            case GRContentTypeFormUrlEncoded:
                requestBody = [GRHttpUtils formUrlencodedBodyWithDictionary:body];
                break;
            case GRContentTypeJson:
                requestBody = [GRHttpUtils jsonBodyWithDictionary:body];
                break;
            case GRContentTypeMultipart:
                requestBody = [GRHttpUtils multipartBodyWithDictionary:body];
                break;
            default:
                break;
        }
    }
    
    switch (contentType) {
        case GRContentTypeMultipart:
            contentTypeString = [NSString stringWithFormat:@"%@; boundary=%@; charset=%@", NSStringFromContnetType(contentType), kMultipartBoundary, CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding))];
            break;
        default:
            contentTypeString = [NSString stringWithFormat:@"%@; charset=%@", NSStringFromContnetType(contentType), CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding))];
            break;
    }
    
    NSString *requestQueryString = [GRHttpUtils queryStringWithDictionary:requestQuery];

    if ([requestQueryString length] > 0) {
        requestPath = [NSString stringWithFormat:@"%@?%@", requestPath, requestQueryString];
    }

    NSURL *url = [NSURL URLWithString:requestPath relativeToURL:baseUrl];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setHTTPMethod:NSStringFromGRRequestMethod(requestMethod)];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];

    if (requestMethod != GRRequestMethodGet) {
        [urlRequest setValue:contentTypeString forHTTPHeaderField:@"Content-Type"];
        [urlRequest setHTTPBody:requestBody];
    }

    return urlRequest;

}

@end
