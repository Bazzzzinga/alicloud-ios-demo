#import "EAPMDemoNetworkAnalysisViewController.h"

#import "EAPMDemoHomeUI.h"

static NSString * const EAPMDemoNetworkAnalysisDefaultURLString = @"https://www.aliyun.com";
static NSString * const EAPMDemoNetworkAnalysisTransportErrorURLString = @"https://demo-network-error.invalid/";
static NSString * const EAPMDemoNetworkAnalysisHTTPErrorURLString = @"https://postman-echo.com/status/500";

static UIColor *EAPMDemoNetworkAnalysisHexColor(NSUInteger hexValue, CGFloat alpha) {
    return [UIColor colorWithRed:((hexValue >> 16) & 0xFF) / 255.0
                           green:((hexValue >> 8) & 0xFF) / 255.0
                            blue:(hexValue & 0xFF) / 255.0
                           alpha:alpha];
}

@interface EAPMDemoNetworkAnalysisViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UITextField *urlTextField;
@property (nonatomic, strong) UIButton *sendButton;
@property (nonatomic, strong) UIButton *transportErrorButton;
@property (nonatomic, strong) UIButton *httpErrorButton;
@property (nonatomic, strong) CAGradientLayer *sendButtonGradientLayer;
@property (nonatomic, assign) BOOL requestInProgress;

@end

@implementation EAPMDemoNetworkAnalysisViewController

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

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.sendButtonGradientLayer.frame = self.sendButton.bounds;
    self.sendButtonGradientLayer.cornerRadius = self.sendButton.layer.cornerRadius;
}

