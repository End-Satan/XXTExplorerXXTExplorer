//
//  XXTEUtils.mm
//  XXTExplorer
//
//  Created by Zheng on 30/01/2018.
//  Copyright © 2018 Zheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "XXTExplorerDefaults.h"

#import "UIView+XXTEToast.h"
#import "NSString+XQueryComponents.h"
#import "NSString+SHA1.h"
#import "XXTECloudApiSdk.h"

#import <pwd.h>
#import <spawn.h>
#import <sys/stat.h>
#import <time.h>

#import "XXTEAppDelegate.h"

#pragma mark - Defaults

const char **XXTESharedEnvp() {
    static const char *sharedEnvp[] = { "PATH=/bootstrap/usr/local/bin:/bootstrap/usr/sbin:/bootstrap/usr/bin:/bootstrap/sbin:/bootstrap/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/bin/X11:/usr/games:/usr/bin/1ferver", "HOME=/var/mobile", "USER=mobile", "LOGNAME=mobile", NULL };
    return sharedEnvp;
}

id uAppDefine(NSString *key) {
    return XXTEAppDelegate.appDefines[key];
}

id XXTEDefaultsObject(NSString *key, id defaultValue) {
    id value = [XXTEAppDelegate.userDefaults objectForKey:key];
    if (!value && defaultValue) {
        [XXTEAppDelegate.userDefaults setObject:defaultValue forKey:key];
        value = defaultValue;
    }
    return (value);
}

BOOL XXTEDefaultsBool(NSString *key, BOOL defaultValue) {
    id storedValue = XXTEDefaultsObject(key, @(defaultValue));
    if (![storedValue isKindOfClass:[NSNumber class]]) {
        return defaultValue;
    }
    return ([storedValue boolValue]);
}

NSUInteger XXTEDefaultsEnum(NSString *key, NSUInteger defaultValue) {
    id storedValue = XXTEDefaultsObject(key, @(defaultValue));
    if (![storedValue isKindOfClass:[NSNumber class]]) {
        return defaultValue;
    }
    return ([storedValue unsignedIntegerValue]);
}

double XXTEDefaultsDouble(NSString *key, double defaultValue) {
    id storedValue = XXTEDefaultsObject(key, @(defaultValue));
    if (![storedValue isKindOfClass:[NSNumber class]]) {
        return defaultValue;
    }
    return ([storedValue doubleValue]);
}

NSInteger XXTEDefaultsInt(NSString *key, int defaultValue) {
    id storedValue = XXTEDefaultsObject(key, @(defaultValue));
    if (![storedValue isKindOfClass:[NSNumber class]]) {
        return defaultValue;
    }
    return ([storedValue integerValue]);
}

id XXTEBuiltInDefaultsObject(NSString *key) {
    return (XXTEAppDelegate.builtInDefaults[key]);
}

BOOL XXTEBuiltInDefaultsObjectBool(NSString *key) {
    return ([XXTEBuiltInDefaultsObject(key) boolValue]);
}

NSUInteger XXTEBuiltInDefaultsObjectEnum(NSString *key) {
    return ([XXTEBuiltInDefaultsObject(key) unsignedIntegerValue]);
}

void XXTEDefaultsSetObject(NSString *key, id obj) {
    [XXTEAppDelegate.userDefaults setObject:obj forKey:key];
}

NSString *XXTERootPath() {
    return [XXTEAppDelegate sharedRootPath];
}

NSString *XXTStrippedPath(NSString *fullPath) {
    if ([fullPath hasPrefix:@"/private/var/"]) {  // 13
        return [fullPath stringByReplacingCharactersInRange:NSMakeRange(0, 13) withString:@"/var/"];
    }
    return fullPath;
}

NSString *XXTTiledPath(NSString *fullPath) {
    NSString *rootPath = XXTERootPath();
    NSRange rootRange = [fullPath rangeOfString:rootPath];
    if (rootRange.location == 0) {
        NSString *tiledPath = [fullPath stringByReplacingCharactersInRange:rootRange withString:@"~"];
        return tiledPath;
    }
    return fullPath;
}

