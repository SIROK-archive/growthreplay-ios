//
//  GRRecordStatusUtils.m
//  replay
//
//  Created by A13048 on 2014/01/28.
//  Copyright (c) 2014年 SIROK. All rights reserved.
//

#import "GRRecordStatusUtils.h"

NSString *NSStringFromGRRecordStatus(GRRecordStatus status){

    switch (status) {
        case GRRecordStatusNone:
            return @"none";
        case GRRecordStatusAdded:
            return @"added";
        case GRRecordStatusAlready:
            return @"already";
        case GRRecordStatusUnknown:
            return nil;
    }

}

GRRecordStatus GRRecordStatusFromNSString(NSString *statusString){

    if ([statusString isEqualToString:@"none"]) {
        return GRRecordStatusNone;
    }
    if ([statusString isEqualToString:@"added"]) {
        return GRRecordStatusAdded;
    }
    if ([statusString isEqualToString:@"already"]) {
        return GRRecordStatusAlready;
    }
    return GRRecordStatusUnknown;

}

