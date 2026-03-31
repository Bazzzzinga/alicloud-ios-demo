#import "EAPMDemoRemoteLog.h"

#import "EAPMDemoHomeUI.h"
#import "EAPMDemoSDKImports.h"

static void EAPMDemoPresentRemoteLogAlert(UIViewController *presenter, NSString *message) {
    if (!presenter || presenter.presentedViewController) {
        return;
    }

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil]];
    [presenter presentViewController:alertController animated:YES completion:nil];
}

@implementation EAPMDemoRemoteLog

+ (EAPMDemoHomeSectionModel *)sectionWithPresenter:(UIViewController *)presenter {
    __weak UIViewController *weakPresenter = presenter;
    return [EAPMDemoHomeSectionModel sectionWithTitle:@"远程日志" items:@[
        [EAPMDemoHomeActionItem itemWithTitle:@"日志回捞" actionHandler:^{
            EAPMDemoPresentRemoteLogAlert(weakPresenter, @"功能建设中，暂未接入触发动作");
        }],
        [EAPMDemoHomeActionItem itemWithTitle:@"主动上报" actionHandler:^{
            EAPMRemoteLog *remoteLogger = [[EAPMRemoteLog alloc] initWithModuleName:@"YourModuleName"];
            [remoteLogger error:@"error message"];
            [remoteLogger warn:@"warn message"];
            [remoteLogger debug:@"debug message"];
            [remoteLogger info:@"info message"];
            [EAPMRemoteLog uploadTLog:@"主动上报bizComment"];
            EAPMDemoPresentRemoteLogAlert(weakPresenter, @"已写入并主动上报远程日志");
        }],
    ]];
}

@end
