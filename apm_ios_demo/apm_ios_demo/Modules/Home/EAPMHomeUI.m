#import "EAPMHomeUI.h"

static UIColor *EAPMColorHex(NSUInteger hexValue, CGFloat alpha) {
    return [UIColor colorWithRed:((hexValue >> 16) & 0xFF) / 255.0
                           green:((hexValue >> 8) & 0xFF) / 255.0
                            blue:(hexValue & 0xFF) / 255.0
                           alpha:alpha];
}

@interface EAPMHomeActionItem ()

@property (nonatomic, copy, readwrite) NSString *title;
@property (nonatomic, assign, readwrite) EAPMHomeActionType actionType;

@end

@implementation EAPMHomeActionItem

+ (instancetype)itemWithTitle:(NSString *)title actionType:(EAPMHomeActionType)actionType {
    EAPMHomeActionItem *item = [[self alloc] init];
    item.title = title;
    item.actionType = actionType;
    return item;
}

@end

@interface EAPMGradientBackgroundView ()

@property (nonatomic, strong) UIImageView *backgroundImageView;

@end

@implementation EAPMGradientBackgroundView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = EAPMColorHex(0xF3F4F8, 1.0);
        self.clipsToBounds = YES;

        _backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"eapm_home_bg"]];
        _backgroundImageView.contentMode = UIViewContentModeScaleToFill;
        _backgroundImageView.alpha = 0.15;
        [self addSubview:_backgroundImageView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat scale = CGRectGetWidth(self.bounds) / 375.0;
    self.backgroundImageView.frame = CGRectMake(-283.89 * scale,
                                                0.0,
                                                1160.89 * scale,
                                                653.0 * scale);
}

@end

@interface EAPMHeroHeaderView ()

@property (nonatomic, strong) UIImageView *deviceImageView;
@property (nonatomic, strong) UIImageView *topOrbView;
@property (nonatomic, strong) UIImageView *leftOrbView;
@property (nonatomic, strong) UIImageView *largeBlueOrbView;
@property (nonatomic, strong) UIImageView *smallBlueOrbView;
@property (nonatomic, strong) UIImageView *smallPurpleOrbView;
@property (nonatomic, strong) UIView *deviceShadowView;
@property (nonatomic, strong) UIView *bottomGradientView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;

@end

@implementation EAPMHeroHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self buildViews];
    }
    return self;
}

