//
//  UtilityMethod.h
//  ZCcoretext
//
//  Created by 张程 on 15/12/21.
//  Copyright © 2015年 张程. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UtilityMethod : NSObject

#pragma mark - 生成json格式的数据
+ (NSDictionary *)TextTypWithColor:(NSString *)colorStr FontSize:(NSString *)fontSize Content:(NSString *)contentStr;
/** 点击跳转  -- 任意*/
+ (NSDictionary *)LinkTypeWithVC:(id)delegate Content:(NSString *)content Color:(NSString *)colorStr;
+ (NSDictionary *)LinkTypeWithVC:(NSString *)VcStr Content:(NSString *)content ValueA:(NSString *)valueA Color:(NSString *)colorStr;
+ (NSDictionary *)ImgTypeWithWidth:(NSString *)width Height:(NSString *)height imageName:(NSString *)imageStr;
+ (NSDictionary *)ImgTypeWithWidth:(NSString *)width Height:(NSString *)height imageurl:(NSString *)imageStr DefaultImageName:(NSString *)defaultImageName;


@end