#pragma mark - Permissions

const char *add1s_binary() {
    static NSString *add1s_binary = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        add1s_binary = uAppDefine(@"ADD1S_PATH");
    });
    return [add1s_binary fileSystemRepresentation];
}

const char *installer_binary() {
    static NSString *installer_binary = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        installer_binary = uAppDefine(@"INSTALLER_PATH");
    });
    return [installer_binary fileSystemRepresentation];
}

int promiseFixPermission(NSString *path, BOOL resursive) {
#ifdef APPSTORE
    return 0; // app store version, skipped
#else
    static NSString *realRootPath = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        const char *root_path = [[XXTEAppDelegate sharedRootPath] fileSystemRepresentation];
        char *resolved_root_path = realpath(root_path, NULL);
        if (resolved_root_path) {
            realRootPath = [[NSString alloc] initWithUTF8String:resolved_root_path];
            free(resolved_root_path);
        }
    });
    const char *original_path = [path fileSystemRepresentation];
    char *resolved_path = realpath(original_path, NULL);
    if (resolved_path)
    {
        NSString *resolvedPath = [[NSString alloc] initWithUTF8String:resolved_path];
        free(resolved_path);
        if (NO == [resolvedPath hasPrefix:realRootPath])
        {
            return -1; // not in root path, skipped
        }
    }
    struct stat entryStat;
    if (lstat(original_path, &entryStat) != 0) return -2;
    struct passwd pwent;
    struct passwd *pwentp;
    char buf[BUFSIZ];
    getpwuid_r(entryStat.st_uid, &pwent, buf, sizeof buf, &pwentp);
    if (pwentp != NULL) {
        if (pwent.pw_name) {
            NSString *pwName = [[NSString alloc] initWithUTF8String:pwent.pw_name];
            if ([pwName isEqualToString:@"mobile"]) {
                return 0; // already mobile owner, skipped
            }
        }
    }
    const char *binary = add1s_binary();
    BOOL fixEnabled = XXTEDefaultsBool(XXTExplorerFixFileOwnerAutomaticallyKey, YES);
    if (fixEnabled) {
        int status = 0;
        if (resursive)
        {
            pid_t pid = 0;
            const char* args[] = {binary, "chown", "-R", "mobile:mobile", original_path, NULL};
            posix_spawn(&pid, binary, NULL, NULL, (char* const*)args, (char* const*)XXTESharedEnvp());
            waitpid(pid, &status, 0);
        }
        else
        {
            pid_t pid = 0;
            const char* args[] = {binary, "chown", "mobile:mobile", original_path, NULL};
            posix_spawn(&pid, binary, NULL, NULL, (char* const*)args, (char* const*)XXTESharedEnvp());
            waitpid(pid, &status, 0);
        }
        if (WIFEXITED(status)) {
            status = WEXITSTATUS(status);
        }
        return status;
    }
    return 0;
#endif
}

#pragma mark - Networking

#ifndef APPSTORE
id (^convertJsonString)(id) =
^id (id obj) {
    if ([obj isKindOfClass:[NSString class]]) {
        NSString *jsonString = obj;
        NSError *serverError = nil;
        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:&serverError];
        if (serverError) {
            @throw [serverError localizedDescription];
        }
        return jsonDictionary;
    } else if ([obj isKindOfClass:[NSDictionary class]]) {
        NSDictionary *jsonDictionary = obj;
        return jsonDictionary;
    }
    return @{};
};
#endif

NSDateFormatter *RFC822DateFormatter() {
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"EEE',' dd MMM yyyy HH':'mm':'ss 'GMT'";
        formatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
        formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:XXTE_STANDARD_LOCALE];
    });
    return formatter;
}

