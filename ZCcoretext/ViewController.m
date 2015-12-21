//
//  ViewController.m
//  ZCcoretext
//
//  Created by 张程 on 15/12/21.
//  Copyright © 2015年 张程. All rights reserved.
//

#import "ViewController.h"
#import "ZCBBSCoreTextData.h"
#import "ZCCoreTextView.h"

#import "UtilityMethod.h"

#define K_SCREEN_WIDHT [UIScreen mainScreen].bounds.size.width  //屏幕宽度
#define K_SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height    //屏幕高度
#define KTextViewWidth (K_SCREEN_WIDHT-20)

@interface ViewController ()<ZCCoreTextViewLinkDelegate>
@property (nonatomic, strong) ZCBBSCoreTextData *coretextData;
@property (nonatomic, strong) ZCCoreTextView *cTview;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self setData];
    [self addcTview];
}

- (void)setData
{
    // ***步骤一：设置宽，行间距
    ZCBBSCTFrameParserConfig *config = [[ZCBBSCTFrameParserConfig alloc] init];
    config.width = KTextViewWidth;
    config.lineSpace = 4.5;
    config.fontSize = 15.0f;
    
    
    
    // *****步骤二：设置字体大小、颜色、内容
    
    NSDictionary *dic0 = [UtilityMethod TextTypWithColor:@"black" FontSize:@"15.0f" Content:@"文字展示示文字展示文字展示文字展示文字展示文字展示文字展示文字展示文字展示文字展示文字展示文字展示"];   // 内容文字展示
    
    
    NSDictionary *dic1 = [UtilityMethod LinkTypeWithVC:self Content:@"点击点击" Color:@"red"];
    
    NSDictionary *dic2 = [UtilityMethod LinkTypeWithVC:@"HT" Content:@"设置" ValueA:@"" Color:@"#6c9cc6"];  // 话题支持点击
    
    // 需要加下请求框架
    //    NSDictionary *dic3 = [ZCBBSPublicMethod ImgTypeWithWidth:@"30" Height:@"30" imageurl:@"http://img5.imgtn.bdimg.com/it/u=2180782850,1658767923&fm=21&gp=0.jpg" DefaultImageName:@"HF_DingDan_GuangGao.png"];  // 图片暂不支持点击。有时间再增加。
    NSDictionary *dic3 = [UtilityMethod TextTypWithColor:@"black" FontSize:@"15.0f" Content:@"文字展示文字展示文字展示文字展示文字展示文字展示文字展示文字展示文字展示文字展示文字展示文字展示"];   // 内容文字展示
    
    NSDictionary *dic4 = [UtilityMethod LinkTypeWithVC:self Content:@"点击2" Color:@"green"];
    
    NSDictionary *dic5 = [UtilityMethod ImgTypeWithWidth:@"180" Height:@"86" imageName:@"bd_logo.png"];
    
    NSDictionary *dic6 = [UtilityMethod LinkTypeWithVC:self Content:@"点击点击点击点击点击点击点击点击点击点击点击点击点击点击点击点击点击点击点击点击点击点击点击点击点击点击点击点击点击点击点击点击点击点击点击点击点击点击点击" Color:@"blue"];
    
    NSDictionary *dic7 = [UtilityMethod TextTypWithColor:@"black" FontSize:@"15.0f" Content:@"文字展示文字展示文字展示文字展示文字展示文字展示文字展示文字展示文字展示文字展示文字展示文字展示文字展示文字展示"];   // 内容文字展示
    
    NSMutableArray * array = [NSMutableArray array];
    [array addObject:dic0];
    [array addObject:dic1];
    [array addObject:dic2];
    [array addObject:dic3];
    [array addObject:dic4];
    [array addObject:dic5];
    [array addObject:dic6];
    [array addObject:dic7];
    
    
    _coretextData = [ZCBBSCTFrameParser parseTemplateSetArray:array config:config];
    
}


- (void)addcTview
{
    self.cTview = [[ZCCoreTextView alloc] initWithFrame:CGRectMake(10, 100, KTextViewWidth, _coretextData.height) WithData:_coretextData];
    self.cTview.height = _coretextData.height;
    self.cTview.tag = 122334;
    self.cTview.controller = self;
    [self.view addSubview:self.cTview];
}

- (void)linkWithKeyWord:(NSString *)str andLinkData:(ZCBBSCoreTextLinkData *)linkData
{
    NSLog(@"%@", str);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