- (void)buildViews {
    self.clipsToBounds = NO;

    _deviceImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"eapm_home_device"]];
    _deviceImageView.contentMode = UIViewContentModeScaleAspectFit;

    _topOrbView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"eapm_orb_large_blue"]];
    _topOrbView.contentMode = UIViewContentModeScaleAspectFit;
    _topOrbView.alpha = 0.14;

    _leftOrbView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"eapm_orb_small_blue"]];
    _leftOrbView.contentMode = UIViewContentModeScaleAspectFit;
    _leftOrbView.alpha = 0.14;

    _largeBlueOrbView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"eapm_orb_large_blue"]];
    _largeBlueOrbView.contentMode = UIViewContentModeScaleAspectFit;
    _largeBlueOrbView.alpha = 0.86;

    _smallBlueOrbView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"eapm_orb_small_blue"]];
    _smallBlueOrbView.contentMode = UIViewContentModeScaleAspectFit;
    _smallBlueOrbView.alpha = 0.85;

    _smallPurpleOrbView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"eapm_orb_small_purple"]];
    _smallPurpleOrbView.contentMode = UIViewContentModeScaleAspectFit;
    _smallPurpleOrbView.alpha = 0.88;

    _deviceShadowView = [[UIView alloc] init];
    _deviceShadowView.backgroundColor = EAPMColorHex(0xE3E9F6, 0.63);
    _deviceShadowView.layer.cornerRadius = 42.0;
    _deviceShadowView.layer.shadowColor = EAPMColorHex(0x979797, 0.32).CGColor;
    _deviceShadowView.layer.shadowOpacity = 1.0;
    _deviceShadowView.layer.shadowRadius = 30.0;
    _deviceShadowView.layer.shadowOffset = CGSizeMake(0.0, 8.0);

    _bottomGradientView = [[UIView alloc] init];
    CAGradientLayer *bottomLayer = [CAGradientLayer layer];
    bottomLayer.colors = @[
        (__bridge id)[UIColor colorWithWhite:1 alpha:0.0].CGColor,
        (__bridge id)EAPMColorHex(0xF3F4F8, 1.0).CGColor,
    ];
    bottomLayer.startPoint = CGPointMake(0.5, 0.0);
    bottomLayer.endPoint = CGPointMake(0.5, 1.0);
    [_bottomGradientView.layer addSublayer:bottomLayer];

    _titleLabel = [[UILabel alloc] init];
    _titleLabel.text = @"移动监控Demo";
    _titleLabel.textColor = EAPMColorHex(0x4B4D52, 1.0);
    _titleLabel.font = [UIFont systemFontOfSize:21.0 weight:UIFontWeightSemibold];
    _titleLabel.numberOfLines = 1;

    _subtitleLabel = [[UILabel alloc] init];
    _subtitleLabel.text = @"欢迎来到阿里云移动监控Demo,开始你的调试吧~";
    _subtitleLabel.textColor = EAPMColorHex(0x607B9C, 1.0);
    _subtitleLabel.font = [UIFont systemFontOfSize:15.0 weight:UIFontWeightRegular];
    _subtitleLabel.numberOfLines = 2;

    for (UIView *view in @[_deviceShadowView, _deviceImageView, _topOrbView, _leftOrbView, _largeBlueOrbView, _smallBlueOrbView, _smallPurpleOrbView, _bottomGradientView, _titleLabel, _subtitleLabel]) {
        view.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:view];
    }

    [NSLayoutConstraint activateConstraints:@[
        [_deviceShadowView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-32.0],
        [_deviceShadowView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-88.0],
        [_deviceShadowView.widthAnchor constraintEqualToConstant:148.0],
        [_deviceShadowView.heightAnchor constraintEqualToConstant:38.0],

        [_deviceImageView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-24.0],
        [_deviceImageView.topAnchor constraintEqualToAnchor:self.topAnchor constant:52.0],
        [_deviceImageView.widthAnchor constraintEqualToConstant:178.0],
        [_deviceImageView.heightAnchor constraintEqualToConstant:254.0],

        [_topOrbView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:71.0],
        [_topOrbView.topAnchor constraintEqualToAnchor:self.topAnchor constant:30.0],
        [_topOrbView.widthAnchor constraintEqualToConstant:22.0],
        [_topOrbView.heightAnchor constraintEqualToConstant:22.0],

        [_leftOrbView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:11.0],
        [_leftOrbView.topAnchor constraintEqualToAnchor:self.topAnchor constant:54.0],
        [_leftOrbView.widthAnchor constraintEqualToConstant:18.0],
        [_leftOrbView.heightAnchor constraintEqualToConstant:18.0],

        [_largeBlueOrbView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:175.0],
        [_largeBlueOrbView.topAnchor constraintEqualToAnchor:self.topAnchor constant:252.0],
        [_largeBlueOrbView.widthAnchor constraintEqualToConstant:28.0],
        [_largeBlueOrbView.heightAnchor constraintEqualToConstant:28.0],

        [_smallBlueOrbView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:145.0],
        [_smallBlueOrbView.topAnchor constraintEqualToAnchor:self.topAnchor constant:230.0],
        [_smallBlueOrbView.widthAnchor constraintEqualToConstant:14.0],
        [_smallBlueOrbView.heightAnchor constraintEqualToConstant:14.0],

        [_smallPurpleOrbView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-18.0],
        [_smallPurpleOrbView.topAnchor constraintEqualToAnchor:self.topAnchor constant:204.0],
        [_smallPurpleOrbView.widthAnchor constraintEqualToConstant:26.0],
        [_smallPurpleOrbView.heightAnchor constraintEqualToConstant:26.0],

        [_titleLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:16.0],
        [_titleLabel.topAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.topAnchor constant:84.0],
        [_titleLabel.widthAnchor constraintEqualToConstant:220.0],

        [_subtitleLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:16.0],
        [_subtitleLabel.topAnchor constraintEqualToAnchor:_titleLabel.bottomAnchor constant:14.0],
        [_subtitleLabel.widthAnchor constraintEqualToConstant:198.0],

        [_bottomGradientView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [_bottomGradientView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [_bottomGradientView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
        [_bottomGradientView.heightAnchor constraintEqualToConstant:84.0],
    ]];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CALayer *layer = self.bottomGradientView.layer.sublayers.firstObject;
    layer.frame = self.bottomGradientView.bounds;
}

@end

@interface EAPMSectionHeaderView ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) EAPMInfoLinkView *infoLinkView;

@end

@implementation EAPMSectionHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:18.0 weight:UIFontWeightMedium];
        _titleLabel.textColor = EAPMColorHex(0x4B4D52, 1.0);

        _infoLinkView = [[EAPMInfoLinkView alloc] init];
        [_infoLinkView configureWithTitle:@"测试步骤"];
        [_infoLinkView addTarget:self action:@selector(handleAccessoryTap) forControlEvents:UIControlEventTouchUpInside];
        _infoLinkView.hidden = YES;

        for (UIView *view in @[_titleLabel, _infoLinkView]) {
            view.translatesAutoresizingMaskIntoConstraints = NO;
            [self addSubview:view];
        }

        [NSLayoutConstraint activateConstraints:@[
            [_titleLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
            [_titleLabel.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
            [_titleLabel.topAnchor constraintEqualToAnchor:self.topAnchor],

            [_infoLinkView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
            [_infoLinkView.centerYAnchor constraintEqualToAnchor:_titleLabel.centerYAnchor],
        ]];
    }
    return self;
}

- (void)configureWithTitle:(NSString *)title accessoryTitle:(NSString *)accessoryTitle {
    self.titleLabel.text = title;
    BOOL showsAccessory = accessoryTitle.length > 0;
    self.infoLinkView.hidden = !showsAccessory;
    if (showsAccessory) {
        [self.infoLinkView configureWithTitle:accessoryTitle];
    }
}

- (void)handleAccessoryTap {
    if (self.accessoryTapHandler) {
        self.accessoryTapHandler();
    }
}

@end

@interface EAPMActionCardView ()

@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation EAPMActionCardView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.whiteColor;
        self.layer.cornerRadius = 10.0;
        self.layer.borderWidth = 1.0;
        self.layer.borderColor = EAPMColorHex(0xE6E8EB, 1.0).CGColor;
        self.layer.shadowOpacity = 0.0;

        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = EAPMColorHex(0x1F2024, 1.0);
        _titleLabel.font = [UIFont systemFontOfSize:16.0 weight:UIFontWeightRegular];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.numberOfLines = 2;
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_titleLabel];

        [NSLayoutConstraint activateConstraints:@[
            [_titleLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:12.0],
            [_titleLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-12.0],
            [_titleLabel.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
        ]];
    }
    return self;
}

