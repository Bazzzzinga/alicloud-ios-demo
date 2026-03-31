#import "EAPMDemoConfigStore.h"

#import "EAPMDemoConstants.h"

@implementation EAPMDemoConfigStore

+ (void)userDefaultSetObject:(id)value forKey:(NSString *)key {
    if (key) {
        [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (id)userDefaultGet:(NSString *)key {
    if (key) {
        return [[NSUserDefaults standardUserDefaults] objectForKey:key];
    }
    return nil;
}

+ (void)setUpConfigWithAppKey:(NSString * _Nullable * _Nonnull)appKey
                    appSecret:(NSString * _Nullable * _Nonnull)appSecret
                 appRsaSecret:(NSString * _Nullable * _Nonnull)appRsaSecret
                    functions:(NSArray * _Nullable * _Nonnull)functions {
    if ([*appKey isEqualToString:@"请替换您的appKey"]) {
        *appKey = (NSString *)[EAPMDemoConfigStore userDefaultGet:kAppKey];
    }

    if ([*appSecret isEqualToString:@"请替换您的appSecret"]) {
        *appSecret = (NSString *)[EAPMDemoConfigStore userDefaultGet:kAppSecret];
    }

    if ([*appRsaSecret isEqualToString:@"请替换您的appRsaSecret"]) {
        *appRsaSecret = (NSString *)[EAPMDemoConfigStore userDefaultGet:kAppRsaSecret];
    }

    NSArray *localFunctions = (NSArray *)[EAPMDemoConfigStore userDefaultGet:kFunctions];
    if (localFunctions && localFunctions.count >= 0) {
        NSMutableArray *functionsClass = [NSMutableArray array];
        for (NSString *function in localFunctions) {
            [functionsClass addObject:NSClassFromString(function)];
        }
        *functions = functionsClass;
    }
}

@end
