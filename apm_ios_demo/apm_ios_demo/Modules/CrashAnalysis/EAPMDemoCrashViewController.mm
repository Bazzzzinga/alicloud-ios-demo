#import "EAPMDemoCrashViewController.h"

#import "EAPMDemoHomeUI.h"
#import "../Shared/EAPMDemoUIStyleGuide.h"
#import <signal.h>
#import <stdlib.h>
#import <string.h>
#import <TargetConditionals.h>
#import <stdexcept>
#import <unistd.h>

static UIColor *EAPMDemoCrashHexColor(NSUInteger hexValue, CGFloat alpha) {
    return [UIColor colorWithRed:((hexValue >> 16) & 0xFF) / 255.0
                           green:((hexValue >> 8) & 0xFF) / 255.0
                           blue:(hexValue & 0xFF) / 255.0
                           alpha:alpha];
}

static NSMutableArray<NSValue *> *EAPMDemoOOMPointers(void) {
    static NSMutableArray<NSValue *> *pointers = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pointers = [NSMutableArray array];
    });
    return pointers;
}

typedef NS_ENUM(NSInteger, EAPMDemoCrashTriggerType) {
    EAPMDemoCrashTriggerTypeNSException = 0,
    EAPMDemoCrashTriggerTypeCpp,
    EAPMDemoCrashTriggerTypeMach,
    EAPMDemoCrashTriggerTypeSignal,
    EAPMDemoCrashTriggerTypeHang,
    EAPMDemoCrashTriggerTypeOOM,
    EAPMDemoCrashTriggerTypeAsyncException,
    EAPMDemoCrashTriggerTypeDeadlock,
};

@interface EAPMDemoCrashViewController ()

@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;

@end

