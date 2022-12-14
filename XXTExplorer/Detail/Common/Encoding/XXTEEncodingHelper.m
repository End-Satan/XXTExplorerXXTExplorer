//
//  XXTEEncodingHelper.m
//  XXTExplorer
//
//  Created by Darwin on 8/2/19.
//  Copyright © 2019 Zheng. All rights reserved.
//

#import "XXTEEncodingHelper.h"

@implementation XXTEEncodingHelper

+ (NSDictionary *)encodingMap {
    static NSDictionary *encodingMap = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        encodingMap = @{
                        @(kCFStringEncodingUTF8): @"Unicode (UTF-8)",
                        @(kCFStringEncodingASCII): @"Western (ASCII)",
                        @(kCFStringEncodingISOLatin1): @"Western (ISO Latin 1)",
                        @(kCFStringEncodingMacRoman): @"Western (Mac OS Roman)",
                        @(kCFStringEncodingWindowsLatin1): @"Western (Windows Latin 1, CP 1252)",
                        @(kCFStringEncodingDOSLatin1): @"Western (DOS Latin 1, CP 850)",
                        @(kCFStringEncodingISOLatin3): @"Western (ISO Latin 3)",
                        @(kCFStringEncodingISOLatin9): @"Western (ISO Latin 9)",
                        @(kCFStringEncodingDOSLatinUS): @"Latin-US (DOS, CP 437)",
                        @(kCFStringEncodingISOLatin7): @"Baltic (ISO Latin 7)",
                        @(kCFStringEncodingWindowsBalticRim): @"Baltic (Windows)",
                        @(kCFStringEncodingDOSBalticRim): @"Baltic (DOS)",
                        @(kCFStringEncodingISOLatin2): @"Central European (ISO Latin 2)",
                        @(kCFStringEncodingISOLatin4): @"Central European (ISO Latin 4)",
                        @(kCFStringEncodingMacCentralEurRoman): @"Central European (Mac OS)",
                        @(kCFStringEncodingWindowsLatin2): @"Central European (Windows Latin 2)",
                        @(kCFStringEncodingDOSLatin2): @"Central European (DOS Latin 2, CP 852)",
                        @(kCFStringEncodingKOI8_R): @"Cyrillic (KOI8-R)",
                        @(kCFStringEncodingISOLatinCyrillic): @"Cyrillic (ISO 8859-5)",
                        @(kCFStringEncodingMacCyrillic): @"Cyrillic (Mac OS)",
                        @(kCFStringEncodingWindowsCyrillic): @"Cyrillic (Windows, CP 1251)",
                        @(kCFStringEncodingDOSCyrillic): @"Cyrillic (DOS)",
                        @(kCFStringEncodingISOLatinGreek): @"Greek (ISO 8859-7)",
                        @(kCFStringEncodingMacGreek): @"Greek (Mac OS)",
                        @(kCFStringEncodingWindowsGreek): @"Greek (Windows, CP 1253)",
                        @(kCFStringEncodingDOSGreek): @"Greek (DOS)",
                        @(kCFStringEncodingDOSGreek1): @"Greek (DOS Greek 1)",
                        @(kCFStringEncodingDOSGreek2): @"Greek (DOS Greek 2)",
                        @(kCFStringEncodingISOLatin6): @"Nordic (ISO Latin 6)",
                        @(kCFStringEncodingDOSNordic): @"Nordic (DOS)",
                        @(kCFStringEncodingISOLatin8): @"Celtic (ISO Latin 8)",
                        @(kCFStringEncodingMacCeltic): @"Celtic (Mac OS)",
                        @(kCFStringEncodingISOLatin10): @"Romanian (ISO Latin 10)",
                        @(kCFStringEncodingMacRomanian): @"Romanian (Mac OS)",
                        @(kCFStringEncodingISOLatin5): @"Turkish (ISO Latin 5)",
                        @(kCFStringEncodingMacTurkish): @"Turkish (Mac OS)",
                        @(kCFStringEncodingWindowsLatin5): @"Turkish (Windows Latin 5)",
                        @(kCFStringEncodingDOSTurkish): @"Turkish (DOS)",
                        @(kCFStringEncodingShiftJIS): @"Japanese (Shift JIS)",
                        @(kCFStringEncodingISO_2022_JP): @"Japanese (ISO 2022-JP)",
                        @(kCFStringEncodingISO_2022_JP_1): @"Japanese (ISO 2022-JP-1)",
                        @(kCFStringEncodingISO_2022_JP_2): @"Japanese (ISO 2022-JP-2)",
                        @(kCFStringEncodingISO_2022_JP_3): @"Japanese (ISO 2022-JP-3)",
                        @(kCFStringEncodingEUC_JP): @"Japanese (EUC)",
                        @(kCFStringEncodingMacJapanese): @"Japanese (Mac OS)",
                        @(kCFStringEncodingDOSJapanese): @"Japanese (Windows, DOS)",
                        @(kCFStringEncodingGB_18030_2000): @"Chinese (GB 18030)",
                        @(kCFStringEncodingISO_2022_CN): @"Chinese (ISO 2022-CN)",
                        @(kCFStringEncodingISO_2022_CN_EXT): @"Chinese (ISO 2022-CN-EXT)",
                        @(kCFStringEncodingGB_2312_80): @"Simplified Chinese (GB 2312)",
                        @(kCFStringEncodingMacChineseSimp): @"Simplified Chinese (Mac OS)",
                        @(kCFStringEncodingDOSChineseSimplif): @"Simplified Chinese (Windows, DOS)",
                        @(kCFStringEncodingBig5): @"Traditional Chinese (Big 5)",
                        @(kCFStringEncodingBig5_HKSCS_1999): @"Traditional Chinese (Big 5 HKSCS)",
                        @(kCFStringEncodingEUC_TW): @"Traditional Chinese (EUC)",
                        @(kCFStringEncodingMacChineseTrad): @"Traditional Chinese (Mac OS)",
                        @(kCFStringEncodingDOSChineseTrad): @"Traditional Chinese (Windows, DOS)",
                        @(kCFStringEncodingEUC_KR): @"Korean (EUC)",
                        @(kCFStringEncodingMacKorean): @"Korean (Mac OS)",
                        @(kCFStringEncodingWindowsKoreanJohab): @"Korean (Windows Johab)",
                        @(kCFStringEncodingDOSKorean): @"Korean (Windows, DOS)",
                        @(kCFStringEncodingMacVietnamese): @"Vietnamese (Mac OS)",
                        @(kCFStringEncodingWindowsVietnamese): @"Vietnamese (Windows)",
                        @(kCFStringEncodingISOLatinThai): @"Thai (ISO 8859-11)",
                        @(kCFStringEncodingMacThai): @"Thai (Mac OS)",
                        @(kCFStringEncodingDOSThai): @"Thai (Windows, DOS)",
                        @(kCFStringEncodingISOLatinHebrew): @"Hebrew (ISO 8859-8)",
                        @(kCFStringEncodingMacHebrew): @"Hebrew (Mac OS)",
                        @(kCFStringEncodingWindowsHebrew): @"Hebrew (Windows)",
                        @(kCFStringEncodingDOSHebrew): @"Hebrew (DOS)",
                        @(kCFStringEncodingISOLatinArabic): @"Arabic (ISO 8859-6)",
                        @(kCFStringEncodingMacArabic): @"Arabic (Mac OS)",
                        @(kCFStringEncodingWindowsArabic): @"Arabic (Windows)",
                        @(kCFStringEncodingDOSArabic): @"Arabic (DOS)",
                        @(kCFStringEncodingUTF16): @"Unicode (UTF-16)",
                        @(kCFStringEncodingUTF16BE): @"Unicode (UTF-16BE)",
                        @(kCFStringEncodingUTF16LE): @"Unicode (UTF-16LE)",
                        @(kCFStringEncodingUTF32): @"Unicode (UTF-32)",
                        @(kCFStringEncodingUTF32BE): @"Unicode (UTF-32BE)",
                        @(kCFStringEncodingUTF32LE): @"Unicode (UTF-32LE)",
                        @(kCFStringEncodingEBCDIC_US): @"Western (EBCDIC US)",
                        @(kCFStringEncodingEBCDIC_CP037): @"Western (EBCDIC Latin 1)",
                        @(kCFStringEncodingNonLossyASCII): @"Non-lossy ASCII",
                        };
    });
    return encodingMap;
}

