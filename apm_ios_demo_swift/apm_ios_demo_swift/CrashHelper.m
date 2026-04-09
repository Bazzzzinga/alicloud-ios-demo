#import "CrashHelper.h"
#import "CrashHandler.hpp"

@implementation CrashHelper

+ (void)triggerNSArrayException {
    NSArray *array = @[];
    NSLog(@"Crash element: %@", array[1]);
}

+ (void)triggerCppCrash {
    triggerCppCrash();
}

+ (void)triggerMachException {
    __builtin_trap();
}

@end
