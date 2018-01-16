//
//  RMCloudProjectViewController.m
//  XXTExplorer
//
//  Created by Zheng on 13/01/2018.
//  Copyright © 2018 Zheng. All rights reserved.
//

#import "RMCloudProjectViewController.h"
#import "RMCloudProjectDetailCell.h"
#import "RMCloudProjectDescriptionCell.h"
#import "RMProject.h"
#import "RMCloudLoadingView.h"

#import "XXTEUserInterfaceDefines.h"
#import "RMCloudExpandableCell.h"
#import "RMCloudExpandedCell.h"
#import "RMCloudLinkCell.h"

#import "XXTENotificationCenterDefines.h"
#import "XXTExplorerViewController+SharedInstance.h"

typedef enum : NSUInteger {
    RMCloudDetailSectionHeader = 0,
    RMCloudDetailSectionDescription,
    RMCloudDetailSectionInformation,
    RMCloudDetailSectionMax
} RMCloudDetailSection;

typedef enum : NSUInteger {
    RMCloudInformationRowAuthor = 0,
    RMCloudInformationRowVersion,
    RMCloudInformationRowDownloadTimes,
    RMCloudInformationRowTrail,
    RMCloudInformationRowContact,
    RMCloudInformationRowBuy,
    RMCloudInformationRowMax
} RMCloudInformationRow;

@interface RMCloudProjectViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) RMCloudProjectDetailCell *headerCell;
@property (nonatomic, strong) RMCloudProjectDescriptionCell *descriptionCell;

@property (nonatomic, strong) RMProject *project;
@property (nonatomic, strong) RMCloudLoadingView *pawAnimation;

@property (nonatomic, assign) BOOL authorNameExpanded;
@property (nonatomic, assign) BOOL projectVersionExpanded;
@property (nonatomic, assign) BOOL downloadTimesExpanded;
@property (nonatomic, assign) BOOL trailTypeExpanded;
@property (nonatomic, assign) BOOL contactStringExpanded;

@end

@implementation RMCloudProjectViewController

- (instancetype)initWithProjectID:(NSUInteger)projectID {
    if (self = [super init]) {
        _projectID = projectID;
        [self setup];
    }
    return self;
}

- (void)setup {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([RMCloudProjectDetailCell class]) bundle:[NSBundle mainBundle]] forCellReuseIdentifier:RMCloudProjectDetailCellReuseIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([RMCloudProjectDescriptionCell class]) bundle:[NSBundle mainBundle]] forCellReuseIdentifier:RMCloudProjectDescriptionCellReuseIdentifier];
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([RMCloudExpandableCell class]) bundle:[NSBundle mainBundle]] forCellReuseIdentifier:RMCloudExpandableCellReuseIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([RMCloudExpandedCell class]) bundle:[NSBundle mainBundle]] forCellReuseIdentifier:RMCloudExpandedCellReuseIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([RMCloudLinkCell class]) bundle:[NSBundle mainBundle]] forCellReuseIdentifier:RMCloudLinkCellReuseIdentifier];
    
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.pawAnimation];
    
    [self loadProjectDetail];
}

XXTE_START_IGNORE_PARTIAL
- (void)viewSafeAreaInsetsDidChange {
    [super viewSafeAreaInsetsDidChange];
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInset =
        self.tableView.scrollIndicatorInsets =
        self.view.safeAreaInsets;
    }
}
XXTE_END_IGNORE_PARTIAL

#pragma mark - Request

- (void)loadProjectDetail {
    [RMProject projectWithID:self.projectID]
    .then(^ (RMProject *model) {
        self.project = model;
        [self.tableView reloadData];
    })
    .catch(^ (NSError *error) {
        toastMessage(self, error.localizedDescription);
    })
    .finally(^ () {
        self.pawAnimation.hidden = YES;
    });
}

#pragma mark - UIView Getters

