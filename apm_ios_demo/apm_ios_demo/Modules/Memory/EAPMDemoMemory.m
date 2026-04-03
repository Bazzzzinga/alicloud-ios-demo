#import "EAPMDemoMemory.h"

#import "EAPMDemoHomeUI.h"

static void EAPMDemoPresentMemoryAlert(UIViewController *presenter) {
    if (!presenter || presenter.presentedViewController) {
        return;
    }

    [EAPMDemoHomeAlertPresenter presentAlertFrom:presenter
                                           title:@"提示"
                                         message:@"功能建设中，暂未接入触发动作"
                                         actions:@[
        [EAPMDemoHomeAlertAction actionWithTitle:@"知道了"
                                           style:EAPMDemoHomeAlertActionStylePrimary
                                         handler:nil],
    ]];
}

@implementation EAPMDemoMemory

+ (EAPMDemoHomeSectionModel *)sectionWithPresenter:(UIViewController *)presenter {
    __weak UIViewController *weakPresenter = presenter;
    return [EAPMDemoHomeSectionModel sectionWithTitle:@"内存分析" items:@[
        [EAPMDemoHomeActionItem itemWithTitle:@"OOM" actionHandler:^{
            EAPMDemoPresentMemoryAlert(weakPresenter);
        }],
        [EAPMDemoHomeActionItem itemWithTitle:@"内存泄漏" actionHandler:^{
            EAPMDemoPresentMemoryAlert(weakPresenter);
        }],
        [EAPMDemoHomeActionItem itemWithTitle:@"大对象" actionHandler:^{
            EAPMDemoPresentMemoryAlert(weakPresenter);
        }],
    ]];
}

@end