#ifndef APPSTORE
id (^sendCloudApiRequest)(NSArray *objs) =
^(NSArray *objs) {
    NSString *commandUrl = objs[0];
    NSDictionary *sendDictionary = objs[1];
    NSMutableDictionary *sendMutableDictionary = [[NSMutableDictionary alloc] initWithDictionary:sendDictionary];
    NSString *signatureString = [[sendDictionary stringFromQueryComponents] sha1String];
    sendMutableDictionary[@"sign"] = signatureString;
    NSURL *sendUrl = [NSURL URLWithString:commandUrl];
    NSURLRequest *request = [XXTECloudApiSdk buildRequest:[NSString stringWithFormat:@"%@://", [sendUrl scheme]]
                                                   method:@"POST"
                                                     host:[sendUrl host]
                                                     path:[sendUrl path]
                                               pathParams:nil
                                              queryParams:nil
                                               formParams:[sendMutableDictionary copy]
                                                     body:nil
                                       requestContentType:@"application/x-www-form-urlencoded"
                                        acceptContentType:@"application/json"
                                             headerParams:nil];
    NSHTTPURLResponse *licenseResponse = nil;
    NSError *licenseError = nil;
    NSData *licenseReceived = [NSURLConnection sendSynchronousRequest:request returningResponse:&licenseResponse error:&licenseError];
    if (licenseError) {
        @throw [licenseError localizedDescription];
    }
    NSDictionary *returningHeadersDict = [licenseResponse allHeaderFields];
    {
        NSString *dateString = returningHeadersDict[@"Date"];
        NSDate *newDate = [RFC822DateFormatter() dateFromString:dateString];
        NSTimeInterval interval1 = [[NSDate date] timeIntervalSince1970];
        NSTimeInterval interval2 = [newDate timeIntervalSince1970];
        NSTimeInterval interval = interval1 - interval2;
        if (interval < 0) interval = 0.0 - interval;
        if (interval > 300) {
            @throw NSLocalizedString(@"Local time is not accurate.", nil);
        }
    }
    if (licenseResponse.statusCode != 200 &&
        returningHeadersDict[@"X-Ca-Error-Message"])
    {
        @throw [NSString stringWithFormat:NSLocalizedString(@"Aliyun gateway error: %@", nil), returningHeadersDict[@"X-Ca-Error-Message"]];
    }
    NSDictionary *licenseDictionary = [NSJSONSerialization JSONObjectWithData:licenseReceived options:0 error:&licenseError];
    if (licenseError) {
        @throw [licenseError localizedDescription];
    }
    return licenseDictionary;
};
#endif

#ifndef APPSTORE
NSString *uAppDaemonCommandUrl(NSString *command) {
    return ([uAppDefine(@"LOCAL_API") stringByAppendingString:command]);
}
#endif

#ifndef APPSTORE
NSString *uAppWebAccessUrl(NSString *path) {
    return ([uAppDefine(@"LOCAL_API") stringByAppendingFormat:@"download_file?filename=%@", [path stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]]);
}
#endif

#ifndef APPSTORE
NSString *uAppLicenseServerCommandUrl(NSString *command) {
    return ([uAppDefine(@"AUTH_API") stringByAppendingString:command]);
}
#endif

NSDictionary *uAppConstEnvp(void) {
    NSString *languageCode = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
    if (!languageCode) languageCode = @"en";
    NSString *versionString = uAppDefine(kXXTDaemonVersionKey);
    if (!versionString) versionString = @"";
    return @{ @"XXTOUCH_LAUNCH_VIA": @"APPLICATION", @"XXTOUCH_LANGUAGE": languageCode, @"XXTOUCH_VERSION": versionString };
}

#pragma mark - Interface

