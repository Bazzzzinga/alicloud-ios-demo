//
//  AppDelegate.m
//  apm_ios_demo
//
//  Created by sky on 2019/10/11.
//  Copyright © 2019 aliyun. All rights reserved.
//

#import "AppDelegate.h"

#import "EAPMDemoConfigStore.h"
#import "EAPMDemoHomeViewController.h"
#import <AlicloudApmCore/AlicloudApmCore.h>
#import <AlicloudApmCrashAnalysis/AlicloudApmCrashAnalysis.h>
#import <AlicloudApmPerformance/AlicloudApmPerformance.h>
#import <AlicloudApmRemoteLog/AlicloudApmRemoteLog.h>
#import <AlicloudApmMemAlloc/AlicloudApmMemAlloc.h>
#import <AlicloudApmMemLeak/AlicloudApmMemLeak.h>

static NSString * const EAPMDemoPlaceholderAppKey = @"请替换您的appKey";
static NSString * const EAPMDemoPlaceholderAppSecret = @"请替换您的appSecret";
static NSString * const EAPMDemoPlaceholderAppRsaSecret = @"请替换您的appRsaSecret";

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    UIViewController *launchViewController = [self installLaunchViewController];

//    if (![self canStartApmSDK]) {
//        [self presentInvalidConfigAlertOnPresenter:launchViewController];
//        return YES;
//    }

    // 启动 Alicloud APM SDK
    [self startApmSDK];

    [self installMainInterface];

    return YES;
}

- (UIViewController *)installLaunchViewController {
    UIViewController *launchViewController = [[UIViewController alloc] init];
    launchViewController.view.backgroundColor = [UIColor colorWithRed:0xF3 / 255.0 green:0xF4 / 255.0 blue:0xF8 / 255.0 alpha:1.0];
    self.window.rootViewController = launchViewController;
    [self.window makeKeyAndVisible];
    return launchViewController;
}

- (void)installMainInterface {
    EAPMDemoHomeViewController *homeViewController = [[EAPMDemoHomeViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:homeViewController];
    navigationController.navigationBar.prefersLargeTitles = NO;
    self.window.rootViewController = navigationController;
}

- (BOOL)canStartApmSDK {
    NSString *appKey = EAPMDemoPlaceholderAppKey;
    NSString *appSecret = EAPMDemoPlaceholderAppSecret;
    NSString *appRsaSecret = EAPMDemoPlaceholderAppRsaSecret;

    return [self isValidConfigValue:appKey placeholder:EAPMDemoPlaceholderAppKey] &&
           [self isValidConfigValue:appSecret placeholder:EAPMDemoPlaceholderAppSecret] &&
           [self isValidConfigValue:appRsaSecret placeholder:EAPMDemoPlaceholderAppRsaSecret];
}

- (void)startApmSDK {
    NSString *appKey = EAPMDemoPlaceholderAppKey;
    NSString *appSecret = EAPMDemoPlaceholderAppSecret;
    NSString *appRsaSecret = EAPMDemoPlaceholderAppRsaSecret;
    NSArray *functions = @[[EAPMCrashAnalysis class],
                           [EAPMPerformance class],
                           [EAPMRemoteLog class],
                           [EAPMMemAlloc class],
                           [EAPMMemLeak class]];

    EAPMOptions *options = [[EAPMOptions alloc] initWithAppKey:appKey
                                                     appSecret:appSecret];

    options.userId = [EAPMDemoConfigStore storedUserId];
    options.userNick = [EAPMDemoConfigStore storedUserNick];
    options.channel = @"dev";
    options.appRsaSecret = appRsaSecret;
    options.sdkComponents = functions;

    [EAPMApm startWithOptions:options];
}

- (BOOL)isValidConfigValue:(NSString *)value placeholder:(NSString *)placeholder {
    NSString *trimmedValue = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return trimmedValue.length > 0 && ![trimmedValue isEqualToString:placeholder];
}

- (void)presentInvalidConfigAlertOnPresenter:(UIViewController *)presenter {
    NSString *message = @"当前缺少 appKey 等应用配置。\n请前往 EMAS 控制台获取应用配置，并修改 AppDelegate.m 中的对应常量后重新启动应用。";
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"应用配置缺失"
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) weakSelf = self;
    [alertController addAction:[UIAlertAction actionWithTitle:@"确认退出" style:UIAlertActionStyleDestructive handler:^(__unused UIAlertAction * _Nonnull action) {
        [weakSelf terminateApplication];
    }]];
    [presenter presentViewController:alertController animated:YES completion:nil];
}

- (void)terminateApplication {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        exit(0);
    });
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
