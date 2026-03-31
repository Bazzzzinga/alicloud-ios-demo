#import "EAPMDemoHomeUI.h"

static UIColor *EAPMDemoColorHex(NSUInteger hexValue, CGFloat alpha) {
    return [UIColor colorWithRed:((hexValue >> 16) & 0xFF) / 255.0
                           green:((hexValue >> 8) & 0xFF) / 255.0
                            blue:(hexValue & 0xFF) / 255.0
                           alpha:alpha];
}

@interface EAPMDemoHomeActionItem ()

@property (nonatomic, copy, readwrite) NSString *title;
@property (nonatomic, copy, readwrite) EAPMDemoHomeActionHandler actionHandler;

@end

@implementation EAPMDemoHomeActionItem

+ (instancetype)itemWithTitle:(NSString *)title actionHandler:(EAPMDemoHomeActionHandler)actionHandler {
    EAPMDemoHomeActionItem *item = [[self alloc] init];
    item.title = title;
    item.actionHandler = actionHandler;
    return item;
}

- (void)performAction {
    if (self.actionHandler) {
        self.actionHandler();
    }
}

@end

@interface EAPMDemoHomeSectionModel ()

@property (nonatomic, copy, readwrite) NSString *title;
@property (nonatomic, copy, readwrite) NSArray<EAPMDemoHomeActionItem *> *items;

@end

@implementation EAPMDemoHomeSectionModel

+ (instancetype)sectionWithTitle:(NSString *)title items:(NSArray<EAPMDemoHomeActionItem *> *)items {
    EAPMDemoHomeSectionModel *section = [[self alloc] init];
    section.title = title;
    section.items = items;
    return section;
}

@end

@interface EAPMDemoGradientBackgroundView ()

@property (nonatomic, strong) UIImageView *backgroundImageView;

@end

@implementation EAPMDemoGradientBackgroundView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = EAPMDemoColorHex(0xF3F4F8, 1.0);
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

@interface EAPMDemoHeroHeaderView ()

@property (nonatomic, strong) UIImageView *heroImageView;
@property (nonatomic, strong) NSLayoutConstraint *heroImageHeightConstraint;
@property (nonatomic, strong) EAPMDemoInfoBannerView *infoBannerView;
@property (nonatomic, strong) UIView *bottomGradientView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;

@end

@implementation EAPMDemoHeroHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self buildViews];
    }
    return self;
}

