#import "EAPMDemoCrashAnalysis.h"

#import "EAPMDemoHomeUI.h"
#import <AlicloudApmCrashAnalysis/AlicloudApmCrashAnalysis.h>

static void EAPMDemoPresentAlert(UIViewController *presenter, NSString *message) {
    if (!presenter || presenter.presentedViewController) {
        return;
    }

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil]];
    [presenter presentViewController:alertController animated:YES completion:nil];
}

@implementation EAPMDemoCrashAnalysis

+ (EAPMDemoHomeSectionModel *)sectionWithPresenter:(UIViewController *)presenter {
    __weak UIViewController *weakPresenter = presenter;
    return [EAPMDemoHomeSectionModel sectionWithTitle:@"崩溃分析" items:@[
        [EAPMDemoHomeActionItem itemWithTitle:@"全堆栈Crash" actionHandler:^{
            NSArray *array = @[];
            NSLog(@"%@", array[1]);
        }],
        [EAPMDemoHomeActionItem itemWithTitle:@"Abort" actionHandler:^{
            abort();
        }],
        [EAPMDemoHomeActionItem itemWithTitle:@"触发卡顿" actionHandler:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [NSThread sleepForTimeInterval:30];
            });
        }],
        [EAPMDemoHomeActionItem itemWithTitle:@"自定义异常" actionHandler:^{
            [[EAPMCrashAnalysis crashAnalysis] setCustomValue:@"customValue" forKey:@"configCustomInfoWithKey"];
            NSError *error = [NSError errorWithDomain:@"customError" code:10001 userInfo:@{@"errorInfoKey": @"errorInfoValue"}];
            [[EAPMCrashAnalysis crashAnalysis] recordError:error];
            EAPMDemoPresentAlert(weakPresenter, @"已记录自定义异常和自定义维度");
        }],
    ]];
}

@end
