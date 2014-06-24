//
//  GRContentTypeUtils.m
//  replay
//
//  Created by Kataoka Naoyuki on 2014/02/05.
//  Copyright (c) 2014年 SIROK. All rights reserved.
//

#import "GRContentTypeUtils.h"

NSString *NSStringFromContnetType(GRContentType contentType) {
    
    switch (contentType) {
        case GRContentTypeUnknown:
            return nil;
        case GRContentTypeFormUrlEncoded:
            return @"application/x-www-form-urlencoded";
        case GRContentTypeMultipart:
            return @"multipart/form-data";
        case GRContentTypeJson:
            return @"application/json";
    }
    
}

GRContentType GRContentTypeFromNSString(NSString *contentTypeString) {
    
    if ([contentTypeString isEqualToString:@"application/x-www-form-urlencoded"]) {
        return GRContentTypeFormUrlEncoded;
    }
    if ([contentTypeString isEqualToString:@"multipart/form-data"]) {
        return GRContentTypeMultipart;
    }
    if ([contentTypeString isEqualToString:@"application/json"]) {
        return GRContentTypeJson;
    }
    return GRContentTypeUnknown;
    
}