//
//  GPService.h
//  pickaxe
//
//  Created by Kataoka Naoyuki on 2013/07/03.
//  Copyright (c) 2013年 SIROK, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GRHttpClient.h"

@interface GRService : NSObject

- (void)httpRequest:(GRHttpRequest *)httpRequest success:(void(^) (GRHttpResponse * httpResponse)) success fail:(void(^) (GRHttpResponse * httpResponse))fail;

@end
