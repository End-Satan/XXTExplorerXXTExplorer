//
//  XXTEEditorTextContainer.m
//  XXTExplorer
//
//  Created by Zheng Wu on 15/12/2017.
//  Copyright © 2017 Zheng. All rights reserved.
//

#import "XXTEEditorTextContainer.h"
#import "XXTEEditorLayoutManager.h"

@implementation XXTEEditorTextContainer {
    XXTEEditorLayoutManager *_xxteLayoutManager;
}

- (instancetype)init {
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    
}

#pragma mark - Getters

- (XXTEEditorLayoutManager *)xxteLayoutManager {
    if (!_xxteLayoutManager) {
        if ([self.layoutManager isKindOfClass:[XXTEEditorLayoutManager class]])
        {
            _xxteLayoutManager = (XXTEEditorLayoutManager *)self.layoutManager;
        }
    }
    return _xxteLayoutManager;
}

- (BOOL)isSimpleRectangularTextContainer {
    return ![[self xxteLayoutManager] indentWrappedLines];
}

- (CGRect)lineFragmentRectForProposedRect:(CGRect)proposedRect atIndex:(NSUInteger)characterIndex writingDirection:(NSWritingDirection)baseWritingDirection remainingRect:(CGRect *)remainingRect
{
    CGRect rect = [super lineFragmentRectForProposedRect:proposedRect atIndex:characterIndex writingDirection:baseWritingDirection remainingRect:remainingRect];
    
    // IMPORTANT: Inset width only, since setting a non-zero X coordinate kills the text system
    // Offset must be done *after layout computation* in UMLayoutManager's -setLineFragmentRect:forGlyphRange:usedRect:
    
    XXTEEditorLayoutManager *layoutManager = [self xxteLayoutManager];
    if ([layoutManager indentWrappedLines]) {
        UIEdgeInsets insets = [layoutManager insetsForLineStartingAtCharacterIndex:characterIndex lineFragmentRect:rect];
        rect.size.width -= insets.left + insets.right;
    }
    
    return rect;
}

@end