@implementation EAPMDemoCrashViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"";
    self.navigationItem.hidesBackButton = YES;
    self.view.backgroundColor = UIColor.whiteColor;

    [self buildViews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)buildViews {
    _headerView = [[UIView alloc] init];
    _headerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_headerView];

    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    backButton.translatesAutoresizingMaskIntoConstraints = NO;
    if (@available(iOS 13.0, *)) {
        UIImageSymbolConfiguration *configuration = [UIImageSymbolConfiguration configurationWithPointSize:12.0 weight:UIImageSymbolWeightMedium];
        UIImage *image = [UIImage systemImageNamed:@"chevron.left" withConfiguration:configuration];
        [backButton setImage:image forState:UIControlStateNormal];
    } else {
        [backButton setTitle:@"返回" forState:UIControlStateNormal];
        backButton.titleLabel.font = [UIFont systemFontOfSize:13.0 weight:UIFontWeightMedium];
    }
    backButton.tintColor = EAPMDemoCrashHexColor(0x1F2024, 1.0);
    [backButton addTarget:self action:@selector(handleBackButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [_headerView addSubview:backButton];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    titleLabel.numberOfLines = 1;
    titleLabel.attributedText = EAPMDemoPageTitleAttributedString(@"其它类型崩溃", EAPMDemoCrashHexColor(0x4B4D52, 1.0));
    [_headerView addSubview:titleLabel];

    _scrollView = [[UIScrollView alloc] init];
    _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    _scrollView.alwaysBounceVertical = YES;
    [self.view addSubview:_scrollView];

    _contentView = [[UIView alloc] init];
    _contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [_scrollView addSubview:_contentView];

    UIView *tipCardView = [[UIView alloc] init];
    tipCardView.translatesAutoresizingMaskIntoConstraints = NO;
    EAPMDemoApplyTipCardStyle(tipCardView, EAPMDemoCrashHexColor(0xEEF3FF, 1.0));
    [_contentView addSubview:tipCardView];

    UILabel *descLabel = [[UILabel alloc] init];
    descLabel.translatesAutoresizingMaskIntoConstraints = NO;
    descLabel.numberOfLines = 0;
    descLabel.text = @"更多崩溃和错误类型，点击按钮触发对应类型的异常。触发后请前往 EMAS 控制台查看崩溃详情和堆栈信息。";
    descLabel.attributedText = EAPMDemoInfoAttributedString(descLabel.text, EAPMDemoCrashHexColor(0x7A8FB8, 1.0));
    [tipCardView addSubview:descLabel];

    UIView *sectionIndicator = EAPMDemoCreateSectionIndicatorView(EAPMDemoCrashHexColor(0x315CFC, 1.0));
    [_contentView addSubview:sectionIndicator];

    UILabel *sectionTitleLabel = [[UILabel alloc] init];
    EAPMDemoConfigureSectionTitleLabel(sectionTitleLabel, @"崩溃列表", EAPMDemoCrashHexColor(0x4B4D52, 1.0));
    [_contentView addSubview:sectionTitleLabel];

    NSArray<NSDictionary<NSString *, id> *> *items = @[
        @{@"title": @"NSException", @"type": @(EAPMDemoCrashTriggerTypeNSException)},
        @{@"title": @"C++ 异常", @"type": @(EAPMDemoCrashTriggerTypeCpp)},
        @{@"title": @"Mach 异常", @"type": @(EAPMDemoCrashTriggerTypeMach)},
        @{@"title": @"SIGNAL 崩溃", @"type": @(EAPMDemoCrashTriggerTypeSignal)},
        @{@"title": @"卡死", @"type": @(EAPMDemoCrashTriggerTypeHang)},
        @{@"title": @"OOM", @"type": @(EAPMDemoCrashTriggerTypeOOM)},
        @{@"title": @"AsyncException", @"type": @(EAPMDemoCrashTriggerTypeAsyncException)},
        @{@"title": @"Deadlock", @"type": @(EAPMDemoCrashTriggerTypeDeadlock)},
    ];

    UIStackView *gridStackView = [[UIStackView alloc] init];
    gridStackView.translatesAutoresizingMaskIntoConstraints = NO;
    gridStackView.axis = UILayoutConstraintAxisVertical;
    gridStackView.spacing = 6.0;
    [_contentView addSubview:gridStackView];

    for (NSInteger index = 0; index < items.count; index += 2) {
        UIStackView *rowStackView = [[UIStackView alloc] init];
        rowStackView.axis = UILayoutConstraintAxisHorizontal;
        rowStackView.alignment = UIStackViewAlignmentFill;
        rowStackView.distribution = UIStackViewDistributionFillEqually;
        rowStackView.spacing = 6.0;

        NSRange range = NSMakeRange(index, MIN(2, items.count - index));
        NSArray<NSDictionary<NSString *, id> *> *rowItems = [items subarrayWithRange:range];
        for (NSDictionary<NSString *, id> *item in rowItems) {
            UIButton *button = [self createCrashButtonWithTitle:item[@"title"] type:(EAPMDemoCrashTriggerType)[item[@"type"] integerValue]];
            [rowStackView addArrangedSubview:button];
        }

        if (rowItems.count == 1) {
            UIView *placeholderView = [[UIView alloc] init];
            [rowStackView addArrangedSubview:placeholderView];
        }

        [gridStackView addArrangedSubview:rowStackView];
        [rowStackView.heightAnchor constraintEqualToConstant:EAPMDemoUISecondaryActionHeight].active = YES;
    }

    UILayoutGuide *safeArea = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [_headerView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [_headerView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [_headerView.topAnchor constraintEqualToAnchor:safeArea.topAnchor],

        [backButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:EAPMDemoUIHorizontalInset],
        [backButton.topAnchor constraintEqualToAnchor:_headerView.topAnchor constant:EAPMDemoUIHeaderTopPadding],
        [backButton.widthAnchor constraintEqualToConstant:20.0],
        [backButton.heightAnchor constraintEqualToConstant:20.0],

        [titleLabel.leadingAnchor constraintEqualToAnchor:backButton.trailingAnchor constant:EAPMDemoUIHeaderTitleSpacing],
        [titleLabel.centerYAnchor constraintEqualToAnchor:backButton.centerYAnchor],

        [_headerView.bottomAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:EAPMDemoUIHeaderBottomPadding],

        [_scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [_scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [_scrollView.topAnchor constraintEqualToAnchor:_headerView.bottomAnchor],
        [_scrollView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],

        [_contentView.leadingAnchor constraintEqualToAnchor:_scrollView.contentLayoutGuide.leadingAnchor],
        [_contentView.trailingAnchor constraintEqualToAnchor:_scrollView.contentLayoutGuide.trailingAnchor],
        [_contentView.topAnchor constraintEqualToAnchor:_scrollView.contentLayoutGuide.topAnchor],
        [_contentView.bottomAnchor constraintEqualToAnchor:_scrollView.contentLayoutGuide.bottomAnchor],
        [_contentView.widthAnchor constraintEqualToAnchor:_scrollView.frameLayoutGuide.widthAnchor],

        [tipCardView.leadingAnchor constraintEqualToAnchor:_contentView.leadingAnchor constant:EAPMDemoUIHorizontalInset],
        [tipCardView.trailingAnchor constraintEqualToAnchor:_contentView.trailingAnchor constant:-EAPMDemoUIHorizontalInset],
        [tipCardView.topAnchor constraintEqualToAnchor:_contentView.topAnchor constant:EAPMDemoUIContentTopSpacing],

        [descLabel.leadingAnchor constraintEqualToAnchor:tipCardView.leadingAnchor constant:EAPMDemoUIHorizontalInset],
        [descLabel.trailingAnchor constraintEqualToAnchor:tipCardView.trailingAnchor constant:-EAPMDemoUIHorizontalInset],
        [descLabel.topAnchor constraintEqualToAnchor:tipCardView.topAnchor constant:EAPMDemoUITipCardVerticalInset],
        [descLabel.bottomAnchor constraintEqualToAnchor:tipCardView.bottomAnchor constant:-EAPMDemoUITipCardVerticalInset],

        [sectionIndicator.leadingAnchor constraintEqualToAnchor:_contentView.leadingAnchor constant:EAPMDemoUIHorizontalInset],
        [sectionIndicator.topAnchor constraintEqualToAnchor:tipCardView.bottomAnchor constant:EAPMDemoUISectionTopSpacing],
        [sectionIndicator.widthAnchor constraintEqualToConstant:4.0],
        [sectionIndicator.heightAnchor constraintEqualToConstant:20.0],

        [sectionTitleLabel.leadingAnchor constraintEqualToAnchor:sectionIndicator.trailingAnchor constant:12.0],
        [sectionTitleLabel.centerYAnchor constraintEqualToAnchor:sectionIndicator.centerYAnchor],

        [gridStackView.leadingAnchor constraintEqualToAnchor:_contentView.leadingAnchor constant:EAPMDemoUIHorizontalInset],
        [gridStackView.trailingAnchor constraintEqualToAnchor:_contentView.trailingAnchor constant:-EAPMDemoUIHorizontalInset],
        [gridStackView.topAnchor constraintEqualToAnchor:sectionIndicator.bottomAnchor constant:EAPMDemoUISectionContentSpacing],
        [gridStackView.bottomAnchor constraintEqualToAnchor:_contentView.bottomAnchor constant:-EAPMDemoUIContentBottomPadding],
    ]];
}

- (UIButton *)createCrashButtonWithTitle:(NSString *)title type:(EAPMDemoCrashTriggerType)type {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.tag = type;
    EAPMDemoApplySecondaryCardStyle(button,
                                    EAPMDemoCrashHexColor(0xF0F2F5, 1.0),
                                    EAPMDemoCrashHexColor(0xE6E8EB, 1.0));
    button.titleLabel.numberOfLines = 2;
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    [button setAttributedTitle:[self crashButtonTitle:title] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(handleTriggerButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (NSAttributedString *)crashButtonTitle:(NSString *)title {
    return EAPMDemoCenteredActionAttributedString(title, EAPMDemoCrashHexColor(0x1F2024, 1.0));
}

- (void)handleBackButtonTapped {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)handleTriggerButtonTapped:(UIButton *)sender {
    switch ((EAPMDemoCrashTriggerType)sender.tag) {
        case EAPMDemoCrashTriggerTypeNSException: {
            [self presentCrashConfirmAlertWithTitle:@"NSException" confirmAction:^{
                @throw [NSException exceptionWithName:@"DemoNSException"
                                               reason:@"Trigger NSException in demo page."
                                             userInfo:nil];
            }];
            break;
        }
        case EAPMDemoCrashTriggerTypeCpp: {
            [self presentCrashConfirmAlertWithTitle:@"C++ 异常" confirmAction:^{
                throw std::runtime_error("Trigger C++ crash in demo page.");
            }];
            break;
        }
        case EAPMDemoCrashTriggerTypeMach: {
            [self presentCrashConfirmAlertWithTitle:@"Mach 异常" confirmAction:^{
                __builtin_trap();
            }];
            break;
        }
        case EAPMDemoCrashTriggerTypeSignal: {
            [self presentCrashConfirmAlertWithTitle:@"SIGNAL 崩溃" confirmAction:^{
                raise(SIGSEGV);
            }];
            break;
        }
        case EAPMDemoCrashTriggerTypeHang: {
            [self presentCrashConfirmAlertWithTitle:@"卡死" confirmAction:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [NSThread sleepForTimeInterval:60.0];
                });
            }];
            break;
        }
        case EAPMDemoCrashTriggerTypeOOM: {
            [[self class] presentOOMAlertFromViewController:self];
            break;
        }
        case EAPMDemoCrashTriggerTypeAsyncException: {
            [self presentCrashConfirmAlertWithTitle:@"AsyncException" confirmAction:^{
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    @throw [NSException exceptionWithName:@"DemoAsyncException"
                                                   reason:@"Trigger async exception in demo page."
                                                 userInfo:nil];
                });
            }];
            break;
        }
        case EAPMDemoCrashTriggerTypeDeadlock: {
            [self presentCrashConfirmAlertWithTitle:@"Deadlock" confirmAction:^{
                dispatch_queue_t serialQueue = dispatch_queue_create("com.aliyun.emas.demo.deadlock", DISPATCH_QUEUE_SERIAL);
                dispatch_async(serialQueue, ^{
                    NSLog(@"Task 1");
                    dispatch_barrier_sync(serialQueue, ^{
                        NSLog(@"Barrier Task");
                    });
                    NSLog(@"This will never be printed because of the deadlock");
                });
                NSLog(@"Code after dispatch_async");
            }];
            break;
        }
    }
}

+ (void)presentOOMAlertFromViewController:(UIViewController *)viewController {
    if (!viewController || viewController.presentedViewController) {
        return;
    }

    [EAPMDemoAlertPresenter presentAlertFrom:viewController
                                       title:@"OOM"
                                     message:@"即将触发「OOM」，App将闪退，重启App之后可在 EMAS 控制台看到崩溃信息。"
                                     actions:@[
        [EAPMDemoAlertAction actionWithTitle:@"取消"
                                       style:EAPMDemoAlertActionStyleSecondary
                                         handler:nil],
        [EAPMDemoAlertAction actionWithTitle:@"确定"
                                       style:EAPMDemoAlertActionStylePrimary
                                         handler:^{
            [self triggerOOM];
        }],
    ]];
}

+ (void)triggerOOM {
    NSMutableArray<NSValue *> *oomPointers = EAPMDemoOOMPointers();
    [oomPointers removeAllObjects];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        const size_t chunkSize =
#if TARGET_OS_SIMULATOR
            64 * 1024 * 1024;
#else
            16 * 1024 * 1024;
#endif

        while (YES) {
            @autoreleasepool {
                void *chunk = malloc(chunkSize);
                if (!chunk) {
                    abort();
                }

                // Touch the full block so the allocator commits real resident memory.
                memset(chunk, 0xA5, chunkSize);
                [oomPointers addObject:[NSValue valueWithPointer:chunk]];
                usleep(20000);
            }
        }
    });
}

- (void)presentCrashConfirmAlertWithTitle:(NSString *)title confirmAction:(dispatch_block_t)confirmAction {
    NSString *message = [NSString stringWithFormat:@"即将触发「%@」，App将闪退，稍后可在 EMAS 控制台看到崩溃信息。", title];
    [self presentHomeStyleAlertWithTitle:title message:message confirmAction:confirmAction];
}

- (void)presentHomeStyleAlertWithTitle:(NSString *)title
                               message:(NSString *)message
                         confirmAction:(dispatch_block_t)confirmAction {
    if (self.presentedViewController) {
        return;
    }

    [EAPMDemoAlertPresenter presentAlertFrom:self
                                       title:title
                                     message:message
                                     actions:@[
        [EAPMDemoAlertAction actionWithTitle:@"取消"
                                       style:EAPMDemoAlertActionStyleSecondary
                                         handler:nil],
        [EAPMDemoAlertAction actionWithTitle:@"确定"
                                       style:EAPMDemoAlertActionStylePrimary
                                         handler:confirmAction],
    ]];
}

@end