- (void)buildViews {
    self.headerView = [[UIView alloc] init];
    self.headerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.headerView];

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
    backButton.tintColor = EAPMDemoNetworkAnalysisHexColor(0x1F2024, 1.0);
    [backButton addTarget:self action:@selector(handleBackButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.headerView addSubview:backButton];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    titleLabel.numberOfLines = 1;
    UIFont *titleFont = [UIFont fontWithName:@"PingFangSC-Medium" size:22.0] ?: [UIFont systemFontOfSize:22.0 weight:UIFontWeightMedium];
    titleLabel.attributedText = [[NSAttributedString alloc] initWithString:@"网络分析" attributes:@{
        NSFontAttributeName: titleFont,
        NSForegroundColorAttributeName: EAPMDemoNetworkAnalysisHexColor(0x4B4D52, 1.0),
        NSKernAttributeName: @(0.8),
    }];
    [self.headerView addSubview:titleLabel];

    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.view addSubview:self.scrollView];

    self.contentView = [[UIView alloc] init];
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.scrollView addSubview:self.contentView];

    UIView *tipCardView = [[UIView alloc] init];
    tipCardView.translatesAutoresizingMaskIntoConstraints = NO;
    tipCardView.backgroundColor = EAPMDemoNetworkAnalysisHexColor(0xEEF3FF, 1.0);
    tipCardView.layer.cornerRadius = 8.0;
    tipCardView.layer.masksToBounds = YES;
    [self.contentView addSubview:tipCardView];

    UILabel *tipLabel = [[UILabel alloc] init];
    tipLabel.translatesAutoresizingMaskIntoConstraints = NO;
    tipLabel.numberOfLines = 0;
    tipLabel.text = @"请触发不同类型的网络请求。网络分析数据在App退至后台时统一上报，稍后可在 EMAS 控制台查看。";
    tipLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15.0] ?: [UIFont systemFontOfSize:15.0 weight:UIFontWeightRegular];
    NSMutableParagraphStyle *tipParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    tipParagraphStyle.alignment = NSTextAlignmentLeft;
    tipParagraphStyle.minimumLineHeight = 20.0;
    tipParagraphStyle.maximumLineHeight = 20.0;
    tipLabel.attributedText = [[NSAttributedString alloc] initWithString:tipLabel.text attributes:@{
        NSFontAttributeName: tipLabel.font,
        NSForegroundColorAttributeName: EAPMDemoNetworkAnalysisHexColor(0x7A8FB8, 1.0),
        NSParagraphStyleAttributeName: tipParagraphStyle,
        NSKernAttributeName: @(0.2),
    }];
    [tipCardView addSubview:tipLabel];

    UIView *requestSectionIndicator = [self createSectionIndicatorView];
    [self.contentView addSubview:requestSectionIndicator];

    UILabel *requestSectionLabel = [self createSectionTitleLabel:@"网络请求"];
    [self.contentView addSubview:requestSectionLabel];

    UILabel *urlLabel = [[UILabel alloc] init];
    urlLabel.translatesAutoresizingMaskIntoConstraints = NO;
    UIFont *fieldTitleFont = [UIFont fontWithName:@"PingFangSC-Regular" size:18.0] ?: [UIFont systemFontOfSize:18.0 weight:UIFontWeightRegular];
    NSMutableParagraphStyle *fieldTitleParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    fieldTitleParagraphStyle.minimumLineHeight = 24.0;
    fieldTitleParagraphStyle.maximumLineHeight = 24.0;
    urlLabel.attributedText = [[NSAttributedString alloc] initWithString:@"URL" attributes:@{
        NSFontAttributeName: fieldTitleFont,
        NSForegroundColorAttributeName: EAPMDemoNetworkAnalysisHexColor(0x9A9EA8, 1.0),
        NSKernAttributeName: @(0.2),
        NSParagraphStyleAttributeName: fieldTitleParagraphStyle,
    }];
    [self.contentView addSubview:urlLabel];

    UIView *urlInputContainerView = [[UIView alloc] init];
    urlInputContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    urlInputContainerView.backgroundColor = EAPMDemoNetworkAnalysisHexColor(0xF0F2F5, 1.0);
    urlInputContainerView.layer.cornerRadius = 8.0;
    [self.contentView addSubview:urlInputContainerView];

    self.urlTextField = [[UITextField alloc] init];
    self.urlTextField.translatesAutoresizingMaskIntoConstraints = NO;
    UIFont *textFont = [UIFont fontWithName:@"PingFangSC-Regular" size:15.0] ?: [UIFont systemFontOfSize:15.0 weight:UIFontWeightRegular];
    self.urlTextField.font = textFont;
    self.urlTextField.textColor = EAPMDemoNetworkAnalysisHexColor(0x4B4D52, 1.0);
    self.urlTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入完整URL，默认https://www.aliyun.com" attributes:@{
        NSFontAttributeName: textFont,
        NSForegroundColorAttributeName: EAPMDemoNetworkAnalysisHexColor(0xC8D0DD, 1.0),
    }];
    self.urlTextField.keyboardType = UIKeyboardTypeURL;
    self.urlTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.urlTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.urlTextField.returnKeyType = UIReturnKeyGo;
    self.urlTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.urlTextField.delegate = self;
    [urlInputContainerView addSubview:self.urlTextField];

    self.sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.sendButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.sendButton setTitle:@"发送请求" forState:UIControlStateNormal];
    [self.sendButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    self.sendButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:18.0] ?: [UIFont systemFontOfSize:18.0 weight:UIFontWeightSemibold];
    self.sendButton.layer.cornerRadius = 8.0;
    self.sendButton.layer.masksToBounds = YES;
    [self.sendButton addTarget:self action:@selector(handleSendButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    self.sendButtonGradientLayer = [CAGradientLayer layer];
    self.sendButtonGradientLayer.colors = @[
        (__bridge id)EAPMDemoNetworkAnalysisHexColor(0x6E84FF, 1.0).CGColor,
        (__bridge id)EAPMDemoNetworkAnalysisHexColor(0x7277FF, 1.0).CGColor,
    ];
    self.sendButtonGradientLayer.locations = @[@0, @1];
    self.sendButtonGradientLayer.startPoint = CGPointMake(0.0, 0.5);
    self.sendButtonGradientLayer.endPoint = CGPointMake(1.0, 0.5);
    [self.sendButton.layer insertSublayer:self.sendButtonGradientLayer atIndex:0];
    [self.contentView addSubview:self.sendButton];

    UIView *errorSectionIndicator = [self createSectionIndicatorView];
    [self.contentView addSubview:errorSectionIndicator];

    UILabel *errorSectionLabel = [self createSectionTitleLabel:@"网络错误"];
    [self.contentView addSubview:errorSectionLabel];

    UIStackView *errorButtonStackView = [[UIStackView alloc] init];
    errorButtonStackView.translatesAutoresizingMaskIntoConstraints = NO;
    errorButtonStackView.axis = UILayoutConstraintAxisHorizontal;
    errorButtonStackView.alignment = UIStackViewAlignmentFill;
    errorButtonStackView.distribution = UIStackViewDistributionFillEqually;
    errorButtonStackView.spacing = 6.0;
    [self.contentView addSubview:errorButtonStackView];

    self.transportErrorButton = [self createErrorButtonWithTitle:@"网络错误" action:@selector(handleTransportErrorButtonTapped)];
    self.httpErrorButton = [self createErrorButtonWithTitle:@"HTTP错误" action:@selector(handleHTTPErrorButtonTapped)];
    [errorButtonStackView addArrangedSubview:self.transportErrorButton];
    [errorButtonStackView addArrangedSubview:self.httpErrorButton];

    UILayoutGuide *safeArea = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [self.headerView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.headerView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.headerView.topAnchor constraintEqualToAnchor:safeArea.topAnchor],

        [backButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:16.0],
        [backButton.topAnchor constraintEqualToAnchor:self.headerView.topAnchor constant:10.0],
        [backButton.widthAnchor constraintEqualToConstant:20.0],
        [backButton.heightAnchor constraintEqualToConstant:20.0],

        [titleLabel.leadingAnchor constraintEqualToAnchor:backButton.trailingAnchor constant:6.0],
        [titleLabel.centerYAnchor constraintEqualToAnchor:backButton.centerYAnchor constant:-1.0],

        [self.headerView.bottomAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:18.0],

        [self.scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.scrollView.topAnchor constraintEqualToAnchor:self.headerView.bottomAnchor],
        [self.scrollView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],

        [self.contentView.leadingAnchor constraintEqualToAnchor:self.scrollView.contentLayoutGuide.leadingAnchor],
        [self.contentView.trailingAnchor constraintEqualToAnchor:self.scrollView.contentLayoutGuide.trailingAnchor],
        [self.contentView.topAnchor constraintEqualToAnchor:self.scrollView.contentLayoutGuide.topAnchor],
        [self.contentView.bottomAnchor constraintEqualToAnchor:self.scrollView.contentLayoutGuide.bottomAnchor],
        [self.contentView.widthAnchor constraintEqualToAnchor:self.scrollView.frameLayoutGuide.widthAnchor],

        [tipCardView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:16.0],
        [tipCardView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-16.0],
        [tipCardView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:0.0],

        [tipLabel.leadingAnchor constraintEqualToAnchor:tipCardView.leadingAnchor constant:16.0],
        [tipLabel.trailingAnchor constraintEqualToAnchor:tipCardView.trailingAnchor constant:-16.0],
        [tipLabel.topAnchor constraintEqualToAnchor:tipCardView.topAnchor constant:12.0],
        [tipLabel.bottomAnchor constraintEqualToAnchor:tipCardView.bottomAnchor constant:-12.0],

        [requestSectionIndicator.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:16.0],
        [requestSectionIndicator.topAnchor constraintEqualToAnchor:tipCardView.bottomAnchor constant:20.0],
        [requestSectionIndicator.widthAnchor constraintEqualToConstant:4.0],
        [requestSectionIndicator.heightAnchor constraintEqualToConstant:20.0],

        [requestSectionLabel.leadingAnchor constraintEqualToAnchor:requestSectionIndicator.trailingAnchor constant:12.0],
        [requestSectionLabel.centerYAnchor constraintEqualToAnchor:requestSectionIndicator.centerYAnchor],

        [urlLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:16.0],
        [urlLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-16.0],
        [urlLabel.topAnchor constraintEqualToAnchor:requestSectionIndicator.bottomAnchor constant:14.0],

        [urlInputContainerView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:16.0],
        [urlInputContainerView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-16.0],
        [urlInputContainerView.topAnchor constraintEqualToAnchor:urlLabel.bottomAnchor constant:6.0],
        [urlInputContainerView.heightAnchor constraintEqualToConstant:52.0],

        [self.urlTextField.leadingAnchor constraintEqualToAnchor:urlInputContainerView.leadingAnchor constant:16.0],
        [self.urlTextField.trailingAnchor constraintEqualToAnchor:urlInputContainerView.trailingAnchor constant:-16.0],
        [self.urlTextField.topAnchor constraintEqualToAnchor:urlInputContainerView.topAnchor],
        [self.urlTextField.bottomAnchor constraintEqualToAnchor:urlInputContainerView.bottomAnchor],

        [self.sendButton.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:16.0],
        [self.sendButton.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-16.0],
        [self.sendButton.topAnchor constraintEqualToAnchor:urlInputContainerView.bottomAnchor constant:20.0],
        [self.sendButton.heightAnchor constraintEqualToConstant:58.0],

        [errorSectionIndicator.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:16.0],
        [errorSectionIndicator.topAnchor constraintEqualToAnchor:self.sendButton.bottomAnchor constant:24.0],
        [errorSectionIndicator.widthAnchor constraintEqualToConstant:4.0],
        [errorSectionIndicator.heightAnchor constraintEqualToConstant:20.0],

        [errorSectionLabel.leadingAnchor constraintEqualToAnchor:errorSectionIndicator.trailingAnchor constant:12.0],
        [errorSectionLabel.centerYAnchor constraintEqualToAnchor:errorSectionIndicator.centerYAnchor],

        [errorButtonStackView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:16.0],
        [errorButtonStackView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-16.0],
        [errorButtonStackView.topAnchor constraintEqualToAnchor:errorSectionIndicator.bottomAnchor constant:14.0],
        [errorButtonStackView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-32.0],
        [errorButtonStackView.heightAnchor constraintEqualToConstant:56.0],
    ]];
}

