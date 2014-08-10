//
//  GRClientService.m
//  replay
//
//  Created by A13048 on 2014/01/29.
//  Copyright (c) 2014年 SIROK. All rights reserved.
//

#import "GRClientService.h"
#import "GBUtils.h"
#import "GBMultipartFile.h"

static GRClientService *sharedInstance = nil;

@implementation GRClientService

+ (GRClientService *) sharedInstance {
    @synchronized(self) {
        if (!sharedInstance) {
            sharedInstance = [[self alloc] init];
        }
        return sharedInstance;
    }
}

- (void) authorizeWithApplicationId:(NSInteger)applicationId secret:(NSString *)secret client:(GRClient *)client success:(void (^)(GRClient *))success fail:(void (^)(NSInteger, NSError *))fail {

    NSString *path = @"v2/authorize";
    NSMutableDictionary *body = [NSMutableDictionary dictionary];

    if (applicationId) {
        [body setObject:@(applicationId) forKey:@"applicationId"];
    }
    if (secret) {
        [body setObject:secret forKey:@"secret"];
    }

    [body setObject:client ? @(client.id):[NSNull null] forKey:@"clientId"];
    [body setObject:client ? client.token:[NSNull null] forKey:@"token"];

    NSString *network = [GBDeviceUtils connectedToWiFi] ? @"wifi" : @"carrier";
    [body setObject:network forKey:@"network"];

    float deviceVersion = [GBDeviceUtils getCurrentDeviceVersion];
    [body setObject:@(deviceVersion) forKey:@"version"];

    unsigned int memory = [GBDeviceUtils getAvailableMemory];
    [body setObject:@(memory) forKey:@"memory"];

    uint64_t cpuUsage = [GBDeviceUtils getCPUUsage];
    [body setObject:@(cpuUsage) forKey:@"cpu"];

    NSString *model = [GBDeviceUtils getPlatformString];
    [body setObject:model forKey:@"model"];
    
    [body setObject:@"ios" forKey:@"os"];

    GBHttpRequest *httpRequest = [GBHttpRequest instanceWithMethod:GBRequestMethodPost path:path query:nil body:body];
    [self httpRequest:httpRequest success:^(GBHttpResponse *httpResponse) {
        GRClient *client = [GRClient domainWithDictionary:httpResponse.body];
        if (success) {
            success(client);
        }
    } fail:^(GBHttpResponse *httpResponse) {
        if (fail) {
            fail(httpResponse.httpUrlResponse.statusCode, httpResponse.error);
        }
    }];

}

- (void) sendPicture:(long long)clientId token:(NSString *)token recordScheduleToken:(NSString *)recordScheduleToken recordedCheck:(BOOL)recordedCheck file:(NSData *)file timestamp:(long long)timestamp success:(void (^)(GRPicture *picture))success fail:(void (^)(NSInteger status, NSError *error))fail {
    
    NSString *path = @"v2/picture";
    NSMutableDictionary *body = [NSMutableDictionary dictionary];

    if (clientId) {
        [body setObject:@(clientId) forKey:@"clientId"];
    }
    if (token) {
        [body setObject:token forKey:@"token"];
    }
    if (recordScheduleToken) {
        [body setObject:recordScheduleToken forKey:@"recordScheduleToken"];
    }
    if(file){
        [body setObject:[GBMultipartFile multipartFileWithFileName:[NSString stringWithFormat:@"%lld.jpg", timestamp] contentType:@"image/jpeg" body:file] forKey:@"file"];
    }
    if(recordedCheck) {
        [body setObject:@(recordedCheck) forKey:@"recordedCheck"];
    }
    
    [body setObject:[NSString stringWithFormat:@"%lld", timestamp] forKey:@"timestamp"];

    GBHttpRequest *httpRequest = [GBHttpRequest instanceWithMethod:GBRequestMethodPost path:path query:nil body:body contentType:GRContentTypeMultipart];
    [self httpRequest:httpRequest success:^(GBHttpResponse *httpResponse) {
        if (success) {
            GRPicture *picture = [GRPicture domainWithDictionary:httpResponse.body];
            success(picture);
        }
    } fail:^(GBHttpResponse *httpResponse) {
        if (fail) {
            fail(httpResponse.httpUrlResponse.statusCode, httpResponse.error);
        }
    }];

}

@end
