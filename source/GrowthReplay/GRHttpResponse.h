//
//  GPHttpResponse.h
//  pickaxe
//
//  Created by Kataoka Naoyuki on 2013/07/03.
//  Copyright (c) 2013年 SIROK, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GRHttpResponse : NSObject {

    NSURLRequest *urlRequest;
    NSHTTPURLResponse *httpUrlResponse;
    NSError *error;
    id body;

}

@property (nonatomic) NSURLRequest *urlRequest;
@property (nonatomic) NSHTTPURLResponse *httpUrlResponse;
@property (nonatomic) NSError *error;
@property (nonatomic) id body;

+ (id)instanceWithUrlRequest:(NSURLRequest *)urlRequest httpUrlResponse:(NSHTTPURLResponse *)httpUrlResponse error:(NSError *)error body:(id)body;

@end
