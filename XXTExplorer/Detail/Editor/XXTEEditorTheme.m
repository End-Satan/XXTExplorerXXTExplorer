//
//  XXTEEditorTheme.m
//  XXTExplorer
//
//  Created by Zheng Wu on 11/08/2017.
//  Copyright © 2017 Zheng. All rights reserved.
//

#import "XXTEEditorTheme.h"
#import "UIColor+SKColor.h"

#import "SKTheme.h"

@interface XXTEEditorTheme ()

@property (nonatomic, strong) NSParagraphStyle *paragraphStyle;

@end

@implementation XXTEEditorTheme

+ (NSArray <NSDictionary *> *)themeMetas {
    static NSArray <NSDictionary *> *metas = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        metas = ({
            NSString *themeMetasPath = [[NSBundle mainBundle] pathForResource:@"SKTheme" ofType:@"plist"];
            assert(themeMetasPath);
            NSArray <NSDictionary *> *themeMetas = [[NSArray alloc] initWithContentsOfFile:themeMetasPath];
            assert([themeMetas isKindOfClass:[NSArray class]]);
            themeMetas;
        });
    });
    return metas;
}

+ (NSDictionary *)themeMetaForName:(NSString *)name atPath:(NSString **)path {
    BOOL registered = NO;
    for (NSDictionary *themeMeta in [[self class] themeMetas]) {
        NSString *themeName = themeMeta[@"name"];
        if ([themeName isKindOfClass:[NSString class]] &&
            [themeName isEqualToString:name]) {
            if ([[NSBundle mainBundle] pathForResource:themeName ofType:@"tmTheme"])
            {
                registered = YES;
                break;
            }
        }
    }
    
    if (registered) {
        NSString *themePath = [[NSBundle mainBundle] pathForResource:name ofType:@"tmTheme"];
        if (path) *path = [themePath copy];
        NSDictionary *themeDictionary = [[NSDictionary alloc] initWithContentsOfFile:themePath];
        NSAssert([themeDictionary isKindOfClass:[NSDictionary class]], @"Malformed textmate theme: \"%@\".", themePath);
        
        return themeDictionary;
    }
    
    return nil;
}

- (instancetype)initWithName:(NSString *)name baseFont:(UIFont *)font {
    if (self = [super init]) {
        _font = font ? font : [UIFont fontWithName:@"Courier" size:14.0];
        _name = name ? name : @"";
        _backgroundColor = [UIColor whiteColor];
        _foregroundColor = [UIColor blackColor];
        _caretColor = XXTColorForeground();
        _selectionColor = XXTColorForeground();
        _invisibleColor = [UIColor blackColor];
        _barTintColor = nil;
        _barTextColor = nil;
        
        NSString *themePath = nil;
        NSDictionary *themeDictionary = [[self class] themeMetaForName:name atPath:&themePath];
        if (!themeDictionary) {
            return nil;
        }
        
        NSArray <NSDictionary *> *themeSettings = themeDictionary[@"settings"];
        NSAssert([themeSettings isKindOfClass:[NSArray class]], @"Malformed textmate theme: \"%@\".", themePath);
        NSDictionary *globalTheme = nil;
        for (NSDictionary *themeSetting in themeSettings) {
            if (!themeSetting[@"scope"]) {
                globalTheme = themeSetting[@"settings"];
                break;
            }
        }
        NSAssert([globalTheme isKindOfClass:[NSDictionary class]], @"Cannot find global table for theme: \"%@\".", themePath);
        [self setupWithDictionary:globalTheme];
        
        NSArray <UIFont *> *rawFonts = [[self class] fontsForFontFamilyAnyOfFontName:font.fontName ofSize:font.pointSize];
        SKTheme *rawTheme = [[SKTheme alloc] initWithDictionary:themeDictionary baseFonts:rawFonts];
        assert(rawTheme);
        _skTheme = rawTheme;
    }
    return self;
}

