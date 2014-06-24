//
//  GPRequestMethod.h
//  pickaxe
//
//  Created by Kataoka Naoyuki on 2013/07/03.
//  Copyright (c) 2013年 SIROK, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSInteger, GRRequestMethod) {
    GRRequestMethodUnknown = 0,
    GRRequestMethodGet,
    GRRequestMethodPost,
    GRRequestMethodPut,
    GRRequestMethodDelete
};

NSString *NSStringFromGRRequestMethod(GRRequestMethod requestMethod);
GRRequestMethod GRRequestMethodFromNSString(NSString *requestMethodString);
