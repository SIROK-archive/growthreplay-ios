//
//  GRPicture.m
//  replay
//
//  Created by A13048 on 2014/01/30.
//  Copyright (c) 2014年 SIROK. All rights reserved.
//

#import "GRPicture.h"
#import "GBUtils.h"
#import "GBHttpClient.h"
#import "GBMultipartFile.h"
#import "GrowthReplay.h"

@implementation GRPicture

@synthesize continuation;
@synthesize status;
@synthesize recordedClient;

+ (GRPicture *) sendPicture:(NSString *)clientId credentialId:(NSString *)credentialId recordScheduleToken:(NSString *)recordScheduleToken recordedCheck:(BOOL)recordedCheck file:(NSData *)file timestamp:(long long)timestamp {
    
    NSString *path = @"v3/picture";
    NSMutableDictionary *body = [NSMutableDictionary dictionary];
    
    if (clientId) {
        [body setObject:clientId forKey:@"clientId"];
    }
    if (credentialId) {
        [body setObject:credentialId forKey:@"credentialId"];
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
    
    GBHttpRequest *httpRequest = [GBHttpRequest instanceWithMethod:GBRequestMethodPost path:path query:nil body:body contentType:GBContentTypeMultipart];
    GBHttpResponse *httpResponse = [[[GrowthReplay sharedInstance] httpClient] httpRequest:httpRequest];
    if(!httpResponse.success){
        [[[GrowthReplay sharedInstance] logger] error:@"Filed to create client event. %@", httpResponse.error];
        return nil;
    }
    
    return [GRPicture domainWithDictionary:httpResponse.body];
    
}

- (id) initWithDictionary:(NSDictionary *)dictionary {

    self = [super init];
    if (self) {
        if ([dictionary objectForKey:@"continuation"] && [dictionary objectForKey:@"continuation"] != [NSNull null]) {
            self.continuation = [[dictionary objectForKey:@"continuation"] boolValue];
        }
        if ([dictionary objectForKey:@"status"] && [dictionary objectForKey:@"status"] != [NSNull null]) {
            self.status = [[dictionary objectForKey:@"status"] boolValue];
        }
        if ([dictionary objectForKey:@"recordedClient"] && [dictionary objectForKey:@"recordedClient"] != [NSNull null]) {
            self.recordedClient = [[dictionary objectForKey:@"recordedClient"] boolValue];
        }
    }

    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder {

    self = [super init];
    if (self) {
        if ([aDecoder containsValueForKey:@"continuation"]) {
            self.continuation = [[aDecoder decodeObjectForKey:@"continuation"] boolValue];
        }
        if ([aDecoder containsValueForKey:@"status"]) {
            self.status = [[aDecoder decodeObjectForKey:@"status"] boolValue];
        }
        if ([aDecoder containsValueForKey:@"recordedClient"]) {
            self.recordedClient = [[aDecoder decodeObjectForKey:@"recordedClient"] boolValue];
        }
    }

    return self;

}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:@(continuation) forKey:@"contiuation"];
    [aCoder encodeObject:@(status) forKey:@"status"];
    [aCoder encodeObject:@(recordedClient) forKey:@"recordedClient"];
}



@end
