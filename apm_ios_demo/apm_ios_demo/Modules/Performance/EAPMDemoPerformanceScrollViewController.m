#import "EAPMDemoPerformanceScrollViewController.h"

@interface EAPMDemoPerformanceScrollViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation EAPMDemoPerformanceScrollViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"页面分析";
    self.view.backgroundColor = [UIColor colorWithRed:0xF3 / 255.0 green:0xF4 / 255.0 blue:0xF8 / 255.0 alpha:1.0];

    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleInsetGrouped];
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.rowHeight = 72.0;
    _tableView.backgroundColor = UIColor.clearColor;
    [self.view addSubview:_tableView];

    [NSLayoutConstraint activateConstraints:@[
        [_tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [_tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [_tableView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [_tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
    ]];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 12;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [NSString stringWithFormat:@"滚动分组 %ld", (long)section + 1];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"scrollCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    cell.textLabel.text = [NSString stringWithFormat:@"列表项 %ld-%ld", (long)indexPath.section + 1, (long)indexPath.row + 1];
    cell.detailTextLabel.text = @"用于模拟长列表滚动和 tableView 滑动性能场景。";
    return cell;
}

@end
