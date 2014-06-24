//
//  GRDomain.m
//  replay
//
//  Created by A13048 on 2014/01/28.
//  Copyright (c) 2014年 SIROK. All rights reserved.
//

#import "GRDomain.h"

@implementation GRDomain

+ (id) domainWithDictionary:(NSDictionary *)dictionary {

    if (!dictionary) {
        return nil;
    }

    return [[self alloc] initWithDictionary:dictionary];
}

- (id) initWithDictionary:(NSDictionary *)dictionary {
    return nil;
}

@end
