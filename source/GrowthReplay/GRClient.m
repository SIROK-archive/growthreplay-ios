//
//  GRClient.m
//  replay
//
//  Created by A13048 on 2014/01/28.
//  Copyright (c) 2014年 SIROK. All rights reserved.
//

#import "GRClient.h"
#import "GBUtils.h"
#import "GRConfiguration.h"

@implementation GRClient

@synthesize id;
@synthesize applicationId;
@synthesize token;
@synthesize recorded;
@synthesize status;
@synthesize recordScheduleToken;
@synthesize configuration;

- (id) initWithDictionary:(NSDictionary *)dictionary {

    self = [super init];
    if (self) {
        if ([dictionary objectForKey:@"clientId"] && [dictionary objectForKey:@"clientId"] != [NSNull null]) {
            self.id = [[dictionary objectForKey:@"clientId"] longLongValue];
        }
        if ([dictionary objectForKey:@"applicationId"] && [dictionary objectForKey:@"application"] != [NSNull null]) {
            self.applicationId = [[dictionary objectForKey:@"applicationId"] integerValue];
        }
        if ([dictionary objectForKey:@"token"] && [dictionary objectForKey:@"token"] != [NSNull null]) {
            self.token = [dictionary objectForKey:@"token"];
        }
        if ([dictionary objectForKey:@"recorded"] && [dictionary objectForKey:@"recorded"] != [NSNull null]) {
            self.recorded = [[dictionary objectForKey:@"recorded"] boolValue];
        }
        if ([dictionary objectForKey:@"recordClientStatus"] && [dictionary objectForKey:@"recordClientStatus"] != [NSNull null]) {
            self.status = GRRecordStatusFromNSString([dictionary objectForKey:@"recordClientStatus"]);
        }
        if ([dictionary objectForKey:@"recordScheduleToken"] && [dictionary objectForKey:@"recordScheduleToken"] != [NSNull null]) {
            self.recordScheduleToken = [dictionary objectForKey:@"recordScheduleToken"];
        }
        if ([dictionary objectForKey:@"clientConfiguration"] && [dictionary objectForKey:@"clientConfiguration"] != [NSNull null]) {
            NSDictionary *configurationDictionary = [dictionary objectForKey:@"clientConfiguration"];
            self.configuration = [GRConfiguration domainWithDictionary:configurationDictionary];
        }
    }

    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder {

    self = [super init];
    if (self) {
        if ([aDecoder containsValueForKey:@"clientId"]) {
            self.id = [[aDecoder decodeObjectForKey:@"clientId"] longLongValue];
        }
        if ([aDecoder containsValueForKey:@"applicationId"]) {
            self.applicationId = [[aDecoder decodeObjectForKey:@"applicationId"] integerValue];
        }
        if ([aDecoder containsValueForKey:@"token"]) {
            self.token = [aDecoder decodeObjectForKey:@"token"];
        }
        if ([aDecoder containsValueForKey:@"recorded"]) {
            self.recorded = [[aDecoder decodeObjectForKey:@"recorded"] boolValue];
        }
        if ([aDecoder containsValueForKey:@"recordClientStatus"]) {
            self.status = GRRecordStatusFromNSString([aDecoder decodeObjectForKey:@"recordClientStatus"]);
        }
        if ([aDecoder containsValueForKey:@"recordScheduleToken"]) {
            self.recordScheduleToken = [aDecoder decodeObjectForKey:@"recordScheduleToken"];
        }
        if ([aDecoder containsValueForKey:@"clientConfiguration"]) {
            self.configuration = [aDecoder decodeObjectForKey:@"clientConfiguration"];
        }
    }

    return self;

}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:@(id) forKey:@"clientId"];
    [aCoder encodeObject:@(applicationId) forKey:@"applicationId"];
    [aCoder encodeObject:token forKey:@"token"];
    [aCoder encodeObject:@(recorded) forKey:@"recorded"];
    [aCoder encodeObject:NSStringFromGRRecordStatus(status) forKey:@"recordClientStatus"];
    [aCoder encodeObject:recordScheduleToken forKey:@"recordScheduleToken"];
    [aCoder encodeObject:configuration forKey:@"clientConfiguration"];
}

@end
