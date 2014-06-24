//
//  GRNetworkUtils.m
//  replay
//
//  Created by A13048 on 2014/01/31.
//  Copyright (c) 2014年 SIROK. All rights reserved.
//

#import "GRDeviceUtils.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import <mach/mach.h>
#import <netinet/in.h>
#include <sys/types.h>
#include <sys/sysctl.h>

#define tval2msec(tval) ((tval.seconds * 1000) + (tval.microseconds / 1000))

static GRDeviceUtils *sharedInstance = nil;

@implementation GRDeviceUtils

+ (GRDeviceUtils *) sharedInstance {

    @synchronized(self) {
        if (!sharedInstance) {
            sharedInstance = [[self alloc] init];
        }
        return sharedInstance;
    }
}

- (BOOL) networkIsWiFi {
    
    struct sockaddr_in address;
    bzero(&address, sizeof(address));
    address.sin_len = sizeof(address);
    address.sin_family = AF_INET;

    
    SCNetworkReachabilityRef networkReachablitiyRef = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr*)&address);
    if (!networkReachablitiyRef)
        return NO;
    

    BOOL returnVal = YES;
    SCNetworkReachabilityFlags networkReachablitiyFlags = 0;

    if(!SCNetworkReachabilityGetFlags(networkReachablitiyRef, &networkReachablitiyFlags))
        returnVal = NO;
    if(!(networkReachablitiyFlags & kSCNetworkReachabilityFlagsReachable))
        returnVal = NO;
    if((networkReachablitiyFlags & kSCNetworkReachabilityFlagsIsWWAN))
        returnVal = NO;
    
    CFRelease(networkReachablitiyRef);
    return returnVal;
    
}

- (float) getCurrentDeviceVersion {
    return [[[UIDevice currentDevice] systemVersion] floatValue];
}

- (unsigned int) getFreeMemory {

    mach_port_t host_port;
    mach_msg_type_number_t host_size;
    vm_size_t pagesize;

    host_port = mach_host_self();
    host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    host_page_size(host_port, &pagesize);
    vm_statistics_data_t vm_stat;

    if (host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size) != KERN_SUCCESS) {
        return 0;
    }

    natural_t mem_free = vm_stat.free_count * pagesize;

    return (unsigned int)mem_free;
}

- (uint64_t) getCPUUsage {

    struct task_thread_times_info thread_info;
    mach_msg_type_number_t t_info_count = TASK_THREAD_TIMES_INFO_COUNT;
    kern_return_t status;

    status = task_info(current_task(), TASK_THREAD_TIMES_INFO,
            (task_info_t)&thread_info, &t_info_count);

    if (status != KERN_SUCCESS) {
        return 0;
    }

    return tval2msec(thread_info.user_time);
}

- (NSString *) getPlatformString {
    
    NSString  *device = [[UIDevice currentDevice] model];
    if ([device isEqualToString:@"iPhone Simulator"])
        return device;
    
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithUTF8String:machine];
    free(machine);

    return platform;
    
}

@end
