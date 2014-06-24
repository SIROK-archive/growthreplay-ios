//
//  GRMultipartFile.m
//  replay
//
//  Created by Kataoka Naoyuki on 2014/02/05.
//  Copyright (c) 2014年 SIROK. All rights reserved.
//

#import "GRMultipartFile.h"

@implementation GRMultipartFile

@synthesize fileName;
@synthesize contentType;
@synthesize body;

+ (id)multipartFileWithFileName:(NSString *)fileName contentType:(NSString *)contentType body:(NSData *)body {
    
    GRMultipartFile *multipartFile = [[self alloc] init];
    
    multipartFile.fileName = fileName;
    multipartFile.contentType = contentType;
    multipartFile.body = body;
    
    return multipartFile;
    
}

@end
