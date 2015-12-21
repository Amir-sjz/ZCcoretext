//
//  UtilityMethod.m
//  ZCcoretext
//
//  Created by 张程 on 15/12/21.
//  Copyright © 2015年 张程. All rights reserved.
//

#import "UtilityMethod.h"

@implementation UtilityMethod

#pragma mark - 生成json格式的数据
// color传 #121212 样式 或者 red black blue等

// 文字
+ (NSDictionary *)TextTypWithColor:(NSString *)colorStr FontSize:(NSString *)fontSize Content:(NSString *)contentStr
{
    contentStr = (contentStr==nil?@"":contentStr);
    colorStr = (colorStr==nil?@"":colorStr);
    fontSize = (fontSize==nil?@"":fontSize);
    
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjects:@[@"txt", colorStr, fontSize, contentStr] forKeys:@[@"type", @"color", @"size", @"content"]];
    return dic;
}

// 点击跳转  -- 任意
+ (NSDictionary *)LinkTypeWithVC:(id)delegate Content:(NSString *)content Color:(NSString *)colorStr
{
    NSDictionary *dic = [NSDictionary dictionaryWithObjects:@[@"link", content, delegate, colorStr] forKeys:@[@"type", @"content", @"delegate", @"color"]];
    return dic;
}
// 点击跳转
+ (NSDictionary *)LinkTypeWithVC:(NSString *)VcStr Content:(NSString *)content ValueA:(NSString *)valueA Color:(NSString *)colorStr
{
    //****根据各个页面传相应的参数****//
    if (content == nil) {
        content = @"";
    }
    
    if (valueA == nil) {
        valueA = @"";
    }
    NSDictionary *dic;
    if ([VcStr isEqualToString:@"GRZL"] || [VcStr isEqualToString:@"HT"] || [VcStr isEqualToString:@"XQ"]) {    // 跳转到 个人资料(GRZL) 页  或者  跳转到话题页(HT)
        dic = [NSDictionary dictionaryWithObjects:@[@"link", colorStr, VcStr, content, valueA] forKeys:@[@"type", @"color", @"vc", @"content", @"valueA"]];
    }  else {
        
    }
    
    return dic;
}

// 请求的图片展示
+ (NSDictionary *)ImgTypeWithWidth:(NSString *)width Height:(NSString *)height imageurl:(NSString *)imageStr DefaultImageName:(NSString *)defaultImageName
{
    NSDictionary *dic = [NSDictionary dictionaryWithObjects:@[@"imgUrl",defaultImageName, width, height, imageStr] forKeys:@[@"type", @"name", @"width", @"height", @"url"]];
    return dic;
}

// 本地图片展示
+ (NSDictionary *)ImgTypeWithWidth:(NSString *)width Height:(NSString *)height imageName:(NSString *)imageStr
{
    NSDictionary *dic = [NSDictionary dictionaryWithObjects:@[@"img", width, height, imageStr] forKeys:@[@"type", @"width", @"height", @"name"]];
    return dic;
}

@end
