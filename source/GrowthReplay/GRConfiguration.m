//
//  GRConfiguration.m
//  replay
//
//  Created by A13048 on 2014/01/28.
//  Copyright (c) 2014年 SIROK. All rights reserved.
//

#import "GRConfiguration.h"

@implementation GRConfiguration

@synthesize recordTerm;
@synthesize compressibility;
@synthesize scale;
@synthesize numberOfRemaining;
@synthesize wheres;

- (id) initWithDictionary:(NSDictionary *)dictionary {

    self = [super init];
    if (self) {
        if ([dictionary objectForKey:@"recordTerm"] && [dictionary objectForKey:@"recordTerm"] != [NSNull null]) {
            self.recordTerm = [[dictionary objectForKey:@"recordTerm"] floatValue];
        }
        if ([dictionary objectForKey:@"compressibility"] && [dictionary objectForKey:@"compressibility"] != [NSNull null]) {
            self.compressibility = [[dictionary objectForKey:@"compressibility"] integerValue];
        }
        if ([dictionary objectForKey:@"scale"] && [dictionary objectForKey:@"scale"] != [NSNull null]) {
            self.scale = [[dictionary objectForKey:@"scale"] floatValue];
        }
        if ([dictionary objectForKey:@"numberOfRemaining"] && [dictionary objectForKey:@"numberOfRemaining"] != [NSNull null]) {
            self.numberOfRemaining = [[dictionary objectForKey:@"numberOfRemaining"] intValue];
        }
        if ([dictionary objectForKey:@"wheres"] && [dictionary objectForKey:@"wheres"] != [NSNull null]) {
            self.wheres = [dictionary objectForKey:@"wheres"];
        }
    }

    return self;
}

- (NSString*) getJSONString {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:@(recordTerm) forKey:@"recordTerm"];
    [dictionary setObject:@(compressibility) forKey:@"compressibility"];
    [dictionary setObject:@(scale) forKey:@"scale"];
    [dictionary setObject:@(numberOfRemaining) forKey:@"numberOfRemaining"];
    [dictionary setObject:wheres forKey:@"wheres"];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

- (id) initWithCoder:(NSCoder *)aDecoder {

    self = [super init];
    if (self) {
        if ([aDecoder containsValueForKey:@"recordTerm"]) {
            self.recordTerm = [[aDecoder decodeObjectForKey:@"recordTerm"] floatValue];
        }
        if ([aDecoder containsValueForKey:@"compressibility"]) {
            self.compressibility = [[aDecoder decodeObjectForKey:@"compressibility"] integerValue];
        }
        if ([aDecoder containsValueForKey:@"scale"]) {
            self.scale = [[aDecoder decodeObjectForKey:@"scale"] floatValue];
        }
        if ([aDecoder containsValueForKey:@"numberOfRemaining"]) {
            self.numberOfRemaining = [[aDecoder decodeObjectForKey:@"numberOfRemaining"] intValue];
        }
        if ([aDecoder containsValueForKey:@"wheres"]) {
            self.wheres = [aDecoder decodeObjectForKey:@"wheres"];
        }
    }

    return self;

}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:@(recordTerm) forKey:@"recordTerm"];
    [aCoder encodeObject:@(compressibility) forKey:@"compressibility"];
    [aCoder encodeObject:@(scale) forKey:@"scale"];
    [aCoder encodeObject:@(numberOfRemaining) forKey:@"numberOfRemaining"];
    [aCoder encodeObject:wheres forKey:@"wheres"];
}


@end
