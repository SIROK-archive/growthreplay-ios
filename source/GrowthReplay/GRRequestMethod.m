//
//  GPRequestMethod.m
//  pickaxe
//
//  Created by Kataoka Naoyuki on 2013/07/03.
//  Copyright (c) 2013年 SIROK, Inc. All rights reserved.
//

#import "GRRequestMethod.h"

NSString *NSStringFromGRRequestMethod(GRRequestMethod requestMethod) {

    switch (requestMethod) {
        case GRRequestMethodGet:
            return @"GET";
        case GRRequestMethodPost:
            return @"POST";
        case GRRequestMethodPut:
            return @"PUT";
        case GRRequestMethodDelete:
            return @"DELETE";
        default:
            return nil;
    }

}

GRRequestMethod GRRequestMethodFromNSString(NSString *requestMethodString) {

    if ([requestMethodString isEqualToString:@"GET"]) {
        return GRRequestMethodGet;
    }
    if ([requestMethodString isEqualToString:@"POST"]) {
        return GRRequestMethodPost;
    }
    if ([requestMethodString isEqualToString:@"PUT"]) {
        return GRRequestMethodPut;
    }
    if ([requestMethodString isEqualToString:@"DELETE"]) {
        return GRRequestMethodDelete;
    }

    return GRRequestMethodUnknown;

}
