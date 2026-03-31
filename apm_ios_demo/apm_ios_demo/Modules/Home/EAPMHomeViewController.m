#import "EAPMHomeViewController.h"

#import "EAPMHomeUI.h"
#import "../../EAPMSDKImports.h"
#import "EAPMPerformanceLoadDemoViewController.h"
#import "EAPMPerformanceScrollDemoViewController.h"

static NSString * const EAPMHeroCellReuseIdentifier = @"EAPMHeroCell";
static NSString * const EAPMActionCellReuseIdentifier = @"EAPMActionCell";
static NSString * const EAPMSectionHeaderReuseIdentifier = @"EAPMSectionHeader";

typedef NS_ENUM(NSInteger, EAPMHomeSectionType) {
    EAPMHomeSectionTypeHero,
    EAPMHomeSectionTypeCrash,
    EAPMHomeSectionTypePerformance,
    EAPMHomeSectionTypeMemory,
    EAPMHomeSectionTypeRemoteLog,
};

static NSString *EAPMSectionTitle(EAPMHomeSectionType sectionType) {
    switch (sectionType) {
        case EAPMHomeSectionTypeCrash:
            return @"崩溃分析";
        case EAPMHomeSectionTypePerformance:
            return @"性能分析";
        case EAPMHomeSectionTypeMemory:
            return @"内存分析";
        case EAPMHomeSectionTypeRemoteLog:
            return @"远程日志";
        default:
            return @"";
    }
}

@interface EAPMHeroHeaderCell : UICollectionViewCell

- (void)configureWithInfoText:(NSString *)text;

@end

@interface EAPMActionCardCell : UICollectionViewCell

- (void)configureWithItem:(EAPMHomeActionItem *)item;
- (void)setCardHighlighted:(BOOL)highlighted;

@end

@interface EAPMSectionHeaderReusableView : UICollectionReusableView

- (void)configureWithTitle:(NSString *)title;

@end

@interface EAPMHomeViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray<NSNumber *> *sections;
@property (nonatomic, strong) NSDictionary<NSNumber *, NSArray<EAPMHomeActionItem *> *> *sectionItems;
@property (nonatomic, copy) NSString *infoBannerText;
@property (nonatomic, strong) EAPMRemoteLog *remoteLogger;

@end

@implementation EAPMHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"";
    self.view.backgroundColor = [UIColor colorWithRed:0xF3 / 255.0 green:0xF4 / 255.0 blue:0xF8 / 255.0 alpha:1.0];
    self.remoteLogger = [[EAPMRemoteLog alloc] initWithModuleName:@"YourModuleName"];

    [self buildData];
    [self buildViews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)buildData {
    self.sections = @[
        @(EAPMHomeSectionTypeHero),
        @(EAPMHomeSectionTypeCrash),
        @(EAPMHomeSectionTypePerformance),
        @(EAPMHomeSectionTypeMemory),
        @(EAPMHomeSectionTypeRemoteLog),
    ];
    self.infoBannerText = @"触发相关事件，并在 EMAS 控制台 查看上报数据";

    self.sectionItems = @{
        @(EAPMHomeSectionTypeCrash): @[
            [EAPMHomeActionItem itemWithTitle:@"全堆栈Crash" actionType:EAPMHomeActionTypeFullStackCrash],
            [EAPMHomeActionItem itemWithTitle:@"Abort" actionType:EAPMHomeActionTypeAbort],
            [EAPMHomeActionItem itemWithTitle:@"触发卡顿" actionType:EAPMHomeActionTypeFreeze],
            [EAPMHomeActionItem itemWithTitle:@"自定义异常" actionType:EAPMHomeActionTypeCustomException],
        ],
        @(EAPMHomeSectionTypePerformance): @[
            [EAPMHomeActionItem itemWithTitle:@"测页面加载" actionType:EAPMHomeActionTypePageLoad],
            [EAPMHomeActionItem itemWithTitle:@"测页面滑动" actionType:EAPMHomeActionTypePageScroll],
            [EAPMHomeActionItem itemWithTitle:@"网络请求" actionType:EAPMHomeActionTypeNetworkRequest],
        ],
        @(EAPMHomeSectionTypeMemory): @[
            [EAPMHomeActionItem itemWithTitle:@"OOM" actionType:EAPMHomeActionTypePlaceholder],
            [EAPMHomeActionItem itemWithTitle:@"内存泄漏" actionType:EAPMHomeActionTypePlaceholder],
            [EAPMHomeActionItem itemWithTitle:@"大对象" actionType:EAPMHomeActionTypePlaceholder],
        ],
        @(EAPMHomeSectionTypeRemoteLog): @[
            [EAPMHomeActionItem itemWithTitle:@"日志回捞" actionType:EAPMHomeActionTypePlaceholder],
            [EAPMHomeActionItem itemWithTitle:@"主动上报" actionType:EAPMHomeActionTypeCreateLog],
        ],
    };
}

