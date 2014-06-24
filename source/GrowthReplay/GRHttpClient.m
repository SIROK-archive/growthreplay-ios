//
//  GPHttpClient.m
//  pickaxe
//
//  Created by Kataoka Naoyuki on 2013/07/03.
//  Copyright (c) 2013年 SIROK, Inc. All rights reserved.
//

#import "GRHttpClient.h"

static GRHttpClient *sharedInstance = nil;

NSString *const GrowthReplayErrorDomain = @"GrowthReplayErrorDomain";
NSString *const GRHttpClientURLResponseKey = @"GRHttpClientURLResponse";

@interface GRHttpClient () {

    NSURL *baseUrl;

}

@property (nonatomic) NSURL *baseUrl;

@end

@implementation GRHttpClient

@synthesize baseUrl;

+ (GRHttpClient *) sharedInstance {
    @synchronized(self) {
        if (!sharedInstance) {
            sharedInstance = [[self alloc] init];
        }
        return sharedInstance;
    }
}

- (void) httpRequest:(GRHttpRequest *)httpRequest success:(void (^)(GRHttpResponse *httpResponse))success fail:(void (^)(GRHttpResponse *httpResponse))fail {

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

            NSURLRequest *urlRequest = [httpRequest urlRequestWithBaseUrl:baseUrl];
            NSHTTPURLResponse *urlResponse = nil;
            NSError *error = nil;
            NSData *data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&urlResponse error:&error];

            if (error) {
                GRHttpResponse *httpResponse = [GRHttpResponse instanceWithUrlRequest:urlRequest httpUrlResponse:urlResponse error:error body:nil];
                if (fail) {
                    fail(httpResponse);
                }
                return;
            }

            NSError *_error = nil;
            id body = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&_error];

            GRHttpResponse *httpResponse = [GRHttpResponse instanceWithUrlRequest:urlRequest httpUrlResponse:urlResponse error:nil body:body];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (urlResponse.statusCode >= 200 && urlResponse.statusCode < 300) {
                    if (success) {
                        success(httpResponse);
                    }
                } else {
                    NSDictionary *userInfo = @{
                        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Request failed with status code %d",
                        urlResponse.statusCode],
                        NSURLErrorFailingURLErrorKey: urlResponse.URL,
                        GRHttpClientURLResponseKey: urlResponse
                    };
                    httpResponse.error = [NSError errorWithDomain:GrowthReplayErrorDomain code:0 userInfo:userInfo];
                    if (fail) {
                        fail(httpResponse);
                    }
                }
            });

        });

}

@end
