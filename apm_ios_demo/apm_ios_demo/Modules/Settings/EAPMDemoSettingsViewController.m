#import "EAPMDemoSettingsViewController.h"

#import "EAPMDemoConfigStore.h"
#import "../Shared/EAPMDemoUIStyleGuide.h"
#import <AlicloudApmCore/AlicloudApmCore.h>

static UIColor *EAPMDemoSettingsHexColor(NSUInteger hexValue, CGFloat alpha) {
    return [UIColor colorWithRed:((hexValue >> 16) & 0xFF) / 255.0
                           green:((hexValue >> 8) & 0xFF) / 255.0
                            blue:(hexValue & 0xFF) / 255.0
                           alpha:alpha];
}

@interface EAPMDemoSettingsInputView : UIView

@property (nonatomic, strong, readonly) UITextField *textField;

- (instancetype)initWithTitle:(NSString *)title placeholder:(NSString *)placeholder editable:(BOOL)editable;

@end

@interface EAPMDemoSettingsGradientButton : UIButton
@end

@interface EAPMDemoSettingsViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) EAPMDemoSettingsInputView *userIdInputView;
@property (nonatomic, strong) EAPMDemoSettingsInputView *userNickInputView;
@property (nonatomic, strong) EAPMDemoSettingsInputView *utdidInputView;
@property (nonatomic, strong) UIView *toastView;

@end

