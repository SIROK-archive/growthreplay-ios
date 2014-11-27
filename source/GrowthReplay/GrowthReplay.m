//
//  GrowthReplay.m
//  replay
//
//  Created by A13048 on 2014/01/23.
//  Copyright (c) 2014年 SIROK. All rights reserved.
//

#import "GrowthReplay.h"
#import "GBUtils.h"
#import "GRClient.h"
#import "GRPicture.h"
#import "GRRecorder.h"
#import "GrowthAnalytics.h"

static GrowthReplay *sharedInstance = nil;
static NSString *const kGBLoggerDefaultTag = @"GrowthReplay";
static NSString *const kGBHttpClientDefaultBaseUrl = @"https://api.growthreplay.com/";
static NSString *const kGBPreferenceDefaultFileName = @"growthreplay-preferences";
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

- (id) init {
    self = [super init];
    if (self) {
        self.logger = [[GBLogger alloc] initWithTag:kGBLoggerDefaultTag];
        self.httpClient = [[GBHttpClient alloc] initWithBaseUrl:[NSURL URLWithString:kGBHttpClientDefaultBaseUrl]];
        self.preference = [[GBPreference alloc] initWithFileName:kGBPreferenceDefaultFileName];
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
            [self clearClient];
        }
        
        [self authorizeWithClientId:growthbeatClient.id credentialId:self.credentialId];
    });
    
}

- (void) authorizeWithClientId:(NSString *)newClientId credentialId:(NSString *)_credentialId {
    
    if (registeringClient) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kGRRegisterPollingInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
            [self authorizeWithClientId:newClientId credentialId:_credentialId];
        });
        return;
    }
    
    self.registeringClient = YES;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        [logger info:@"Authorize client... (applicationId: %d)", applicationId];
        
        GRClient *authorizedClient = [GRClient authorizeWithClientId:newClientId credentialId:_credentialId client:[self loadClient]];
        if(authorizedClient) {
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
        } else {
            self.registeringClient = NO;
        }
        
    });
    
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
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        GRPicture *picture = [GRPicture sendPicture:self.client.growthbeatClientId credentialId:self.credentialId recordScheduleToken:client.recordScheduleToken recordedCheck:recordedCheck file:data timestamp:timestamp];
        if(picture) {
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
        }
        
    });

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

- (void) clearClient {
    
    self.client = nil;
    [preference removeAll];
    
}

@end
