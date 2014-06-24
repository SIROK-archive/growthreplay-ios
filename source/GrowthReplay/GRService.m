//
//  GPService.m
//  pickaxe
//
//  Created by Kataoka Naoyuki on 2013/07/03.
//  Copyright (c) 2013年 SIROK, Inc. All rights reserved.
//

#import "GRService.h"

@implementation GRService

- (void) httpRequest:(GRHttpRequest *)httpRequest success:(void (^)(GRHttpResponse *httpResponse))success fail:(void (^)(GRHttpResponse *httpResponse))fail {

    [[GRHttpClient sharedInstance] httpRequest:httpRequest success:success fail:fail];

}

@end