- (UITableView *)tableView {
    if (!_tableView) {
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.backgroundColor = [UIColor whiteColor];
        tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        tableView.delegate = self;
        tableView.dataSource = self;
        XXTE_START_IGNORE_PARTIAL
        if (@available(iOS 9.0, *)) {
            tableView.cellLayoutMarginsFollowReadableWidth = NO;
        }
        if (@available(iOS 11.0, *)) {
            tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        XXTE_END_IGNORE_PARTIAL
        _tableView = tableView;
    }
    return _tableView;
}

- (RMCloudLoadingView *)pawAnimation {
    if (!_pawAnimation) {
        RMCloudLoadingView *pawAnimation = [[RMCloudLoadingView alloc] initWithFrame:CGRectMake(0, 0, 41.0, 45.0)];
        pawAnimation.center = CGPointMake(CGRectGetWidth(self.view.bounds) / 2.0, CGRectGetHeight(self.view.bounds) / 2.0);
        pawAnimation.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        _pawAnimation = pawAnimation;
    }
    return _pawAnimation;
}

- (RMCloudProjectDetailCell *)headerCell {
    if (!_headerCell) {
        RMCloudProjectDetailCell *cell = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([RMCloudProjectDetailCell class]) owner:nil options:nil] lastObject];
        RMProject *project = self.project;
        if (project) {
            [cell setProject:project];
        }
        [cell.downloadButton addTarget:self action:@selector(downloadButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        _headerCell = cell;
    }
    return _headerCell;
}

- (RMCloudProjectDescriptionCell *)descriptionCell {
    if (!_descriptionCell) {
        RMCloudProjectDescriptionCell *cell = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([RMCloudProjectDescriptionCell class]) owner:nil options:nil] lastObject];
        RMProject *project = self.project;
        if (project) {
            [cell setProject:project];
        }
        _descriptionCell = cell;
    }
    return _descriptionCell;
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return RMCloudDetailSectionMax;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.project) {
        if (section == RMCloudDetailSectionHeader) {
            return 1;
        } else if (section == RMCloudDetailSectionDescription) {
            return 1;
        } else if (section == RMCloudDetailSectionInformation) {
            return RMCloudInformationRowMax;
        }
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (@available(iOS 8.0, *)) {
        return 44.f;
    } else {
        return [self tableView:tableView heightForRowAtIndexPath:indexPath];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.tableView) {
        if (indexPath.section == RMCloudDetailSectionHeader || indexPath.section == RMCloudDetailSectionDescription || indexPath.section == RMCloudDetailSectionInformation)
        {
            if (@available(iOS 8.0, *)) {
                return UITableViewAutomaticDimension;
            }
            else {
                if (indexPath.section == RMCloudDetailSectionHeader) {
                    return [self tableView:tableView heightForAutoResizingCell:self.headerCell];
                } else if (indexPath.section == RMCloudDetailSectionDescription) {
                    return [self tableView:tableView heightForAutoResizingCell:self.descriptionCell];
                } else {
                    return UITableViewAutomaticDimension;
                }
            }
        }
    }
    return 0;
}

