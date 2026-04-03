#import "EAPMDemoCrashAnalysis.h"

#import "EAPMDemoHomeUI.h"
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

    UIVisualEffectView *toastView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    toastView.translatesAutoresizingMaskIntoConstraints = NO;
    toastView.alpha = 0.0;
    toastView.layer.cornerRadius = 16.0;
    toastView.layer.shadowColor = EAPMDemoCrashAnalysisHexColor(0x6782B5, 0.18).CGColor;
    toastView.layer.shadowOpacity = 1.0;
    toastView.layer.shadowRadius = 18.0;
    toastView.layer.shadowOffset = CGSizeMake(0, 10);
    toastView.layer.masksToBounds = NO;

    UIView *contentView = toastView.contentView;
    contentView.backgroundColor = EAPMDemoCrashAnalysisHexColor(0xFFFFFF, 0.9);

    UILabel *messageLabel = [[UILabel alloc] init];
    messageLabel.translatesAutoresizingMaskIntoConstraints = NO;
    messageLabel.text = message;
    messageLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16.0] ?: [UIFont systemFontOfSize:16.0 weight:UIFontWeightRegular];
    messageLabel.textColor = EAPMDemoCrashAnalysisHexColor(0x2F3642, 1.0);
    messageLabel.textAlignment = NSTextAlignmentCenter;

    [contentView addSubview:messageLabel];
    [presenter.view addSubview:toastView];

    [NSLayoutConstraint activateConstraints:@[
        [toastView.centerXAnchor constraintEqualToAnchor:presenter.view.centerXAnchor],
        [toastView.bottomAnchor constraintEqualToAnchor:presenter.view.safeAreaLayoutGuide.bottomAnchor constant:-28.0],
        [toastView.leadingAnchor constraintGreaterThanOrEqualToAnchor:presenter.view.leadingAnchor constant:20.0],
        [messageLabel.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:18.0],
        [messageLabel.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-18.0],
        [messageLabel.topAnchor constraintEqualToAnchor:contentView.topAnchor constant:14.0],
        [messageLabel.bottomAnchor constraintEqualToAnchor:contentView.bottomAnchor constant:-14.0],
    ]];

    [UIView animateWithDuration:0.2 animations:^{
        toastView.alpha = 1.0;
    } completion:^(__unused BOOL finished) {
        [UIView animateWithDuration:0.2
                              delay:1.2
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
            toastView.alpha = 0.0;
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
                                        @"即将触发应用5秒「卡顿」，卡顿结束后，请切换至后台以触发上报，稍后即可在 EMAS 控制台看到卡顿信息。",
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
        [EAPMDemoHomeActionItem itemWithTitle:@"其它崩溃类型" actionHandler:^{
            if (!weakPresenter.navigationController) {
                return;
            }

            EAPMDemoCrashViewController *viewController = [[EAPMDemoCrashViewController alloc] init];
            [weakPresenter.navigationController pushViewController:viewController animated:YES];
        }],
    ]];
}

@end
