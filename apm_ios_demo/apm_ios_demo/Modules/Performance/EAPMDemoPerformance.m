#import "EAPMDemoPerformance.h"

#import "EAPMDemoHomeUI.h"
#import "EAPMDemoPerformanceLoadViewController.h"
#import "EAPMDemoPerformanceScrollViewController.h"

static void EAPMDemoPresentPerformanceAlert(UIViewController *presenter, NSString *message) {
    if (!presenter || presenter.presentedViewController) {
        return;
    }

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil]];
    [presenter presentViewController:alertController animated:YES completion:nil];
}

@implementation EAPMDemoPerformance

+ (EAPMDemoHomeSectionModel *)sectionWithPresenter:(UIViewController *)presenter {
    __weak UIViewController *weakPresenter = presenter;
    return [EAPMDemoHomeSectionModel sectionWithTitle:@"性能分析" items:@[
        [EAPMDemoHomeActionItem itemWithTitle:@"启动分析" actionHandler:^{
            EAPMDemoPerformanceLoadViewController *viewController = [[EAPMDemoPerformanceLoadViewController alloc] init];
            [weakPresenter.navigationController pushViewController:viewController animated:YES];
        }],
        [EAPMDemoHomeActionItem itemWithTitle:@"页面分析" actionHandler:^{
            EAPMDemoPerformanceScrollViewController *viewController = [[EAPMDemoPerformanceScrollViewController alloc] init];
            [weakPresenter.navigationController pushViewController:viewController animated:YES];
        }],
        [EAPMDemoHomeActionItem itemWithTitle:@"网络分析" actionHandler:^{
            NSString *urlString = @"https://www.baidu.com/";
            __block BOOL hasPresented = NO;
            for (NSInteger index = 0; index < 10; index++) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
                    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]
                                                                          delegate:nil
                                                                     delegateQueue:[NSOperationQueue mainQueue]];
                    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                        if (hasPresented) {
                            return;
                        }
                        hasPresented = YES;
                        if (error) {
                            EAPMDemoPresentPerformanceAlert(weakPresenter, [NSString stringWithFormat:@"触发:%@，error:%@", urlString, error.localizedDescription]);
                        } else {
                            EAPMDemoPresentPerformanceAlert(weakPresenter, [NSString stringWithFormat:@"触发:%@，success", urlString]);
                        }
                    }];
                    [task resume];
                });
            }
        }],
    ]];
}

@end
