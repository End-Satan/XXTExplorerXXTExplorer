//
//  XXTEAgreementViewController.m
//  XXTExplorer
//
//  Created by Zheng on 2018/5/31.
//  Copyright © 2018 Zheng. All rights reserved.
//

#import "XXTEAgreementViewController.h"
#import "XXTEAppDelegate.h"

#import <LGAlertView/LGAlertView.h>

@interface XXTEAgreementViewController ()

@property (nonatomic, strong) UIBarButtonItem *quitItem;
@property (nonatomic, strong) UIBarButtonItem *agreeItem;

@end

@implementation XXTEAgreementViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = self.quitItem;
    self.navigationItem.rightBarButtonItem = self.agreeItem;
}

#pragma mark - Getter

- (UIBarButtonItem *)quitItem {
    if (!_quitItem) {
        _quitItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Quit", nil) style:UIBarButtonItemStylePlain target:self action:@selector(quitItemTapped:)];
    }
    return _quitItem;
}

- (UIBarButtonItem *)agreeItem {
    if (!_agreeItem) {
        _agreeItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Agree", nil) style:UIBarButtonItemStyleDone target:self action:@selector(agreeItemTapped:)];
    }
    return _agreeItem;
}

#pragma mark - Actions

- (void)quitItemTapped:(UIBarButtonItem *)sender {
    LGAlertView *alertView = [[LGAlertView alloc] initWithTitle:NSLocalizedString(@"Quit Confirm", nil) message:NSLocalizedString(@"Do you want to quit XXTouch? \nIf you do not agree to our terms of service, you cannot continue using our application.", nil) style:LGAlertViewStyleAlert buttonTitles:nil cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:NSLocalizedString(@"Quit Now", nil) actionHandler:nil cancelHandler:^(LGAlertView * _Nonnull alertView) {
        [alertView dismissAnimated];
    } destructiveHandler:^(LGAlertView * _Nonnull alertView) {
        [alertView dismissAnimated];
        [self ExitImmediately];
    }];
    [alertView showAnimated];
}

- (void)ExitImmediately {
    exit(0);
}

- (void)agreeItemTapped:(UIBarButtonItem *)sender {
    LGAlertView *alertView = [[LGAlertView alloc] initWithTitle:NSLocalizedString(@"Confirm", nil) message:NSLocalizedString(@"I Agree To Terms Of Service (XXTouch).", nil) style:LGAlertViewStyleAlert buttonTitles:@[ NSLocalizedString(@"I Agree", nil) ] cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil actionHandler:^(LGAlertView * _Nonnull alertView, NSUInteger index, NSString * _Nullable title) {
        [alertView dismissAnimated];
        [self AgreeImmediately];
    } cancelHandler:^(LGAlertView * _Nonnull alertView) {
        [alertView dismissAnimated];
    } destructiveHandler:nil];
    [alertView showAnimated];
}

- (void)AgreeImmediately {
    XXTEAppDelegate *delegate = (XXTEAppDelegate *)[UIApplication sharedApplication].delegate;
    if (![delegate isKindOfClass:[XXTEAppDelegate class]]) {
        return;
    }
    [delegate reloadWorkspace];
}

#pragma mark - Style

- (NSString *)title {
    return NSLocalizedString(@"Terms Of Service (XXTouch)", nil);
}

- (UIColor *)preferredNavigationBarColor {
    return XXTColorDefault();
}

- (UIColor *)preferredNavigationBarTintColor {
    return [UIColor whiteColor];
}

#pragma mark - Memory

- (void)dealloc {
    
}

@end