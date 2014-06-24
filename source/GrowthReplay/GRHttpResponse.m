//
//  GPHttpResponse.m
//  pickaxe
//
//  Created by Kataoka Naoyuki on 2013/07/03.
//  Copyright (c) 2013年 SIROK, Inc. All rights reserved.
//

#import "GRHttpResponse.h"

@implementation GRHttpResponse

@synthesize urlRequest;
@synthesize httpUrlResponse;
@synthesize error;
@synthesize body;

+ (id) instanceWithUrlRequest:(NSURLRequest *)urlRequest httpUrlResponse:(NSHTTPURLResponse *)httpUrlResponse error:(NSError *)error body:(id)body {

    GRHttpResponse *httpResponse = [[self alloc] init];

    httpResponse.urlRequest = urlRequest;
    httpResponse.httpUrlResponse = httpUrlResponse;
    httpResponse.error = error;
    httpResponse.body = body;

    return httpResponse;

}

@end