+ (NSDictionary *)encodingNameMap {
    static NSDictionary *encodingNameMap = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        encodingNameMap = @{
                            @"Unicode (UTF-8)": @(kCFStringEncodingUTF8),
                            @"Western (ASCII)": @(kCFStringEncodingASCII),
                            @"Western (ISO Latin 1)": @(kCFStringEncodingISOLatin1),
                            @"Western (Mac OS Roman)": @(kCFStringEncodingMacRoman),
                            @"Western (Windows Latin 1, CP 1252)": @(kCFStringEncodingWindowsLatin1),
                            @"Western (DOS Latin 1, CP 850)": @(kCFStringEncodingDOSLatin1),
                            @"Western (ISO Latin 3)": @(kCFStringEncodingISOLatin3),
                            @"Western (ISO Latin 9)": @(kCFStringEncodingISOLatin9),
                            @"Latin-US (DOS, CP 437)": @(kCFStringEncodingDOSLatinUS),
                            @"Baltic (ISO Latin 7)": @(kCFStringEncodingISOLatin7),
                            @"Baltic (Windows)": @(kCFStringEncodingWindowsBalticRim),
                            @"Baltic (DOS)": @(kCFStringEncodingDOSBalticRim),
                            @"Central European (ISO Latin 2)": @(kCFStringEncodingISOLatin2),
                            @"Central European (ISO Latin 4)": @(kCFStringEncodingISOLatin4),
                            @"Central European (Mac OS)": @(kCFStringEncodingMacCentralEurRoman),
                            @"Central European (Windows Latin 2)": @(kCFStringEncodingWindowsLatin2),
                            @"Central European (DOS Latin 2, CP 852)": @(kCFStringEncodingDOSLatin2),
                            @"Cyrillic (KOI8-R)": @(kCFStringEncodingKOI8_R),
                            @"Cyrillic (ISO 8859-5)": @(kCFStringEncodingISOLatinCyrillic),
                            @"Cyrillic (Mac OS)": @(kCFStringEncodingMacCyrillic),
                            @"Cyrillic (Windows, CP 1251)": @(kCFStringEncodingWindowsCyrillic),
                            @"Cyrillic (DOS)": @(kCFStringEncodingDOSCyrillic),
                            @"Greek (ISO 8859-7)": @(kCFStringEncodingISOLatinGreek),
                            @"Greek (Mac OS)": @(kCFStringEncodingMacGreek),
                            @"Greek (Windows, CP 1253)": @(kCFStringEncodingWindowsGreek),
                            @"Greek (DOS)": @(kCFStringEncodingDOSGreek),
                            @"Greek (DOS Greek 1)": @(kCFStringEncodingDOSGreek1),
                            @"Greek (DOS Greek 2)": @(kCFStringEncodingDOSGreek2),
                            @"Nordic (ISO Latin 6)": @(kCFStringEncodingISOLatin6),
                            @"Nordic (DOS)": @(kCFStringEncodingDOSNordic),
                            @"Celtic (ISO Latin 8)": @(kCFStringEncodingISOLatin8),
                            @"Celtic (Mac OS)": @(kCFStringEncodingMacCeltic),
                            @"Romanian (ISO Latin 10)": @(kCFStringEncodingISOLatin10),
                            @"Romanian (Mac OS)": @(kCFStringEncodingMacRomanian),
                            @"Turkish (ISO Latin 5)": @(kCFStringEncodingISOLatin5),
                            @"Turkish (Mac OS)": @(kCFStringEncodingMacTurkish),
                            @"Turkish (Windows Latin 5)": @(kCFStringEncodingWindowsLatin5),
                            @"Turkish (DOS)": @(kCFStringEncodingDOSTurkish),
                            @"Japanese (Shift JIS)": @(kCFStringEncodingShiftJIS),
                            @"Japanese (ISO 2022-JP)": @(kCFStringEncodingISO_2022_JP),
                            @"Japanese (ISO 2022-JP-1)": @(kCFStringEncodingISO_2022_JP_1),
                            @"Japanese (ISO 2022-JP-2)": @(kCFStringEncodingISO_2022_JP_2),
                            @"Japanese (ISO 2022-JP-3)": @(kCFStringEncodingISO_2022_JP_3),
                            @"Japanese (EUC)": @(kCFStringEncodingEUC_JP),
                            @"Japanese (Mac OS)": @(kCFStringEncodingMacJapanese),
                            @"Japanese (Windows, DOS)": @(kCFStringEncodingDOSJapanese),
                            @"Chinese (GB 18030)": @(kCFStringEncodingGB_18030_2000),
                            @"Chinese (ISO 2022-CN)": @(kCFStringEncodingISO_2022_CN),
                            @"Chinese (ISO 2022-CN-EXT)": @(kCFStringEncodingISO_2022_CN_EXT),
                            @"Simplified Chinese (GB 2312)": @(kCFStringEncodingGB_2312_80),
                            @"Simplified Chinese (Mac OS)": @(kCFStringEncodingMacChineseSimp),
                            @"Simplified Chinese (Windows, DOS)": @(kCFStringEncodingDOSChineseSimplif),
                            @"Traditional Chinese (Big 5)": @(kCFStringEncodingBig5),
                            @"Traditional Chinese (Big 5 HKSCS)": @(kCFStringEncodingBig5_HKSCS_1999),
                            @"Traditional Chinese (EUC)": @(kCFStringEncodingEUC_TW),
                            @"Traditional Chinese (Mac OS)": @(kCFStringEncodingMacChineseTrad),
                            @"Traditional Chinese (Windows, DOS)": @(kCFStringEncodingDOSChineseTrad),
                            @"Korean (EUC)": @(kCFStringEncodingEUC_KR),
                            @"Korean (Mac OS)": @(kCFStringEncodingMacKorean),
                            @"Korean (Windows Johab)": @(kCFStringEncodingWindowsKoreanJohab),
                            @"Korean (Windows, DOS)": @(kCFStringEncodingDOSKorean),
                            @"Vietnamese (Mac OS)": @(kCFStringEncodingMacVietnamese),
                            @"Vietnamese (Windows)": @(kCFStringEncodingWindowsVietnamese),
                            @"Thai (ISO 8859-11)": @(kCFStringEncodingISOLatinThai),
                            @"Thai (Mac OS)": @(kCFStringEncodingMacThai),
                            @"Thai (Windows, DOS)": @(kCFStringEncodingDOSThai),
                            @"Hebrew (ISO 8859-8)": @(kCFStringEncodingISOLatinHebrew),
                            @"Hebrew (Mac OS)": @(kCFStringEncodingMacHebrew),
                            @"Hebrew (Windows)": @(kCFStringEncodingWindowsHebrew),
                            @"Hebrew (DOS)": @(kCFStringEncodingDOSHebrew),
                            @"Arabic (ISO 8859-6)": @(kCFStringEncodingISOLatinArabic),
                            @"Arabic (Mac OS)": @(kCFStringEncodingMacArabic),
                            @"Arabic (Windows)": @(kCFStringEncodingWindowsArabic),
                            @"Arabic (DOS)": @(kCFStringEncodingDOSArabic),
                            @"Unicode (UTF-16)": @(kCFStringEncodingUTF16),
                            @"Unicode (UTF-16BE)": @(kCFStringEncodingUTF16BE),
                            @"Unicode (UTF-16LE)": @(kCFStringEncodingUTF16LE),
                            @"Unicode (UTF-32)": @(kCFStringEncodingUTF32),
                            @"Unicode (UTF-32BE)": @(kCFStringEncodingUTF32BE),
                            @"Unicode (UTF-32LE)": @(kCFStringEncodingUTF32LE),
                            @"Western (EBCDIC US)": @(kCFStringEncodingEBCDIC_US),
                            @"Western (EBCDIC Latin 1)": @(kCFStringEncodingEBCDIC_CP037),
                            @"Non-lossy ASCII": @(kCFStringEncodingNonLossyASCII),
                            };
    });
    return encodingNameMap;
}

