#import "EAPMDemoSettingsViewController.h"

#import "EAPMDemoConfigStore.h"
#import <UTDID/UTDevice.h>

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
    self.view.backgroundColor = EAPMDemoSettingsHexColor(0xF3F4F8, 1.0);

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
        UIImageSymbolConfiguration *configuration = [UIImageSymbolConfiguration configurationWithPointSize:14.0 weight:UIImageSymbolWeightMedium];
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
    UIFont *pageTitleFont = [UIFont fontWithName:@"PingFangSC-Medium" size:22.0] ?: [UIFont systemFontOfSize:22.0 weight:UIFontWeightMedium];
    NSMutableAttributedString *titleText = [[NSMutableAttributedString alloc] initWithString:@"设置" attributes:@{
        NSFontAttributeName: pageTitleFont,
        NSForegroundColorAttributeName: EAPMDemoSettingsHexColor(0x4B4D52, 1.0),
        NSKernAttributeName: @(4.56),
    }];
    pageTitleLabel.attributedText = titleText;
    [_headerView addSubview:pageTitleLabel];

    _scrollView = [[UIScrollView alloc] init];
    _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    _scrollView.alwaysBounceVertical = YES;
    _scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.view addSubview:_scrollView];

    _contentView = [[UIView alloc] init];
    _contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [_scrollView addSubview:_contentView];

    UIView *sectionHeaderView = [[UIView alloc] init];
    sectionHeaderView.translatesAutoresizingMaskIntoConstraints = NO;
    [_contentView addSubview:sectionHeaderView];

    UIView *accentView = [[UIView alloc] init];
    accentView.translatesAutoresizingMaskIntoConstraints = NO;
    accentView.backgroundColor = EAPMDemoSettingsHexColor(0x315CFC, 1.0);
    accentView.layer.cornerRadius = 3.0;
    [sectionHeaderView addSubview:accentView];

    UILabel *sectionTitleLabel = [[UILabel alloc] init];
    sectionTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    sectionTitleLabel.text = @"用户信息";
    sectionTitleLabel.font = [UIFont systemFontOfSize:18.0 weight:UIFontWeightMedium];
    sectionTitleLabel.textColor = EAPMDemoSettingsHexColor(0x4B4D52, 1.0);
    [sectionHeaderView addSubview:sectionTitleLabel];

    UIView *cardView = [[UIView alloc] init];
    cardView.translatesAutoresizingMaskIntoConstraints = NO;
    cardView.backgroundColor = UIColor.whiteColor;
    cardView.layer.cornerRadius = 18.0;
    cardView.layer.borderWidth = 1.0;
    cardView.layer.borderColor = EAPMDemoSettingsHexColor(0xE6E8EB, 1.0).CGColor;
    [_contentView addSubview:cardView];

    _userIdInputView = [[EAPMDemoSettingsInputView alloc] initWithTitle:@"UserID" placeholder:@"请输入 UserID" editable:YES];
    _userNickInputView = [[EAPMDemoSettingsInputView alloc] initWithTitle:@"用户昵称" placeholder:@"请输入 用户昵称" editable:YES];
    _utdidInputView = [[EAPMDemoSettingsInputView alloc] initWithTitle:@"UTDID" placeholder:@"" editable:NO];

    for (EAPMDemoSettingsInputView *inputView in @[_userIdInputView, _userNickInputView, _utdidInputView]) {
        inputView.translatesAutoresizingMaskIntoConstraints = NO;
        [cardView addSubview:inputView];
    }

    _userIdInputView.textField.delegate = self;
    _userNickInputView.textField.delegate = self;
    _userNickInputView.textField.returnKeyType = UIReturnKeyDone;

    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeSystem];
    saveButton.translatesAutoresizingMaskIntoConstraints = NO;
    saveButton.backgroundColor = EAPMDemoSettingsHexColor(0x315CFC, 1.0);
    saveButton.layer.cornerRadius = 10.0;
    saveButton.titleLabel.font = [UIFont systemFontOfSize:16.0 weight:UIFontWeightSemibold];
    [saveButton setTitle:@"保存设置" forState:UIControlStateNormal];
    [saveButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [saveButton addTarget:self action:@selector(handleSaveButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [_contentView addSubview:saveButton];

    UILayoutGuide *margins = self.view.layoutMarginsGuide;
    [NSLayoutConstraint activateConstraints:@[
        [_headerView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [_headerView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [_headerView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],

        [backButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:14.0],
        [backButton.topAnchor constraintEqualToAnchor:_headerView.topAnchor constant:8.0],
        [backButton.widthAnchor constraintEqualToConstant:22.0],
        [backButton.heightAnchor constraintEqualToConstant:22.0],

        [pageTitleLabel.leadingAnchor constraintEqualToAnchor:backButton.trailingAnchor constant:10.0],
        [pageTitleLabel.centerYAnchor constraintEqualToAnchor:backButton.centerYAnchor constant:-1.0],

        [_headerView.bottomAnchor constraintEqualToAnchor:pageTitleLabel.bottomAnchor constant:10.0],

        [_scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [_scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [_scrollView.topAnchor constraintEqualToAnchor:_headerView.bottomAnchor constant:8.0],
        [_scrollView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],

        [_contentView.leadingAnchor constraintEqualToAnchor:_scrollView.contentLayoutGuide.leadingAnchor],
        [_contentView.trailingAnchor constraintEqualToAnchor:_scrollView.contentLayoutGuide.trailingAnchor],
        [_contentView.topAnchor constraintEqualToAnchor:_scrollView.contentLayoutGuide.topAnchor],
        [_contentView.bottomAnchor constraintEqualToAnchor:_scrollView.contentLayoutGuide.bottomAnchor],
        [_contentView.widthAnchor constraintEqualToAnchor:_scrollView.frameLayoutGuide.widthAnchor],

        [sectionHeaderView.leadingAnchor constraintEqualToAnchor:margins.leadingAnchor],
        [sectionHeaderView.trailingAnchor constraintEqualToAnchor:margins.trailingAnchor],
        [sectionHeaderView.topAnchor constraintEqualToAnchor:_contentView.topAnchor constant:18.0],
        [sectionHeaderView.heightAnchor constraintEqualToConstant:28.0],

        [accentView.leadingAnchor constraintEqualToAnchor:sectionHeaderView.leadingAnchor],
        [accentView.centerYAnchor constraintEqualToAnchor:sectionHeaderView.centerYAnchor],
        [accentView.widthAnchor constraintEqualToConstant:4.0],
        [accentView.heightAnchor constraintEqualToConstant:20.0],

        [sectionTitleLabel.leadingAnchor constraintEqualToAnchor:accentView.trailingAnchor constant:14.0],
        [sectionTitleLabel.centerYAnchor constraintEqualToAnchor:accentView.centerYAnchor],

        [cardView.leadingAnchor constraintEqualToAnchor:margins.leadingAnchor],
        [cardView.trailingAnchor constraintEqualToAnchor:margins.trailingAnchor],
        [cardView.topAnchor constraintEqualToAnchor:sectionHeaderView.bottomAnchor constant:18.0],

        [_userIdInputView.leadingAnchor constraintEqualToAnchor:cardView.leadingAnchor constant:18.0],
        [_userIdInputView.trailingAnchor constraintEqualToAnchor:cardView.trailingAnchor constant:-18.0],
        [_userIdInputView.topAnchor constraintEqualToAnchor:cardView.topAnchor constant:22.0],

        [_userNickInputView.leadingAnchor constraintEqualToAnchor:cardView.leadingAnchor constant:18.0],
        [_userNickInputView.trailingAnchor constraintEqualToAnchor:cardView.trailingAnchor constant:-18.0],
        [_userNickInputView.topAnchor constraintEqualToAnchor:_userIdInputView.bottomAnchor constant:22.0],

        [_utdidInputView.leadingAnchor constraintEqualToAnchor:cardView.leadingAnchor constant:18.0],
        [_utdidInputView.trailingAnchor constraintEqualToAnchor:cardView.trailingAnchor constant:-18.0],
        [_utdidInputView.topAnchor constraintEqualToAnchor:_userNickInputView.bottomAnchor constant:22.0],
        [_utdidInputView.bottomAnchor constraintEqualToAnchor:cardView.bottomAnchor constant:-22.0],

        [saveButton.leadingAnchor constraintEqualToAnchor:margins.leadingAnchor],
        [saveButton.trailingAnchor constraintEqualToAnchor:margins.trailingAnchor],
        [saveButton.topAnchor constraintEqualToAnchor:cardView.bottomAnchor constant:22.0],
        [saveButton.heightAnchor constraintEqualToConstant:52.0],
        [saveButton.bottomAnchor constraintEqualToAnchor:_contentView.bottomAnchor constant:-30.0],
    ]];
}

- (void)reloadValues {
    self.userIdInputView.textField.text = [EAPMDemoConfigStore storedUserId] ?: @"";
    self.userNickInputView.textField.text = [EAPMDemoConfigStore storedUserNick] ?: @"";

    NSString *utdid = [UTDevice utdid];
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
    toastView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.72];
    toastView.layer.cornerRadius = 10.0;
    toastView.alpha = 0.0;

    UILabel *messageLabel = [[UILabel alloc] init];
    messageLabel.translatesAutoresizingMaskIntoConstraints = NO;
    messageLabel.text = @"设置已保存";
    messageLabel.textColor = UIColor.whiteColor;
    messageLabel.font = [UIFont systemFontOfSize:15.0 weight:UIFontWeightMedium];
    messageLabel.textAlignment = NSTextAlignmentCenter;
    [toastView addSubview:messageLabel];

    [self.view addSubview:toastView];
    self.toastView = toastView;

    [NSLayoutConstraint activateConstraints:@[
        [toastView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [toastView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-28.0],
        [toastView.heightAnchor constraintEqualToConstant:40.0],
        [messageLabel.leadingAnchor constraintEqualToAnchor:toastView.leadingAnchor constant:18.0],
        [messageLabel.trailingAnchor constraintEqualToAnchor:toastView.trailingAnchor constant:-18.0],
        [messageLabel.centerYAnchor constraintEqualToAnchor:toastView.centerYAnchor],
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

@interface EAPMDemoSettingsInputView ()

@property (nonatomic, strong, readwrite) UITextField *textField;

@end

@implementation EAPMDemoSettingsInputView

- (instancetype)initWithTitle:(NSString *)title placeholder:(NSString *)placeholder editable:(BOOL)editable {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        titleLabel.text = title;
        titleLabel.font = [UIFont systemFontOfSize:15.0 weight:UIFontWeightMedium];
        titleLabel.textColor = EAPMDemoSettingsHexColor(0x5E6066, 1.0);
        [self addSubview:titleLabel];

        UIView *inputContainerView = [[UIView alloc] init];
        inputContainerView.translatesAutoresizingMaskIntoConstraints = NO;
        inputContainerView.backgroundColor = editable ? EAPMDemoSettingsHexColor(0xFBFCFE, 1.0) : EAPMDemoSettingsHexColor(0xF0F3F8, 1.0);
        inputContainerView.layer.cornerRadius = 14.0;
        inputContainerView.layer.borderWidth = 1.0;
        inputContainerView.layer.borderColor = EAPMDemoSettingsHexColor(0xE1E5EE, 1.0).CGColor;
        [self addSubview:inputContainerView];

        _textField = [[UITextField alloc] init];
        _textField.translatesAutoresizingMaskIntoConstraints = NO;
        _textField.font = [UIFont systemFontOfSize:16.0 weight:UIFontWeightRegular];
        _textField.textColor = editable ? EAPMDemoSettingsHexColor(0x1F2024, 1.0) : EAPMDemoSettingsHexColor(0x9AA3B2, 1.0);
        _textField.placeholder = placeholder;
        _textField.enabled = editable;
        _textField.returnKeyType = editable ? UIReturnKeyNext : UIReturnKeyDone;
        _textField.clearButtonMode = editable ? UITextFieldViewModeWhileEditing : UITextFieldViewModeNever;
        [inputContainerView addSubview:_textField];

        [NSLayoutConstraint activateConstraints:@[
            [titleLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
            [titleLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
            [titleLabel.topAnchor constraintEqualToAnchor:self.topAnchor],

            [inputContainerView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
            [inputContainerView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
            [inputContainerView.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:12.0],
            [inputContainerView.heightAnchor constraintEqualToConstant:56.0],
            [inputContainerView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],

            [_textField.leadingAnchor constraintEqualToAnchor:inputContainerView.leadingAnchor constant:16.0],
            [_textField.trailingAnchor constraintEqualToAnchor:inputContainerView.trailingAnchor constant:-16.0],
            [_textField.topAnchor constraintEqualToAnchor:inputContainerView.topAnchor],
            [_textField.bottomAnchor constraintEqualToAnchor:inputContainerView.bottomAnchor],
        ]];
    }
    return self;
}

@end
