#import "EAPMDemoRemoteLog.h"

#import "EAPMDemoHomeUI.h"
#import <AlicloudApmRemoteLog/AlicloudApmRemoteLog.h>

static UIColor *EAPMDemoRemoteLogColorHex(NSUInteger hexValue, CGFloat alpha) {
    return [UIColor colorWithRed:((hexValue >> 16) & 0xFF) / 255.0
                           green:((hexValue >> 8) & 0xFF) / 255.0
                            blue:(hexValue & 0xFF) / 255.0
                           alpha:alpha];
}

static CGFloat EAPMDemoRemoteLogButtonBottomSpacing(CGFloat safeAreaBottomInset) {
    return MAX(safeAreaBottomInset - 10.0, 12.0);
}

@interface EAPMDemoRemoteLogGuideViewController : UIViewController

- (instancetype)initWithTitleText:(NSString *)titleText
                       statusText:(NSString *)statusText
                       guideItems:(NSArray<NSString *> *)guideItems;

@end

static void EAPMDemoPresentRemoteLogGuide(UIViewController *presenter,
                                          NSString *title,
                                          NSString *statusText,
                                          NSArray<NSString *> *guideItems) {
    if (!presenter || presenter.presentedViewController) {
        return;
    }

    EAPMDemoRemoteLogGuideViewController *viewController = [[EAPMDemoRemoteLogGuideViewController alloc] initWithTitleText:title
                                                                                                                  statusText:statusText
                                                                                                                  guideItems:guideItems];
    viewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    viewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [presenter presentViewController:viewController animated:YES completion:nil];
}

@interface EAPMDemoRemoteLogGuideViewController ()

@property (nonatomic, copy) NSString *titleText;
@property (nonatomic, copy) NSString *statusText;
@property (nonatomic, copy) NSArray<NSString *> *guideItems;
@property (nonatomic, strong) UIView *panelView;
@property (nonatomic, strong) UIView *statusBackgroundView;
@property (nonatomic, strong) UIButton *confirmButton;
@property (nonatomic, strong) CAGradientLayer *statusGradientLayer;
@property (nonatomic, strong) CAGradientLayer *buttonGradientLayer;
@property (nonatomic, strong) NSLayoutConstraint *confirmButtonBottomConstraint;
@property (nonatomic, strong) NSLayoutConstraint *panelTopConstraint;

@end

@implementation EAPMDemoRemoteLogGuideViewController