- (void)configureWithTitle:(NSString *)title {
    self.titleLabel.text = title;
}

- (void)setCardHighlighted:(BOOL)highlighted {
    CGFloat alpha = highlighted ? 0.9 : 1.0;
    CGAffineTransform transform = highlighted ? CGAffineTransformMakeScale(0.98, 0.98) : CGAffineTransformIdentity;
    [UIView animateWithDuration:0.18 animations:^{
        self.alpha = alpha;
        self.transform = transform;
    }];
}

@end

@interface EAPMInfoLinkView ()

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation EAPMInfoLinkView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.accessibilityTraits = UIAccessibilityTraitButton;

        UIImageSymbolConfiguration *configuration = [UIImageSymbolConfiguration configurationWithPointSize:17 weight:UIImageSymbolWeightRegular];
        UIImage *icon = [UIImage systemImageNamed:@"info.circle" withConfiguration:configuration];
        _iconView = [[UIImageView alloc] initWithImage:icon];
        _iconView.tintColor = EAPMColorHex(0x315CFC, 1.0);

        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:16.0 weight:UIFontWeightRegular];
        _titleLabel.textColor = EAPMColorHex(0x315CFC, 1.0);

        for (UIView *view in @[_iconView, _titleLabel]) {
            view.translatesAutoresizingMaskIntoConstraints = NO;
            [self addSubview:view];
        }

        [NSLayoutConstraint activateConstraints:@[
            [_iconView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
            [_iconView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
            [_iconView.widthAnchor constraintEqualToConstant:18.0],
            [_iconView.heightAnchor constraintEqualToConstant:18.0],

            [_titleLabel.leadingAnchor constraintEqualToAnchor:_iconView.trailingAnchor constant:4.0],
            [_titleLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
            [_titleLabel.topAnchor constraintEqualToAnchor:self.topAnchor],
            [_titleLabel.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
        ]];
    }
    return self;
}

- (void)configureWithTitle:(NSString *)title {
    self.titleLabel.text = title;
}

@end
