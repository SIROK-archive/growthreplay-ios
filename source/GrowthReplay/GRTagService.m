//
//  GRTagService.m
//  replay
//
//  Created by A13048 on 2014/01/29.
//  Copyright (c) 2014年 SIROK. All rights reserved.
//

#import "GRTagService.h"
#import "GRUtils.h"

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

- (void) setTag:(long long)clientId token:(NSString *)token name:(NSString *)name value:(NSString *)value success:(void (^)(void))success fail:(void (^)(NSInteger, NSError *))fail {

    NSString *path = @"tag";
    NSMutableDictionary *body = [NSMutableDictionary dictionary];

    if (clientId) {
        [body setObject:@(clientId) forKey:@"clientId"];
    }
    if (token) {
        [body setObject:token forKey:@"token"];
    }
    if (name) {
        [body setObject:name forKey:@"name"];
    }
    if (value) {
        [body setObject:value forKey:@"value"];
    }

    GRHttpRequest *httpRequest = [GRHttpRequest instanceWithRequestMethod:GRRequestMethodPost version:@"v1" path:path query:nil body:body];
    [self httpRequest:httpRequest success:^(GRHttpResponse *httpResponse){
        if (success) {
            success();
        }
    } fail:^(GRHttpResponse *httpResponse) {
        if (fail) {
            fail(httpResponse.httpUrlResponse.statusCode, httpResponse.error);
        }
    }];

}
@end