- (UIView *)createSectionIndicatorView {
    UIView *sectionIndicator = [[UIView alloc] init];
    sectionIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    sectionIndicator.backgroundColor = EAPMDemoNetworkAnalysisHexColor(0x315CFC, 1.0);
    sectionIndicator.layer.cornerRadius = 3.0;
    return sectionIndicator;
}

- (UILabel *)createSectionTitleLabel:(NSString *)title {
    UILabel *label = [[UILabel alloc] init];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.text = title;
    label.textColor = EAPMDemoNetworkAnalysisHexColor(0x4B4D52, 1.0);
    label.font = [UIFont systemFontOfSize:18.0 weight:UIFontWeightMedium];
    return label;
}

- (UIButton *)createErrorButtonWithTitle:(NSString *)title action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.backgroundColor = EAPMDemoNetworkAnalysisHexColor(0xF0F2F5, 1.0);
    button.layer.cornerRadius = 8.0;
    button.layer.borderWidth = 2.0;
    button.layer.borderColor = EAPMDemoNetworkAnalysisHexColor(0xE6E8EB, 1.0).CGColor;
    button.titleLabel.numberOfLines = 1;
    [button setAttributedTitle:[self errorButtonTitle:title] forState:UIControlStateNormal];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (NSAttributedString *)errorButtonTitle:(NSString *)title {
    UIFont *font = [UIFont fontWithName:@"PingFangSC-Regular" size:18.0] ?: [UIFont systemFontOfSize:18.0 weight:UIFontWeightRegular];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    paragraphStyle.minimumLineHeight = 28.0;
    paragraphStyle.maximumLineHeight = 28.0;
    return [[NSAttributedString alloc] initWithString:title attributes:@{
        NSFontAttributeName: font,
        NSForegroundColorAttributeName: EAPMDemoNetworkAnalysisHexColor(0x1F2024, 1.0),
        NSParagraphStyleAttributeName: paragraphStyle,
    }];
}

