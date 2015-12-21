//
//  ZCBBSCoreTextData.m
//  ZC
//
//  Created by 张程 on 15/5/3.
//
//  关于Core的model  以及方法实现

#import "ZCBBSCoreTextData.h"
//#import "Utilities.h"

#pragma mark 文字设置  原型Model
@implementation ZCBBSCTFrameParserConfig

static CGFloat ascentCallback(void *ref){
    return [[(__bridge NSDictionary*)ref objectForKey:@"height"] floatValue];
}

static CGFloat descentCallback(void *ref){
    return 0;
}

static CGFloat widthCallback(void* ref){
    return [[(__bridge NSDictionary*)ref objectForKey:@"width"] floatValue];
}

- (id)init {
    self = [super init];
    if (self) {
        _width = 200.0f;
        _fontSize = 13.0f;
        _lineSpace = 4.0f;
        _textColor = [UIColor blackColor];
    }
    return self;
}

@end

#pragma mark 链接
@implementation ZCBBSCoreTextLinkData

@end

#pragma mark 图片
@implementation ZCBBSCoreTextImageData

@end


#pragma mark 生成的文字
@implementation ZCBBSCoreTextData

- (void)setCtFrame:(CTFrameRef)ctFrame {
    if (_ctFrame != ctFrame) {
        if (_ctFrame != nil) {
            CFRelease(_ctFrame);
        }
        CFRetain(ctFrame);
        _ctFrame = ctFrame;
    }
}

- (void)dealloc {
    if (_ctFrame != nil) {
        CFRelease(_ctFrame);
        _ctFrame = nil;
    }
}

- (void)setImageArray:(NSArray *)imageArray {
    _imageArray = imageArray;
    [self fillImagePosition];
}

- (void)fillImagePosition {
    if (self.imageArray.count == 0) {
        return;
    }
    NSArray *lines = (NSArray *)CTFrameGetLines(self.ctFrame);
    NSUInteger lineCount = [lines count];
    CGPoint lineOrigins[lineCount];
    CTFrameGetLineOrigins(self.ctFrame, CFRangeMake(0, 0), lineOrigins);
    
    int imgIndex = 0;
    ZCBBSCoreTextImageData * imageData = self.imageArray[0];
    
    for (int i = 0; i < lineCount; ++i) {
        if (imageData == nil) {
            break;
        }
        CTLineRef line = (__bridge CTLineRef)lines[i];
        NSArray * runObjArray = (NSArray *)CTLineGetGlyphRuns(line);
        for (id runObj in runObjArray) {
            CTRunRef run = (__bridge CTRunRef)runObj;
            NSDictionary *runAttributes = (NSDictionary *)CTRunGetAttributes(run);
            CTRunDelegateRef delegate = (__bridge CTRunDelegateRef)[runAttributes valueForKey:(id)kCTRunDelegateAttributeName];
            if (delegate == nil) {
                continue;
            }
            
            NSDictionary * metaDic = CTRunDelegateGetRefCon(delegate);
            if (![metaDic isKindOfClass:[NSDictionary class]]) {
                continue;
            }
            
            CGRect runBounds;
            CGFloat ascent;
            CGFloat descent;
            runBounds.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, NULL);
            runBounds.size.height = ascent + descent;
            
            CGFloat xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL);
            runBounds.origin.x = lineOrigins[i].x + xOffset;
            runBounds.origin.y = lineOrigins[i].y;
            runBounds.origin.y -= descent;
            
            CGPathRef pathRef = CTFrameGetPath(self.ctFrame);
            CGRect colRect = CGPathGetBoundingBox(pathRef);
            
            CGRect delegateBounds = CGRectOffset(runBounds, colRect.origin.x, colRect.origin.y);
            
            imageData.imagePosition = delegateBounds;
            imgIndex++;
            if (imgIndex == self.imageArray.count) {
                imageData = nil;
                break;
            } else {
                imageData = self.imageArray[imgIndex];
            }
        }
    }
}

@end

#pragma mark 转化引擎
@implementation ZCBBSCTFrameParser

