//
//  XXTEArrayObjectViewController.m
//  XXTExplorer
//
//  Created by Zheng on 01/08/2017.
//  Copyright © 2017 Zheng. All rights reserved.
//

#import "XXTEArrayObjectViewController.h"
#import "XXTEMoreTitleValueCell.h"
#import "XXTEObjectViewController.h"
#import "NSObject+XUIStringValue.h"
#import "XXTEBaseObjectViewController.h"
#import <PromiseKit/PromiseKit.h>

@interface XXTEArrayObjectViewController ()

@end

@implementation XXTEArrayObjectViewController {
    NSArray <Class> *supportedTypes;
}

@synthesize RootObject = _RootObject;

+ (NSArray <Class> *)supportedTypes {
    return @[ [NSArray class] ];
}

- (instancetype)initWithRootObject:(id)RootObject {
    if (self = [super init]) {
        _RootObject = RootObject;
        supportedTypes = [XXTEBaseObjectViewController supportedTypes];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([XXTEMoreTitleValueCell class]) bundle:[NSBundle mainBundle]] forCellReuseIdentifier:XXTEMoreTitleValueCellReuseIdentifier];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (0 == section) {
        return ((NSArray *)self.RootObject).count;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0)
    {
        XXTEMoreTitleValueCell *cell =
        [tableView dequeueReusableCellWithIdentifier:XXTEMoreTitleValueCellReuseIdentifier];
        if (nil == cell)
        {
            cell = [[XXTEMoreTitleValueCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                 reuseIdentifier:XXTEMoreTitleValueCellReuseIdentifier];
        }
        [self configureCell:cell forRowAtIndexPath:indexPath];
        return cell;
    }
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}

- (void)configureCell:(XXTEMoreTitleValueCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.tintColor = XXTColorForeground();
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    cell.titleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Item %lu", nil), indexPath.row];
    id elementValue = ((NSArray *)self.RootObject)[indexPath.row];
    Class elementClass = [elementValue class];
    BOOL supported = NO;
    for (Class supportedType in supportedTypes) {
        if ([elementClass isSubclassOfClass:supportedType]) {
            supported = YES;
            break;
        }
    }
    if (supported)
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.valueLabel.textColor = [UIColor secondaryLabelColor];
        cell.valueLabel.text = [elementValue xui_stringValue];
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        if (self.containerDisplayMode == XXTEObjectContainerDisplayModeNone) {
            cell.valueLabel.text = @"";
        } else if (self.containerDisplayMode == XXTEObjectContainerDisplayModeCount) {
            if ([elementValue respondsToSelector:@selector(count)]) {
                NSUInteger childCount = [elementValue count];
                cell.valueLabel.textColor = XXTColorForeground();
                cell.valueLabel.text = [NSString stringWithFormat:@"(%@)", [@(childCount) stringValue]];
            }
        } else if (self.containerDisplayMode == XXTEObjectContainerDisplayModeDescription) {
            cell.valueLabel.text = [[[elementValue description] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsJoinedByString:@""];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView == self.tableView) {
        if (0 == indexPath.section) {
            id elementValue = ((NSArray *)self.RootObject)[indexPath.row];
            Class elementClass = [elementValue class];
            BOOL supported = NO;
            for (Class supportedType in supportedTypes) {
                if ([elementClass isSubclassOfClass:supportedType]) {
                    supported = YES;
                    break;
                }
            }
            XXTEMoreTitleValueCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            if (supported)
            {
                NSString *detailText = cell.valueLabel.text;
                if (detailText && detailText.length > 0) {
                    UIViewController *blockVC = blockInteractionsWithToastAndDelay(self, YES, YES, 1.0);
                    [PMKPromise new:^(PMKFulfiller fulfill, PMKRejecter reject) {
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                            [[UIPasteboard generalPasteboard] setString:detailText];
                            fulfill(nil);
                        });
                    }].finally(^() {
                        toastMessage(self, NSLocalizedString(@"Copied to the pasteboard.", nil));
                        blockInteractions(blockVC, NO);
                    });
                }
            }
            else
            {
                XXTEObjectViewController *objectViewController = [[XXTEObjectViewController alloc] initWithRootObject:elementValue];
                objectViewController.title = cell.titleLabel.text;
                objectViewController.entryBundle = self.entryBundle;
                objectViewController.tableViewStyle = self.tableViewStyle;
                objectViewController.containerDisplayMode = self.containerDisplayMode;
                [self.navigationController pushViewController:objectViewController animated:YES];
            }
        }
    }
}

@end