- (void)handleBackButtonTapped {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)handleSendButtonTapped {
    [self.view endEditing:YES];
    NSString *normalizedURLString = [self normalizedURLString:self.urlTextField.text];
    if (normalizedURLString.length == 0) {
        normalizedURLString = EAPMDemoNetworkAnalysisDefaultURLString;
    }
    [self triggerRequestWithURLString:normalizedURLString];
}

- (void)handleTransportErrorButtonTapped {
    [self.view endEditing:YES];
    [self triggerRequestWithURLString:EAPMDemoNetworkAnalysisTransportErrorURLString];
}

- (void)handleHTTPErrorButtonTapped {
    [self.view endEditing:YES];
    [self triggerRequestWithURLString:EAPMDemoNetworkAnalysisHTTPErrorURLString];
}

- (nullable NSString *)normalizedURLString:(nullable NSString *)urlString {
    NSString *trimmedURLString = [urlString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return trimmedURLString.length > 0 ? trimmedURLString : nil;
}

- (nullable NSURL *)validatedURLFromString:(NSString *)urlString {
    NSURLComponents *components = [NSURLComponents componentsWithString:urlString];
    if (components.URL == nil || components.scheme.length == 0 || components.host.length == 0) {
        return nil;
    }
    return components.URL;
}

- (void)triggerRequestWithURLString:(NSString *)urlString {
    if (self.requestInProgress) {
        return;
    }

    NSURL *url = [self validatedURLFromString:urlString];
    if (url == nil) {
        [self presentAlertWithTitle:@"提示" message:@"请输入有效的完整 URL"];
        return;
    }

    self.requestInProgress = YES;
    [self updateInteractiveViewsEnabled:NO];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"GET";
    request.timeoutInterval = 15.0;

    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    configuration.timeoutIntervalForRequest = 15.0;
    configuration.timeoutIntervalForResource = 20.0;

    __weak typeof(self) weakSelf = self;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            [session finishTasksAndInvalidate];
            return;
        }

        NSHTTPURLResponse *httpResponse = [response isKindOfClass:[NSHTTPURLResponse class]] ? (NSHTTPURLResponse *)response : nil;
        BOOL requestSucceeded = (error == nil && httpResponse.statusCode == 200);
        NSString *statusCodeText = httpResponse ? [NSString stringWithFormat:@"%ld", (long)httpResponse.statusCode] : @"";
        NSAttributedString *message = [strongSelf resultMessageWithURLString:url.absoluteString
                                                            requestSucceeded:requestSucceeded
                                                              statusCodeText:statusCodeText];

        dispatch_async(dispatch_get_main_queue(), ^{
            strongSelf.requestInProgress = NO;
            [strongSelf updateInteractiveViewsEnabled:YES];
            [strongSelf presentResultAlertWithMessage:message];
        });

        [session finishTasksAndInvalidate];
    }];
    [task resume];
}

