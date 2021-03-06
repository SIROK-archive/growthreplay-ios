//
//  GPHttpUtils.m
//  pickaxe
//
//  Created by Kataoka Naoyuki on 2013/07/03.
//  Copyright (c) 2013年 SIROK, Inc. All rights reserved.
//

#import "GRHttpUtils.h"
#import "GRMultipartFile.h"

@implementation GRHttpUtils

+ (NSString *) queryStringWithDictionary:(NSDictionary *)params {

    NSMutableArray *combinedParams = [NSMutableArray array];

    for (NSString *key in [params keyEnumerator]) {
        NSString *encodedKey = [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        id values = [params objectForKey:key];
        if (![values isKindOfClass:[NSArray class]]) {
            values = [NSArray arrayWithObject:values];
        }
        for (id value in values) {
            NSString *encodedValue = [[NSString stringWithFormat:@"%@", value] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [combinedParams addObject:[NSString stringWithFormat:@"%@=%@", encodedKey, encodedValue]];
        }
    }

    return [combinedParams componentsJoinedByString:@"&"];

}

+ (NSData *)formUrlencodedBodyWithDictionary:(NSDictionary *)params {
    return [[self queryStringWithDictionary:params] dataUsingEncoding:NSUTF8StringEncoding];
}

+ (NSData *)jsonBodyWithDictionary:(NSDictionary *)params {
    return [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil];
}

+ (NSData *)multipartBodyWithDictionary:(NSDictionary *)params {
    
    NSMutableData *body = [NSMutableData data];
    
    for (id key in [params keyEnumerator]) {
        id value = [params objectForKey:key];
        
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", kMultipartBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
        
        if([value isKindOfClass:[GRMultipartFile class]]){
            GRMultipartFile *multipartFile = (GRMultipartFile *)value;
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", key, multipartFile.fileName] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", multipartFile.contentType] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:multipartFile.body];
        }else{
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"%@", value] dataUsingEncoding:NSUTF8StringEncoding]];
        }
        
        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", kMultipartBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
return body;
    
}

@end
