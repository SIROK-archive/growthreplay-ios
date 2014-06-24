//
//  GRRecorder.m
//  replay
//
//  Created by A13048 on 2014/01/23.
//  Copyright (c) 2014年 SIROK. All rights reserved.
//

#import "GRRecorder.h"

@interface GRRecorder () {

    void (^callback)(NSData *, NSDate *);
    NSTimer *timer;

}

@property (nonatomic, copy) void (^callback)(NSData *, NSDate *);
@property (nonatomic) NSTimer *timer;

@end

@implementation GRRecorder

@synthesize configuration;
@synthesize callback;
@synthesize timer;
@synthesize isRec;
@synthesize spot;

- (void) startWithConfiguration:(GRConfiguration *)newConfiguration callback:(void (^)(NSData *, NSDate *))newCallback {

    self.configuration = newConfiguration;
    self.callback = newCallback;
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:newConfiguration.recordTerm target:self selector:@selector(takeScreenshot) userInfo:nil repeats:YES];

}

- (void) stop {

    [self.timer invalidate];
    self.timer = nil;
    self.configuration = nil;
    self.callback = nil;

}

- (void) takeScreenshot {

    if (![self.timer isValid] || !isRec || ![self checkSpot]) {
        return;
    }
    
    
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    if (!window) {
        return;
    }
    NSDate *date = [NSDate date];
    
    [self synchronusGetImageFromContext:date window:window];
    
}

- (BOOL) checkSpot {
    
    if (configuration.wheres) {
        for (NSString *refSpot in configuration.wheres) {
            if ([refSpot isEqualToString:self.spot])
                return YES;
        }
        return NO;
    }
    
    return YES;
}

- (void) synchronusGetImageFromContext:(NSDate *)date window:(UIWindow *)window {
    
    if(UIGraphicsBeginImageContextWithOptions != NULL)
        UIGraphicsBeginImageContextWithOptions(window.bounds.size, NO, [UIScreen mainScreen].scale);
    else
        UIGraphicsBeginImageContext(window.bounds.size);

    CGContextSetInterpolationQuality(UIGraphicsGetCurrentContext(), kCGInterpolationNone);
    
    for(UIWindow *_window in [[UIApplication sharedApplication] windows])
        [_window drawViewHierarchyInRect:_window.bounds afterScreenUpdates:NO];
    
    [window drawViewHierarchyInRect:window.bounds afterScreenUpdates:NO];

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground)
            return ;
        [self callbackSendImage:[self GPUCompressImage:image] date:date];
    });
    
}

- (NSData *) GPUCompressImage:(UIImage *)image {
    
    int baseLength = 360;
    if (image.size.width < image.size.height) {
        baseLength = 480;
    }
    
    float scale = image.size.width / baseLength;
    if (scale > 0)
        scale = configuration.scale / scale;
    else
        scale = configuration.scale;
    
    CIImage *sourceImage = [[CIImage alloc] initWithCGImage:image.CGImage];
    CGSize size = CGSizeMake(image.size.width * scale, image.size.height * scale);
    CGRect imageRect = [sourceImage extent];
    
    CGPoint point = CGPointMake(size.width / imageRect.size.width, size.height / imageRect.size.height);
    CIImage *filteredImage = [sourceImage imageByApplyingTransform:CGAffineTransformMakeScale(point.x, point.y)];
    filteredImage = [filteredImage imageByCroppingToRect:CGRectMake(0, 0, size.width, size.height)];
    
    CIContext *ciContext = [CIContext contextWithOptions:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:kCIContextUseSoftwareRenderer]];
    CGImageRef imageRef = [ciContext createCGImage:filteredImage fromRect:[filteredImage extent]];
    UIImage *outputImage = [UIImage imageWithCGImage:imageRef scale:1.0f orientation:UIImageOrientationUp];
    CGImageRelease(imageRef);
    
    float quality = configuration.compressibility;
    NSData *jpegData = UIImageJPEGRepresentation(outputImage, quality);
    outputImage = nil;
    
    return jpegData;
}

- (void) callbackSendImage:(NSData *)data date:(NSDate *)date {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (!self.callback) {
            return;
        }
        
        if (isRec)
            self.callback(data, date);
        
    });
}

@end


