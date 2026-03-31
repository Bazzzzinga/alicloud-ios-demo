#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EAPMDemoConfigStore : NSObject

+ (void)userDefaultSetObject:(id)value forKey:(NSString *)key;
+ (id)userDefaultGet:(NSString *)key;
+ (void)setUpConfigWithAppKey:(NSString * _Nullable * _Nonnull)appKey
                    appSecret:(NSString * _Nullable * _Nonnull)appSecret
                 appRsaSecret:(NSString * _Nullable * _Nonnull)appRsaSecret
                    functions:(NSArray * _Nullable * _Nonnull)functions;

@end

NS_ASSUME_NONNULL_END