UIViewController *blockInteractionsWithToastAndDelay(UIViewController *viewController, BOOL shouldBlock, BOOL shouldToast, NSTimeInterval delay) {
    if (!viewController) return nil;
    NSMutableArray <UIViewController *> *viewControllerToBlock = [NSMutableArray array];
    NSMutableArray <UIView *> *viewToBlock = [NSMutableArray array];
    if (viewController.tabBarController.view) {
        [viewControllerToBlock addObject:viewController.tabBarController];
        [viewToBlock addObject:viewController.tabBarController.view];
    }
    if (viewController.navigationController.view) {
        [viewControllerToBlock addObject:viewController.navigationController];
        [viewToBlock addObject:viewController.navigationController.view];
    }
    if (viewController.view) {
        [viewControllerToBlock addObject:viewController];
        [viewToBlock addObject:viewController.view];
    }
    if (shouldBlock) {
        UIView *view = viewToBlock[0];
        view.userInteractionEnabled = NO;
        if (shouldToast)
        {
            if (delay > 0) {
                [view performSelector:@selector(makeToastActivity:) withObject:XXTEToastPositionCenter afterDelay:delay];
            } else {
                [view makeToastActivity:XXTEToastPositionCenter];
            }
        }
    } else {
        for (UIView *view in viewToBlock) {
            [UIView cancelPreviousPerformRequestsWithTarget:view selector:@selector(makeToastActivity:) object:XXTEToastPositionCenter];
            [view hideToastActivity];
            view.userInteractionEnabled = YES;
        }
    }
    return [viewControllerToBlock firstObject];
}

UIViewController *blockInteractionsWithToast(UIViewController *viewController, BOOL shouldBlock, BOOL shouldToast) {
    return blockInteractionsWithToastAndDelay(viewController, shouldBlock, shouldToast, 0);
}

UIViewController *blockInteractions(UIViewController *viewController, BOOL shouldBlock) {
    return blockInteractionsWithToast(viewController, shouldBlock, YES);
}

BOOL isiPhoneX() {
    static BOOL checkiPhoneX = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (@available(iOS 8.0, *)) {
            if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone && UIScreen.mainScreen.bounds.size.height > 800)  {
                checkiPhoneX = YES;
            }
        } else {
            // Fallback on earlier versions
        }
    });
    return checkiPhoneX;
}

void toastMessageWithDelay(UIViewController *viewController, NSString *message, NSTimeInterval duration) {
    if (viewController.navigationController) {
        [viewController.navigationController.view makeToast:message duration:duration position:XXTEToastPositionCenter];
    } else if (viewController.tabBarController) {
        [viewController.tabBarController.view makeToast:message duration:duration position:XXTEToastPositionCenter];
    } else {
        [viewController.view makeToast:message duration:duration position:XXTEToastPositionCenter];
    }
}

void toastMessage(UIViewController *viewController, NSString *message) {
    toastMessageWithDelay(viewController, message, 2.0);
}

void toastError(UIViewController *viewController, NSError *error) {
    toastMessageWithDelay(viewController, [error localizedDescription], 2.0);
}

NSString *XXTSchemeCloudProjectID(NSUInteger projectID) {
    return [NSString stringWithFormat:@"xxt://cloud/?project=%lu", (unsigned long)projectID];
}

UIColor *XXTColorFixed() { // rgb(52, 152, 219), #3498DB
    static UIColor *xxtColor = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        xxtColor = [UIColor colorWithRed:52.f/255.f green:152.f/255.f blue:219.f/255.f alpha:1.f];
    });
    return xxtColor;
}

UIColor *XXTColorPlainBackground() { // #FEFDFE/#131618
    static UIColor *xxtColor = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
        if (@available(iOS 13.0, *)) {
            xxtColor = [[UIColor alloc] initWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
                if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight) {
                    return [UIColor colorWithRed:0xFE/255.f green:0xFD/255.f blue:0xFE/255.f alpha:1.f];
                } else {
                    return [UIColor colorWithRed:0x13/255.f green:0x16/255.f blue:0x18/255.f alpha:1.f];
                }
            }];
        } else {
#endif
            xxtColor = [UIColor colorWithRed:0xFE/255.f green:0xFD/255.f blue:0xFE/255.f alpha:1.f];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
        }
#endif
    });
    return xxtColor;
}