@implementation EAPMDemoSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"";
    self.navigationItem.hidesBackButton = YES;
    self.view.backgroundColor = UIColor.whiteColor;

    [self buildViews];
    [self reloadValues];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)buildViews {
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapBlank)];
    tapGesture.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGesture];

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
    backButton.tintColor = EAPMDemoSettingsHexColor(0x1F2024, 1.0);
    [backButton addTarget:self action:@selector(handleBackButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [_headerView addSubview:backButton];

    UILabel *pageTitleLabel = [[UILabel alloc] init];
    pageTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    pageTitleLabel.numberOfLines = 1;
    pageTitleLabel.attributedText = EAPMDemoPageTitleAttributedString(@"设置", EAPMDemoSettingsHexColor(0x4B4D52, 1.0));
    [_headerView addSubview:pageTitleLabel];

    _scrollView = [[UIScrollView alloc] init];
    _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    _scrollView.alwaysBounceVertical = YES;
    _scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.view addSubview:_scrollView];

    _contentView = [[UIView alloc] init];
    _contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [_scrollView addSubview:_contentView];

    _userIdInputView = [[EAPMDemoSettingsInputView alloc] initWithTitle:@"UserID" placeholder:@"请输入 UserID" editable:YES];
    _userNickInputView = [[EAPMDemoSettingsInputView alloc] initWithTitle:@"用户昵称" placeholder:@"请输入用户昵称" editable:YES];
    _utdidInputView = [[EAPMDemoSettingsInputView alloc] initWithTitle:@"UTDID" placeholder:@"" editable:NO];

    for (EAPMDemoSettingsInputView *inputView in @[_userIdInputView, _userNickInputView, _utdidInputView]) {
        inputView.translatesAutoresizingMaskIntoConstraints = NO;
        [_contentView addSubview:inputView];
    }

    _userIdInputView.textField.delegate = self;
    _userNickInputView.textField.delegate = self;
    _userNickInputView.textField.returnKeyType = UIReturnKeyDone;

    EAPMDemoSettingsGradientButton *saveButton = [EAPMDemoSettingsGradientButton buttonWithType:UIButtonTypeCustom];
    saveButton.translatesAutoresizingMaskIntoConstraints = NO;
    saveButton.layer.cornerRadius = EAPMDemoUICornerRadius;
    saveButton.clipsToBounds = YES;
    saveButton.titleLabel.font = EAPMDemoUIFontSemibold(18.0);
    [saveButton setTitle:@"保存设置" forState:UIControlStateNormal];
    [saveButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [saveButton addTarget:self action:@selector(handleSaveButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [_contentView addSubview:saveButton];

    UILayoutGuide *safeArea = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [_headerView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [_headerView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [_headerView.topAnchor constraintEqualToAnchor:safeArea.topAnchor],

        [backButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:EAPMDemoUIHorizontalInset],
        [backButton.topAnchor constraintEqualToAnchor:_headerView.topAnchor constant:EAPMDemoUIHeaderTopPadding],
        [backButton.widthAnchor constraintEqualToConstant:20.0],
        [backButton.heightAnchor constraintEqualToConstant:20.0],

        [pageTitleLabel.leadingAnchor constraintEqualToAnchor:backButton.trailingAnchor constant:EAPMDemoUIHeaderTitleSpacing],
        [pageTitleLabel.centerYAnchor constraintEqualToAnchor:backButton.centerYAnchor],

        [_headerView.bottomAnchor constraintEqualToAnchor:pageTitleLabel.bottomAnchor constant:EAPMDemoUIHeaderBottomPadding],

        [_scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [_scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [_scrollView.topAnchor constraintEqualToAnchor:_headerView.bottomAnchor constant:0.0],
        [_scrollView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],

        [_contentView.leadingAnchor constraintEqualToAnchor:_scrollView.contentLayoutGuide.leadingAnchor],
        [_contentView.trailingAnchor constraintEqualToAnchor:_scrollView.contentLayoutGuide.trailingAnchor],
        [_contentView.topAnchor constraintEqualToAnchor:_scrollView.contentLayoutGuide.topAnchor],
        [_contentView.bottomAnchor constraintEqualToAnchor:_scrollView.contentLayoutGuide.bottomAnchor],
        [_contentView.widthAnchor constraintEqualToAnchor:_scrollView.frameLayoutGuide.widthAnchor],

        [_userIdInputView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:EAPMDemoUIHorizontalInset],
        [_userIdInputView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-EAPMDemoUIHorizontalInset],
        [_userIdInputView.topAnchor constraintEqualToAnchor:_contentView.topAnchor constant:EAPMDemoUIContentTopSpacing],

        [_userNickInputView.leadingAnchor constraintEqualToAnchor:_userIdInputView.leadingAnchor],
        [_userNickInputView.trailingAnchor constraintEqualToAnchor:_userIdInputView.trailingAnchor],
        [_userNickInputView.topAnchor constraintEqualToAnchor:_userIdInputView.bottomAnchor constant:12.0],

        [_utdidInputView.leadingAnchor constraintEqualToAnchor:_userIdInputView.leadingAnchor],
        [_utdidInputView.trailingAnchor constraintEqualToAnchor:_userIdInputView.trailingAnchor],
        [_utdidInputView.topAnchor constraintEqualToAnchor:_userNickInputView.bottomAnchor constant:12.0],

        [saveButton.leadingAnchor constraintEqualToAnchor:_userIdInputView.leadingAnchor],
        [saveButton.trailingAnchor constraintEqualToAnchor:_userIdInputView.trailingAnchor],
        [saveButton.topAnchor constraintEqualToAnchor:_utdidInputView.bottomAnchor constant:20.0],
        [saveButton.heightAnchor constraintEqualToConstant:EAPMDemoUIPrimaryButtonHeight],
        [saveButton.bottomAnchor constraintEqualToAnchor:_contentView.bottomAnchor constant:-EAPMDemoUIContentBottomPadding],
    ]];
}

- (void)reloadValues {
    self.userIdInputView.textField.text = [EAPMDemoConfigStore storedUserId] ?: @"";
    self.userNickInputView.textField.text = [EAPMDemoConfigStore storedUserNick] ?: @"";

    NSString *utdid = [EAPMApm utdid];
    self.utdidInputView.textField.text = utdid.length > 0 ? utdid : @"获取失败";
}

- (void)handleTapBlank {
    [self.view endEditing:YES];
}

- (void)handleBackButtonTapped {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)handleSaveButtonTapped {
    [self.view endEditing:YES];
    [EAPMDemoConfigStore saveUserId:self.userIdInputView.textField.text userNick:self.userNickInputView.textField.text];
    [self showSavedToast];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.userIdInputView.textField) {
        [self.userNickInputView.textField becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }
    return YES;
}

- (void)showSavedToast {
    [self.toastView removeFromSuperview];

    UIView *toastView = [[UIView alloc] init];
    toastView.translatesAutoresizingMaskIntoConstraints = NO;
    toastView.backgroundColor = EAPMDemoSettingsHexColor(0x1E2A44, 0.96);
    toastView.layer.cornerRadius = 12.0;
    toastView.alpha = 0.0;

    UILabel *messageLabel = [[UILabel alloc] init];
    messageLabel.translatesAutoresizingMaskIntoConstraints = NO;
    messageLabel.text = @"设置已保存";
    messageLabel.textColor = UIColor.whiteColor;
    messageLabel.font = EAPMDemoUIFontMedium(15.0);
    messageLabel.textAlignment = NSTextAlignmentCenter;
    [toastView addSubview:messageLabel];

    [self.view addSubview:toastView];
    self.toastView = toastView;

    [NSLayoutConstraint activateConstraints:@[
        [toastView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [toastView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-28.0],
        [messageLabel.leadingAnchor constraintEqualToAnchor:toastView.leadingAnchor constant:18.0],
        [messageLabel.trailingAnchor constraintEqualToAnchor:toastView.trailingAnchor constant:-18.0],
        [messageLabel.topAnchor constraintEqualToAnchor:toastView.topAnchor constant:12.0],
        [messageLabel.bottomAnchor constraintEqualToAnchor:toastView.bottomAnchor constant:-12.0],
    ]];

    [self.view layoutIfNeeded];

    [UIView animateWithDuration:0.2 animations:^{
        toastView.alpha = 1.0;
    } completion:^(__unused BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.2 animations:^{
                toastView.alpha = 0.0;
            } completion:^(__unused BOOL innerFinished) {
                if (self.toastView == toastView) {
                    self.toastView = nil;
                }
                [toastView removeFromSuperview];
            }];
        });
    }];
}

@end

@implementation EAPMDemoSettingsGradientButton {
    CAGradientLayer *_gradientLayer;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _gradientLayer = [CAGradientLayer layer];
        _gradientLayer.colors = @[
            (__bridge id)EAPMDemoSettingsHexColor(0x4250F7, 1.0).CGColor,
            (__bridge id)EAPMDemoSettingsHexColor(0x435FF9, 1.0).CGColor
        ];
        _gradientLayer.locations = @[@0, @1];
        _gradientLayer.startPoint = CGPointMake(1.0, 0.0);
        _gradientLayer.endPoint = CGPointMake(0.1, 1.0);
        [self.layer insertSublayer:_gradientLayer atIndex:0];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _gradientLayer.frame = self.bounds;
    _gradientLayer.cornerRadius = self.layer.cornerRadius;
}

@end

@interface EAPMDemoSettingsInputView ()

@property (nonatomic, strong, readwrite) UITextField *textField;
@property (nonatomic, strong) UIView *inputContainerView;
@property (nonatomic, assign) BOOL editable;

@end

@implementation EAPMDemoSettingsInputView

- (instancetype)initWithTitle:(NSString *)title placeholder:(NSString *)placeholder editable:(BOOL)editable {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _editable = editable;

        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        titleLabel.numberOfLines = 1;
        titleLabel.attributedText = EAPMDemoFieldTitleAttributedString(title, EAPMDemoSettingsHexColor(0x9A9EA8, 1.0));
        [self addSubview:titleLabel];

        _inputContainerView = [[UIView alloc] init];
        _inputContainerView.translatesAutoresizingMaskIntoConstraints = NO;
        _inputContainerView.backgroundColor = editable ? EAPMDemoSettingsHexColor(0xF0F2F5, 1.0) : EAPMDemoSettingsHexColor(0xE1E5EB, 1.0);
        _inputContainerView.layer.cornerRadius = EAPMDemoUICornerRadius;
        [self addSubview:_inputContainerView];

        _textField = [[UITextField alloc] init];
        _textField.translatesAutoresizingMaskIntoConstraints = NO;
        UIFont *textFont = EAPMDemoUIFontRegular(16.0);
        _textField.font = textFont;
        _textField.textColor = editable ? EAPMDemoSettingsHexColor(0x4B4D52, 1.0) : EAPMDemoSettingsHexColor(0x95A4C2, 1.0);
        _textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholder ?: @"" attributes:@{
            NSFontAttributeName: textFont,
            NSForegroundColorAttributeName: EAPMDemoSettingsHexColor(0xC8D0DD, 1.0),
        }];
        _textField.enabled = editable;
        _textField.returnKeyType = editable ? UIReturnKeyNext : UIReturnKeyDone;
        _textField.clearButtonMode = editable ? UITextFieldViewModeWhileEditing : UITextFieldViewModeNever;
        [_inputContainerView addSubview:_textField];

        [NSLayoutConstraint activateConstraints:@[
            [titleLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
            [titleLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
            [titleLabel.topAnchor constraintEqualToAnchor:self.topAnchor],

            [_inputContainerView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
            [_inputContainerView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
            [_inputContainerView.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:EAPMDemoUIFieldSpacing],
            [_inputContainerView.heightAnchor constraintEqualToConstant:EAPMDemoUIInputHeight],
            [_inputContainerView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],

            [_textField.leadingAnchor constraintEqualToAnchor:_inputContainerView.leadingAnchor constant:EAPMDemoUIHorizontalInset],
            [_textField.trailingAnchor constraintEqualToAnchor:_inputContainerView.trailingAnchor constant:-EAPMDemoUIHorizontalInset],
            [_textField.topAnchor constraintEqualToAnchor:_inputContainerView.topAnchor],
            [_textField.bottomAnchor constraintEqualToAnchor:_inputContainerView.bottomAnchor],
        ]];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.inputContainerView.backgroundColor = self.editable ? EAPMDemoSettingsHexColor(0xF0F2F5, 1.0) : EAPMDemoSettingsHexColor(0xE1E5EB, 1.0);
}

@end
