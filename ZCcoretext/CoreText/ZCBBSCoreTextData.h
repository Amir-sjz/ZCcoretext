//
//  ZCBBSCoreTextData.h
//  ZC
//
//  Created by 张程 on 15/5/3.
//
//  关于Core的model  以及方法实现

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>
#import "UtilityHelper.h"

#pragma mark 文字设置  原型Model
@interface ZCBBSCTFrameParserConfig : NSObject

@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat fontSize;
@property (nonatomic, assign) CGFloat lineSpace;
@property (nonatomic, strong) UIColor *textColor;

@end

#pragma mark 链接
@interface ZCBBSCoreTextLinkData : NSObject

@property (strong, nonatomic) NSString *vcMark;   // 跳转到对应页面的标识
@property (strong, nonatomic) NSString * title;   // 显示参数   具体根据情况赋值 （e.g.个人资料页：nickename；话题列表：topicname））
@property (strong, nonatomic) NSString * url;
@property (assign, nonatomic) NSRange range;
@property (assign, nonatomic) NSInteger linkIndex;//第几个点击位置
@property (strong, nonatomic) NSString *valueA;  // 参数A   具体根据情况赋值 （e.g.个人资料页：username； 话题列表：topicId）
@property (strong, nonatomic) id delegate;

@end

#pragma mark 图片
@interface ZCBBSCoreTextImageData : NSObject
@property (strong, nonatomic) NSString * name;
@property (strong, nonatomic) NSString * imgUrl;
@property (nonatomic) NSInteger position;
@property (nonatomic) CGRect imagePosition;// 此坐标是 CoreText 的坐标系
@end


#pragma mark 生成的文字
@interface ZCBBSCoreTextData : NSObject

@property (assign, nonatomic) CTFrameRef ctFrame;
@property (assign, nonatomic) CGFloat height;
@property (strong, nonatomic) NSArray * linkArray;
@property (strong, nonatomic) NSArray * imageArray;
@property (strong, nonatomic) NSAttributedString *content;

@end

#pragma mark 转化引擎
@interface ZCBBSCTFrameParser : NSObject

+ (NSMutableDictionary *)attributesWithConfig:(ZCBBSCTFrameParserConfig *)config;

+ (ZCBBSCoreTextData *)parseContent:(NSString *)content config:(ZCBBSCTFrameParserConfig*)config;

+ (ZCBBSCoreTextData *)parseAttributedContent:(NSAttributedString *)content config:(ZCBBSCTFrameParserConfig*)config;

// 多组数据拼在一起
+ (ZCBBSCoreTextData *)parseTemplateSetArray:(NSArray *)setarray config:(ZCBBSCTFrameParserConfig*)config;

@end

#pragma mark 实现link 点击
@interface ZCBBSCoreTextUtils : NSObject

+ (ZCBBSCoreTextLinkData *)touchLinkInView:(UIView *)view atPoint:(CGPoint)point data:(ZCBBSCoreTextData *)data;

+ (CFIndex)touchContentOffsetInView:(UIView *)view atPoint:(CGPoint)point data:(ZCBBSCoreTextData *)data;

@end

