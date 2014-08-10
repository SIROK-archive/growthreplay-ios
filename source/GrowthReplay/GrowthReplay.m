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

static GrowthReplay *sharedInstance = nil;
static NSString *const kGRBaseUrl = @"https://api.growthreplay.com/";
static NSString *const kGRPreferenceFileName = @"growthreplay-preferences";
static NSString *const kGRPreferenceClientKey = @"client";
static const NSTimeInterval kGRRegisterPollingInterval = 5.0f;

@interface GrowthReplay () {
    
    GBLogger *logger;
    GBHttpClient *httpClient;
    GBPreference *preference;
    
    NSString *applicationId;
    NSString *credentialId;
    GRClient *client;
    BOOL registeringClient;
    GRRecorder *recorder;
    NSInteger pictureLimit;
    BOOL recordedCheck;
    
}

@property (nonatomic) GBLogger *logger;
@property (nonatomic) GBHttpClient *httpClient;
@property (nonatomic) GBPreference *preference;
@property (nonatomic) NSString *applicationId;
@property (nonatomic) NSString *credentialId;
@property (nonatomic) GRClient *client;
@property (nonatomic) BOOL registeringClient;
@property (nonatomic) GRRecorder *recorder;
@property (nonatomic) NSInteger pictureLimit;
@property (nonatomic) BOOL recordedCheck;

@end

@implementation GrowthReplay

@synthesize logger;
@synthesize httpClient;
@synthesize preference;
@synthesize applicationId;
@synthesize credentialId;
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

+ (void) initializeWithApplicationId:(NSString *)applicationId credentialId:(NSString *)credentialId {
    [[GrowthReplay sharedInstance] initializeWithApplicationId:applicationId credentialId:credentialId];
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
        self.logger = [[GBLogger alloc] initWithTag:@"GrowthReplay"];
        self.httpClient = [[GBHttpClient alloc] initWithBaseUrl:[NSURL URLWithString:kGRBaseUrl]];
        self.preference = [[GBPreference alloc] initWithFileName:kGRPreferenceFileName];
        self.recorder = [[GRRecorder alloc] init];
        self.recordedCheck = YES;
    }
    return self;
}

- (void) initializeWithApplicationId:(NSString *)newApplicationId credentialId:(NSString *)newCredentialId {
    
    self.applicationId = newApplicationId;
    self.credentialId = newCredentialId;
    
    [GrowthbeatCore initializeWithApplicationId:applicationId credentialId:credentialId];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        GBClient *growthbeatClient = [[GrowthbeatCore sharedInstance] waitClient];
        self.client = [self loadClient];
        if (self.client && self.client.growthbeatClientId && ![self.client.growthbeatClientId isEqualToString:growthbeatClient.id]) {
            // TODO clear client
        }
        [self authorize];
    });
    
}

- (void) authorize {
    
    if (registeringClient) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kGRRegisterPollingInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
            [self authorize];
        });
        return;
    }
    
    self.registeringClient = YES;
    [logger info:@"Authorize client... (applicationId: %d)", applicationId];
    
    [[GRClientService sharedInstance] authorizeWithApplicationId:self.applicationId credentialId:self.credentialId client:[self loadClient] success:^(GRClient *authorizedClient){
        
        self.client = authorizedClient;
        self.registeringClient = NO;
        self.pictureLimit = authorizedClient.configuration.numberOfRemaining;
        [logger info:@"Authorize success. (clientId %ld, picture %d)", self.client.id, self.pictureLimit];
        [self savedClient:authorizedClient];
        
        if (client.recorded || self.pictureLimit > 0) {
            [logger info:@"This device is selected. "];
            
            [logger info:@"start recorder term:%d", authorizedClient.configuration.recordTerm];
            [self.recorder startWithConfiguration:client.configuration callback:^(NSData *data, NSDate *date) {
                [self sendPicture:data date:date];
            }];
            
            if (authorizedClient.status == GRRecordStatusAlready)
                recordedCheck = false;
            
        }
        
    } fail:^(NSInteger status, NSError *error){
        [logger info:@"authorize fail (%@).", error.description];
        self.registeringClient = NO;
    }];
    
}

- (void) setTag:(NSString *)name value:(NSString *)value {
    
    [self runAfterRegister:^{
        [[GRTagService sharedInstance] setTag:self.client.id token:self.client.token name:name value:value success:^(){
            [logger info:@"tag save success. "];
        } fail:^(NSInteger status, NSError *error){
            [logger info:@"tag save fail. "];
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
        [logger info:@"send data is nil"];
        return;
    }
    
    if (self.pictureLimit <= 0) {
        [logger info:@"limit picture size."];
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
            [logger info:@"send picture success. (picture limit size %d)", self.pictureLimit];
        } else {
            [logger info:@"save picture failure.."];
        }
        
        if (!picture.continuation || self.pictureLimit <= 0) {
            [logger info:@"limit picture size."];
            [self.recorder stop];
        }
        
    } fail:^(NSInteger status, NSError *error) {
        [logger info:@"send picture fail. (%@)", error.description];
    }];
    
}

- (void) start {
    if (self.recorder) {
        [self.recorder setIsRec:YES];
        [logger info:@"Start to send picture."];
    }
}

- (void) stop {
    if (self.recorder) {
        [self.recorder setIsRec:NO];
        [logger info:@"Stopped to send picture."];
    }
}

- (void) setSpot:(NSString *)spot {
    if (self.recorder) {
        [self.recorder setSpot:spot];
    }
}

- (GRClient *) loadClient {
    
    NSData *data = [preference objectForKey:kGRPreferenceClientKey];
    
    if (!data) {
        return nil;
    }
    
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
}

- (void) savedClient:(GRClient *)newClient {
    
    if (!newClient) {
        return;
    }
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:newClient];
    [preference setObject:data forKey:kGRPreferenceClientKey];
    
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