- (void)setupWithDictionary:(NSDictionary *)dictionary {
    UIColor *backgroundColor = [UIColor colorWithHex:dictionary[@"background"]];
    _backgroundColor = backgroundColor;
    
    UIColor *foregroundColor = [UIColor colorWithHex:dictionary[@"foreground"]];
    _foregroundColor = foregroundColor;
    
    UIColor *caretColor = [UIColor colorWithHex:dictionary[@"caret"]];
    _caretColor = caretColor;
    
    UIColor *selectionColor = [UIColor colorWithHex:dictionary[@"selection"]];
    _selectionColor = selectionColor;
    
    UIColor *invisibleColor = [UIColor colorWithHex:dictionary[@"invisibles"]];
    _invisibleColor = invisibleColor;
    
    UIColor *navigationBarColor = nil;
    if (dictionary[@"barTint"]) {
        navigationBarColor = [UIColor colorWithHex:dictionary[@"barTint"]];
    }
    if (!navigationBarColor) {
        navigationBarColor = backgroundColor; // fall back to background color
    }
    _barTintColor = navigationBarColor;
    
    UIColor *navigationTitleColor = nil;
    if (dictionary[@"barText"]) {
        navigationTitleColor = [UIColor colorWithHex:dictionary[@"barText"]];
    }
    if (!navigationTitleColor) {
        navigationTitleColor = foregroundColor; // fall back to background color
    }
    _barTextColor = navigationTitleColor;
    
    _lineHeightScale = 1.2;
    UIFont *font = self.font;
    NSDictionary *defaultAttributes = @{
                                        NSForegroundColorAttributeName: foregroundColor,
                                        NSBackgroundColorAttributeName: backgroundColor,
                                        NSFontAttributeName: font,
                                        };
    _fontSpaceWidth = [@" " sizeWithAttributes:defaultAttributes].width;
    _fontLineHeight = font.lineHeight;
    
    CGFloat maximumFontLineHeight = font.lineHeight;
    CGFloat maximumLineHeight = maximumFontLineHeight * _lineHeightScale;
    _baseLineOffset = maximumLineHeight / 2.0 - maximumFontLineHeight / 2.0;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
//    paragraphStyle.minimumLineHeight = font.pointSize;
//    paragraphStyle.maximumLineHeight = font.pointSize;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentLeft;
    _paragraphStyle = [paragraphStyle copy];
}

- (NSDictionary *)defaultAttributes {
    return @{
             NSForegroundColorAttributeName: self.foregroundColor,
             NSBackgroundColorAttributeName: self.backgroundColor,
             NSFontAttributeName: self.font,
             NSParagraphStyleAttributeName: self.paragraphStyle,
             };
}

#pragma mark - Fonts

+ (NSArray <UIFont *> *)fontsForFontFamilyAnyOfFontName:(NSString *)tFontName ofSize:(CGFloat)size {
    if (!tFontName) return nil;
    static NSArray <NSDictionary *> *fontArrs = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        fontArrs = ({
            NSString *fontArrsPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"SKFont" ofType:@"plist"];
            [[NSArray alloc] initWithContentsOfFile:fontArrsPath];
        });
    });
    
    NSArray <NSString *> *retFontNames = nil;
    for (NSDictionary *fontDict in fontArrs) {
        NSArray <NSString *> *fontNames = fontDict[@"fonts"];
        if (![fontNames isKindOfClass:[NSArray class]]) continue;
        if (fontNames.count <= 0) continue;
        NSString *fontName = fontNames[0];
        if (
            [fontName isKindOfClass:[NSString class]] &&
            [tFontName isEqualToString:fontName]
            ) {
            retFontNames = fontNames;
            break;
        }
    }
    
    if (retFontNames.count != 4) return nil;
    NSMutableArray <UIFont *> *retFonts = [[NSMutableArray alloc] init];
    for (NSString *retFontName in retFontNames) {
        UIFont *retFont = [UIFont fontWithName:retFontName size:size];
        if (retFont) {
            [retFonts addObject:retFont];
        }
    }
    
    return [retFonts copy];
}

@end
