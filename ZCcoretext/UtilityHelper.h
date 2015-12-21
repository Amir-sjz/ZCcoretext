//
//  UtilityHelper.h
//  ZCcoretext
//
//  Created by 张程 on 15/12/21.
//  Copyright © 2015年 张程. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define STR_LINE_COLOR    @"#e0e0e0"  //间隔线
#define SF_COLOR(RED, GREEN, BLUE, ALPHA)	[UIColor colorWithRed:RED green:GREEN blue:BLUE alpha:ALPHA]

@interface UtilityHelper : NSObject

+ (UIColor *) colorWithHexString: (NSString *) stringToConvert;

@end
