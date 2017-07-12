//
//  XXTExplorerEntryReader.h
//  XXTExplorer
//
//  Created by Zheng on 12/07/2017.
//  Copyright © 2017 Zheng. All rights reserved.
//

#ifndef XXTExplorerEntryReader_h
#define XXTExplorerEntryReader_h

#import <UIKit/UIKit.h>

@protocol XXTExplorerEntryReader <NSObject>

@property (nonatomic, copy, readonly) NSString *entryPath;
@property (nonatomic, copy, readonly) NSArray <NSString *> *displayMetaKeys;
@property (nonatomic, copy, readonly) NSDictionary <NSString *, id> *metaDictionary;

+ (NSArray <NSString *> *)supportedExtensions;
- (instancetype)initWithPath:(NSString *)filePath;

@property (nonatomic, copy, readonly) NSString *entryName;
@property (nonatomic, copy, readonly) NSString *entryDisplayName;
@property (nonatomic, strong, readonly) UIImage *entryIconImage;


@end

#endif /* XXTExplorerEntryReader_h */