UIColor *XXTColorGroupedBackground() { // #F6F5F6/#1D1F21
    static UIColor *xxtColor = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
        if (@available(iOS 13.0, *)) {
            xxtColor = [[UIColor alloc] initWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
                if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight) {
                    return [UIColor colorWithRed:0xF6/255.f green:0xF5/255.f blue:0xF6/255.f alpha:1.f];
                } else {
                    return [UIColor colorWithRed:0x1D/255.f green:0x1F/255.f blue:0x21/255.f alpha:1.f];
                }
            }];
        } else {
#endif
            xxtColor = [UIColor colorWithRed:0xF6/255.f green:0xF5/255.f blue:0xF6/255.f alpha:1.f];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
        }
#endif
    });
    return xxtColor;
}

UIColor *XXTColorPlainSectionHeader() { // #F8F8FA/#242B2E
    static UIColor *xxtColor = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        #if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
        if (@available(iOS 13.0, *)) {
            xxtColor = [[UIColor alloc] initWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
                if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight) {
                    return [UIColor colorWithRed:0xF8/255.f green:0xF8/255.f blue:0xFA/255.f alpha:1.f];
                } else {
                    return [UIColor colorWithRed:0x24/255.f green:0x2B/255.f blue:0x2E/255.f alpha:1.f];
                }
            }];
        } else {
#endif
            xxtColor = [UIColor colorWithRed:0xF8/255.f green:0xF8/255.f blue:0xFA/255.f alpha:1.f];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
        }
#endif
    });
    return xxtColor;
}

UIColor *XXTColorPlainSectionHeaderText() { // #4A4B4D/#D7D7D9
    static UIColor *xxtColor = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
        if (@available(iOS 13.0, *)) {
            xxtColor = [[UIColor alloc] initWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
                if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight) {
                    return [UIColor colorWithRed:0x4A/255.f green:0x4B/255.f blue:0x4D/255.f alpha:1.f];
                } else {
                    return [UIColor colorWithRed:0xD7/255.f green:0xD7/255.f blue:0xD9/255.f alpha:1.f];
                }
            }];
        } else {
#endif
            xxtColor = [UIColor colorWithRed:0x4A/255.f green:0x4B/255.f blue:0x4D/255.f alpha:1.f];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
        }
#endif
    });
    return xxtColor;
}

UIColor *XXTColorPlainTitleText() { // #323234/#CBCBCD
    static UIColor *xxtColor = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
        if (@available(iOS 13.0, *)) {
            xxtColor = [[UIColor alloc] initWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
                if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight) {
                    return [UIColor colorWithRed:0x32/255.f green:0x32/255.f blue:0x34/255.f alpha:1.f];
                } else {
                    return [UIColor colorWithRed:0xCB/255.f green:0xCB/255.f blue:0xCD/255.f alpha:1.f];
                }
            }];
        } else {
#endif
            xxtColor = [UIColor colorWithRed:0x32/255.f green:0x32/255.f blue:0x34/255.f alpha:1.f];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
        }
#endif
    });
    return xxtColor;
}

UIColor *XXTColorPlainSubtitleText() { // #7E7E80/#98989A
    static UIColor *xxtColor = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
        if (@available(iOS 13.0, *)) {
            xxtColor = [[UIColor alloc] initWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
                if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight) {
                    return [UIColor colorWithRed:0x7E/255.f green:0x7E/255.f blue:0x80/255.f alpha:1.f];
                } else {
                    return [UIColor colorWithRed:0x98/255.f green:0x98/255.f blue:0x9A/255.f alpha:1.f];
                }
            }];
        } else {
#endif
            xxtColor = [UIColor colorWithRed:0x7E/255.f green:0x7E/255.f blue:0x80/255.f alpha:1.f];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
        }
#endif
    });
    return xxtColor;
}

UIColor *XXTColorForeground() {  // fixed/#B5BD68
    static UIColor *xxtColorF = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
        if (@available(iOS 13.0, *)) {
            xxtColorF = [[UIColor alloc] initWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
                if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight) {
                    return XXTColorFixed();
                } else {
                    return [UIColor colorWithRed:0xB5/255.f green:0xBD/255.f blue:0x68/255.f alpha:1.f];
                }
            }];
        } else {
#endif
            xxtColorF = XXTColorFixed();
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
        }
