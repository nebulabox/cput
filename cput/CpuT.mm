//
//  CpuT.m
//  cput
//
//  Created by Jim Raynor on 2016/11/15.
//  Copyright © 2016 para. All rights reserved.
//

#import "CpuT.h"
#import "Process.h"

#include <errno.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/time.h>
#include <sys/proc.h>
#include <sys/ptrace.h>
#include <sys/sysctl.h>
#include <sys/vnode.h>
#include <boost/lexical_cast.hpp>
#include <iostream>
#include <math.h>
#include <time.h>
#include <vector>

bool done = false;
Process::Manipulator manip;

void sleepNanoseconds(double amt_)
{
    timespec tv;
    
    double integral, fractional;
    fractional = modf(amt_, &integral);
    tv.tv_sec = integral;
    tv.tv_nsec = fractional * 1000000000.0;
    
    nanosleep(&tv, 0);
}


@implementation CpuT

+(void)start_cput:(pid_t)tracePid throttle:(double)throttle
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        done = false;
        
        manip.attach(tracePid);
        
        const double period = 0.1; // max amount for us to sleep
        const double minSleepAmt = 0.02; // minimum sleep amount is 20 ms
        double sleepAmt = minSleepAmt;
        double user_time, system_time, percent;
        
        manip.resume(tracePid);
        manip.sample(tracePid, &user_time, &system_time, &percent); // initial sample
        
        try
        {
            while(!done)
            {
                manip.sample(tracePid, &user_time, &system_time, &percent);
                
                double error = percent - throttle;
                if(sleepAmt == 0.0 && error > 0.0)
                {
                    sleepAmt = minSleepAmt;
                }
                sleepAmt += error * minSleepAmt;
                //     std::cout << "Adj sleepamt = " << sleepAmt << std::endl;
                if(sleepAmt < minSleepAmt)
                {
                    sleepAmt = 0;
                }
                
                if(sleepAmt > period)
                {
                    sleepAmt = period;
                }
                
                //std::cout << "Considering Sleep for " << sleepAmt << ", error = " << error << std::endl;
                if(sleepAmt >= minSleepAmt)
                {
                    //	      std::cout << "Sleep for " << sleepAmt << std::endl;
                    manip.suspend(tracePid);
                    sleepNanoseconds(sleepAmt);
                    manip.resume(tracePid);
                }
                
                sleepNanoseconds(period - sleepAmt);
            }
        }
        catch(...)
        {}
    });
}

+(void)stop_cput
{
    done = true;
}

@end