- (void)updateInteractiveViewsEnabled:(BOOL)enabled {
    self.urlTextField.enabled = enabled;
    self.sendButton.enabled = enabled;
    self.transportErrorButton.enabled = enabled;
    self.httpErrorButton.enabled = enabled;

    CGFloat alpha = enabled ? 1.0 : 0.55;
    self.sendButton.alpha = alpha;
    self.transportErrorButton.alpha = alpha;
    self.httpErrorButton.alpha = alpha;
}

- (void)presentAlertWithTitle:(NSString *)title message:(NSString *)message {
    [EAPMDemoHomeAlertPresenter presentAlertFrom:self
                                           title:title
                                         message:message
                                messageAlignment:EAPMDemoHomeAlertMessageAlignmentLeft
                                         actions:@[
        [EAPMDemoHomeAlertAction actionWithTitle:@"知道了"
                                           style:EAPMDemoHomeAlertActionStylePrimary
                                         handler:nil],
    ]];
}

- (NSAttributedString *)resultMessageWithURLString:(NSString *)urlString
                                  requestSucceeded:(BOOL)requestSucceeded
                                    statusCodeText:(NSString *)statusCodeText {
    UIFont *bodyFont = [UIFont fontWithName:@"PingFangSC-Regular" size:15.0] ?: [UIFont systemFontOfSize:15.0 weight:UIFontWeightRegular];
    UIFont *symbolFont = [UIFont systemFontOfSize:16.0 weight:UIFontWeightSemibold];
    UIColor *labelColor = EAPMDemoNetworkAnalysisHexColor(0x5B6472, 1.0);
    UIColor *successColor = EAPMDemoNetworkAnalysisHexColor(0x24B36B, 1.0);
    UIColor *failureColor = EAPMDemoNetworkAnalysisHexColor(0xF04438, 1.0);
    NSString *statusSymbol = requestSucceeded ? @"✓" : @"✕";
    NSString *statusText = requestSucceeded ? @"Success" : @"Failure";
    UIColor *statusColor = requestSucceeded ? successColor : failureColor;

    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentLeft;
    paragraphStyle.minimumLineHeight = 24.0;
    paragraphStyle.maximumLineHeight = 24.0;

    NSDictionary<NSAttributedStringKey, id> *bodyAttributes = @{
        NSFontAttributeName: bodyFont,
        NSForegroundColorAttributeName: labelColor,
        NSParagraphStyleAttributeName: paragraphStyle,
    };
    NSDictionary<NSAttributedStringKey, id> *symbolAttributes = @{
        NSFontAttributeName: symbolFont,
        NSForegroundColorAttributeName: statusColor,
        NSParagraphStyleAttributeName: paragraphStyle,
    };
    NSDictionary<NSAttributedStringKey, id> *statusAttributes = @{
        NSFontAttributeName: bodyFont,
        NSForegroundColorAttributeName: statusColor,
        NSParagraphStyleAttributeName: paragraphStyle,
    };

    NSMutableAttributedString *message = [[NSMutableAttributedString alloc] init];
    [message appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"URL: %@\n", urlString] attributes:bodyAttributes]];
    [message appendAttributedString:[[NSAttributedString alloc] initWithString:@"Result: " attributes:bodyAttributes]];
    [message appendAttributedString:[[NSAttributedString alloc] initWithString:statusSymbol attributes:symbolAttributes]];
    [message appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@\n", statusText] attributes:statusAttributes]];
    [message appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Status Code: %@\n\n", statusCodeText] attributes:bodyAttributes]];
    [message appendAttributedString:[[NSAttributedString alloc] initWithString:@"请切换至后台触发上报，稍后可在 EMAS 控制台查看。" attributes:bodyAttributes]];
    return message;
}

- (void)presentResultAlertWithMessage:(NSAttributedString *)message {
    [EAPMDemoHomeAlertPresenter presentAlertFrom:self
                                           title:@"网络请求"
                               attributedMessage:message
                                         actions:@[
        [EAPMDemoHomeAlertAction actionWithTitle:@"知道了"
                                           style:EAPMDemoHomeAlertActionStylePrimary
                                         handler:nil],
    ]];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.urlTextField) {
        [self handleSendButtonTapped];
        return NO;
    }
    return YES;
}

@end
