//
//  XXTExplorerViewController+Notification.h
//  XXTExplorer
//
//  Created by Zheng on 2017/8/6.
//  Copyright © 2017年 Zheng. All rights reserved.
//

#import "XXTExplorerViewController.h"

@interface XXTExplorerViewController (Notification)

- (void)registerNotifications;
- (void)removeNotifications;

- (void)scrollToCellEntryAtPath:(NSString *)entryPath;
- (void)selectCellEntryAtPath:(NSString *)entryPath;
- (void)selectCellEntriesAtPaths:(NSArray <NSString *> *)entryPaths;

@end