// work around for iOS 7
- (CGFloat)tableView:(UITableView *)tableView heightForAutoResizingCell:(UITableViewCell *)cell {
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
    cell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(tableView.bounds), CGRectGetHeight(cell.bounds));
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    
    // UITextViews cannot autosize well with systemLayoutSizeFittingSize: on iOS 7...
    BOOL textViewInside = NO;
    CGFloat additionalUITextViewsHeight = 0.f;
    UIEdgeInsets textViewContainerInsets = UIEdgeInsetsZero;
    for (UIView *subview in cell.contentView.subviews) {
        if ([subview isKindOfClass:[UITextView class]]) {
            textViewInside = YES;
            UITextView *subTextView = (UITextView *)subview;
            CGSize textViewSize = [subTextView sizeThatFits:CGSizeMake(CGRectGetWidth(subTextView.bounds), CGFLOAT_MAX)];
            textViewContainerInsets = subTextView.textContainerInset;
            additionalUITextViewsHeight = textViewSize.height;
            break;
        }
    }
    
    if (textViewInside) {
        return
        additionalUITextViewsHeight +
        textViewContainerInsets.top +
        textViewContainerInsets.bottom +
        1.f;
    }
    
    CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    CGFloat fixedHeight = (height > 0) ? (height + 1.f) : 44.f;
    return fixedHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == RMCloudDetailSectionHeader) {
        return self.headerCell;
    } else if (indexPath.section == RMCloudDetailSectionDescription) {
        return self.descriptionCell;
    } else if (indexPath.section == RMCloudDetailSectionInformation) {
        RMProject *project = self.project;
        if (project) {
            if (indexPath.row == RMCloudInformationRowAuthor ||
                indexPath.row == RMCloudInformationRowVersion ||
                indexPath.row == RMCloudInformationRowDownloadTimes ||
                indexPath.row == RMCloudInformationRowTrail ||
                indexPath.row == RMCloudInformationRowContact) {
                UITableViewCell <RMCloudExpandable> *cell = nil;
                if (indexPath.row == RMCloudInformationRowAuthor)
                {
                    cell = [self tableView:tableView cellForExpandedState:self.authorNameExpanded];
                    cell.titleTextLabel.text = NSLocalizedString(@"Author", nil);
                    NSString *authorName = self.project.authorName;
                    if (authorName.length) {
                        cell.valueTextLabel.text = authorName;
                    }
                }
                else if (indexPath.row == RMCloudInformationRowVersion)
                {
                    cell = [self tableView:tableView cellForExpandedState:self.projectVersionExpanded];
                    cell.titleTextLabel.text = NSLocalizedString(@"Version", nil);
                    cell.valueTextLabel.text = [NSString stringWithFormat:@"v%.2f", project.projectVersion];
                }
                else if (indexPath.row == RMCloudInformationRowDownloadTimes)
                {
                    cell = [self tableView:tableView cellForExpandedState:self.downloadTimesExpanded];
                    cell.titleTextLabel.text = NSLocalizedString(@"Download Times", nil);
                    cell.valueTextLabel.text = [NSString stringWithFormat:@"%lu", project.downloadTimes];
                }
                else if (indexPath.row == RMCloudInformationRowTrail)
                {
                    cell = [self tableView:tableView cellForExpandedState:self.trailTypeExpanded];
                    cell.titleTextLabel.text = NSLocalizedString(@"Trail", nil);
                    NSString *trailString = [self.project localizedTrailDescription];
                    if (trailString.length) {
                        cell.valueTextLabel.text = trailString;
                    }
                }
                else if (indexPath.row == RMCloudInformationRowContact)
                {
                    cell = [self tableView:tableView cellForExpandedState:self.contactStringExpanded];
                    cell.titleTextLabel.text = NSLocalizedString(@"Contact", nil);
                    NSString *contactString = self.project.contactString;
                    if (contactString.length) {
                        cell.valueTextLabel.text = contactString;
                    }
                }
                if (indexPath.row == 0) {
                    cell.topSepatator.hidden = YES;
                } else {
                    cell.topSepatator.hidden = NO;
                }
                cell.bottomSepatator.hidden = NO;
                return cell;
            }
            else if (indexPath.row == RMCloudInformationRowBuy) {
                RMCloudLinkCell *cell = [tableView dequeueReusableCellWithIdentifier:RMCloudLinkCellReuseIdentifier];
                if (cell == nil) {
                    cell = [[RMCloudLinkCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:RMCloudLinkCellReuseIdentifier];
                }
                if (indexPath.row == RMCloudInformationRowBuy) {
                    cell.titleTextLabel.text = NSLocalizedString(@"Purchase Now", nil);
                    cell.linkIconImageView.image = [[UIImage imageNamed:@"RMCloudLinkPurchase"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                }
                cell.bottomSepatator.hidden = YES;
                return cell;
            }
        }
    }
    return [UITableViewCell new];
}

- (UITableViewCell <RMCloudExpandable> *)tableView:(UITableView *)tableView cellForExpandedState:(BOOL)expanded {
    UITableViewCell <RMCloudExpandable> *cell = nil;
    if (expanded) {
        cell = [tableView dequeueReusableCellWithIdentifier:RMCloudExpandedCellReuseIdentifier];
        if (cell == nil) {
            cell = [[RMCloudExpandedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:RMCloudExpandedCellReuseIdentifier];
        }
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:RMCloudExpandableCellReuseIdentifier];
        if (cell == nil) {
            cell = [[RMCloudExpandableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:RMCloudExpandableCellReuseIdentifier];
        }
    }
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == RMCloudDetailSectionHeader) {
        return nil;
    }
    return [UITableViewHeaderFooterView new];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UITableViewHeaderFooterView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == RMCloudDetailSectionHeader) {
        return CGFLOAT_MIN;
    }
    return 32.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == RMCloudDetailSectionHeader) {
        return 16.f;
    } else if (section == RMCloudDetailSectionInformation) {
        return 48.f;
    }
    return 16.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView == self.tableView) {
        if (indexPath.section == RMCloudDetailSectionInformation) {
            BOOL shouldExpand = NO;
            if (indexPath.row == RMCloudInformationRowAuthor) {
                if (NO == self.authorNameExpanded) {
                    shouldExpand = YES;
                }
                self.authorNameExpanded = YES;
            }
            else if (indexPath.row == RMCloudInformationRowVersion) {
                if (NO == self.projectVersionExpanded) {
                    shouldExpand = YES;
                }
                self.projectVersionExpanded = YES;
            }
            else if (indexPath.row == RMCloudInformationRowDownloadTimes) {
                if (NO == self.downloadTimesExpanded) {
                    shouldExpand = YES;
                }
                self.downloadTimesExpanded = YES;
            }
            else if (indexPath.row == RMCloudInformationRowTrail) {
                if (NO == self.trailTypeExpanded) {
                    shouldExpand = YES;
                }
                self.trailTypeExpanded = YES;
            }
            else if (indexPath.row == RMCloudInformationRowContact) {
                if (NO == self.contactStringExpanded) {
                    shouldExpand = YES;
                }
                self.contactStringExpanded = YES;
            }
            if (shouldExpand) {
                [self.tableView reloadData];
            } else {
                if (indexPath.row == RMCloudInformationRowAuthor ||
                    indexPath.row == RMCloudInformationRowVersion ||
                    indexPath.row == RMCloudInformationRowDownloadTimes ||
                    indexPath.row == RMCloudInformationRowTrail ||
                    indexPath.row == RMCloudInformationRowContact) {
                    UITableViewCell <RMCloudExpandable> *cell = [tableView cellForRowAtIndexPath:indexPath];
                    NSString *titleText = cell.titleTextLabel.text;
                    NSString *detailText = cell.valueTextLabel.text;
                    if (titleText && titleText.length > 0 &&
                        detailText && detailText.length > 0) {
                        @weakify(self);
                        void (^copyBlock)(NSString *) = ^(NSString *textToCopy) {
                            @strongify(self);
                            UIViewController *blockVC = blockInteractionsWithDelay(self, YES, 2.0);
                            [PMKPromise new:^(PMKFulfiller fulfill, PMKRejecter reject) {
                                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                                    [[UIPasteboard generalPasteboard] setString:textToCopy];
                                    fulfill(nil);
                                });
                            }].finally(^() {
                                toastMessage(self, NSLocalizedString(@"Copied to the pasteboard.", nil));
                                blockInteractions(blockVC, NO);
                            });
                        };
                        copyBlock(detailText);
                    }
                }
            }
        }
    }
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    header.textLabel.font = [UIFont boldSystemFontOfSize:20.0];
    header.textLabel.textColor = [UIColor blackColor];
    UIView *bgView = [[UIView alloc] init];
    header.backgroundView = bgView;
    bgView.backgroundColor = [UIColor clearColor];
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(nonnull UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *footer = (UITableViewHeaderFooterView *)view;
    footer.textLabel.font = [UIFont systemFontOfSize:12.0];
    footer.textLabel.textColor = [UIColor lightGrayColor];
    UIView *bgView = [[UIView alloc] init];
    footer.backgroundView = bgView;
    bgView.backgroundColor = [UIColor clearColor];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.project) {
        if (tableView == self.tableView) {
            if (section == RMCloudDetailSectionDescription) {
                return NSLocalizedString(@"Item Detail", nil);
            }
            else if (section == RMCloudDetailSectionInformation) {
                return NSLocalizedString(@"Information", nil);
            }
        }
    }
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (self.project) {
        if (tableView == self.tableView) {
            if (section == RMCloudDetailSectionInformation) {
                return NSLocalizedString(@"The information on this page is provided by RuanMao Cloud.", nil);
            }
        }
    }
    return nil;
}

#pragma mark - Action

- (void)downloadButtonTapped:(UIButton *)sender {
    RMProject *project = self.project;
    if (!project) {
        return;
    }
    UIViewController *blockController = blockInteractions(self, YES);
    [project downloadURL]
    .then(^(NSString *downloadURL) {
        if (downloadURL) {
            NSURL *sourceURL = [NSURL URLWithString:downloadURL];
            NSString *scheme = sourceURL.scheme;
            if ([scheme isEqualToString:@"http"] || [scheme isEqualToString:@"https"])
            {
                NSDictionary *internalArgs =
                @{
                  @"url": downloadURL,
                  };
                NSDictionary *userInfo =
                @{XXTENotificationShortcutInterface: @"download",
                  XXTENotificationShortcutUserData: internalArgs};
                [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:XXTENotificationShortcut object:nil userInfo:userInfo]];
            }
        }
    })
    .catch(^ (NSError *error) {
        toastMessage(self, error.localizedDescription);
    })
    .finally(^() {
        blockInteractions(blockController, NO);
    });
}

#pragma mark - Memory

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"- [RMCloudProjectViewController dealloc]");
#endif
}

@end