- (void)buildViews {
    self.clipsToBounds = YES;

    _heroImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"eapm_home_hero"]];
    _heroImageView.contentMode = UIViewContentModeScaleAspectFit;

    _bottomGradientView = [[UIView alloc] init];
    CAGradientLayer *bottomLayer = [CAGradientLayer layer];
    bottomLayer.colors = @[
        (__bridge id)[UIColor colorWithWhite:1 alpha:0.0].CGColor,
        (__bridge id)EAPMDemoColorHex(0xF3F4F8, 1.0).CGColor,
    ];
    bottomLayer.startPoint = CGPointMake(0.5, 0.0);
    bottomLayer.endPoint = CGPointMake(0.5, 1.0);
    [_bottomGradientView.layer addSublayer:bottomLayer];

    _infoBannerView = [[EAPMDemoInfoBannerView alloc] init];

    _titleLabel = [[UILabel alloc] init];
    _titleLabel.text = @"移动监控";
    _titleLabel.textColor = EAPMDemoColorHex(0x4B4D52, 1.0);
    _titleLabel.font = [UIFont systemFontOfSize:21.0 weight:UIFontWeightSemibold];
    _titleLabel.numberOfLines = 1;

    _subtitleLabel = [[UILabel alloc] init];
    _subtitleLabel.text = @"欢迎来到阿里云移动监控，开始你的调试吧~";
    _subtitleLabel.textColor = EAPMDemoColorHex(0x607B9C, 1.0);
    _subtitleLabel.font = [UIFont systemFontOfSize:15.0 weight:UIFontWeightRegular];
    _subtitleLabel.numberOfLines = 2;

    for (UIView *view in @[_heroImageView, _bottomGradientView, _infoBannerView, _titleLabel, _subtitleLabel]) {
        view.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:view];
    }

    _heroImageHeightConstraint = [_heroImageView.heightAnchor constraintEqualToConstant:266.0];

    [NSLayoutConstraint activateConstraints:@[
        [_heroImageView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [_heroImageView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [_heroImageView.topAnchor constraintEqualToAnchor:self.topAnchor],
        _heroImageHeightConstraint,

        [_titleLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:16.0],
        [_titleLabel.topAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.topAnchor constant:58.0],
        [_titleLabel.widthAnchor constraintEqualToConstant:220.0],

        [_subtitleLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:16.0],
        [_subtitleLabel.topAnchor constraintEqualToAnchor:_titleLabel.bottomAnchor constant:12.0],
        [_subtitleLabel.widthAnchor constraintEqualToConstant:208.0],

        [_infoBannerView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:16.0],
        [_infoBannerView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-16.0],
        [_infoBannerView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],

        [_bottomGradientView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [_bottomGradientView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [_bottomGradientView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
        [_bottomGradientView.heightAnchor constraintEqualToConstant:24.0],
    ]];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat imageHeight = CGRectGetWidth(self.bounds) * 1068.0 / 1500.0;
    self.heroImageHeightConstraint.constant = ceil(imageHeight);

    CALayer *layer = self.bottomGradientView.layer.sublayers.firstObject;
    layer.frame = self.bottomGradientView.bounds;
}

- (void)configureWithInfoText:(NSString *)text {
    [self.infoBannerView configureWithText:text];
}

@end

@interface EAPMDemoSectionHeaderView ()

@property (nonatomic, strong) UIView *accentView;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation EAPMDemoSectionHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _accentView = [[UIView alloc] init];
        _accentView.backgroundColor = EAPMDemoColorHex(0x315CFC, 1.0);
        _accentView.layer.cornerRadius = 3.0;

        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:18.0 weight:UIFontWeightMedium];
        _titleLabel.textColor = EAPMDemoColorHex(0x4B4D52, 1.0);

        for (UIView *view in @[_accentView, _titleLabel]) {
            view.translatesAutoresizingMaskIntoConstraints = NO;
            [self addSubview:view];
        }

        [NSLayoutConstraint activateConstraints:@[
            [_accentView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
            [_accentView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
            [_accentView.widthAnchor constraintEqualToConstant:4.0],
            [_accentView.heightAnchor constraintEqualToConstant:20.0],

            [_titleLabel.leadingAnchor constraintEqualToAnchor:_accentView.trailingAnchor constant:12.0],
            [_titleLabel.centerYAnchor constraintEqualToAnchor:_accentView.centerYAnchor],
        ]];
    }
    return self;
}

- (void)configureWithTitle:(NSString *)title {
    self.titleLabel.text = title;
}

@end

@interface EAPMDemoInfoBannerView ()

@property (nonatomic, strong) UILabel *textLabel;

@end

@implementation EAPMDemoInfoBannerView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = EAPMDemoColorHex(0xE2EBFF, 0.96);
        self.layer.cornerRadius = 6.0;
        self.layer.borderWidth = 1.0;
        self.layer.borderColor = EAPMDemoColorHex(0xD5E0F7, 1.0).CGColor;

        _textLabel = [[UILabel alloc] init];
        _textLabel.textColor = EAPMDemoColorHex(0x767D89, 1.0);
        _textLabel.font = [UIFont systemFontOfSize:15.0 weight:UIFontWeightRegular];
        _textLabel.numberOfLines = 0;
        _textLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_textLabel];

        [NSLayoutConstraint activateConstraints:@[
            [_textLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:16.0],
            [_textLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-16.0],
            [_textLabel.topAnchor constraintEqualToAnchor:self.topAnchor constant:10.0],
            [_textLabel.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-10.0],
        ]];
    }
    return self;
}

- (void)configureWithText:(NSString *)text {
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:text attributes:@{
        NSFontAttributeName: [UIFont systemFontOfSize:15.0 weight:UIFontWeightRegular],
        NSForegroundColorAttributeName: EAPMDemoColorHex(0x767D89, 1.0),
    }];
    NSRange highlightRange = [text rangeOfString:@"EMAS 控制台"];
    if (highlightRange.location != NSNotFound) {
        [attributedText addAttributes:@{
            NSFontAttributeName: [UIFont systemFontOfSize:15.0 weight:UIFontWeightSemibold],
            NSForegroundColorAttributeName: EAPMDemoColorHex(0x767D89, 1.0),
        } range:highlightRange];
    }
    self.textLabel.attributedText = attributedText;
}

@end

@interface EAPMDemoActionCardView ()

@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation EAPMDemoActionCardView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.whiteColor;
        self.layer.cornerRadius = 6.0;
        self.layer.borderWidth = 2.0;
        self.layer.borderColor = EAPMDemoColorHex(0xE6E8EB, 1.0).CGColor;
        self.layer.shadowOpacity = 0.0;

        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = EAPMDemoColorHex(0x1F2024, 1.0);
        _titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16.0] ?: [UIFont systemFontOfSize:16.0 weight:UIFontWeightRegular];
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
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    paragraphStyle.minimumLineHeight = 24.0;
    paragraphStyle.maximumLineHeight = 24.0;

    self.titleLabel.attributedText = [[NSAttributedString alloc] initWithString:title attributes:@{
        NSFontAttributeName: self.titleLabel.font,
        NSForegroundColorAttributeName: EAPMDemoColorHex(0x1F2024, 1.0),
        NSParagraphStyleAttributeName: paragraphStyle,
    }];
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
