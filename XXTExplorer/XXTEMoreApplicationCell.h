//
//  XXTEMoreApplicationCell.h
//  XXTPickerCollection
//
//  Created by Zheng on 03/05/2017.
//  Copyright © 2017 Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * const kXXTEMoreApplicationCellReuseIdentifier = @"kXXTEMoreApplicationCellReuseIdentifier";

@interface XXTEMoreApplicationCell : UITableViewCell

- (void)setApplicationName:(NSString *)name;

- (NSString *)applicationBundleID;
- (void)setApplicationBundleID:(NSString *)bundleID;

- (void)setApplicationIconImage:(UIImage *)image;

@end