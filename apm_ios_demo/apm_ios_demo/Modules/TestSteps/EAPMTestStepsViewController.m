#import "EAPMTestStepsViewController.h"

@interface EAPMTestStepsViewController ()

@end

@implementation EAPMTestStepsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"测试步骤";
    self.view.backgroundColor = [UIColor colorWithRed:0xF3 / 255.0 green:0xF4 / 255.0 blue:0xF8 / 255.0 alpha:1.0];

    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:scrollView];

    UIView *contentView = [[UIView alloc] init];
    contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [scrollView addSubview:contentView];

    UIStackView *stackView = [[UIStackView alloc] init];
    stackView.translatesAutoresizingMaskIntoConstraints = NO;
    stackView.axis = UILayoutConstraintAxisVertical;
    stackView.spacing = 16.0;
    [contentView addSubview:stackView];

    NSArray<NSDictionary<NSString *, NSString *> *> *steps = @[
        @{@"title": @"崩溃分析", @"body": @"依次点击全堆栈Crash、Abort、触发卡顿、自定义异常，观察崩溃与异常数据的采集结果。"},
        @{@"title": @"性能分析", @"body": @"点击测页面加载和测页面滑动，进入承接页后执行页面首屏加载和长列表滚动操作。"},
        @{@"title": @"网络请求", @"body": @"点击网络请求后，Demo 会发起多次请求，用于验证网络采集和链路回传。"},
        @{@"title": @"远程日志", @"body": @"点击打日志、更新昵称，验证日志写入与用户维度更新是否生效。"},
    ];

    for (NSDictionary<NSString *, NSString *> *step in steps) {
        UIView *cardView = [[UIView alloc] init];
        cardView.backgroundColor = UIColor.whiteColor;
        cardView.layer.cornerRadius = 18.0;
        cardView.layer.borderWidth = 1.0;
        cardView.layer.borderColor = [UIColor colorWithRed:0xE6 / 255.0 green:0xE8 / 255.0 blue:0xEB / 255.0 alpha:1.0].CGColor;

        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        titleLabel.text = step[@"title"];
        titleLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightSemibold];
        titleLabel.textColor = [UIColor colorWithRed:0x4B / 255.0 green:0x4D / 255.0 blue:0x52 / 255.0 alpha:1.0];
        [cardView addSubview:titleLabel];

        UILabel *bodyLabel = [[UILabel alloc] init];
        bodyLabel.translatesAutoresizingMaskIntoConstraints = NO;
        bodyLabel.text = step[@"body"];
        bodyLabel.numberOfLines = 0;
        bodyLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightRegular];
        bodyLabel.textColor = [UIColor colorWithRed:0x60 / 255.0 green:0x7B / 255.0 blue:0x9C / 255.0 alpha:1.0];
        [cardView addSubview:bodyLabel];

        [NSLayoutConstraint activateConstraints:@[
            [titleLabel.leadingAnchor constraintEqualToAnchor:cardView.leadingAnchor constant:18.0],
            [titleLabel.trailingAnchor constraintEqualToAnchor:cardView.trailingAnchor constant:-18.0],
            [titleLabel.topAnchor constraintEqualToAnchor:cardView.topAnchor constant:18.0],

            [bodyLabel.leadingAnchor constraintEqualToAnchor:cardView.leadingAnchor constant:18.0],
            [bodyLabel.trailingAnchor constraintEqualToAnchor:cardView.trailingAnchor constant:-18.0],
            [bodyLabel.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:10.0],
            [bodyLabel.bottomAnchor constraintEqualToAnchor:cardView.bottomAnchor constant:-18.0],
        ]];

        [stackView addArrangedSubview:cardView];
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

        [stackView.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:16.0],
        [stackView.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-16.0],
        [stackView.topAnchor constraintEqualToAnchor:contentView.topAnchor constant:20.0],
        [stackView.bottomAnchor constraintEqualToAnchor:contentView.bottomAnchor constant:-24.0],
    ]];
}

@end