// 将设置参数转化 成（可转化成NSAttributedString的）字典
+ (NSMutableDictionary *)attributesWithConfig:(ZCBBSCTFrameParserConfig *)config
{
    CGFloat fontSize = config.fontSize;
    CTFontRef fontRef = CTFontCreateWithName((CFStringRef)@"ArialMT", fontSize, NULL);
    CGFloat lineSpacing = config.lineSpace;
    const CFIndex kNumberOfSettings = 4;
    
    
    CTLineBreakMode lineBreak = kCTLineBreakByCharWrapping;//kCTLineBreakByCharWrapping;//换行模式
    
    CTParagraphStyleSetting theSettings[kNumberOfSettings] = {
        { kCTParagraphStyleSpecifierLineSpacingAdjustment, sizeof(CGFloat), &lineSpacing },
        { kCTParagraphStyleSpecifierMaximumLineSpacing, sizeof(CGFloat), &lineSpacing },
        { kCTParagraphStyleSpecifierMinimumLineSpacing, sizeof(CGFloat), &lineSpacing },
        { kCTParagraphStyleSpecifierLineBreakMode, sizeof(CTLineBreakMode), &lineBreak}     // 换行
    };
    
    
    
    
    CTParagraphStyleRef theParagraphRef = CTParagraphStyleCreate(theSettings, kNumberOfSettings);
    
    UIColor * textColor = config.textColor;
    
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    dict[(id)kCTForegroundColorAttributeName] = (id)textColor.CGColor;
    dict[(id)kCTFontAttributeName] = (__bridge id)fontRef;
    dict[(id)kCTParagraphStyleAttributeName] = (__bridge id)theParagraphRef;
    
    CFRelease(theParagraphRef);
    CFRelease(fontRef);
    return dict;
}

+ (ZCBBSCoreTextData *)parseContent:(NSString *)content config:(ZCBBSCTFrameParserConfig*)config
{
    NSDictionary *attributes = [self attributesWithConfig:config];
    
    // 将NSString 转化成NSAttributedString
    NSAttributedString *contentString = [[NSAttributedString alloc] initWithString:content
                                                                        attributes:attributes];
    return [self parseAttributedContent:contentString config:config];
}

+ (ZCBBSCoreTextData *)parseAttributedContent:(NSAttributedString *)content config:(ZCBBSCTFrameParserConfig*)config {
    // 创建CTFramesetterRef实例
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)content);
    
    // 获得要缓制的区域的高度
    CGSize restrictSize = CGSizeMake(config.width, CGFLOAT_MAX);
    CGSize coreTextSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0,0), nil, restrictSize, nil);
    CGFloat textHeight = coreTextSize.height;
    
    // 生成CTFrameRef实例
    CTFrameRef frame = [self createFrameWithFramesetter:framesetter config:config height:textHeight];
    
    // 将生成好的CTFrameRef实例和计算好的缓制高度保存到ZCBBSCoreTextData实例中，最后返回ZCBBSCoreTextData实例
    ZCBBSCoreTextData *data = [[ZCBBSCoreTextData alloc] init];
    data.ctFrame = frame;
    data.height = textHeight;
    data.content = content;
    
    // 释放内存
    CFRelease(frame);
    CFRelease(framesetter);
    return data;
}

+ (CTFrameRef)createFrameWithFramesetter:(CTFramesetterRef)framesetter
                                  config:(ZCBBSCTFrameParserConfig *)config
                                  height:(CGFloat)height {
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0, 0, config.width, height));
    
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
    CFRelease(path);
    return frame;
}



#pragma mark 通过路径  设置参数model 来生成ZCBBSCoreTextData
+ (ZCBBSCoreTextData *)parseTemplateSetArray:(NSArray *)setarray config:(ZCBBSCTFrameParserConfig*)config
{
    NSMutableArray *linkArray = [NSMutableArray array];
    NSMutableArray *imageArray = [NSMutableArray array];
    NSAttributedString *content = [self loadTemplateSetArray:setarray
                                                      config:config
                                                   linkArray:linkArray
                                                  imageArray:imageArray];
    ZCBBSCoreTextData *data = [self parseAttributedContent:content config:config];
    data.linkArray = linkArray;
    data.imageArray = imageArray;
    return data;
}

