//
//  GrowthReplay.m
//  replay
//
//  Created by A13048 on 2014/01/23.
//  Copyright (c) 2014年 SIROK. All rights reserved.
//

#import "GrowthReplay.h"
#import "GBUtils.h"
#import "GRClientService.h"
#import "GRTagService.h"
#import "GRRecorder.h"
#import "GRPreference.h"

static GrowthReplay *sharedInstance = nil;
static NSString *const kGRBaseUrl = @"https://api.growthreplay.com/";
static NSString *const kGRPreferenceClientKey = @"client";
static const NSTimeInterval kGRRegisterPollingInterval = 5.0f;

@interface GrowthReplay () {
    
    GBHttpClient *httpClient;
    
    NSInteger applicationId;
    NSString *secret;
    BOOL debug;
    GRClient *client;
    BOOL registeringClient;
    GRRecorder *recorder;
    NSInteger pictureLimit;
    BOOL recordedCheck;
    
}

@property (nonatomic) GBHttpClient *httpClient;
@property (nonatomic) NSInteger applicationId;
@property (nonatomic) NSString *secret;
@property (nonatomic) BOOL debug;
@property (nonatomic) GRClient *client;
@property (nonatomic) BOOL registeringClient;
@property (nonatomic) GRRecorder *recorder;
@property (nonatomic) NSInteger pictureLimit;
@property (nonatomic) BOOL recordedCheck;

@end

@implementation GrowthReplay

@synthesize httpClient;
@synthesize applicationId;
@synthesize secret;
@synthesize debug;
@synthesize client;
@synthesize registeringClient;
@synthesize recorder;
@synthesize pictureLimit;
@synthesize recordedCheck;

+ (GrowthReplay *) sharedInstance {
    @synchronized(self) {
        if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0f) {
            return nil;
        }
        if (!sharedInstance) {
            sharedInstance = [[self alloc] init];
        }
        return sharedInstance;
    }
}

+ (void) initializeWithApplicationId:(NSInteger)applicationId secret:(NSString *)secret debug:(BOOL)debug {
    [[GrowthReplay sharedInstance] initializeWithApplicationId:applicationId secret:secret debug:debug];
}

+ (void) setTag:(NSString *)name value:(NSString *)value {
    [[GrowthReplay sharedInstance] setTag:name value:value];
}

+ (void) setDeviceTags {
    [[GrowthReplay sharedInstance] setDeviceTags];
}

+ (void) start {
    [[GrowthReplay sharedInstance] start];
}

+ (void) stop {
    [[GrowthReplay sharedInstance] stop];
}

+ (void) setSpot:(NSString *)spot {
    [[GrowthReplay sharedInstance] setSpot:spot];
}

- (id) init {
    self = [super init];
    if (self) {
        self.httpClient = [[GBHttpClient alloc] initWithBaseUrl:[NSURL URLWithString:kGRBaseUrl]];
        self.recorder = [[GRRecorder alloc] init];
        self.recordedCheck = YES;
    }
    return self;
}

- (void) initializeWithApplicationId:(NSInteger)newApplicationId secret:(NSString *)newSecret debug:(BOOL)newDebug {
    
    self.applicationId = newApplicationId;
    self.secret = newSecret;
    self.debug = newDebug;
    
    [self authorize];
    
}

- (void) authorize {
    
    if (registeringClient) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kGRRegisterPollingInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
            [self authorize];
        });
        return;
    }
    
    self.registeringClient = YES;
    [self log:@"Authorize client... (applicationId: %d)", applicationId];
    
    [[GRClientService sharedInstance] authorizeWithApplicationId:self.applicationId secret:self.secret client:[self loadClient] success:^(GRClient *authorizedClient){
        
        self.client = authorizedClient;
        self.registeringClient = NO;
        self.pictureLimit = authorizedClient.configuration.numberOfRemaining;
        [self log:@"Authorize success. (clientId %ld, picture %d)", self.client.id, self.pictureLimit];
        [self savedClient:authorizedClient];
        
        if (client.recorded || self.pictureLimit > 0) {
            [self log:@"This device is selected. "];
            
            [self log:@"start recorder term:%d", authorizedClient.configuration.recordTerm];
            [self.recorder startWithConfiguration:client.configuration callback:^(NSData *data, NSDate *date) {
                [self sendPicture:data date:date];
            }];
            
            if (authorizedClient.status == GRRecordStatusAlready)
                recordedCheck = false;
            
        }
        
    } fail:^(NSInteger status, NSError *error){
        [self log:@"authorize fail (%@).", error.description];
        self.registeringClient = NO;
    }];
    
}

