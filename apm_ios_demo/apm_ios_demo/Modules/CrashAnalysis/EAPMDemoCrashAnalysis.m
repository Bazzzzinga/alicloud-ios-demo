#import "EAPMDemoCrashAnalysis.h"

#import "EAPMDemoHomeUI.h"
#import "../Shared/EAPMDemoUIStyleGuide.h"
#import "EAPMDemoCrashViewController.h"
#import <AlicloudApmCrashAnalysis/AlicloudApmCrashAnalysis.h>

static UIColor *EAPMDemoCrashAnalysisHexColor(NSUInteger hexValue, CGFloat alpha) {
    return [UIColor colorWithRed:((hexValue >> 16) & 0xFF) / 255.0
                           green:((hexValue >> 8) & 0xFF) / 255.0
                            blue:(hexValue & 0xFF) / 255.0
                           alpha:alpha];
}

static void EAPMDemoShowToast(UIViewController *presenter, NSString *message) {
    if (!presenter || !presenter.view || message.length == 0) {
        return;
    }

    UIView *toastView = [[UIView alloc] init];
    toastView.translatesAutoresizingMaskIntoConstraints = NO;
    toastView.alpha = 0.0;
    toastView.backgroundColor = EAPMDemoCrashAnalysisHexColor(0x1E2A44, 0.96);
    toastView.layer.cornerRadius = 12.0;

    UILabel *messageLabel = [[UILabel alloc] init];
    messageLabel.translatesAutoresizingMaskIntoConstraints = NO;
    messageLabel.text = message;
    messageLabel.font = EAPMDemoUIFontMedium(15.0);
    messageLabel.textColor = UIColor.whiteColor;
    messageLabel.textAlignment = NSTextAlignmentCenter;
    [toastView addSubview:messageLabel];
    [presenter.view addSubview:toastView];

    [NSLayoutConstraint activateConstraints:@[
        [toastView.centerXAnchor constraintEqualToAnchor:presenter.view.centerXAnchor],
        [toastView.bottomAnchor constraintEqualToAnchor:presenter.view.safeAreaLayoutGuide.bottomAnchor constant:-28.0],
        [toastView.leadingAnchor constraintGreaterThanOrEqualToAnchor:presenter.view.leadingAnchor constant:20.0],
        [messageLabel.leadingAnchor constraintEqualToAnchor:toastView.leadingAnchor constant:18.0],
        [messageLabel.trailingAnchor constraintEqualToAnchor:toastView.trailingAnchor constant:-18.0],
        [messageLabel.topAnchor constraintEqualToAnchor:toastView.topAnchor constant:12.0],
        [messageLabel.bottomAnchor constraintEqualToAnchor:toastView.bottomAnchor constant:-12.0],
    ]];

    toastView.transform = CGAffineTransformMakeTranslation(0, 8.0);
    [UIView animateWithDuration:0.22
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
        toastView.alpha = 1.0;
        toastView.transform = CGAffineTransformIdentity;
    } completion:^(__unused BOOL finished) {
        [UIView animateWithDuration:0.2
                              delay:1.2
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
            toastView.alpha = 0.0;
            toastView.transform = CGAffineTransformMakeTranslation(0, 6.0);
        } completion:^(__unused BOOL finishedInner) {
            [toastView removeFromSuperview];
        }];
    }];
}

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
        [EAPMDemoHomeActionItem itemWithTitle:@"崩溃" actionHandler:^{
            EAPMDemoPresentConfirmAlert(weakPresenter,
                                        @"崩溃",
                                        @"即将触发崩溃，App将闪退，稍后可在 EMAS 控制台看到崩溃信息。",
                                        ^{
                NSArray *array = @[];
                NSLog(@"%@", array[1]);
            });
        }],
        [EAPMDemoHomeActionItem itemWithTitle:@"卡顿" actionHandler:^{
            EAPMDemoPresentConfirmAlert(weakPresenter,
                                        @"卡顿",
                                        @"即将触发应用5秒「卡顿」，卡顿结束后，请切换至后台触发上报，稍后可在 EMAS 控制台看到卡顿信息。",
                                        ^{
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    EAPMDemoShowToast(weakPresenter, @"卡顿结束");
                });
                dispatch_async(dispatch_get_main_queue(), ^{
                    [NSThread sleepForTimeInterval:5];
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
        [EAPMDemoHomeActionItem itemWithTitle:@"其它类型崩溃" actionHandler:^{
            if (!weakPresenter.navigationController) {
                return;
            }

            EAPMDemoCrashViewController *viewController = [[EAPMDemoCrashViewController alloc] init];
            [weakPresenter.navigationController pushViewController:viewController animated:YES];
        }],
    ]];
}

@end
