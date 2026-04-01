#import "EAPMDemoCrashViewController.h"

#import <signal.h>
#import <stdlib.h>
#import <stdexcept>
#import <unistd.h>

static UIColor *EAPMDemoCrashHexColor(NSUInteger hexValue, CGFloat alpha) {
    return [UIColor colorWithRed:((hexValue >> 16) & 0xFF) / 255.0
                           green:((hexValue >> 8) & 0xFF) / 255.0
                            blue:(hexValue & 0xFF) / 255.0
                           alpha:alpha];
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
@property (nonatomic, strong) NSMutableArray<NSMutableData *> *oomBuffers;

@end

@implementation EAPMDemoCrashViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"";
    self.navigationItem.hidesBackButton = YES;
    self.view.backgroundColor = EAPMDemoCrashHexColor(0xF3F4F8, 1.0);
    self.oomBuffers = [NSMutableArray array];

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
        UIImageSymbolConfiguration *configuration = [UIImageSymbolConfiguration configurationWithPointSize:14.0 weight:UIImageSymbolWeightMedium];
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
    UIFont *titleFont = [UIFont fontWithName:@"PingFangSC-Medium" size:22.0] ?: [UIFont systemFontOfSize:22.0 weight:UIFontWeightMedium];
    titleLabel.attributedText = [[NSAttributedString alloc] initWithString:@"其它类型错误" attributes:@{
        NSFontAttributeName: titleFont,
        NSForegroundColorAttributeName: EAPMDemoCrashHexColor(0x4B4D52, 1.0),
        NSKernAttributeName: @(1.6),
    }];
    [_headerView addSubview:titleLabel];

    UIView *separatorView = [[UIView alloc] init];
    separatorView.translatesAutoresizingMaskIntoConstraints = NO;
    separatorView.backgroundColor = EAPMDemoCrashHexColor(0xE6E8EB, 1.0);
    [_headerView addSubview:separatorView];

    _scrollView = [[UIScrollView alloc] init];
    _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    _scrollView.alwaysBounceVertical = YES;
    [self.view addSubview:_scrollView];

    _contentView = [[UIView alloc] init];
    _contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [_scrollView addSubview:_contentView];

    UILabel *descLabel = [[UILabel alloc] init];
    descLabel.translatesAutoresizingMaskIntoConstraints = NO;
    descLabel.numberOfLines = 0;
    descLabel.text = @"更多崩溃和错误类型，点击按钮触发对应类型的异常。触发后请前往 EMAS 控制台查看崩溃详情和堆栈信息。";
    descLabel.font = [UIFont systemFontOfSize:14.0 weight:UIFontWeightRegular];
    descLabel.textColor = EAPMDemoCrashHexColor(0x6B7380, 1.0);
    [_contentView addSubview:descLabel];

    NSArray<NSDictionary<NSString *, id> *> *items = @[
        @{@"title": @"NSException", @"type": @(EAPMDemoCrashTriggerTypeNSException)},
        @{@"title": @"C++ 异常", @"type": @(EAPMDemoCrashTriggerTypeCpp)},
        @{@"title": @"Mach 异常", @"type": @(EAPMDemoCrashTriggerTypeMach)},
        @{@"title": @"SIGNAL 崩溃", @"type": @(EAPMDemoCrashTriggerTypeSignal)},
        @{@"title": @"卡死", @"type": @(EAPMDemoCrashTriggerTypeHang)},
        @{@"title": @"Out-Of-Memory", @"type": @(EAPMDemoCrashTriggerTypeOOM)},
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
        [rowStackView.heightAnchor constraintEqualToConstant:48.0].active = YES;
    }

    [NSLayoutConstraint activateConstraints:@[
        [_headerView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [_headerView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [_headerView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],

        [backButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:14.0],
        [backButton.topAnchor constraintEqualToAnchor:_headerView.topAnchor constant:8.0],
        [backButton.widthAnchor constraintEqualToConstant:22.0],
        [backButton.heightAnchor constraintEqualToConstant:22.0],

        [titleLabel.leadingAnchor constraintEqualToAnchor:backButton.trailingAnchor constant:10.0],
        [titleLabel.centerYAnchor constraintEqualToAnchor:backButton.centerYAnchor constant:-1.0],

        [separatorView.leadingAnchor constraintEqualToAnchor:_headerView.leadingAnchor],
        [separatorView.trailingAnchor constraintEqualToAnchor:_headerView.trailingAnchor],
        [separatorView.bottomAnchor constraintEqualToAnchor:_headerView.bottomAnchor],
        [separatorView.heightAnchor constraintEqualToConstant:0.5],

        [_headerView.bottomAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:10.0],

        [_scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [_scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [_scrollView.topAnchor constraintEqualToAnchor:_headerView.bottomAnchor constant:8.0],
        [_scrollView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],

        [_contentView.leadingAnchor constraintEqualToAnchor:_scrollView.contentLayoutGuide.leadingAnchor],
        [_contentView.trailingAnchor constraintEqualToAnchor:_scrollView.contentLayoutGuide.trailingAnchor],
        [_contentView.topAnchor constraintEqualToAnchor:_scrollView.contentLayoutGuide.topAnchor],
        [_contentView.bottomAnchor constraintEqualToAnchor:_scrollView.contentLayoutGuide.bottomAnchor],
        [_contentView.widthAnchor constraintEqualToAnchor:_scrollView.frameLayoutGuide.widthAnchor],

        [descLabel.leadingAnchor constraintEqualToAnchor:_contentView.leadingAnchor constant:16.0],
        [descLabel.trailingAnchor constraintEqualToAnchor:_contentView.trailingAnchor constant:-16.0],
        [descLabel.topAnchor constraintEqualToAnchor:_contentView.topAnchor constant:34.0],

        [gridStackView.leadingAnchor constraintEqualToAnchor:_contentView.leadingAnchor constant:16.0],
        [gridStackView.trailingAnchor constraintEqualToAnchor:_contentView.trailingAnchor constant:-16.0],
        [gridStackView.topAnchor constraintEqualToAnchor:descLabel.bottomAnchor constant:34.0],
        [gridStackView.bottomAnchor constraintEqualToAnchor:_contentView.bottomAnchor constant:-26.0],
    ]];
}

- (UIButton *)createCrashButtonWithTitle:(NSString *)title type:(EAPMDemoCrashTriggerType)type {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.tag = type;
    button.backgroundColor = UIColor.whiteColor;
    button.layer.cornerRadius = 6.0;
    button.layer.borderWidth = 2.0;
    button.layer.borderColor = EAPMDemoCrashHexColor(0xE6E8EB, 1.0).CGColor;
    button.titleLabel.numberOfLines = 2;
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    [button setAttributedTitle:[self crashButtonTitle:title] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(handleTriggerButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (NSAttributedString *)crashButtonTitle:(NSString *)title {
    UIFont *font = [UIFont fontWithName:@"PingFangSC-Regular" size:16.0] ?: [UIFont systemFontOfSize:16.0 weight:UIFontWeightRegular];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    paragraphStyle.minimumLineHeight = 24.0;
    paragraphStyle.maximumLineHeight = 24.0;
    return [[NSAttributedString alloc] initWithString:title attributes:@{
        NSFontAttributeName: font,
        NSForegroundColorAttributeName: EAPMDemoCrashHexColor(0x1F2024, 1.0),
        NSParagraphStyleAttributeName: paragraphStyle,
    }];
}

- (void)handleBackButtonTapped {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)handleTriggerButtonTapped:(UIButton *)sender {
    switch ((EAPMDemoCrashTriggerType)sender.tag) {
        case EAPMDemoCrashTriggerTypeNSException:
            [self presentCrashConfirmAlertWithTitle:@"NSException" confirmAction:^{
                @throw [NSException exceptionWithName:@"DemoNSException"
                                               reason:@"Trigger NSException in demo page."
                                             userInfo:nil];
            }];
            break;
        case EAPMDemoCrashTriggerTypeCpp:
            [self presentCrashConfirmAlertWithTitle:@"C++ 异常" confirmAction:^{
                throw std::runtime_error("Trigger C++ crash in demo page.");
            }];
            break;
        case EAPMDemoCrashTriggerTypeMach:
            [self presentCrashConfirmAlertWithTitle:@"Mach 异常" confirmAction:^{
                __builtin_trap();
            }];
            break;
        case EAPMDemoCrashTriggerTypeSignal:
            [self presentCrashConfirmAlertWithTitle:@"SIGNAL 崩溃" confirmAction:^{
                raise(SIGSEGV);
            }];
            break;
        case EAPMDemoCrashTriggerTypeHang:
            [self presentCrashConfirmAlertWithTitle:@"卡死" confirmAction:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [NSThread sleepForTimeInterval:30.0];
                });
            }];
            break;
        case EAPMDemoCrashTriggerTypeOOM: {
            [self presentCrashConfirmAlertWithTitle:@"Out-Of-Memory" confirmAction:^{
                [self triggerOOM];
            }];
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

- (void)triggerOOM {
    [self.oomBuffers removeAllObjects];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (YES) {
            @autoreleasepool {
                NSMutableData *chunk = [NSMutableData dataWithLength:10 * 1024 * 1024];
                [self.oomBuffers addObject:chunk];
                usleep(100000);
            }
        }
    });
}

- (void)presentCrashConfirmAlertWithTitle:(NSString *)title confirmAction:(dispatch_block_t)confirmAction {
    NSString *message = [NSString stringWithFormat:@"即将触发【%@】崩溃，App将闪退，稍后可在 EMAS 控制台看到崩溃信息。", title];
    [self presentConfirmAlertWithTitle:title message:message confirmAction:confirmAction];
}

- (void)presentConfirmAlertWithTitle:(NSString *)title
                             message:(NSString *)message
                       confirmAction:(dispatch_block_t)confirmAction {
    if (self.presentedViewController) {
        return;
    }

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(__unused UIAlertAction * _Nonnull action) {
        if (confirmAction) {
            confirmAction();
        }
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