- (instancetype)initWithTitleText:(NSString *)titleText
                       statusText:(NSString *)statusText
                       guideItems:(NSArray<NSString *> *)guideItems {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _titleText = [titleText copy];
        _statusText = [statusText copy];
        _guideItems = [guideItems copy];
        self.modalPresentationCapturesStatusBarAppearance = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.18];

    UIVisualEffectView *backdropView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular]];
    backdropView.translatesAutoresizingMaskIntoConstraints = NO;
    backdropView.alpha = 0.72;
    [self.view addSubview:backdropView];

    UIButton *dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
    dismissButton.translatesAutoresizingMaskIntoConstraints = NO;
    dismissButton.backgroundColor = UIColor.clearColor;
    [dismissButton addTarget:self action:@selector(handleDismissTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:dismissButton];

    self.panelView = [[UIView alloc] init];
    self.panelView.translatesAutoresizingMaskIntoConstraints = NO;
    self.panelView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.98];
    self.panelView.layer.cornerRadius = 22.0;
    self.panelView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    self.panelView.layer.masksToBounds = YES;
    [self.view addSubview:self.panelView];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = EAPMDemoRemoteLogColorHex(0x4B4D52, 1.0);
    UIFont *titleFont = [UIFont fontWithName:@"PingFangSC-Medium" size:20.0] ?: [UIFont systemFontOfSize:20.0 weight:UIFontWeightMedium];
    titleLabel.attributedText = [[NSAttributedString alloc] initWithString:self.titleText attributes:@{
        NSFontAttributeName: titleFont,
        NSKernAttributeName: @(0.4),
        NSForegroundColorAttributeName: EAPMDemoRemoteLogColorHex(0x4B4D52, 1.0),
    }];
    [self.panelView addSubview:titleLabel];

    self.statusBackgroundView = [[UIView alloc] init];
    self.statusBackgroundView.translatesAutoresizingMaskIntoConstraints = NO;
    self.statusBackgroundView.backgroundColor = EAPMDemoRemoteLogColorHex(0xDFF9DF, 1.0);
    self.statusBackgroundView.layer.cornerRadius = 8.0;
    self.statusBackgroundView.layer.masksToBounds = YES;
    self.statusGradientLayer = [CAGradientLayer layer];
    self.statusGradientLayer.colors = @[
        (__bridge id)EAPMDemoRemoteLogColorHex(0xD9F8D2, 1.0).CGColor,
        (__bridge id)EAPMDemoRemoteLogColorHex(0xD6F8E7, 1.0).CGColor,
    ];
    self.statusGradientLayer.startPoint = CGPointMake(0.0, 0.5);
    self.statusGradientLayer.endPoint = CGPointMake(1.0, 0.5);
    [self.statusBackgroundView.layer insertSublayer:self.statusGradientLayer atIndex:0];
    [self.panelView addSubview:self.statusBackgroundView];

    UIView *statusContentView = [[UIView alloc] init];
    statusContentView.translatesAutoresizingMaskIntoConstraints = NO;
    statusContentView.backgroundColor = UIColor.clearColor;
    [self.statusBackgroundView addSubview:statusContentView];

    UIImageView *statusIconView = [[UIImageView alloc] init];
    statusIconView.translatesAutoresizingMaskIntoConstraints = NO;
    if (@available(iOS 13.0, *)) {
        statusIconView.image = [UIImage systemImageNamed:@"checkmark.circle.fill"];
        statusIconView.tintColor = EAPMDemoRemoteLogColorHex(0x2DA45B, 1.0);
    }
    [statusContentView addSubview:statusIconView];

    UILabel *statusLabel = [[UILabel alloc] init];
    statusLabel.translatesAutoresizingMaskIntoConstraints = NO;
    statusLabel.text = self.statusText;
    statusLabel.textColor = EAPMDemoRemoteLogColorHex(0x2DA45B, 1.0);
    statusLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:15.0] ?: [UIFont systemFontOfSize:15.0 weight:UIFontWeightMedium];
    [statusContentView addSubview:statusLabel];

    UIStackView *guideStackView = [[UIStackView alloc] init];
    guideStackView.translatesAutoresizingMaskIntoConstraints = NO;
    guideStackView.axis = UILayoutConstraintAxisVertical;
    guideStackView.spacing = 16.0;
    [self.panelView addSubview:guideStackView];

    BOOL showsStepIndex = self.guideItems.count > 1;
    [self.guideItems enumerateObjectsUsingBlock:^(NSString * _Nonnull guideItem, NSUInteger idx, BOOL * _Nonnull stop) {
        [guideStackView addArrangedSubview:[self guideRowWithText:guideItem index:(showsStepIndex ? idx + 1 : 0)]];
    }];

    self.confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.confirmButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.confirmButton setTitle:@"我知道了" forState:UIControlStateNormal];
    [self.confirmButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    self.confirmButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:18.0] ?: [UIFont systemFontOfSize:18.0 weight:UIFontWeightSemibold];
    self.confirmButton.backgroundColor = EAPMDemoRemoteLogColorHex(0x4250F7, 1.0);
    self.confirmButton.layer.cornerRadius = 8.0;
    self.confirmButton.layer.masksToBounds = YES;
    [self.confirmButton addTarget:self action:@selector(handleDismissTapped) forControlEvents:UIControlEventTouchUpInside];
    self.buttonGradientLayer = [CAGradientLayer layer];
    self.buttonGradientLayer.colors = @[
        (__bridge id)EAPMDemoRemoteLogColorHex(0x4250F7, 1.0).CGColor,
        (__bridge id)EAPMDemoRemoteLogColorHex(0x435FF9, 1.0).CGColor,
    ];
    self.buttonGradientLayer.locations = @[@0, @1];
    self.buttonGradientLayer.startPoint = CGPointMake(1.0, 0.0);
    self.buttonGradientLayer.endPoint = CGPointMake(0.1, 1.0);
    [self.confirmButton.layer insertSublayer:self.buttonGradientLayer atIndex:0];
    [self.panelView addSubview:self.confirmButton];

    UILayoutGuide *safeArea = self.view.safeAreaLayoutGuide;
    self.panelTopConstraint = [self.panelView.topAnchor constraintGreaterThanOrEqualToAnchor:safeArea.topAnchor constant:120.0];
    self.confirmButtonBottomConstraint = [self.confirmButton.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-EAPMDemoRemoteLogButtonBottomSpacing(self.view.safeAreaInsets.bottom)];
    [NSLayoutConstraint activateConstraints:@[
        [backdropView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [backdropView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [backdropView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [backdropView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],

        [dismissButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [dismissButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [dismissButton.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [dismissButton.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],

        [self.panelView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.panelView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.panelView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        self.panelTopConstraint,

        [titleLabel.leadingAnchor constraintEqualToAnchor:self.panelView.leadingAnchor constant:24.0],
        [titleLabel.trailingAnchor constraintEqualToAnchor:self.panelView.trailingAnchor constant:-24.0],
        [titleLabel.topAnchor constraintEqualToAnchor:self.panelView.topAnchor constant:24.0],

        [self.statusBackgroundView.leadingAnchor constraintEqualToAnchor:self.panelView.leadingAnchor constant:16.0],
        [self.statusBackgroundView.trailingAnchor constraintEqualToAnchor:self.panelView.trailingAnchor constant:-16.0],
        [self.statusBackgroundView.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:18.0],
        [self.statusBackgroundView.heightAnchor constraintEqualToConstant:40.0],

        [statusContentView.centerXAnchor constraintEqualToAnchor:self.statusBackgroundView.centerXAnchor],
        [statusContentView.centerYAnchor constraintEqualToAnchor:self.statusBackgroundView.centerYAnchor],

        [statusIconView.leadingAnchor constraintEqualToAnchor:statusContentView.leadingAnchor],
        [statusIconView.centerYAnchor constraintEqualToAnchor:statusContentView.centerYAnchor],
        [statusIconView.widthAnchor constraintEqualToConstant:18.0],
        [statusIconView.heightAnchor constraintEqualToConstant:18.0],

        [statusLabel.leadingAnchor constraintEqualToAnchor:statusIconView.trailingAnchor constant:8.0],
        [statusLabel.trailingAnchor constraintEqualToAnchor:statusContentView.trailingAnchor],
        [statusLabel.centerYAnchor constraintEqualToAnchor:statusContentView.centerYAnchor],

        [guideStackView.leadingAnchor constraintEqualToAnchor:self.panelView.leadingAnchor constant:16.0],
        [guideStackView.trailingAnchor constraintEqualToAnchor:self.panelView.trailingAnchor constant:-16.0],
        [guideStackView.topAnchor constraintEqualToAnchor:self.statusBackgroundView.bottomAnchor constant:20.0],
        [guideStackView.bottomAnchor constraintLessThanOrEqualToAnchor:self.confirmButton.topAnchor constant:-28.0],

        [self.confirmButton.leadingAnchor constraintEqualToAnchor:self.panelView.leadingAnchor constant:16.0],
        [self.confirmButton.trailingAnchor constraintEqualToAnchor:self.panelView.trailingAnchor constant:-16.0],
        [self.confirmButton.topAnchor constraintGreaterThanOrEqualToAnchor:guideStackView.bottomAnchor constant:28.0],
        [self.confirmButton.heightAnchor constraintEqualToConstant:60.0],
        self.confirmButtonBottomConstraint,
    ]];
}

- (UIView *)guideRowWithText:(NSString *)text index:(NSUInteger)index {
    UIView *containerView = [[UIView alloc] init];
    containerView.translatesAutoresizingMaskIntoConstraints = NO;

    UILabel *textLabel = [[UILabel alloc] init];
    textLabel.translatesAutoresizingMaskIntoConstraints = NO;
    textLabel.numberOfLines = 0;
    textLabel.textColor = EAPMDemoRemoteLogColorHex(0x63728D, 1.0);
    textLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:17.0] ?: [UIFont systemFontOfSize:17.0 weight:UIFontWeightRegular];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.minimumLineHeight = 25.0;
    paragraphStyle.maximumLineHeight = 25.0;
    textLabel.attributedText = [[NSAttributedString alloc] initWithString:text attributes:@{
        NSFontAttributeName: textLabel.font,
        NSForegroundColorAttributeName: textLabel.textColor,
        NSParagraphStyleAttributeName: paragraphStyle,
    }];
    [containerView addSubview:textLabel];

    if (index > 0) {
        UILabel *indexLabel = [[UILabel alloc] init];
        indexLabel.translatesAutoresizingMaskIntoConstraints = NO;
        indexLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)index];
        indexLabel.textAlignment = NSTextAlignmentCenter;
        indexLabel.textColor = UIColor.whiteColor;
        indexLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:12.0] ?: [UIFont systemFontOfSize:12.0 weight:UIFontWeightSemibold];
        indexLabel.backgroundColor = EAPMDemoRemoteLogColorHex(0x4D61FF, 1.0);
        indexLabel.layer.cornerRadius = 9.0;
        indexLabel.layer.masksToBounds = YES;
        [containerView addSubview:indexLabel];

        [NSLayoutConstraint activateConstraints:@[
            [indexLabel.leadingAnchor constraintEqualToAnchor:containerView.leadingAnchor],
            [indexLabel.topAnchor constraintEqualToAnchor:containerView.topAnchor constant:2.0],
            [indexLabel.widthAnchor constraintEqualToConstant:18.0],
            [indexLabel.heightAnchor constraintEqualToConstant:18.0],

            [textLabel.leadingAnchor constraintEqualToAnchor:indexLabel.trailingAnchor constant:12.0],
            [textLabel.trailingAnchor constraintEqualToAnchor:containerView.trailingAnchor],
            [textLabel.topAnchor constraintEqualToAnchor:containerView.topAnchor],
            [textLabel.bottomAnchor constraintEqualToAnchor:containerView.bottomAnchor],
        ]];
    } else {
        [NSLayoutConstraint activateConstraints:@[
            [textLabel.leadingAnchor constraintEqualToAnchor:containerView.leadingAnchor],
            [textLabel.trailingAnchor constraintEqualToAnchor:containerView.trailingAnchor],
            [textLabel.topAnchor constraintEqualToAnchor:containerView.topAnchor],
            [textLabel.bottomAnchor constraintEqualToAnchor:containerView.bottomAnchor],
        ]];
    }

    return containerView;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.statusGradientLayer.frame = self.statusBackgroundView.bounds;
    self.buttonGradientLayer.frame = self.confirmButton.bounds;
    [self.panelView bringSubviewToFront:self.confirmButton];
}

- (void)viewSafeAreaInsetsDidChange {
    [super viewSafeAreaInsetsDidChange];
    self.confirmButtonBottomConstraint.constant = -EAPMDemoRemoteLogButtonBottomSpacing(self.view.safeAreaInsets.bottom);
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (void)handleDismissTapped {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

@implementation EAPMDemoRemoteLog

+ (EAPMDemoHomeSectionModel *)sectionWithPresenter:(UIViewController *)presenter {
    __weak UIViewController *weakPresenter = presenter;
    return [EAPMDemoHomeSectionModel sectionWithTitle:@"远程日志" items:@[
        [EAPMDemoHomeActionItem itemWithTitle:@"日志回捞" actionHandler:^{
            EAPMRemoteLog *remoteLogger = [[EAPMRemoteLog alloc] initWithModuleName:@"YourModuleName"];
            [remoteLogger error:@"error message"];
            [remoteLogger warn:@"warn message"];
            [remoteLogger debug:@"debug message"];
            [remoteLogger info:@"info message"];
            EAPMDemoPresentRemoteLogGuide(weakPresenter,
                                          @"日志回捞",
                                          @"打日志成功",
                                          @[
                                              @"在 EMAS 控制台「远程日志」模块，根据当前设备，创建回捞任务",
                                              @"Demo App 切换前后台上报日志",
                                              @"等待1-2分钟，在控制台查看日志",
                                          ]);
        }],
        [EAPMDemoHomeActionItem itemWithTitle:@"主动上报" actionHandler:^{
            [EAPMRemoteLog uploadTLog:@"主动上报bizComment"];
            EAPMDemoPresentRemoteLogGuide(weakPresenter,
                                          @"主动上报",
                                          @"打日志成功",
                                          @[
                                              @"等待1-2分钟，在 EMAS 控制台「远程日志」模块查看日志",
                                          ]);
        }],
    ]];
}

@end