- (void)buildViews {
    EAPMGradientBackgroundView *backgroundView = [[EAPMGradientBackgroundView alloc] init];
    backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:backgroundView];

    UICollectionViewCompositionalLayout *layout = [[UICollectionViewCompositionalLayout alloc] initWithSectionProvider:^NSCollectionLayoutSection * _Nullable(NSInteger sectionIndex, id<NSCollectionLayoutEnvironment>  _Nonnull environment) {
        EAPMHomeSectionType sectionType = self.sections[sectionIndex].integerValue;
        if (sectionType == EAPMHomeSectionTypeHero) {
            NSCollectionLayoutSize *itemSize = [NSCollectionLayoutSize sizeWithWidthDimension:[NSCollectionLayoutDimension fractionalWidthDimension:1.0]
                                                                              heightDimension:[NSCollectionLayoutDimension absoluteDimension:316.0]];
            NSCollectionLayoutItem *item = [NSCollectionLayoutItem itemWithLayoutSize:itemSize];
            NSCollectionLayoutGroup *group = [NSCollectionLayoutGroup horizontalGroupWithLayoutSize:itemSize subitems:@[item]];
            NSCollectionLayoutSection *section = [NSCollectionLayoutSection sectionWithGroup:group];
            section.contentInsets = NSDirectionalEdgeInsetsMake(0.0, 0.0, 18.0, 0.0);
            return section;
        }

        NSCollectionLayoutSize *itemSize = [NSCollectionLayoutSize sizeWithWidthDimension:[NSCollectionLayoutDimension fractionalWidthDimension:0.5]
                                                                          heightDimension:[NSCollectionLayoutDimension absoluteDimension:48.0]];
        NSCollectionLayoutItem *item = [NSCollectionLayoutItem itemWithLayoutSize:itemSize];
        item.contentInsets = NSDirectionalEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);

        NSCollectionLayoutSize *groupSize = [NSCollectionLayoutSize sizeWithWidthDimension:[NSCollectionLayoutDimension fractionalWidthDimension:1.0]
                                                                           heightDimension:[NSCollectionLayoutDimension absoluteDimension:48.0]];
        NSCollectionLayoutGroup *group = [NSCollectionLayoutGroup horizontalGroupWithLayoutSize:groupSize subitem:item count:2];
        group.interItemSpacing = [NSCollectionLayoutSpacing fixedSpacing:6.0];

        NSCollectionLayoutSection *section = [NSCollectionLayoutSection sectionWithGroup:group];
        section.contentInsets = NSDirectionalEdgeInsetsMake(0.0, 16.0, 12.0, 16.0);
        section.interGroupSpacing = 6.0;

        NSCollectionLayoutBoundarySupplementaryItem *header = [NSCollectionLayoutBoundarySupplementaryItem boundarySupplementaryItemWithLayoutSize:[NSCollectionLayoutSize sizeWithWidthDimension:[NSCollectionLayoutDimension fractionalWidthDimension:1.0]
                                                                                                                                 heightDimension:[NSCollectionLayoutDimension absoluteDimension:28.0]]
                                                                                                                                      elementKind:UICollectionElementKindSectionHeader
                                                                                                                                           alignment:NSRectAlignmentTop];
        header.contentInsets = NSDirectionalEdgeInsetsMake(0.0, 0.0, 6.0, 0.0);
        section.boundarySupplementaryItems = @[header];

        return section;
    }];

    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    _collectionView.backgroundColor = UIColor.clearColor;
    _collectionView.alwaysBounceVertical = YES;
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    [_collectionView registerClass:[EAPMHeroHeaderCell class] forCellWithReuseIdentifier:EAPMHeroCellReuseIdentifier];
    [_collectionView registerClass:[EAPMActionCardCell class] forCellWithReuseIdentifier:EAPMActionCellReuseIdentifier];
    [_collectionView registerClass:[EAPMSectionHeaderReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:EAPMSectionHeaderReuseIdentifier];
    [self.view addSubview:_collectionView];

    [NSLayoutConstraint activateConstraints:@[
        [backgroundView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [backgroundView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [backgroundView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [backgroundView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],

        [_collectionView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [_collectionView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [_collectionView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [_collectionView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
    ]];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.sections.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    EAPMHomeSectionType sectionType = self.sections[section].integerValue;
    if (sectionType == EAPMHomeSectionTypeHero) {
        return 1;
    }
    return self.sectionItems[@(sectionType)].count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    EAPMHomeSectionType sectionType = self.sections[indexPath.section].integerValue;
    if (sectionType == EAPMHomeSectionTypeHero) {
        EAPMHeroHeaderCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:EAPMHeroCellReuseIdentifier forIndexPath:indexPath];
        [cell configureWithInfoText:self.infoBannerText];
        return cell;
    }

    EAPMActionCardCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:EAPMActionCellReuseIdentifier forIndexPath:indexPath];
    EAPMHomeActionItem *item = self.sectionItems[@(sectionType)][indexPath.item];
    [cell configureWithItem:item];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    EAPMSectionHeaderReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:EAPMSectionHeaderReuseIdentifier forIndexPath:indexPath];
    EAPMHomeSectionType sectionType = self.sections[indexPath.section].integerValue;
    [view configureWithTitle:EAPMSectionTitle(sectionType)];
    return view;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    if ([cell isKindOfClass:[EAPMActionCardCell class]]) {
        [(EAPMActionCardCell *)cell setCardHighlighted:YES];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    if ([cell isKindOfClass:[EAPMActionCardCell class]]) {
        [(EAPMActionCardCell *)cell setCardHighlighted:NO];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    EAPMHomeSectionType sectionType = self.sections[indexPath.section].integerValue;
    if (sectionType == EAPMHomeSectionTypeHero) {
        return;
    }

    EAPMHomeActionItem *item = self.sectionItems[@(sectionType)][indexPath.item];
    [self handleActionType:item.actionType];
}

#pragma mark - Actions

- (void)handleActionType:(EAPMHomeActionType)actionType {
    switch (actionType) {
        case EAPMHomeActionTypeFullStackCrash: {
            NSMutableArray *array = [NSMutableArray array];
            [array addObject:nil];
            break;
        }
        case EAPMHomeActionTypeAbort:
            abort();
            break;
        case EAPMHomeActionTypeFreeze:
            dispatch_async(dispatch_get_main_queue(), ^{
                [NSThread sleepForTimeInterval:30];
            });
            break;
        case EAPMHomeActionTypeCustomException: {
            [[EAPMCrashAnalysis crashAnalysis] setCustomValue:@"customValue" forKey:@"configCustomInfoWithKey"];
            NSError *error = [NSError errorWithDomain:@"customError" code:10001 userInfo:@{@"errorInfoKey": @"errorInfoValue"}];
            [[EAPMCrashAnalysis crashAnalysis] recordError:error];
            [self showAlertWithMessage:@"已记录自定义异常和自定义维度"];
            break;
        }
        case EAPMHomeActionTypePageLoad: {
            EAPMPerformanceLoadDemoViewController *viewController = [[EAPMPerformanceLoadDemoViewController alloc] init];
            [self.navigationController pushViewController:viewController animated:YES];
            break;
        }
        case EAPMHomeActionTypePageScroll: {
            EAPMPerformanceScrollDemoViewController *viewController = [[EAPMPerformanceScrollDemoViewController alloc] init];
            [self.navigationController pushViewController:viewController animated:YES];
            break;
        }
        case EAPMHomeActionTypeNetworkRequest:
            [self triggerNetworkRequests];
            break;
        case EAPMHomeActionTypeCreateLog:
            [self createRemoteLog];
            break;
        case EAPMHomeActionTypeUpdateNickname: {
            NSString *nickName = @"emas-update-nick";
            [[EAPMApm defaultApm] setUserNick:nickName];
            [self showAlertWithMessage:[NSString stringWithFormat:@"已更新昵称: %@", nickName]];
            break;
        }
        case EAPMHomeActionTypePlaceholder:
            [self showAlertWithMessage:@"功能建设中，暂未接入触发动作"];
            break;
    }
}

- (void)triggerNetworkRequests {
    NSString *urlString = @"https://www.baidu.com/";
    __block BOOL hasPresented = NO;
    for (NSInteger index = 0; index < 10; index++) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
            NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]
                                                                  delegate:nil
                                                             delegateQueue:[NSOperationQueue mainQueue]];
            NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                if (hasPresented) {
                    return;
                }
                hasPresented = YES;
                if (error) {
                    [self showAlertWithMessage:[NSString stringWithFormat:@"触发:%@，error:%@", urlString, error.localizedDescription]];
                } else {
                    [self showAlertWithMessage:[NSString stringWithFormat:@"触发:%@，success", urlString]];
                }
            }];
            [task resume];
        });
    }
}

