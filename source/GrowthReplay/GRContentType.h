//
//  GRContentType.h
//  replay
//
//  Created by Kataoka Naoyuki on 2014/02/05.
//  Copyright (c) 2014年 SIROK. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSUInteger, GRContentType) {
    GRContentTypeUnknown = 0,
    GRContentTypeFormUrlEncoded,
    GRContentTypeMultipart,
    GRContentTypeJson
};

NSString *NSStringFromContnetType(GRContentType contentType);
GRContentType ContentTypeFromNSString(NSString *contentTypeString);
