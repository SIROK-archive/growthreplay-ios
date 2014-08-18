//
//  GRTagService.m
//  replay
//
//  Created by A13048 on 2014/01/29.
//  Copyright (c) 2014年 SIROK. All rights reserved.
//

#import "GRTagService.h"
#import "GBUtils.h"

static GRTagService *sharedInstance = nil;

@implementation GRTagService

+ (GRTagService *) sharedInstance {
    @synchronized(self) {
        if (!sharedInstance) {
            sharedInstance = [[self alloc] init];
        }
        return sharedInstance;
    }
}

- (void) setTag:(NSString *)clientId credentialId:(NSString *)credentialId name:(NSString *)name value:(NSString *)value success:(void (^)(void))success fail:(void (^)(NSInteger, NSError *))fail {

    NSString *path = @"v3/tag";
    NSMutableDictionary *body = [NSMutableDictionary dictionary];

    if (clientId) {
        [body setObject:clientId forKey:@"clientId"];
    }
    if (credentialId) {
        [body setObject:credentialId forKey:@"credentialId"];
    }
    if (name) {
        [body setObject:name forKey:@"name"];
    }
    if (value) {
        [body setObject:value forKey:@"value"];
    }

    GBHttpRequest *httpRequest = [GBHttpRequest instanceWithMethod:GBRequestMethodPost path:path query:nil body:body];
    [self httpRequest:httpRequest success:^(GBHttpResponse *httpResponse){
        if (success) {
            success();
        }
    } fail:^(GBHttpResponse *httpResponse) {
        if (fail) {
            fail(httpResponse.httpUrlResponse.statusCode, httpResponse.error);
        }
    }];

}
@end
