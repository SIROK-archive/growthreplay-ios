//
//  GRPicture.m
//  replay
//
//  Created by A13048 on 2014/01/30.
//  Copyright (c) 2014年 SIROK. All rights reserved.
//

#import "GRPicture.h"

@implementation GRPicture

@synthesize continuation;
@synthesize status;
@synthesize recordedClient;

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