#endif
    });
    return xxtColorF;
}

UIColor *XXTColorTint() {  // fixed/#DBDBDD
    static UIColor *xxtColorT = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
        if (@available(iOS 13.0, *)) {
            xxtColorT = [[UIColor alloc] initWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
                if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight) {
                    if (isAppStore()) {
                        return XXTColorFixed();
                    } else {
                        return [UIColor colorWithRed:0xDB/255.f green:0xDB/255.f blue:0xDD/255.f alpha:1.f];
                    }
                } else {
                    return [UIColor labelColor];
                }
            }];
        } else {
#endif
            if (isAppStore()) {
                xxtColorT = XXTColorFixed();
            } else {
                xxtColorT = [UIColor whiteColor];
            }
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
        }
#endif
    });
    return xxtColorT;
}

UIColor *XXTColorToolbarBarTint() {  // #F1F1F3/#1D1F21
    static UIColor *xxtColorBT = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
        if (@available(iOS 13.0, *)) {
            xxtColorBT = [[UIColor alloc] initWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
                if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight) {
                    return [UIColor colorWithRed:0xF1/255.0 green:0xF1/255.0 blue:0xF3/255.0 alpha:1.0];  // #F1F1F3
                } else {
                    return [UIColor colorWithRed:0x1D/255.0 green:0x1F/255.0 blue:0x21/255.0 alpha:1.0];
                }
            }];
        } else {
#endif
            xxtColorBT = [UIColor colorWithRed:0xF1/255.0 green:0xF1/255.0 blue:0xF3/255.0 alpha:1.0];  // #F1F1F3
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
        }
#endif
    });
    return xxtColorBT;
}

UIColor *XXTColorBarTint() { // #F1F1F3/#1D1F21
    static UIColor *xxtColorBT = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
        if (@available(iOS 13.0, *)) {
            xxtColorBT = [[UIColor alloc] initWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
                if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight) {
                    if (isAppStore()) {
                        return [UIColor colorWithRed:0xF1/255.0 green:0xF1/255.0 blue:0xF3/255.0 alpha:1.0];  // #F1F1F3
                    } else {
                        return XXTColorFixed();
                    }
                } else {
                    return [UIColor colorWithRed:0x1D/255.0 green:0x1F/255.0 blue:0x21/255.0 alpha:1.0];
                }
            }];
        } else {
#endif
            if (isAppStore()) {
                xxtColorBT = [UIColor colorWithRed:0xF1/255.0 green:0xF1/255.0 blue:0xF3/255.0 alpha:1.0];  // #F1F1F3
            } else {
                xxtColorBT = XXTColorFixed();
            }
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
        }
#endif
    });
    return xxtColorBT;
}

UIColor *XXTColorBarText() {  // #58585A/#C5C8C6
    static UIColor *xxtColorBT1 = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
        if (@available(iOS 13.0, *)) {
            xxtColorBT1 = [[UIColor alloc] initWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
                if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight) {
                    if (isAppStore()) {
                        return [UIColor colorWithRed:0x58/255.f green:0x58/255.f blue:0x5A/255.f alpha:1.0];  // #58585A
                    } else {
                        return [UIColor whiteColor];
                    }
                } else {
                    return [UIColor colorWithRed:0xC5/255.f green:0xC8/255.f blue:0xC6/255.f alpha:1.0];
                }
            }];
        } else {
#endif
            if (isAppStore()) {
                xxtColorBT1 = [UIColor colorWithRed:0x58/255.f green:0x58/255.f blue:0x5A/255.f alpha:1.0];  // #58585A
            } else {
                xxtColorBT1 = [UIColor whiteColor];
            }
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
        }
#endif
    });
    return xxtColorBT1;
}