// 数组 设置参数model link数组  生成NSAttributedString
+ (NSAttributedString *)loadTemplateSetArray:(NSArray *)array
                                      config:(ZCBBSCTFrameParserConfig *)config
                                   linkArray:(NSMutableArray *)linkArray
                                  imageArray:(NSMutableArray *)imageArray
{
    NSMutableAttributedString *result = [[NSMutableAttributedString alloc] init];
    if ([array isKindOfClass:[NSArray class]]) {
        for (NSDictionary *dict in array) {
            NSString *type = dict[@"type"];
            if ([type isEqualToString:@"txt"]) {
                NSAttributedString *as = [self parseAttributedContentFromNSDictionary:dict
                                                                               config:config];
                [result appendAttributedString:as];
            } else if ([type isEqualToString:@"img"]) {
                // 创建 CoreTextImageData
                ZCBBSCoreTextImageData *imageData = [[ZCBBSCoreTextImageData alloc] init];
                imageData.name = dict[@"name"];
                imageData.position = [result length];
                [imageArray addObject:imageData];
                // 创建空白占位符，并且设置它的CTRunDelegate信息
                NSAttributedString *as = [self parseImageDataFromNSDictionary:dict config:config];
                [result appendAttributedString:as];
            } else if ([type isEqualToString:@"imgUrl"]) {
                // 创建 CoreTextImageData
                ZCBBSCoreTextImageData *imageData = [[ZCBBSCoreTextImageData alloc] init];
                imageData.name = dict[@"name"];
                imageData.position = [result length];
                imageData.imgUrl = dict[@"url"];
                [imageArray addObject:imageData];
                // 创建空白占位符，并且设置它的CTRunDelegate信息
                NSAttributedString *as = [self parseImageDataFromNSDictionary:dict config:config];
                [result appendAttributedString:as];
            } else if ([type isEqualToString:@"link"]) {
                NSUInteger startPos = result.length;
                NSAttributedString *as = [self parseAttributedContentFromNSDictionary:dict
                                                                               config:config];
                [result appendAttributedString:as];
                // 创建 CoreTextLinkData
                NSUInteger length = result.length - startPos;
                NSRange linkRange = NSMakeRange(startPos, length);
                ZCBBSCoreTextLinkData *linkData = [[ZCBBSCoreTextLinkData alloc] init];
                linkData.vcMark = dict[@"vc"];
                linkData.title = dict[@"content"];
                linkData.url = dict[@"url"];
                linkData.range = linkRange;
                linkData.valueA = dict[@"valueA"];
                linkData.delegate = dict[@"delegate"];
                [linkArray addObject:linkData];
            }
        }
    }
    return result;

}

+ (NSAttributedString *)parseImageDataFromNSDictionary:(NSDictionary *)dict
                                                config:(ZCBBSCTFrameParserConfig*)config {
    CTRunDelegateCallbacks callbacks;
    memset(&callbacks, 0, sizeof(CTRunDelegateCallbacks));
    callbacks.version = kCTRunDelegateVersion1;
    callbacks.getAscent = ascentCallback;
    callbacks.getDescent = descentCallback;
    callbacks.getWidth = widthCallback;
    CTRunDelegateRef delegate = CTRunDelegateCreate(&callbacks, (__bridge void *)(dict));
    
    // 使用0xFFFC作为空白的占位符
    unichar objectReplacementChar = 0xFFFC;
    NSString * content = [NSString stringWithCharacters:&objectReplacementChar length:1];
    NSDictionary * attributes = [self attributesWithConfig:config];
    NSMutableAttributedString * space = [[NSMutableAttributedString alloc] initWithString:content
                                                                               attributes:attributes];
    CFAttributedStringSetAttribute((CFMutableAttributedStringRef)space, CFRangeMake(0, 1),
                                   kCTRunDelegateAttributeName, delegate);
    CFRelease(delegate);
    return space;
}

+ (NSAttributedString *)parseAttributedContentFromNSDictionary:(NSDictionary *)dict
                                                        config:(ZCBBSCTFrameParserConfig*)config {
    NSMutableDictionary *attributes = [self attributesWithConfig:config];
    // set color
    UIColor *color = [self colorFromTemplate:dict[@"color"]];
    if (color) {
        attributes[(id)kCTForegroundColorAttributeName] = (id)color.CGColor;
    }
    // set font size
    CGFloat fontSize = [dict[@"size"] floatValue];
    if (fontSize > 0) {
        CTFontRef fontRef = CTFontCreateWithName((CFStringRef)@"ArialMT", fontSize, NULL);
        attributes[(id)kCTFontAttributeName] = (__bridge id)fontRef;
        CFRelease(fontRef);
    }
    NSString *content = dict[@"content"];
    return [[NSAttributedString alloc] initWithString:content attributes:attributes];
}