- (void)createRemoteLog {
    [self.remoteLogger error:@"error message"];
    [self.remoteLogger warn:@"warn message"];
    [self.remoteLogger debug:@"debug message"];
    [self.remoteLogger info:@"info message"];
    [EAPMRemoteLog uploadTLog:@"主动上报bizComment"];
    [self showAlertWithMessage:@"已写入并主动上报远程日志"];
}

- (void)showAlertWithMessage:(NSString *)message {
    if (self.presentedViewController) {
        return;
    }

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

@end

@interface EAPMHeroHeaderCell ()

@property (nonatomic, strong) EAPMHeroHeaderView *heroHeaderView;

@end

@implementation EAPMHeroHeaderCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        _heroHeaderView = [[EAPMHeroHeaderView alloc] init];
        _heroHeaderView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_heroHeaderView];

        [NSLayoutConstraint activateConstraints:@[
            [_heroHeaderView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor],
            [_heroHeaderView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor],
            [_heroHeaderView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor],
            [_heroHeaderView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor],
        ]];
    }
    return self;
}

- (void)configureWithInfoText:(NSString *)text {
    [self.heroHeaderView configureWithInfoText:text];
}

@end

@interface EAPMActionCardCell ()

@property (nonatomic, strong) EAPMActionCardView *cardView;

@end

@implementation EAPMActionCardCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        _cardView = [[EAPMActionCardView alloc] init];
        _cardView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_cardView];

        [NSLayoutConstraint activateConstraints:@[
            [_cardView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor],
            [_cardView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor],
            [_cardView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor],
            [_cardView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor],
        ]];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.cardView setCardHighlighted:NO];
}

- (void)configureWithItem:(EAPMHomeActionItem *)item {
    [self.cardView configureWithTitle:item.title];
}

- (void)setCardHighlighted:(BOOL)highlighted {
    [self.cardView setCardHighlighted:highlighted];
}

@end

@interface EAPMSectionHeaderReusableView ()

@property (nonatomic, strong) EAPMSectionHeaderView *headerView;

@end

@implementation EAPMSectionHeaderReusableView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _headerView = [[EAPMSectionHeaderView alloc] init];
        _headerView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_headerView];

        [NSLayoutConstraint activateConstraints:@[
            [_headerView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
            [_headerView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
            [_headerView.topAnchor constraintEqualToAnchor:self.topAnchor],
            [_headerView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
        ]];
    }
    return self;
}

- (void)configureWithTitle:(NSString *)title {
    [self.headerView configureWithTitle:title];
}

@end