- (void) setTag:(NSString *)name value:(NSString *)value {
    
    [self runAfterRegister:^{
        [[GRTagService sharedInstance] setTag:self.client.id token:self.client.token name:name value:value success:^(){
            [self log:@"tag save success. "];
        } fail:^(NSInteger status, NSError *error){
            [self log:@"tag save fail. "];
        }];
    }];
    
}

- (void) setDeviceTags {
    [self setTag:@"os" value:@"ios"];
    [self setTag:@"deviceVersion" value:[NSString stringWithFormat:@"%g", [GBDeviceUtils getCurrentDeviceVersion]]];
    [self setTag:@"deviceModel" value:[GBDeviceUtils getPlatformString]];
    [self setTag:@"appVersion" value:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
    [self setTag:@"sdkVersion" value:@"0.3"];
}

- (void) sendPicture:(NSData *)data date:(NSDate *)date {
    
    if (![GBDeviceUtils connectedToWiFi]) {
        return;
    }
    
    if (!data) {
        [self log:@"send data is nil"];
        return;
    }
    
    if (self.pictureLimit <= 0) {
        [self log:@"limit picture size."];
        [self.recorder stop];
        return ;
    }
    
    long long timestamp = (long long)1000 * [date timeIntervalSince1970];
    if(!client.configuration.wheres)
        recordedCheck = false;
    
    [[GRClientService sharedInstance] sendPicture:self.client.id token:self.client.token recordScheduleToken:client.recordScheduleToken recordedCheck:recordedCheck file:data timestamp:timestamp success:^(GRPicture *picture){
       
        recordedCheck = false;
        if (picture.status) {
            self.pictureLimit--;
            [self log:@"send picture success. (picture limit size %d)", self.pictureLimit];
        } else {
            [self log:@"save picture failure.."];
        }
        
        if (!picture.continuation || self.pictureLimit <= 0) {
            [self log:@"limit picture size."];
            [self.recorder stop];
        }
        
    } fail:^(NSInteger status, NSError *error) {
        [self log:@"send picture fail. (%@)", error.description];
    }];
    
}

- (void) start {
    if (self.recorder) {
        [self.recorder setIsRec:YES];
        [self log:@"Start to send picture."];
    }
}

- (void) stop {
    if (self.recorder) {
        [self.recorder setIsRec:NO];
        [self log:@"Stopped to send picture."];
    }
}

- (void) setSpot:(NSString *)spot {
    if (self.recorder) {
        [self.recorder setSpot:spot];
    }
}

- (GRClient *) loadClient {
    
    NSData *data = [[GRPreference sharedInstance] objectForKey:kGRPreferenceClientKey];
    
    if (!data) {
        return nil;
    }
    
    GRClient *refClient = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    if (refClient.applicationId != self.applicationId)
        return nil;
    
    return refClient;
}

- (void) savedClient:(GRClient *)newClient {
    
    if (!newClient) {
        return;
    }
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:newClient];
    [[GRPreference sharedInstance] setObject:data forKey:kGRPreferenceClientKey];
    
}

- (void) log:(NSString *)format, ...{
    
    if (!debug) {
        return;
    }
    
    va_list args;
    
    va_start(args, format);
    
    NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
    NSLog(@"GrowthReplay - %@", message);
    
}

- (void) runAfterRegister:(void (^)(void))runnable {
    
    if (client) {
        if (runnable) {
            runnable();
        }
        return;
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kGRRegisterPollingInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
        [self runAfterRegister:runnable];
    });
    
}

@end
