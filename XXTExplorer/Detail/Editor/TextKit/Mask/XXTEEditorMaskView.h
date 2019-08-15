//
//  XXTEEditorMaskView.h
//  XXTExplorer
//
//  Created by Zheng on 2017/11/9.
//  Copyright © 2017年 Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XXTEEditorMaskView : UIView

- (instancetype)initWithTextView:(UITextView *)textView;

@property (nonatomic, weak) UITextView *textView;
@property (nonatomic, strong) UIColor *focusColor;
@property (nonatomic, strong) UIColor *flashColor;

- (void)focusRange:(NSRange)range;
- (void)flashRange:(NSRange)range;

@end