UIColor *XXTColorCellSelected() { // rgba(52, 152, 219, 0.1)/#373b4190
    static UIColor *xxtColorCS = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
        if (@available(iOS 13.0, *)) {
            xxtColorCS = [[UIColor alloc] initWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
                if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight) {
                    return [UIColor colorWithRed:52.f/255.f green:152.f/255.f blue:219.f/255.f alpha:0.1];
                } else {
                    return [UIColor colorWithRed:0x37/255.f green:0x3b/255.f blue:0x41/255.f alpha:0.9];
                }
            }];
        } else {
#endif
            xxtColorCS = [UIColor colorWithRed:52.f/255.f green:152.f/255.f blue:219.f/255.f alpha:0.1];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
        }
#endif
    });
    return xxtColorCS;
}

UIColor *XXTColorSearchHighlight() {
    static UIColor *xxtColor = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
        if (@available(iOS 13.0, *)) {
            xxtColor = [[UIColor alloc] initWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
                if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight) {
                    return [UIColor colorWithRed:253.0/255.0 green:247.0/255.0 blue:148.0/255.0 alpha:1.0];
                } else {
                    return [UIColor colorWithRed:62.0/255.f green:100.0/255.0 blue:25.0/255.0 alpha:1.0];
                }
            }];
        } else {
#endif
            xxtColor = [UIColor colorWithRed:253.0/255.0 green:247.0/255.0 blue:148.0/255.0 alpha:1.0];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
        }
#endif
    });
    return xxtColor;
}

UIColor *XXTColorWarning() { // rgb(241, 196, 15)
    static UIColor *xxtWarningColor = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        xxtWarningColor = [UIColor colorWithRed:241.0/255.0 green:196.0/255.0 blue:15.0/255.0 alpha:1.f];
    });
    return xxtWarningColor;
}

UIColor *XXTColorDanger() { // rgb(231, 76, 60)
    static UIColor *xxtDangerColor = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        xxtDangerColor = [UIColor colorWithRed:231.f/255.f green:76.f/255.f blue:60.f/255.f alpha:1.f];
    });
    return xxtDangerColor;
}

UIColor *XXTColorSuccess() { // rgb(26, 188, 134)
    static UIColor *xxtSuccessColor = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        xxtSuccessColor = [UIColor colorWithRed:26.f/255.f green:188.f/255.f blue:134.f/255.f alpha:1.f];
    });
    return xxtSuccessColor;
}

BOOL isOS13Above() {
    if (@available(iOS 13.0, *)) {
        return YES;
    }
    return NO;
}

BOOL isOS12Above() {
    if (@available(iOS 12.0, *)) {
        return YES;
    }
    return NO;
}

BOOL isOS11Above() {
    if (@available(iOS 11.0, *)) {
        return YES;
    }
    return NO;
}

BOOL isOS10Above() {
    if (@available(iOS 10.0, *)) {
        return YES;
    }
    return NO;
}

BOOL isOS9Above() {
    if (@available(iOS 9.0, *)) {
        return YES;
    }
    return NO;
}

BOOL isOS8Above() {
    if (@available(iOS 8.0, *)) {
        return YES;
    }
    return NO;
}

BOOL isAppStore() {
#ifdef APPSTORE
    return YES;
#else
    return NO;
#endif
}

NSString *uAppUserAgent() {
    return [NSString stringWithFormat:@"XXTExplorer/%@", [uAppDefine(kXXTDaemonVersionKey) stringByReplacingOccurrencesOfString:@"-" withString:@"."]];
}

#ifndef APPSTORE
BOOL SBSOpenSensitiveURLAndUnlock(NSURL *url, BOOL flags);
#endif

#if (TARGET_OS_SIMULATOR)
BOOL SBSOpenSensitiveURLAndUnlock(NSURL *url, BOOL flags) {
    return YES;
}
#endif

BOOL uOpenURL(NSURL *url) {
#ifndef APPSTORE
    BOOL canOpenURL = SBSOpenSensitiveURLAndUnlock(url, YES);
#else
    BOOL canOpenURL = [[UIApplication sharedApplication] canOpenURL:url];
    if (canOpenURL) {
        [[UIApplication sharedApplication] openURL:url];
    }
#endif
    return canOpenURL;
}
