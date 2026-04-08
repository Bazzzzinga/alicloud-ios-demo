#import "EAPMDemoPerformanceLoadViewController.h"
#import "../Shared/EAPMDemoUIStyleGuide.h"

@interface EAPMDemoPerformanceLoadViewController ()

@end

@implementation EAPMDemoPerformanceLoadViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"启动分析";
    self.view.backgroundColor = [UIColor colorWithRed:0xF3 / 255.0 green:0xF4 / 255.0 blue:0xF8 / 255.0 alpha:1.0];

    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    scrollView.alwaysBounceVertical = YES;
    [self.view addSubview:scrollView];

    UIView *contentView = [[UIView alloc] init];
    contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [scrollView addSubview:contentView];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    titleLabel.text = @"启动分析示例";
    titleLabel.font = EAPMDemoUIFontSemibold(22.0);
    titleLabel.textColor = [UIColor colorWithRed:0x4B / 255.0 green:0x4D / 255.0 blue:0x52 / 255.0 alpha:1.0];
    [contentView addSubview:titleLabel];

    UILabel *descLabel = [[UILabel alloc] init];
    descLabel.translatesAutoresizingMaskIntoConstraints = NO;
    descLabel.text = @"这个页面用于承接首页“启动分析”，首屏包含多组卡片和说明内容，用于模拟真实业务页的首屏渲染。";
    descLabel.numberOfLines = 0;
    descLabel.attributedText = EAPMDemoBodyAttributedString(descLabel.text,
                                                            EAPMDemoUIColor(0x607B9C, 1.0));
    [contentView addSubview:descLabel];

    UIView *previousCard = nil;
    for (NSInteger index = 0; index < 6; index++) {
        UIView *cardView = [[UIView alloc] init];
        cardView.translatesAutoresizingMaskIntoConstraints = NO;
        cardView.backgroundColor = UIColor.whiteColor;
        cardView.layer.cornerRadius = EAPMDemoUICornerRadius;
        cardView.layer.borderWidth = 2.0;
        cardView.layer.borderColor = [UIColor colorWithRed:0xE6 / 255.0 green:0xE8 / 255.0 blue:0xEB / 255.0 alpha:1.0].CGColor;
        [contentView addSubview:cardView];

        UILabel *cardTitle = [[UILabel alloc] init];
        cardTitle.translatesAutoresizingMaskIntoConstraints = NO;
        cardTitle.text = [NSString stringWithFormat:@"首屏模块 %ld", (long)index + 1];
        cardTitle.font = EAPMDemoUIFontMedium(18.0);
        cardTitle.textColor = [UIColor colorWithRed:0x1F / 255.0 green:0x20 / 255.0 blue:0x24 / 255.0 alpha:1.0];
        [cardView addSubview:cardTitle];

        UILabel *cardBody = [[UILabel alloc] init];
        cardBody.translatesAutoresizingMaskIntoConstraints = NO;
        cardBody.numberOfLines = 0;
        cardBody.text = @"用于模拟真实业务卡片布局，包含说明文案、边框、圆角和分隔间距。";
        cardBody.attributedText = EAPMDemoBodyAttributedString(cardBody.text,
                                                               EAPMDemoUIColor(0x607B9C, 1.0));
        [cardView addSubview:cardBody];

        [NSLayoutConstraint activateConstraints:@[
            [cardTitle.leadingAnchor constraintEqualToAnchor:cardView.leadingAnchor constant:18.0],
            [cardTitle.trailingAnchor constraintEqualToAnchor:cardView.trailingAnchor constant:-18.0],
            [cardTitle.topAnchor constraintEqualToAnchor:cardView.topAnchor constant:18.0],

            [cardBody.leadingAnchor constraintEqualToAnchor:cardView.leadingAnchor constant:18.0],
            [cardBody.trailingAnchor constraintEqualToAnchor:cardView.trailingAnchor constant:-18.0],
            [cardBody.topAnchor constraintEqualToAnchor:cardTitle.bottomAnchor constant:10.0],
            [cardBody.bottomAnchor constraintEqualToAnchor:cardView.bottomAnchor constant:-18.0],
        ]];

        [NSLayoutConstraint activateConstraints:@[
            [cardView.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:16.0],
            [cardView.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-16.0],
            [cardView.heightAnchor constraintGreaterThanOrEqualToConstant:112.0],
            previousCard ? [cardView.topAnchor constraintEqualToAnchor:previousCard.bottomAnchor constant:16.0] : [cardView.topAnchor constraintEqualToAnchor:descLabel.bottomAnchor constant:24.0],
        ]];
        previousCard = cardView;
    }

    [NSLayoutConstraint activateConstraints:@[
        [scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [scrollView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [scrollView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],

        [contentView.leadingAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.leadingAnchor],
        [contentView.trailingAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.trailingAnchor],
        [contentView.topAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.topAnchor],
        [contentView.bottomAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.bottomAnchor],
        [contentView.widthAnchor constraintEqualToAnchor:scrollView.frameLayoutGuide.widthAnchor],

        [titleLabel.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:16.0],
        [titleLabel.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-16.0],
        [titleLabel.topAnchor constraintEqualToAnchor:contentView.topAnchor constant:20.0],

        [descLabel.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:16.0],
        [descLabel.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-16.0],
        [descLabel.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:12.0],
        [previousCard.bottomAnchor constraintEqualToAnchor:contentView.bottomAnchor constant:-24.0],
    ]];
}

@end