+ (UIColor *)colorFromTemplate:(NSString *)name {
    if ([name isEqualToString:@"blue"]) {
        return [UIColor blueColor];
    } else if ([name isEqualToString:@"red"]) {
        return [UIColor redColor];
    } else if ([name isEqualToString:@"black"]) {
        return [UIColor blackColor];
    } else if ([name isEqualToString:@"green"]) {
        return [UIColor greenColor];
    } else if ([name isEqualToString:@"cyan"]) {
        return [UIColor cyanColor];
    } else if ([name isEqualToString:@"brown"]) {
        return [UIColor brownColor];
    } else if ([name isEqualToString:@"yellow"]) {
        return [UIColor yellowColor];
    } else if ([name isEqualToString:@"white"]) {
        return [UIColor yellowColor];
    } else if ([name hasPrefix:@"#"]) {
        return [UtilityHelper colorWithHexString:name];
    } else {
        return nil;
    }
}

@end

@implementation ZCBBSCoreTextUtils

// 检测点击位置是否在链接上
+ (ZCBBSCoreTextLinkData *)touchLinkInView:(UIView *)view atPoint:(CGPoint)point data:(ZCBBSCoreTextData *)data {
    CFIndex idx = [self touchContentOffsetInView:view atPoint:point data:data];
    if (idx == -1) {
        return nil;
    }
    ZCBBSCoreTextLinkData * foundLink = [self linkAtIndex:idx linkArray:data.linkArray];
    return foundLink;
}

// 将点击的位置转换成字符串的偏移量，如果没有找到，则返回-1
+ (CFIndex)touchContentOffsetInView:(UIView *)view atPoint:(CGPoint)point data:(ZCBBSCoreTextData *)data {
    CTFrameRef textFrame = data.ctFrame;
    CFArrayRef lines = CTFrameGetLines(textFrame);
    if (!lines) {
        return -1;
    }
    CFIndex count = CFArrayGetCount(lines);
    
    // 获得每一行的origin坐标
    CGPoint origins[count];
    CTFrameGetLineOrigins(textFrame, CFRangeMake(0,0), origins);
    
    // 翻转坐标系
    CGAffineTransform transform =  CGAffineTransformMakeTranslation(0, view.bounds.size.height);
    transform = CGAffineTransformScale(transform, 1.f, -1.f);
    
    CFIndex idx = -1;
    for (int i = 0; i < count; i++) {
        CGPoint linePoint = origins[i];
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        // 获得每一行的CGRect信息
        CGRect flippedRect = [self getLineBounds:line point:linePoint];
        CGRect rect = CGRectApplyAffineTransform(flippedRect, transform);
        
        if (CGRectContainsPoint(rect, point)) {
            // 将点击的坐标转换成相对于当前行的坐标
            CGPoint relativePoint = CGPointMake(point.x-CGRectGetMinX(rect),
                                                point.y-CGRectGetMinY(rect));
            // 获得当前点击坐标对应的字符串偏移
            idx = CTLineGetStringIndexForPosition(line, relativePoint);
        }
    }
    return idx;
}

+ (CGRect)getLineBounds:(CTLineRef)line point:(CGPoint)point {
    CGFloat ascent = 0.0f;
    CGFloat descent = 0.0f;
    CGFloat leading = 0.0f;
    CGFloat width = (CGFloat)CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
    CGFloat height = ascent + descent;
    return CGRectMake(point.x, point.y - descent, width, height);
}

+ (ZCBBSCoreTextLinkData *)linkAtIndex:(CFIndex)i linkArray:(NSArray *)linkArray {
    ZCBBSCoreTextLinkData *link = nil;
    for (ZCBBSCoreTextLinkData *data in linkArray) {
        data.linkIndex = [linkArray indexOfObject:data];
        
        if (NSLocationInRange(i, data.range)) {
            link = data;
            break;
        }
    }
    return link;
}



@end
