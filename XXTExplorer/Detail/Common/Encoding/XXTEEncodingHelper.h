//
//  XXTEEncodingHelper.h
//  XXTExplorer
//
//  Created by Darwin on 8/2/19.
//  Copyright © 2019 Zheng. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface XXTEEncodingHelper : NSObject
+ (NSString *)encodingNameForEncoding:(CFStringEncoding)encoding;
+ (CFStringEncoding)encodingForEncodingName:(NSString *)encodingName;
+ (NSArray <NSNumber *> *)encodings;
+ (CFStringEncoding)encodingAtIndex:(NSInteger)idx;

@end

NS_ASSUME_NONNULL_END
