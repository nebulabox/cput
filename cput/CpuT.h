//
//  CpuT.h
//  cput
//
//  Created by Jim Raynor on 2016/11/15.
//  Copyright © 2016 para. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CpuT : NSObject

+(void)start_cput:(pid_t)tracePid throttle:(double)throttle;
+(void)stop_cput;

@end