+ (NSArray <NSNumber *> *)encodings {
    static NSArray <NSNumber *> *encodings = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        encodings = @[
                      @(kCFStringEncodingUTF8),
                      @(kCFStringEncodingASCII),
                      @(kCFStringEncodingISOLatin1),
                      @(kCFStringEncodingMacRoman),
                      @(kCFStringEncodingWindowsLatin1),
                      @(kCFStringEncodingDOSLatin1),
                      @(kCFStringEncodingISOLatin3),
                      @(kCFStringEncodingISOLatin9),
                      @(kCFStringEncodingDOSLatinUS),
                      @(kCFStringEncodingISOLatin7),
                      @(kCFStringEncodingWindowsBalticRim),
                      @(kCFStringEncodingDOSBalticRim),
                      @(kCFStringEncodingISOLatin2),
                      @(kCFStringEncodingISOLatin4),
                      @(kCFStringEncodingMacCentralEurRoman),
                      @(kCFStringEncodingWindowsLatin2),
                      @(kCFStringEncodingDOSLatin2),
                      @(kCFStringEncodingKOI8_R),
                      @(kCFStringEncodingISOLatinCyrillic),
                      @(kCFStringEncodingMacCyrillic),
                      @(kCFStringEncodingWindowsCyrillic),
                      @(kCFStringEncodingDOSCyrillic),
                      @(kCFStringEncodingISOLatinGreek),
                      @(kCFStringEncodingMacGreek),
                      @(kCFStringEncodingWindowsGreek),
                      @(kCFStringEncodingDOSGreek),
                      @(kCFStringEncodingDOSGreek1),
                      @(kCFStringEncodingDOSGreek2),
                      @(kCFStringEncodingISOLatin6),
                      @(kCFStringEncodingDOSNordic),
                      @(kCFStringEncodingISOLatin8),
                      @(kCFStringEncodingMacCeltic),
                      @(kCFStringEncodingISOLatin10),
                      @(kCFStringEncodingMacRomanian),
                      @(kCFStringEncodingISOLatin5),
                      @(kCFStringEncodingMacTurkish),
                      @(kCFStringEncodingWindowsLatin5),
                      @(kCFStringEncodingDOSTurkish),
                      @(kCFStringEncodingShiftJIS),
                      @(kCFStringEncodingISO_2022_JP),
                      @(kCFStringEncodingISO_2022_JP_1),
                      @(kCFStringEncodingISO_2022_JP_2),
                      @(kCFStringEncodingISO_2022_JP_3),
                      @(kCFStringEncodingEUC_JP),
                      @(kCFStringEncodingMacJapanese),
                      @(kCFStringEncodingDOSJapanese),
                      @(kCFStringEncodingGB_18030_2000),
                      @(kCFStringEncodingISO_2022_CN),
                      @(kCFStringEncodingISO_2022_CN_EXT),
                      @(kCFStringEncodingGB_2312_80),
                      @(kCFStringEncodingMacChineseSimp),
                      @(kCFStringEncodingDOSChineseSimplif),
                      @(kCFStringEncodingBig5),
                      @(kCFStringEncodingBig5_HKSCS_1999),
                      @(kCFStringEncodingEUC_TW),
                      @(kCFStringEncodingMacChineseTrad),
                      @(kCFStringEncodingDOSChineseTrad),
                      @(kCFStringEncodingEUC_KR),
                      @(kCFStringEncodingMacKorean),
                      @(kCFStringEncodingWindowsKoreanJohab),
                      @(kCFStringEncodingDOSKorean),
                      @(kCFStringEncodingMacVietnamese),
                      @(kCFStringEncodingWindowsVietnamese),
                      @(kCFStringEncodingISOLatinThai),
                      @(kCFStringEncodingMacThai),
                      @(kCFStringEncodingDOSThai),
                      @(kCFStringEncodingISOLatinHebrew),
                      @(kCFStringEncodingMacHebrew),
                      @(kCFStringEncodingWindowsHebrew),
                      @(kCFStringEncodingDOSHebrew),
                      @(kCFStringEncodingISOLatinArabic),
                      @(kCFStringEncodingMacArabic),
                      @(kCFStringEncodingWindowsArabic),
                      @(kCFStringEncodingDOSArabic),
                      @(kCFStringEncodingUTF16),
                      @(kCFStringEncodingUTF16BE),
                      @(kCFStringEncodingUTF16LE),
                      @(kCFStringEncodingUTF32),
                      @(kCFStringEncodingUTF32BE),
                      @(kCFStringEncodingUTF32LE),
                      @(kCFStringEncodingEBCDIC_US),
                      @(kCFStringEncodingEBCDIC_CP037),
                      @(kCFStringEncodingNonLossyASCII),
                      ];
    });
    return encodings;
}

+ (NSString *)encodingNameForEncoding:(CFStringEncoding)encoding {
    return [[self class] encodingMap][@(encoding)];
}

+ (CFStringEncoding)encodingForEncodingName:(NSString *)encodingName {
    return [[[self class] encodingNameMap][encodingName] intValue];
}

+ (CFStringEncoding)encodingAtIndex:(NSInteger)idx {
    if (idx < [[[self class] encodings] count]) {
        return [[[self class] encodings][idx] intValue];
    }
    return kCFStringEncodingUTF8;
}

@end
