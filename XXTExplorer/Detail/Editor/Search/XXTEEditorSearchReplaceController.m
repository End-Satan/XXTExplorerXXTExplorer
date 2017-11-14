//
//  XXTEEditorSearchReplaceController.m
//  XXTExplorer
//
//  Created by Zheng on 11/11/2017.
//  Copyright © 2017 Zheng. All rights reserved.
//

#import "XXTEEditorSearchReplaceController.h"
#import "XXTEEditorController.h"

@interface XXTEEditorSearchReplaceController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation XXTEEditorSearchReplaceController

- (instancetype)init {
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.title = NSLocalizedString(@"Replace", nil);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.layer.borderColor = [UIColor colorWithWhite:0.85 alpha:1.0].CGColor;
    self.view.layer.borderWidth = .5;
    
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.headerView];
    
    if (@available(iOS 11.0, *)) {
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.headerView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 144.0);
    self.tableView.frame = CGRectMake(0, 144.0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - 144.0);
}

#pragma mark - UIView Getters

- (UIView *)headerView {
    if (!_headerView) {
        UIView *headerView = [[UIView alloc] init];
        headerView.backgroundColor = [UIColor colorWithWhite:0.99 alpha:1.0];
        headerView.layer.borderColor = [UIColor colorWithWhite:0.85 alpha:1.0].CGColor;
        headerView.layer.borderWidth = .5;
        headerView.layer.shadowColor = [UIColor colorWithWhite:0.2 alpha:1.0].CGColor;
        headerView.layer.shadowRadius = 6.0;
        headerView.layer.shadowOpacity = 0.12;
        headerView.layer.shadowOffset = CGSizeMake(4.0, 4.0);
        _headerView = headerView;
    }
    return _headerView;
}

- (UITableView *)tableView {
    if (!_tableView) {
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.tableFooterView = [UIView new];
        _tableView = tableView;
    }
    return _tableView;
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return [UITableViewCell new];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 0;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

@end
