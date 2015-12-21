//
//  ZCCoreTextView.h
//  ZC
//
//  Created by 张程 on 15/5/4.
//
//  功用：图文混排，文字支持点击，分段变色、改字体大小，设置行间距

#import <UIKit/UIKit.h>
#import "ZCBBSCoreTextData.h"

@protocol ZCCoreTextViewLinkDelegate <NSObject>

@optional
/**业主圈之外实现的点击操作的代理方法*/
- (void)linkWithKeyWord:(NSString *)str andLinkData:(ZCBBSCoreTextLinkData *)linkData;  // 点击实现的代理方法
@end

@interface ZCCoreTextView : UIView

@property (nonatomic, assign) CGFloat height;
@property (nonatomic, strong) ZCBBSCoreTextData *data;
@property (nonatomic, weak) UIViewController *controller;

- (id)initWithFrame:(CGRect)frame WithData:(ZCBBSCoreTextData *)data;

@end
