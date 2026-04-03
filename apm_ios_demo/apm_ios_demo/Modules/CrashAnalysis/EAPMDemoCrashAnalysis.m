#import "EAPMDemoCrashAnalysis.h"

#import "EAPMDemoHomeUI.h"
#import "EAPMDemoCrashViewController.h"
#import <AlicloudApmCrashAnalysis/AlicloudApmCrashAnalysis.h>

static void EAPMDemoPresentAlert(UIViewController *presenter, NSString *title, NSString *message) {
    if (!presenter || presenter.presentedViewController) {
        return;
    }

    [EAPMDemoHomeAlertPresenter presentAlertFrom:presenter
                                           title:title
                                         message:message
                                         actions:@[
        [EAPMDemoHomeAlertAction actionWithTitle:@"知道了"
                                           style:EAPMDemoHomeAlertActionStylePrimary
                                         handler:nil],
    ]];
}

static void EAPMDemoPresentConfirmAlert(UIViewController *presenter, NSString *title, NSString *message, dispatch_block_t confirmHandler) {
    if (!presenter || presenter.presentedViewController) {
        return;
    }

    [EAPMDemoHomeAlertPresenter presentAlertFrom:presenter
                                           title:title
                                         message:message
                                         actions:@[
        [EAPMDemoHomeAlertAction actionWithTitle:@"取消"
                                           style:EAPMDemoHomeAlertActionStyleSecondary
                                         handler:nil],
        [EAPMDemoHomeAlertAction actionWithTitle:@"确定"
                                           style:EAPMDemoHomeAlertActionStylePrimary
                                         handler:confirmHandler],
    ]];
}

@implementation EAPMDemoCrashAnalysis

+ (EAPMDemoHomeSectionModel *)sectionWithPresenter:(UIViewController *)presenter {
    __weak UIViewController *weakPresenter = presenter;
    return [EAPMDemoHomeSectionModel sectionWithTitle:@"崩溃分析" items:@[
        [EAPMDemoHomeActionItem itemWithTitle:@"数组越界" actionHandler:^{
            EAPMDemoPresentConfirmAlert(weakPresenter,
                                        @"数组越界",
                                        @"即将触发「数组越界」崩溃，App将闪退，稍后可在 EMAS 控制台看到崩溃信息。",
                                        ^{
                NSArray *array = @[];
                NSLog(@"%@", array[1]);
            });
        }],
        [EAPMDemoHomeActionItem itemWithTitle:@"卡顿" actionHandler:^{
            EAPMDemoPresentConfirmAlert(weakPresenter,
                                        @"卡顿",
                                        @"即将触发应用6秒「卡顿」，卡顿结束后，请切换至后台以触发上报，稍后即可在 EMAS 控制台看到卡顿信息。",
                                        ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [NSThread sleepForTimeInterval:6];
                });
            });
        }],
        [EAPMDemoHomeActionItem itemWithTitle:@"自定义异常" actionHandler:^{
            EAPMCrashAnalysis *crashAnalysis = [EAPMCrashAnalysis crashAnalysis];
            for (NSInteger index = 0; index < 8; index++) {
                [crashAnalysis setCustomValue:[NSString stringWithFormat:@"customValue-%ld", (long)index + 1]
                                       forKey:@"configCustomInfoWithKey"];
                NSError *error = [NSError errorWithDomain:@"customError"
                                                     code:10001 + index
                                                 userInfo:@{
                                                     @"errorInfoKey": [NSString stringWithFormat:@"errorInfoValue-%ld", (long)index + 1],
                                                     @"errorScene": @"home_custom_exception",
                                                 }];
                [crashAnalysis recordError:error];
            }
            EAPMDemoPresentAlert(weakPresenter,
                                 @"自定义异常",
                                 @"已触发多条自定义异常，请在 EMAS 控制台查看自定义异常详情");
        }],
        [EAPMDemoHomeActionItem itemWithTitle:@"其它类型错误" actionHandler:^{
            if (!weakPresenter.navigationController) {
                return;
            }

            EAPMDemoCrashViewController *viewController = [[EAPMDemoCrashViewController alloc] init];
            [weakPresenter.navigationController pushViewController:viewController animated:YES];
        }],
    ]];
}

@end
